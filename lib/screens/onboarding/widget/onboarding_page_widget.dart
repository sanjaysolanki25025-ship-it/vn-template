import 'package:flutter/material.dart';
import 'package:vn_template/core/utils/app_text_style.dart';
import 'package:vn_template/common_widgets/common_text_widget.dart';
import 'package:vn_template/common_widgets/common_sizedbox.dart';
import 'package:vn_template/common_widgets/common_image.dart';

class OnboardingPageWidget extends StatelessWidget {
  final String imagePath;
  final String title;

  const OnboardingPageWidget({
    super.key,
    required this.imagePath,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Flexible(
            child: CommonImage(assetName: imagePath, fit: BoxFit.contain),
          ),
          const SBH5(),
          CommonTextWidget(
            text: title,
            textStyle: size24TextStyle(fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
