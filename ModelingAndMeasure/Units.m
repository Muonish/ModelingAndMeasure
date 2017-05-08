//
//  Units.m
//  ModelingAndMeasure
//
//  Created by Valeryia Breshko on 5/6/17.
//  Copyright © 2017 Valeria Breshko. All rights reserved.
//

#import "Units.h"

@implementation Units

- (instancetype)init {
    self = [super init];
    if (self) {
        self.type = cmUnits;
    }
    return self;
}

- (NSString *)name {
    switch (self.type) {
        case cmUnits:
            return @"cm";
            break;
        case mUnits:
            return @"m";
            break;
        case mmUnits:
            return @"mm";
            break;

        default:
            break;
    }

    return nil;
}

- (float)multiplier {
    switch (self.type) {
        case cmUnits:
            return 1.f;
            break;
        case mUnits:
            return 1.f/100.f;
            break;
        case mmUnits:
            return 10.f;
            break;

        default:
            break;
    }

    return 0;
}

- (UnitsType)nextType {
    switch (self.type) {
        case cmUnits:
            return mUnits;
            break;
        case mUnits:
            return mmUnits;
            break;
        case mmUnits:
            return cmUnits;
            break;

        default:
            break;
    }

    return 0;
}

+ (id)objectFromDictionary:(NSDictionary *)dictionary {
    Units *units = [Units new];
    units.type = [dictionary[@"type"] integerValue];
    return units;
}

- (NSDictionary *)toDictionary {
    NSMutableDictionary *dict = [NSMutableDictionary new];
    dict[@"type"] = @(self.type);
    return [dict copy];
}


@end
