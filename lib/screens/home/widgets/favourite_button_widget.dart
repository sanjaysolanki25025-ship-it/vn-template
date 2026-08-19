import 'package:flutter/material.dart';
import 'package:vn_template/core/constant/app_colors.dart';

class FavouriteButtonWidget extends StatelessWidget {
  final bool isFavourite;

  const FavouriteButtonWidget({
    super.key,
    required this.isFavourite,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.4),
        shape: BoxShape.circle,
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.15),
          width: 1,
        ),
      ),
      child: Center(
        child: Icon(
          isFavourite ? Icons.favorite : Icons.favorite_border,
          color: isFavourite ? Colors.red : AppColors.whiteColor,
          size: 24,
        ),
      ),
    );
  }
}
