//
//  SpecialPointsDetector.h
//  ModelingAndMeasure
//
//  Created by Valeryia Breshko on 4/12/17.
//  Copyright © 2017 Valeria Breshko. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UIImage+OpenCV.h"
#import <opencv2/xfeatures2d.hpp>

@interface SpecialPointsDetector : NSObject

- (instancetype)initWithScale:(CGFloat)scale;

- (std::vector<cv::KeyPoint>)detectAndDrawPointsOn:(cv::Mat&)img;

- (std::vector<cv::KeyPoint>)detectAndDrawPointsOn:(cv::Mat&)img fromImage1:(cv::Mat&)img1 andImage2:(cv::Mat&)img2;

@end
