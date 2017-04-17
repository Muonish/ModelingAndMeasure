//
//  SpecialPointsDetector.mm
//  ModelingAndMeasure
//
//  Created by Valeryia Breshko on 4/12/17.
//  Copyright © 2017 Valeria Breshko. All rights reserved.
//

#import "SpecialPointsDetector.h"
#import "UIImage+OpenCV.h"
#import <opencv2/core/core.hpp>
#import <opencv2/highgui/highgui.hpp>
#import <opencv2/xfeatures2d.hpp>

using namespace std;
using namespace cv;

@interface SpecialPointsDetector() {
    Ptr<ORB> orb_detector;
}

@property (nonatomic, assign) CGFloat scale;

@end

@implementation SpecialPointsDetector

- (instancetype)initWithScale:(CGFloat)scale {
    self = [super init];
    if (self) {
        self.scale = scale;
        orb_detector = cv::ORB::create(4000);
    }

    return self;
}

- (std::vector<cv::KeyPoint>)detectAndDrawPointsOn:(cv::Mat&)img fromImage1:(cv::Mat&)img1 andImage2:(cv::Mat&)img2 {

    Mat imgA, imgB;
    cvtColor(img1, imgA, COLOR_BGR2GRAY);
    cvtColor(img2, imgB, COLOR_BGR2GRAY);

    std::vector<KeyPoint> keypointsA, keypointsB;
    Mat descriptorsA, descriptorsB;
    std::vector<DMatch> matches;

    // DETECTION
    // Any openCV detector such as
    Ptr<cv::xfeatures2d::SURF> detector = cv::xfeatures2d::SURF::create();

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

    // detect
    detector->detect( imgA, keypointsA );
    detector->detect( imgB, keypointsB );

    extractor->compute( imgA, keypointsA, descriptorsA );
    extractor->compute( imgB, keypointsB, descriptorsB );

    // match
    matcher->match(descriptorsA, descriptorsB, matches);

    // Draw matches
    drawMatches(imgA, keypointsA, imgB, keypointsB, matches, img);
    return keypointsB;
}

- (vector<KeyPoint>)detectAndDrawPointsOn:(Mat&)img {
    Mat gray, smallImg( cvRound (img.rows/_scale), cvRound(img.cols/_scale), CV_8UC1);

    cvtColor(img, gray, COLOR_BGR2GRAY);
    resize(gray, smallImg, smallImg.size(), 0, 0, INTER_LINEAR);
    equalizeHist(smallImg, smallImg);

    vector<KeyPoint> kpts;
    orb_detector->detect(gray, kpts);
    drawKeypoints(gray, kpts, img, Scalar(255, 255, 255), cv::DrawMatchesFlags::DRAW_OVER_OUTIMG);
    return kpts;
}

@end

