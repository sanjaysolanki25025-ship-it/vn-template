import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shimmer/shimmer.dart';
import 'package:vn_template/common_widgets/common_sizedbox.dart';
import 'package:vn_template/core/constant/app_colors.dart';

class DiscoverShimmer extends StatelessWidget {
  final bool isGridView;

  const DiscoverShimmer({super.key, required this.isGridView});

  @override
  Widget build(BuildContext context) {
    return isGridView
        ? GridView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            itemCount: 6,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.75,
            ),
            itemBuilder: (context, index) {
              return Shimmer.fromColors(
                baseColor: AppColors.shimmerBaseColor,
                highlightColor: AppColors.shimmerHighlightColor,
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.shimmerContainerColor,
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              );
            },
          )
        : Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Column(
              children: [
                SizedBox(
                  height: 35.h,
                  child: ListView.separated(
                    separatorBuilder: (context, index) => SBW10(),
                    scrollDirection: Axis.horizontal,
                    itemCount: 5,
                    itemBuilder: (context, index) {
                      return Shimmer.fromColors(
                        baseColor: AppColors.shimmerBaseColor,
                        highlightColor: AppColors.shimmerHighlightColor,
                        child: Container(
                          width: 80.w,
                          height: 23.h,
                          decoration: BoxDecoration(
                            color: AppColors.shimmerContainerColor,
                            borderRadius: BorderRadius.circular(50),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                SBH10(),
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.zero,
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 0.w),
                      child: Column(
                        children: [
                          for (int i = 0; i < 6; i += 2) ...[
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Shimmer.fromColors(
                                    baseColor: AppColors.shimmerBaseColor,
                                    highlightColor:
                                        AppColors.shimmerHighlightColor,
                                    child: Container(
                                      height: 300.h,
                                      decoration: BoxDecoration(
                                        color: AppColors.shimmerContainerColor,
                                        borderRadius: BorderRadius.circular(
                                          16.r,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                SBW10(),
                                if (i + 1 < 6)
                                  Expanded(
                                    child: Shimmer.fromColors(
                                      baseColor: AppColors.shimmerBaseColor,
                                      highlightColor:
                                          AppColors.shimmerHighlightColor,
                                      child: Container(
                                        height: 300.h,
                                        decoration: BoxDecoration(
                                          color:
                                              AppColors.shimmerContainerColor,
                                          borderRadius: BorderRadius.circular(
                                            16.r,
                                          ),
                                        ),
                                      ),
                                    ),
                                  )
                                else
                                  const Spacer(),
                              ],
                            ),
                            SBH10(),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
  }
}
