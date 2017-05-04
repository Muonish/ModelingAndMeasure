//
//  Model3DBuilder.mm
//  ModelingAndMeasure
//
//  Created by Valeryia Breshko on 5/4/17.
//  Copyright © 2017 Valeria Breshko. All rights reserved.
//

#import "Model3DBuilder.h"
#import "StructureFromMotion.h"
#import "UIImage+OpenCV.h"

@interface Model3DBuilder() <StructureFromMotionDelegate> {
    std::vector<cv::Mat> images;
}

@property (nonatomic, strong) StructureFromMotion *sfm;
@property (nonatomic, assign) CGFloat scale;

@end

@implementation Model3DBuilder

- (instancetype)initWithImages:(std::vector<cv::Mat>)imgs
                         scale:(CGFloat)scale {
    self = [super init];
    if (self) {
        images = imgs;
        self.scale = scale;
        self.sfm = [[StructureFromMotion alloc] initWithDownscaleFactor:self.scale];
        self.sfm.delegate = self;
        self.isModeling = NO;
    }

    return self;
}

- (void)runModeling {
    if (!self.isModeling) {
        self.isModeling = YES;
        [self.sfm setImages:images];
        [self.sfm run];
    }
}

#pragma mark <StructureFromMotionDelegate>

- (void)sfm:(StructureFromMotion *)sfm didFinishModelingWithImage:(cv::Mat&)image {
    UIImage *img = nil;
    if (image.data != nullptr) {
        img = [UIImage imageFromCVMat:image];
    }
    [self finishWithImg:img];
}

- (void)sfmDidFail:(StructureFromMotion *)sfm {
    [self finishWithImg:nil];
}

- (void)finishWithImg:(UIImage *)img {
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([self.delegate respondsToSelector:@selector(modelBuilder:didFinishModelingWithModel:)]) {
            [self.delegate modelBuilder:self didFinishModelingWithModel:img];
        }
    });
    self.isModeling = NO;
}

@end
