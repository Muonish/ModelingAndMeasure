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

@end
