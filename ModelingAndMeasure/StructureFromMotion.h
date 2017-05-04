//
//  StructureFromMotion.h
//  ModelingAndMeasure
//
//  Created by Valeryia Breshko on 5/4/17.
//  Copyright © 2017 Valeria Breshko. All rights reserved.
//

#import <Foundation/Foundation.h>
#include "SfMCommon.h"
#include "SfM2DFeatureUtilities.h"

#include <string>
#include <vector>
#include <map>
#include <set>
/**
 * This is a matrix of matches from view i to view j
 */

using namespace sfm;
using namespace cv;

typedef std::vector<std::vector<Matching> > MatchMatrix;

typedef std::map<int, Image2D3DMatch> Images2D3DMatches;

@interface StructureFromMotion : NSObject 
- (instancetype)initWithDownscaleFactor:(float)scale;

- (void)setImages:(const std::vector<Mat>)imgs;
- (PointCloud)getReconstructionCloud;
- (std::vector<Matx34f>)getCameraPoses;

- (void)run;

@end
