//
//  UserDefaultsSerializer.m
//  ModelingAndMeasure
//
//  Created by Valeryia Breshko on 4/18/17.
//  Copyright © 2017 Valeria Breshko. All rights reserved.
//

#import "UserDefaultsSerializer.h"

@implementation UserDefaultsSerializer

+ (id)loadObjectWithClass:(Class)aClass {
    NSDictionary * dict = [[NSUserDefaults standardUserDefaults] objectForKey:NSStringFromClass(aClass)];

    if ([aClass conformsToProtocol:@protocol(SerializableProtocol)]) {
        return [aClass objectFromDictionary:dict];
    }

    return nil;
}

+ (void)saveObject:(id<SerializableProtocol>)aObject {
    NSDictionary * dict = [aObject toDictionary];
    [[NSUserDefaults standardUserDefaults] setObject:dict
                                              forKey:NSStringFromClass([aObject class])];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

@end
