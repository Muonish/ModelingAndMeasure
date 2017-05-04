//
//  VideoProcessor.h
//  ModelingAndMeasure
//
//  Created by Valeryia Breshko on 4/14/17.
//  Copyright © 2017 Valeria Breshko. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <opencv2/videoio/cap_ios.h>
#import "CameraCalibrationModel.h"

@interface VideoProcessor : NSObject <CvVideoCameraDelegate>

@property (nonatomic, assign) BOOL modelingEnabled;

- (instancetype)initWithCameraView:(UIImageView *)view
                             scale:(CGFloat)scale;

- (CameraCalibrationModel *)computeCameraCalibration;

- (void)startCapture;
- (void)stopCapture;

- (UIImage *)captureProcessedImage;

- (std::vector<cv::Mat>)getBufferedImages;

@end
