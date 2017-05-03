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

@interface VideoProcessor() {
    cv::Mat prevImage;
}

@property (nonatomic, strong) AVCaptureDevice *inputDevice;
@property (nonatomic, assign) CGFloat scale;
@property (nonatomic, strong) SpecialPointsDetector *pointsDetector;
@property (nonatomic, assign) NSInteger maxIter;


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
        self.maxIter = 2;
        self.pointsDetector = [[SpecialPointsDetector alloc] initWithScale:self.scale];
    }

    return self;
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

#pragma mark <CvVideoCameraDelegate>

- (void)processImage:(cv::Mat &)image {
    if (self.modelingEnabled) {
        [self.pointsDetector detectAndDrawPointsOn:image];
    }
    prevImage = image.clone();
}

@end
