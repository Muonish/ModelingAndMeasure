//
//  VideoProcessor.m
//  ModelingAndMeasure
//
//  Created by Valeryia Breshko on 4/14/17.
//  Copyright © 2017 Valeria Breshko. All rights reserved.
//

#import "VideoProcessor.h"
#import "SpecialPointsDetector.h"

@interface VideoProcessor() {
    cv::Mat prevImage;
}

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
        //    if (prevImage.data != nullptr && _maxIter > 0) {
        //        cv::Mat img2 = image.clone();
        //        [self.pointsDetector detectAndDrawPointsOn:image fromImage1:prevImage andImage2:img2];
        //        _maxIter--;
        //    }
        //    if (_maxIter == 0) {
        //        [self.videoCamera stop];
        //    }
        //    prevImage = image;

    }
    prevImage = image.clone();
}

@end
