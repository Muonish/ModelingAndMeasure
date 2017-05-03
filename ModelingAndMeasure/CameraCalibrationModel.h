//
//  CameraCalibrationModel.h
//  ModelingAndMeasure
//
//  Created by Valeryia Breshko on 5/3/17.
//  Copyright © 2017 Valeria Breshko. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CameraCalibrationModel : NSObject

@property (assign, nonatomic) float fx;
@property (assign, nonatomic) float fy;
@property (assign, nonatomic) float cx;
@property (assign, nonatomic) float cy;

- (instancetype)initWithFx:(float)fx fy:(float)fy cx:(float)cx cy:(float)cy;

@end
