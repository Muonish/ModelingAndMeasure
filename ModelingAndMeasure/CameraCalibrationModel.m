//
//  CameraCalibrationModel.m
//  ModelingAndMeasure
//
//  Created by Valeryia Breshko on 5/3/17.
//  Copyright © 2017 Valeria Breshko. All rights reserved.
//

#import "CameraCalibrationModel.h"

@implementation CameraCalibrationModel

- (instancetype)initWithFx:(float)fx fy:(float)fy cx:(float)cx cy:(float)cy {
    self = [super init];
    if (self) {
        self.fx = fx;
        self.fy = fy;
        self.cx = cx;
        self.cy = cy;
    }
    return self;
}

@end
