//
//  Units.h
//  ModelingAndMeasure
//
//  Created by Valeryia Breshko on 5/6/17.
//  Copyright © 2017 Valeria Breshko. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UserDefaultsSerializer.h"

typedef NS_ENUM(NSInteger, UnitsType) {
    cmUnits = 0,
    mUnits,
    mmUnits
};

@interface Units : NSObject <SerializableProtocol>

@property (assign, nonatomic) UnitsType type;
@property (strong, nonatomic, readonly) NSString *name;
@property (assign, nonatomic, readonly) float multiplier;

- (UnitsType)nextType;

@end
