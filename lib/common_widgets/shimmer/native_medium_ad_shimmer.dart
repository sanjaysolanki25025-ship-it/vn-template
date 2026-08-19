import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shimmer/shimmer.dart';
import 'package:vn_template/common_widgets/common_sizedbox.dart';
import 'package:vn_template/core/constant/app_colors.dart';

class NativeMediumAdShimmer extends StatelessWidget {
  const NativeMediumAdShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.r),
        color: AppColors.shimmerContainerColor,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: Shimmer.fromColors(
              baseColor: AppColors.shimmerBaseColor,
              highlightColor: AppColors.shimmerHighlightColor,
              child: Container(
                height: 190,
                decoration: BoxDecoration(
                  color: AppColors.shimmerContainerColor,
                  borderRadius: BorderRadius.circular(8.r),
                ),
              ),
            ),
          ),
          SBH5(),
          Row(
            children: [
              Shimmer.fromColors(
                baseColor: AppColors.shimmerBaseColor,
                highlightColor: AppColors.shimmerHighlightColor,
                child: Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    color: AppColors.shimmerContainerColor,
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                ),
              ),
              SBW5(),
              Expanded(
                child: Column(
                  children: [
                    _shimmerLine(height: 20.h),
                    SBH5(),
                    _shimmerLine(height: 20.h),
                  ],
                ),
              ),
            ],
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
