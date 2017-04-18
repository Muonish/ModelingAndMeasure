//
//  UserDefaultsSerializer.m
//  ModelingAndMeasure
//
//  Created by Valeryia Breshko on 4/18/17.
//  Copyright © 2017 Valeria Breshko. All rights reserved.
//

#import "UserDefaultsSerializer.h"

@implementation UserDefaultsSerializer

+ (void)saveObject:(id)object forKey:(NSString *)key {
    [[NSUserDefaults standardUserDefaults] setObject:object forKey:key];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (id)getObjectForKey:(NSString *)key {
    return [[NSUserDefaults standardUserDefaults] stringForKey:key];
}

@end
