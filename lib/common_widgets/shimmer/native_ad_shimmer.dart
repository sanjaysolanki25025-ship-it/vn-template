import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shimmer/shimmer.dart';
import 'package:vn_template/common_widgets/common_sizedbox.dart';
import 'package:vn_template/core/constant/app_colors.dart';

class NativeAdShimmer extends StatelessWidget {
  const NativeAdShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: AppColors.shimmerContainerColor,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        children: [
          /// LEFT IMAGE
          Shimmer.fromColors(
            baseColor: AppColors.shimmerBaseColor,
            highlightColor: AppColors.shimmerHighlightColor,
            child: Container(
              width: 150.w,
              height: double.infinity,
              decoration: BoxDecoration(
                color: AppColors.shimmerContainerColor,
                borderRadius: BorderRadius.circular(8.r),
              ),
            ),
          ),

          SBW10(),

          /// RIGHT CONTENT
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _shimmerLine(height: 28.h),
                SBH10(),
                _shimmerLine(height: 28.h),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _shimmerLine({required double height, double? width}) {
    return Shimmer.fromColors(
      baseColor: AppColors.shimmerBaseColor,
      highlightColor: AppColors.shimmerHighlightColor,
      child: Container(
        height: height,
        width: width ?? double.infinity,
        decoration: BoxDecoration(
          color: AppColors.shimmerContainerColor,
          borderRadius: BorderRadius.circular(6.r),
        ),
      ),
    );
  }
}
