//
//  UserSettings.m
//  ModelingAndMeasure
//
//  Created by Valeryia Breshko on 5/6/17.
//  Copyright © 2017 Valeria Breshko. All rights reserved.
//

#import "UserSettings.h"
#import "UserDefaultsSerializer.h"

@implementation UserSettings

+ (instancetype)instance {
    static UserSettings *instance = nil;
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate, ^{
        instance = [UserDefaultsSerializer loadObjectWithClass:[UserSettings class]];
        if (!instance) {
            instance = [UserSettings new];;
        }
    });
    return instance;
}

- (void)save {
    [UserDefaultsSerializer saveObject:self];
}

+ (id)objectFromDictionary:(NSDictionary *)dictionary {
    UserSettings *us = [UserSettings new];
    us.units = [Units objectFromDictionary:dictionary[@"units"]];
    us.height = dictionary[@"height"];
    return us;
}

- (NSDictionary *)toDictionary {
    NSMutableDictionary *dict = [NSMutableDictionary new];
    dict[@"units"] = [self.units toDictionary];
    dict[@"height"] = self.height;
    return [dict copy];
}

@end
