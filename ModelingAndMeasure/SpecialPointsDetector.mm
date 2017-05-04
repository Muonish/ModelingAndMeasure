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

- (sfm::Features)extractFeatures:(const cv::Mat &)img {
    sfm::Features features;
    orb_detector->detectAndCompute(img, noArray(), features.keyPoints, features.descriptors);
    sfm::KeyPointsToPoints(features.keyPoints, features.points);
    return features;
}

@end

