import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vn_template/common_widgets/common_text_widget.dart';
import 'package:vn_template/core/constant/app_colors.dart';
import 'package:vn_template/core/utils/app_text_style.dart';
import 'package:vn_template/data/models/select_app_language_model.dart';


class LanguageTile extends StatelessWidget {
  final SelectAppLanguageModel language;
  final bool isSelected;
  final VoidCallback onTap;

  const LanguageTile({
    super.key,
    required this.language,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: AppColors.whiteColor.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: isSelected ? AppColors.whiteColor : AppColors.secondaryColor,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: ListTile(
          leading: Text(
            language.flag,
            style: TextStyle(fontSize: 24.sp),
          ),
          title: CommonTextWidget(
            text: language.name,
            textStyle: size16TextStyle(
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              textColor: isSelected ? AppColors.whiteColor : AppColors.greyColor,
            ),
          ),
          trailing: isSelected
              ? Container(
                  padding: EdgeInsets.all(4.w),
                  decoration: BoxDecoration(
                    color: AppColors.whiteColor,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.arrow_forward_ios,
                    color: AppColors.primaryColor,
                    size: 14.sp,
                  ),
                )
              : null,
        ),
      ),
    );
  }
}
