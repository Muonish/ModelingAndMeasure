//
//  VideoProcessor.m
//  ModelingAndMeasure
//
//  Created by Valeryia Breshko on 4/14/17.
//  Copyright © 2017 Valeria Breshko. All rights reserved.
//

#import "VideoProcessor.h"
#import "SpecialPointsDetector.h"
#import <AVFoundation/AVFoundation.h>
#import "CircularArray.h"

static const NSUInteger kMaxIterations = 50;

@interface VideoProcessor() {
    cv::Mat prevImage;
}
@property (nonatomic, strong) CvVideoCamera* videoCamera;

@property (nonatomic, strong) AVCaptureDevice *inputDevice;
@property (nonatomic, assign) CGFloat scale;
@property (nonatomic, strong) SpecialPointsDetector *pointsDetector;
@property (nonatomic, assign) NSInteger iteration; // to track every kMaxIterations image
@property (nonatomic, strong) CircularArray *imagesBuffer;

@end

@implementation VideoProcessor

- (instancetype)initWithCameraView:(UIImageView *)view scale:(CGFloat)scale {
    self = [super init];
    if (self) {
        self.videoCamera = [[CvVideoCamera alloc] initWithParentView:view];
        self.videoCamera.defaultAVCaptureDevicePosition = AVCaptureDevicePositionBack;
        self.videoCamera.defaultAVCaptureSessionPreset = AVCaptureSessionPreset1280x720;
        self.videoCamera.defaultAVCaptureVideoOrientation = AVCaptureVideoOrientationPortrait;
        self.videoCamera.defaultFPS = 30;
        self.videoCamera.grayscaleMode = NO;
        self.videoCamera.delegate = self;
        self.scale = scale;
        self.iteration = 0;
        self.pointsDetector = [[SpecialPointsDetector alloc] initWithScale:self.scale];
        [self initImagesBuffer];
    }

    return self;
}

- (void)initImagesBuffer {
    self.imagesBuffer = [[CircularArray alloc] initWithSize:10];
}

- (AVCaptureDevice *)inputDevice {
    AVCaptureDeviceInput *captureInput = [self.videoCamera.captureSession.inputs firstObject];
    return captureInput.device;
}

- (CameraCalibrationModel *)computeCameraCalibration {
    AVCaptureDeviceFormat *format = self.inputDevice.activeFormat;
    CMFormatDescriptionRef fDesc = format.formatDescription;

    CGSize dim = CMVideoFormatDescriptionGetPresentationDimensions(fDesc, YES, YES);

    CGFloat cx = dim.width / 2.f;
    CGFloat cy = dim.height / 2.f;

    CGFloat HFOV = format.videoFieldOfView;
    CGFloat VFOV = (HFOV / cx) * cy;

    CGFloat fx = fabs(dim.width / (2 * tan(HFOV / 180 * M_PI / 2)));
    CGFloat fy = fabs(dim.height / (2 * tan(VFOV / 180 * M_PI / 2)));

    return [[CameraCalibrationModel alloc] initWithFx:fx fy:fy cx:cx cy:cy];
}

- (void)startCapture {
    [self.videoCamera start];
}

- (void)stopCapture; {
    [self.videoCamera stop];
}

- (UIImage *)captureProcessedImage {
    return (prevImage.data != nullptr) ? [UIImage imageFromCVMat:prevImage] : nil;
}

- (std::vector<cv::Mat>)getBufferedImages {
    std::vector<cv::Mat> images = [self.imagesBuffer getImages];
    std::vector<cv::Mat> result;
    for (int i = 0; i < images.size(); i++) {
        cv::Mat image = images[i];
        if (image.data != nullptr) {
            result.push_back(image);
        }
    }
    return result;
}

#pragma mark <CvVideoCameraDelegate>

- (void)processImage:(cv::Mat &)image {
    if (self.modelingEnabled) {
        sfm::Features features = [self.pointsDetector extractFeatures:image];
        drawKeypoints(image, features.keyPoints, image, cvScalar(255, 255, 255), cv::DrawMatchesFlags::DRAW_OVER_OUTIMG);
        //[self.pointsDetector detectAndDrawPointsOn:image];
        if (self.iteration > kMaxIterations) {
            self.iteration = 0;
            [self.imagesBuffer addImage:image];
        }
        self.iteration++;
    }
    prevImage = image.clone();
}

@end
