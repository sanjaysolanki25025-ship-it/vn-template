import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class CommonImage extends StatelessWidget {
  final String assetName;
  final double? height;
  final double? width;
  final BoxFit fit;
  final double? borderRadius;

  const CommonImage({
    super.key,
    required this.assetName,
    this.height,
    this.width,
    this.fit = BoxFit.cover,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    if (assetName.isEmpty) {
      return const SizedBox.shrink();
    }
    final isNetwork = assetName.startsWith('http://') || assetName.startsWith('https://');

    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius ?? 0),
      child: isNetwork
          ? CachedNetworkImage(
              imageUrl: assetName,
              height: height,
              width: width,
              fit: fit,
              placeholder: (context, url) => const SizedBox.shrink(),
              errorWidget: (context, url, error) => const Icon(Icons.error),
            )
          : Image.asset(assetName, height: height, width: width, fit: fit),
    );
  }
}
