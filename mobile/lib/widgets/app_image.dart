import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../config/api_config.dart';
import '../theme/app_theme.dart';

class AppImage extends StatelessWidget {
  const AppImage({
    super.key,
    required this.path,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.radius = 0,
  });

  final String? path;
  final double? width;
  final double? height;
  final BoxFit fit;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final url = ApiConfig.mediaUrl(path);
    final radiusValue = BorderRadius.circular(radius);

    Widget placeholder({bool loading = false}) {
      return Container(
        width: width,
        height: height,
        color: AppColors.soft,
        alignment: Alignment.center,
        child: loading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.red,
                ),
              )
            : const Icon(
                Icons.image_not_supported_outlined,
                color: AppColors.muted,
                size: 28,
              ),
      );
    }

    if (url.isEmpty) {
      return ClipRRect(borderRadius: radiusValue, child: placeholder());
    }

    return ClipRRect(
      borderRadius: radiusValue,
      child: CachedNetworkImage(
        imageUrl: url,
        width: width,
        height: height,
        fit: fit,
        placeholder: (context, value) => placeholder(loading: true),
        errorWidget: (context, value, error) => placeholder(),
      ),
    );
  }
}
