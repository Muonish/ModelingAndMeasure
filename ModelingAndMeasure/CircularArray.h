//
//  CircularArray.h
//  ModelingAndMeasure
//
//  Created by Valeryia Breshko on 5/4/17.
//  Copyright © 2017 Valeria Breshko. All rights reserved.
//

#import <Foundation/Foundation.h>

#ifdef __cplusplus
#import <opencv2/opencv.hpp>
#endif

@interface CircularArray : NSObject

- (instancetype)initWithSize:(NSUInteger)size;

- (void)addImage:(cv::Mat &)image;
- (std::vector<cv::Mat>)getImages;

@end
