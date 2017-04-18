//
//  AccelerationHeightMeasuring.m
//  ModelingAndMeasure
//
//  Created by Valeryia Breshko on 4/18/17.
//  Copyright © 2017 Valeria Breshko. All rights reserved.
//

#import "AccelerationHeightMeasuring.h"
#import "AccelerometerTracker.h"

@implementation AccelerationMeasureModel

@end

@interface AccelerationHeightMeasuring()

@property (assign, nonatomic) double height;
@property (strong, nonatomic) AccelerometerTracker *accelerometer;
@property (strong, nonatomic) AccelerationMeasureModel *measureModel;

@end

@implementation AccelerationHeightMeasuring

- (instancetype)initWithHeight:(double)height {
    self = [super init];
    if (self) {
        self.accelerometer = [AccelerometerTracker new];
        self.measureModel = [AccelerationMeasureModel new];
        self.height = height;
    }
    return self;
}

- (void)startMeasure {
    [self.accelerometer startTracking];
    __weak AccelerationHeightMeasuring * weakSelf = self;
    self.accelerometer.onFirstTrackCycle = ^(CMAcceleration acceleration) {
        weakSelf.measureModel.startAccelerationPose = acceleration;
    };
}

- (void)endMeasure {
    self.measureModel.endAccelerationPose = self.accelerometer.acceleration;
    [self.accelerometer stopTracking];
}

- (double)distance {
    double start = self.measureModel.startAccelerationPose.z;
    double end = self.measureModel.endAccelerationPose.z;

    double sy = atan(start); // in radians
    double ey = atan(end); 

    double distanceToObject = fabs(self.height / tan(sy));

    return tan(ey) * distanceToObject + self.height;
}


@end
