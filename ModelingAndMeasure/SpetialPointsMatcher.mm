//
//  SpetialPointsMatcher.m
//  ModelingAndMeasure
//
//  Created by Valeryia Breshko on 5/3/17.
//  Copyright © 2017 Valeria Breshko. All rights reserved.
//

#import "SpetialPointsMatcher.h"
#import "UIImage+OpenCV.h"
#import <opencv2/core/core.hpp>
#import <opencv2/highgui/highgui.hpp>
#import <opencv2/xfeatures2d.hpp>

using namespace std;
using namespace cv;

const double NN_MATCH_RATIO = 0.8f; // Nearest-neighbour matching ratio

@implementation SpetialPointsMatcher

+ (std::vector<cv::DMatch>)matchKeyPoints1:(std::vector<KeyPoint>)keyPoints1 keyPoints2:(std::vector<KeyPoint>)keyPoints2 image1:(cv::Mat&)img1 image2:(cv::Mat&)img2 {

    Mat imgA, imgB;
    cvtColor(img1, imgA, COLOR_BGR2GRAY);
    cvtColor(img2, imgB, COLOR_BGR2GRAY);

    Mat descriptorsA, descriptorsB;
    std::vector<DMatch> matches;

    // DESCRIPTOR
    // Our proposed FREAK descriptor
    // (roation invariance, scale invariance, pattern radius corresponding to SMALLEST_KP_SIZE,
    // number of octaves, optional vector containing the selected pairs)
    // FREAK extractor(true, true, 22, 4, std::vector<int>());
    Ptr<xfeatures2d::FREAK> extractor = xfeatures2d::FREAK::create(true, true, 22, 4, std::vector<int>());

    // MATCHER
    // The standard Hamming distance can be used such as
    // BruteForceMatcher<Hamming> matcher;
    // or the proposed cascade of hamming distance using SSSE3
    Ptr<DescriptorMatcher> matcher = DescriptorMatcher::create("BruteForce-L1");

    extractor->compute( imgA, keyPoints1, descriptorsA );
    extractor->compute( imgB, keyPoints2, descriptorsB );

    // match
    matcher->match(descriptorsA, descriptorsB, matches);

    // Draw matches
    //drawMatches(imgA, keyPoints1, imgB, keypointsB, matches, img);
    return matches;
}

+ (sfm::Matching)matchFeaturesLeft:(const sfm::Features&)featuresLeft  right:(const sfm::Features&)featuresRight {
    //initial matching between features
    vector<sfm::Matching> initialMatching;

    auto matcher = DescriptorMatcher::create("BruteForce-L1");
    matcher->knnMatch(featuresLeft.descriptors, featuresRight.descriptors, initialMatching, 2);

    //prune the matching using the ratio test
    sfm::Matching prunedMatching;
    for(unsigned i = 0; i < initialMatching.size(); i++) {
        if(initialMatching[i][0].distance < NN_MATCH_RATIO * initialMatching[i][1].distance) {
            prunedMatching.push_back(initialMatching[i][0]);
        }
    }
    
    return prunedMatching;
}


@end
