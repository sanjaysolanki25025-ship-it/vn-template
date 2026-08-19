import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class CommonLottieAsset extends StatelessWidget {
  final String assetName;
  final double? width;
  final double? height;
  final BoxFit? fit;
  final bool repeat;

  const CommonLottieAsset({
    super.key,
    required this.assetName,
    this.width,
    this.height,
    this.fit,
    this.repeat = true,
  });

  @override
  Widget build(BuildContext context) {
    return Lottie.asset(
      assetName,
      width: width,
      height: height,
      fit: fit,
      repeat: repeat,
    );
  }
}
