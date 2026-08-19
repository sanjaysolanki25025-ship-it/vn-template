import 'package:flutter/material.dart';

class CommonActionButton extends StatelessWidget {
  final String assetPath;
  final VoidCallback onTap;
  final double imageSize;
  final bool removeDecoration;
  final BoxFit fit;

  const CommonActionButton({
    super.key,
    required this.assetPath,
    required this.onTap,
    this.imageSize = 48.0,
    this.removeDecoration = false,
    this.fit = BoxFit.cover,
  });

  @override
  Widget build(BuildContext context) {
    if (assetPath.isEmpty) {
      return const SizedBox.shrink();
    }
    final Widget child = Image.asset(
      assetPath,
      width: imageSize,
      height: imageSize,
      fit: fit,
    );

    if (removeDecoration) {
      return GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.translucent,
        child: child,
      );
    }

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.translucent,
      child: Container(
        width: imageSize + 8,
        height: imageSize + 8,
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.4),
          shape: BoxShape.circle,
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.15),
            width: 1,
          ),
        ),
        child: Center(
          child: child,
        ),
      ),
    );
  }
}
