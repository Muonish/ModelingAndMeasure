//
//  StructureFromMotion.h
//  ModelingAndMeasure
//
//  Created by Valeryia Breshko on 5/4/17.
//  Copyright © 2017 Valeria Breshko. All rights reserved.
//

#import <Foundation/Foundation.h>
#include "SfMCommon.h"

#include <string>
#include <vector>
#include <map>
#include <set>

/**
 * This is a matrix of matches from view i to view j
 */
typedef std::vector<std::vector<sfm::Matching> > MatchMatrix;
typedef std::map<int, sfm::Image2D3DMatch> Images2D3DMatches;

@class StructureFromMotion;

@protocol StructureFromMotionDelegate <NSObject>

- (void)sfm:(StructureFromMotion *)sfm didFinishModelingWithImage:(cv::Mat&)image;
- (void)sfmDidFail:(StructureFromMotion *)sfm;

@end

@interface StructureFromMotion : NSObject

@property (strong, nonatomic) id<StructureFromMotionDelegate> delegate;

- (instancetype)initWithDownscaleFactor:(float)scale;

- (void)setImages:(const std::vector<cv::Mat>&)imgs;
- (sfm::PointCloud)getReconstructionCloud;
- (std::vector<cv::Matx34f>)getCameraPoses;

// async operations inside
- (void)run;

@end
