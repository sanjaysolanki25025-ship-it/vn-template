import 'package:flutter/material.dart';
import 'package:vn_template/common_widgets/common_text_widget.dart';
import 'package:vn_template/common_widgets/common_sizedbox.dart';
import 'package:vn_template/core/constant/app_colors.dart';
import 'package:vn_template/core/utils/app_text_style.dart';

class TemplateStatsWidget extends StatelessWidget {
  final String clip;
  final int likes;
  final int usage;

  const TemplateStatsWidget({
    super.key,
    required this.clip,
    required this.likes,
    required this.usage,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.whiteColor.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.whiteColor.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildStatItem(Icons.movie_creation_outlined, clip),
          _buildDivider(),
          _buildStatItem(Icons.favorite_border, likes.toString()),
          _buildDivider(),
          _buildStatItem(Icons.trending_up, usage.toString()),
        ],
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: AppColors.whiteColor, size: 14),
        const SBW5(),
        CommonTextWidget(
          text: text,
          textStyle: size12TextStyle(
            textColor: AppColors.whiteColor,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildDivider() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: CommonTextWidget(
        text: '|',
        textStyle: size12TextStyle(
          textColor: AppColors.whiteColor.withValues(alpha: 0.5),
        ),
      ),
    );
  }
}
