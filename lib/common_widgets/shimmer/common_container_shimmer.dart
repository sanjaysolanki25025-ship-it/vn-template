import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shimmer/shimmer.dart';
import 'package:vn_template/core/constant/app_colors.dart';

class CommonContainerShimmer extends StatelessWidget {
  final double height;
  final double width;
  final double? borderRadius;

  const CommonContainerShimmer({
    super.key,
    required this.height,
    required this.width,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.shimmerBaseColor,
      highlightColor: AppColors.shimmerHighlightColor,
      child: Container(
        height: height,
        width: width,
        decoration: BoxDecoration(
          color: AppColors.shimmerContainerColor,
          borderRadius: BorderRadius.circular(borderRadius ?? 16.r),
        ),
      ),
    );
  }
}
