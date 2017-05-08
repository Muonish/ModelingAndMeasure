//
//  UserDefaultsSerializer.h
//  ModelingAndMeasure
//
//  Created by Valeryia Breshko on 4/18/17.
//  Copyright © 2017 Valeria Breshko. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol SerializableProtocol <NSObject>

@required
+ (id)objectFromDictionary:(NSDictionary *)dictionary;
- (NSDictionary *)toDictionary;

@end

@interface UserDefaultsSerializer : NSObject

+ (id)loadObjectWithClass:(Class)aClass;
+ (void)saveObject:(id<SerializableProtocol>)aObject;

@end
