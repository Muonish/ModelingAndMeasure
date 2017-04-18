//
//  AccelerationHeightMeasuring.h
//  ModelingAndMeasure
//
//  Created by Valeryia Breshko on 4/18/17.
//  Copyright © 2017 Valeria Breshko. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreMotion/CoreMotion.h>

@interface AccelerationMeasureModel : NSObject
@property (assign, nonatomic) CMAcceleration startAccelerationPose;
@property (assign, nonatomic) CMAcceleration endAccelerationPose;
@end

@interface AccelerationHeightMeasuring : NSObject

@property (assign, readonly) double distance;

- (instancetype)initWithHeight:(double)height;

- (void)startMeasure;
- (void)endMeasure;

@end
