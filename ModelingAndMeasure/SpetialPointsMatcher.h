//
//  SpetialPointsMatcher.h
//  ModelingAndMeasure
//
//  Created by Valeryia Breshko on 5/3/17.
//  Copyright © 2017 Valeria Breshko. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UIImage+OpenCV.h"
#import <opencv2/xfeatures2d.hpp>

#include "SfMCommon.h"

@interface SpetialPointsMatcher : NSObject

/**
 * Find matches for two images.
 * @param keyPoints1  First image keypoints array
 * @param keyPoints2  Second image keypoints array
 * @param img1        First image
 * @param img2        Second image
 * @return matches    Matching between images keypoints.
 */
+ (std::vector<cv::DMatch>)matchKeyPoints1:(std::vector<cv::KeyPoint>)keyPoints1 keyPoints2:(std::vector<cv::KeyPoint>)keyPoints2 image1:(cv::Mat&)img1 image2:(cv::Mat&)img2;
+ (sfm::Matching)matchFeaturesLeft:(const sfm::Features&)featuresLeft  right:(const sfm::Features&)featuresRight;
@end
