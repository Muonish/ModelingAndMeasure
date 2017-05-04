/*
 * SfM2DFeatureUtilities.h
 */

#ifndef SFMTOYLIB_SFM2DFEATUREUTILITIES_H_
#define SFMTOYLIB_SFM2DFEATUREUTILITIES_H_

#include "SfMCommon.h"

#include <opencv2/features2d.hpp>

namespace sfm {

class SfM2DFeatureUtilities {
public:
    SfM2DFeatureUtilities();
    virtual ~SfM2DFeatureUtilities();

    Features extractFeatures(const cv::Mat& image);

    static Matching matchFeatures(
            const Features& featuresLeft,
            const Features& featuresRight);

private:
    cv::Ptr<cv::Feature2D>         mDetector;
    cv::Ptr<cv::DescriptorMatcher> mMatcher;

};

} /* namespace sfm */

#endif /* SFMTOYLIB_SFM2DFEATUREUTILITIES_H_ */
