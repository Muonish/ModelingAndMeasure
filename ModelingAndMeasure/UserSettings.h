//
//  UserSettings.h
//  ModelingAndMeasure
//
//  Created by Valeryia Breshko on 5/6/17.
//  Copyright © 2017 Valeria Breshko. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Units.h"

@interface UserSettings : NSObject <SerializableProtocol>

@property (strong, nonatomic) Units *units;
@property (strong, nonatomic) NSNumber *height;

+ (instancetype)instance;
- (void)save;

@end
