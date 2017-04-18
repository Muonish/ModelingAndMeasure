//
//  AccelerometerTracker.m
//  ModelingAndMeasure
//
//  Created by Valeryia Breshko on 4/18/17.
//  Copyright © 2017 Valeria Breshko. All rights reserved.
//

#import "AccelerometerTracker.h"

@interface AccelerometerTracker()

@property (strong, nonatomic) NSTimer *timer;
@property (strong, nonatomic) CMMotionManager *motionManager;

@end

@implementation AccelerometerTracker

- (instancetype)init {
    self = [super init];
    if (self) {
        self.motionManager = [CMMotionManager new];
    }
    return self;
}

- (void)startTracking {
    if (self.motionManager.isDeviceMotionAvailable) {
        self.motionManager.accelerometerUpdateInterval = 1.f / 60.f;
        [self.motionManager startAccelerometerUpdatesToQueue:[NSOperationQueue currentQueue]
                                                 withHandler:^(CMAccelerometerData *accelerometerData, NSError *error) {
                                                     self.acceleration = accelerometerData.acceleration;
                                                     if (self.onFirstTrackCycle) {
                                                         self.onFirstTrackCycle(self.acceleration);
                                                         self.onFirstTrackCycle = nil;
                                                     }
                                                     if(error){

                                                         NSLog(@"%@", error);
                                                     }
                                                 }];
    }
}

- (void)stopTracking {
    [self.motionManager stopAccelerometerUpdates];
}

@end
