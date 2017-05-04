/*
 * SfMBundleAdjustmentUtils.h
 */

#ifndef SFMTOYLIB_SFMBUNDLEADJUSTMENTUTILS_H_
#define SFMTOYLIB_SFMBUNDLEADJUSTMENTUTILS_H_

#include "SfMCommon.h"

namespace sfm {

class SfMBundleAdjustmentUtils {
public:
    /**
     *
     * @param pointCloud
     * @param cameraPoses
     * @param intrinsics
     * @param image2dFeatures
     */
    static void adjustBundle(
            PointCloud&                     pointCloud,
            std::vector<cv::Matx34f>&       cameraPoses,
            Intrinsics&                     intrinsics,
            const std::vector<Features>&    image2dFeatures
            );
};

} /* namespace sfm */

#endif /* SFMTOYLIB_SFMBUNDLEADJUSTMENTUTILS_H_ */
