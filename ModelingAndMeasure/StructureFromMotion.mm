//
//  StructureFromMotion.m
//  ModelingAndMeasure
//
//  Created by Valeryia Breshko on 5/4/17.
//  Copyright © 2017 Valeria Breshko. All rights reserved.
//

#import "StructureFromMotion.h"
#import "SpecialPointsDetector.h"
#import "SpetialPointsMatcher.h"

#include "SfMBundleAdjustmentUtils.h"
#include "SfMStereoUtilities.h"

#include <algorithm>
#include <thread>
#include <mutex>

using namespace std;
using namespace sfm;
using namespace cv;

const float MERGE_CLOUD_POINT_MIN_MATCH_DISTANCE   = 0.01;
const float MERGE_CLOUD_FEATURE_MIN_MATCH_DISTANCE = 20.0;
const int   MIN_POINT_COUNT_FOR_HOMOGRAPHY         = 100;

@interface StructureFromMotion() {
    std::vector<Matx34f>  cameraPoses;
    std::vector<Mat>      images;
    PointCloud            reconstructionCloud;

    std::vector<Features>     imageFeatures;
    MatchMatrix               featureMatchMatrix;
    Intrinsics                intrinsics;
    float                     downscaleFactor;

    std::set<int>             doneViews;
    std::set<int>             goodViews;
}

@property (nonatomic, strong) SpecialPointsDetector *pointsDetector;

@end

@implementation StructureFromMotion

- (instancetype)initWithDownscaleFactor:(float)scale {
    self = [super init];
    if (self) {
        downscaleFactor = scale;
        self.pointsDetector = [[SpecialPointsDetector alloc] initWithScale:scale];
    }
    return self;
}

- (void)setImages:(const std::vector<Mat>&)imgs {
    images = imgs;
}

- (PointCloud)getReconstructionCloud {
    return reconstructionCloud;
}

- (std::vector<Matx34f>)getCameraPoses {
    return cameraPoses;
}

- (void)run {
    if (images.size() <= 0) {
        if ([self.delegate respondsToSelector:@selector(sfmDidFail:)]) {
            [self.delegate sfmDidFail:self];
        }
        return;
    }

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        //initialize intrinsics
        intrinsics.K = (Mat_<float>(3,3) << 2500,   0, images[0].cols / 2,
                        0, 2500, images[0].rows / 2,
                        0,    0, 1);
        intrinsics.Kinv = intrinsics.K.inv();
        intrinsics.distortion = Mat_<float>::zeros(1, 4);

        cameraPoses.resize(images.size());

        //First - extract features from all images
        [self extractFeatures];

        //Create a matching matrix between all images' features
        [self createFeatureMatchMatrix];

        //Find the best two views for an initial triangulation on the 3D map
        [self findBaselineTriangulation];

        [self drawCloud];
        
        //Lastly - add more camera views to the map
        // addMoreViewsToReconstruction();
    });
}

- (void)extractFeatures {
    imageFeatures.resize(images.size());
    for (size_t i = 0; i < images.size(); i++) {
        imageFeatures[i] = [self.pointsDetector extractFeatures:images[i]];
    }
}

- (void)createFeatureMatchMatrix {

    const size_t nuimages = images.size();
    featureMatchMatrix.resize(nuimages, vector<Matching>(nuimages));

    //prepare image pairs to match concurrently
    vector<ImagePair> pairs;
    for (size_t i = 0; i < nuimages; i++) {
        for (size_t j = i + 1; j < nuimages; j++) {
            pairs.push_back({ i, j });
        }
    }

    vector<thread> threads;

    const int numThreads = 4;
    //how many pairs each thread will work on
    const int numPairsForThread = (numThreads > pairs.size()) ? 1 : (int)ceilf((float)(pairs.size()) / numThreads);

    //invoke each thread with its pairs to process (if less pairs than threads, invoke only #pairs threads with 1 pair each)
    for (size_t threadId = 0; threadId < MIN(numThreads, pairs.size()); threadId++) {
        threads.push_back(thread([&, threadId] {
            const long startingPair = numPairsForThread * threadId;

            for (int j = 0; j < numPairsForThread; j++) {
                const long pairId = startingPair + j;
                if (pairId >= pairs.size()) { //make sure threads don't overflow the pairs
                    break;
                }
                const ImagePair& pair = pairs[pairId];

                featureMatchMatrix[pair.left][pair.right] = [SpetialPointsMatcher matchFeaturesLeft:imageFeatures[pair.left]
                                                                                              right:imageFeatures[pair.right]];
            }
        }));
    }

    //wait for threads to complete
    for (auto& t : threads) {
        t.join();
    }

}

- (void)findBaselineTriangulation {
    //maps are sorted, so the best pair is at the beginnning
    map<float, ImagePair> pairsHomographyInliers = [self sortViewsForBaseline];

    Matx34f Pleft  = Matx34f::eye();
    Matx34f Pright = Matx34f::eye();
    PointCloud pointCloud;

    //try to find the best pair, stating at the beginning
    for (auto& imagePair : pairsHomographyInliers) {

        size_t i = imagePair.second.left;
        size_t j = imagePair.second.right;

        Matching prunedMatching;
        //recover camera matrices (poses) from the point matching
        bool success = SfMStereoUtilities::findCameraMatricesFromMatch(intrinsics,
                                                                       featureMatchMatrix[i][j],
                                                                       imageFeatures[i],
                                                                       imageFeatures[j],
                                                                       prunedMatching,
                                                                       Pleft, Pright
                                                                       );

        if (not success) {
            continue;
        }

        float poseInliersRatio = (float)prunedMatching.size() / (float)featureMatchMatrix[i][j].size();

        if (poseInliersRatio < POSE_INLIERS_MINIMAL_RATIO) {
            continue;
        }

        //        if (mVisualDebugLevel <= LOG_INFO) {
        //            Mat outImage;
        //            drawMatches(images[i], mImageFeatures[i].keyPoints,
        //                        images[j], mImageFeatures[j].keyPoints,
        //                        prunedMatching,
        //                        outImage);
        //            resize(outImage, outImage, Size(), 0.5, 0.5);
        //            imshow("outimage", outImage);
        //            waitKey(0);
        //        }

        featureMatchMatrix[i][j] = prunedMatching;

        success = SfMStereoUtilities::triangulateViews(
                                                       intrinsics,
                                                       imagePair.second,
                                                       featureMatchMatrix[i][j],
                                                       imageFeatures[i], imageFeatures[j],
                                                       Pleft, Pright,
                                                       pointCloud
                                                       );
        
        if (not success) {
            continue;
        }
        
        reconstructionCloud = pointCloud;
        cameraPoses[i] = Pleft;
        cameraPoses[j] = Pright;
        doneViews.insert(i);
        doneViews.insert(j);
        goodViews.insert(i);
        goodViews.insert(j);
        
        [self adjustCurrentBundle];
        
        break;
    }
}


- (void)adjustCurrentBundle {
    SfMBundleAdjustmentUtils::adjustBundle(reconstructionCloud,
                                           cameraPoses,
                                           intrinsics,
                                           imageFeatures);
}


- (map<float, ImagePair>)sortViewsForBaseline {

    //sort pairwise matches to find the lowest Homography inliers [Snavely07 4.2]
    map<float, ImagePair> matchesSizes;
    const size_t nuimages = images.size();
    for (size_t i = 0; i < nuimages - 1; i++) {
        for (size_t j = i + 1; j < nuimages; j++) {
            if (featureMatchMatrix[i][j].size() < MIN_POINT_COUNT_FOR_HOMOGRAPHY) {
                //Not enough points in matching
                matchesSizes[1.0] = {i, j};
                continue;
            }

            //Find number of homography inliers
            const int numInliers = SfMStereoUtilities::findHomographyInliers(imageFeatures[i],
                                                                             imageFeatures[j],
                                                                             featureMatchMatrix[i][j]);
            const float inliersRatio = (float)numInliers / (float)(featureMatchMatrix[i][j].size());
            matchesSizes[inliersRatio] = {i, j};
        }
    }
    
    return matchesSizes;
}

- (void)drawCloud {
    if ([self.delegate respondsToSelector:@selector(sfm:didFinishModelingWithImage:)]) {
        Mat templateImg = images[0];
        Mat result;
        Vec3b pointColor(100,0,0);
        result.create(templateImg.rows,templateImg.cols, CV_8UC4);
        for (const Point3DInMap& p : reconstructionCloud) {
            //get color from first originating view
            auto originatingView = p.originatingViews.begin();
            const int viewIdx = originatingView->first;
            Point2f p2d = imageFeatures[viewIdx].points[originatingView->second];
            result.at<Vec3b>(p2d.x, p2d.y) = pointColor;

        }

        [self.delegate sfm:self didFinishModelingWithImage:result];
    }
}

@end
