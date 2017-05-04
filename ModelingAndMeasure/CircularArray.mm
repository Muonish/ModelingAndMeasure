//
//  CircularArray.m
//  ModelingAndMeasure
//
//  Created by Valeryia Breshko on 5/4/17.
//  Copyright © 2017 Valeria Breshko. All rights reserved.
//

#import "CircularArray.h"

@interface CircularArray() {
    std::vector<cv::Mat> images;
}

@property (assign, nonatomic) NSUInteger size;
@property (assign, nonatomic) NSUInteger currentIndex;

@end

@implementation CircularArray

- (instancetype)initWithSize:(NSUInteger)size {
    self = [super init];
    if (self) {
        self.size = size;
        images.resize(size);
        self.currentIndex = 0;
    }
    return self;
}

- (void)addImage:(cv::Mat &)image {
    images[_currentIndex] = image;
    _currentIndex = (_currentIndex + 1) % _size;
}

- (std::vector<cv::Mat>)getImages {
    return images;
}

@end
