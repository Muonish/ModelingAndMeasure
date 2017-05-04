//
//  Model3DBuilder.h
//  ModelingAndMeasure
//
//  Created by Valeryia Breshko on 5/4/17.
//  Copyright © 2017 Valeria Breshko. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class Model3DBuilder;

@protocol Model3DBuilderDelegate <NSObject>

- (void)modelBuilder:(Model3DBuilder *)mb didFinishModelingWithModel:(UIImage *)image;

@end

@interface Model3DBuilder : NSObject

@property (weak, nonatomic) id<Model3DBuilderDelegate> delegate;
@property (assign, nonatomic) BOOL isModeling;

- (instancetype)initWithImages:(std::vector<cv::Mat>)imgs
                         scale:(CGFloat)scale;

- (void)runModeling;

@end
