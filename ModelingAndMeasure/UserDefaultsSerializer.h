//
//  UserDefaultsSerializer.h
//  ModelingAndMeasure
//
//  Created by Valeryia Breshko on 4/18/17.
//  Copyright © 2017 Valeria Breshko. All rights reserved.
//

#import <Foundation/Foundation.h>

static NSString *const kHeightKey = @"heightValue";

@interface UserDefaultsSerializer : NSObject

+ (void)saveObject:(id)object forKey:(NSString *)key;
+ (id)getObjectForKey:(NSString *)key;

@end
