import 'package:flutter/material.dart';
import 'package:vn_template/core/constant/app_colors.dart';
import 'package:vn_template/core/constant/app_string.dart';
import 'package:vn_template/core/utils/app_text_style.dart';
import 'package:vn_template/common_widgets/common_text_widget.dart';
import 'package:vn_template/common_widgets/common_sizedbox.dart';

class FaqWidget extends StatelessWidget {
  const FaqWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.info_outline, color: AppColors.whiteColor.withOpacity(0.7), size: 20),
            const SBW10(),
            CommonTextWidget(
              text: AppStrings.txtFaq,
              textStyle: size16TextStyle(textColor: AppColors.whiteColor.withOpacity(0.7), fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SBH20(),
        const _FaqItem(question: AppStrings.txtFaqQ1, answer: AppStrings.txtFaqA1),
        const _FaqItem(question: AppStrings.txtFaqQ2, answer: AppStrings.txtFaqA2),
        const _FaqItem(question: AppStrings.txtFaqQ3, answer: AppStrings.txtFaqA3),
        const _FaqItem(question: AppStrings.txtFaqQ4, answer: AppStrings.txtFaqA4),
        const _FaqItem(question: AppStrings.txtFaqQ5, answer: AppStrings.txtFaqA5),
        const _FaqItem(question: AppStrings.txtFaqQ6, answer: AppStrings.txtFaqA6),
      ],
    );
  }
}

class _FaqItem extends StatefulWidget {
  final String question;
  final String answer;

  const _FaqItem({required this.question, required this.answer});

  @override
  __FaqItemState createState() => __FaqItemState();
}

class __FaqItemState extends State<_FaqItem> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InkWell(
          onTap: () {
            setState(() {
              _isExpanded = !_isExpanded;
            });
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: CommonTextWidget(
                    text: widget.question,
                    textStyle: size14TextStyle(textColor: AppColors.whiteColor.withOpacity(0.9)),
                  ),
                ),
                const SBW10(),
                Icon(
                  _isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                  color: AppColors.whiteColor,
                ),
              ],
            ),
          ),
        ),
        if (_isExpanded)
          Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: CommonTextWidget(
              text: widget.answer,
              textStyle: size14TextStyle(textColor: AppColors.whiteColor.withOpacity(0.7)),
            ),
          ),
        Divider(color: AppColors.whiteColor.withOpacity(0.1), height: 1),
      ],
    );
  }
}
