/*
 * SfM2DFeatureUtilities.cpp
 */

#include "SfM2DFeatureUtilities.h"

using namespace cv;
using namespace std;

namespace sfm {

const double NN_MATCH_RATIO = 0.8f; // Nearest-neighbour matching ratio

SfM2DFeatureUtilities::SfM2DFeatureUtilities() {
    // initialize detector and extractor
    mDetector = ORB::create(5000);
    mMatcher = DescriptorMatcher::create("BruteForce-Hamming");
}

SfM2DFeatureUtilities::~SfM2DFeatureUtilities() {
}

Features SfM2DFeatureUtilities::extractFeatures(const cv::Mat& image) {
    Features features;
    mDetector->detectAndCompute(image, noArray(), features.keyPoints, features.descriptors);
    KeyPointsToPoints(features.keyPoints, features.points);
    return features;
}

Matching SfM2DFeatureUtilities::matchFeatures(
        const Features& featuresLeft,
        const Features& featuresRight) {
    //initial matching between features
    vector<Matching> initialMatching;

    auto matcher = DescriptorMatcher::create("BruteForce-Hamming");
    matcher->knnMatch(featuresLeft.descriptors, featuresRight.descriptors, initialMatching, 2);

    //prune the matching using the ratio test
    Matching prunedMatching;
    for(unsigned i = 0; i < initialMatching.size(); i++) {
        if(initialMatching[i][0].distance < NN_MATCH_RATIO * initialMatching[i][1].distance) {
            prunedMatching.push_back(initialMatching[i][0]);
        }
    }

    return prunedMatching;
}

} /* namespace sfm */
