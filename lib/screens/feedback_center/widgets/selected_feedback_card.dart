import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:vn_template/common_widgets/common_text_widget.dart';
import 'package:vn_template/core/constant/app_colors.dart';
import 'package:vn_template/core/utils/app_text_style.dart';
import 'package:vn_template/screens/feedback_center/bloc/feedback_center_bloc.dart';
import 'package:vn_template/core/constant/app_string.dart';

class SelectedFeedbackCard extends StatelessWidget {
  final String? isSelectedFeedback;

  const SelectedFeedbackCard({
    super.key,
    required this.isSelectedFeedback,
  });

  @override
  Widget build(BuildContext context) {
    final List<String> options = [
      AppStrings.txtFeedbackIssue.getString(context),
      "Suggestion",
      "Other",
    ];

    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: options.map((option) {
        final isSelected = isSelectedFeedback == option;
        return GestureDetector(
          onTap: () {
            context.read<FeedbackCenterBloc>().add(
                  SelectedFeedbackOptionEvent(selectedOption: option),
                );
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.accentColor : AppColors.secondaryColor,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isSelected ? AppColors.accentColor : AppColors.greyColor.withValues(alpha: 0.5),
              ),
            ),
            child: CommonTextWidget(
              text: option,
              textStyle: size14TextStyle(
                textColor: isSelected ? AppColors.blackColor : AppColors.whiteColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
