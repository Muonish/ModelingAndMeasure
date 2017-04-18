//
//  AccelerometerTracker.h
//  ModelingAndMeasure
//
//  Created by Valeryia Breshko on 4/18/17.
//  Copyright © 2017 Valeria Breshko. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreMotion/CoreMotion.h>

@interface AccelerometerTracker : NSObject

@property (assign, nonatomic) CMAcceleration acceleration;
@property (strong, nonatomic) void (^onFirstTrackCycle)(CMAcceleration acceleration);

- (void)startTracking;
- (void)stopTracking;

@end
