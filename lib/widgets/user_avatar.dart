import 'package:desilynks/core/constants/app_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_constants.dart';
import '../core/utils/image_utils.dart';
import '../services/api/api_endpoints.dart';

/// Reusable user avatar widget with network loading, error handling, and fallback icon.
class UserAvatar extends StatelessWidget {
  final String? photoUrl;
  final double size;
  final String? fallbackSvg;
  final Color? fallbackBgColor;
  final Color? fallbackIconColor;
  final BoxBorder? border;
  final String? fallbackImageUrl;

  const UserAvatar({
    super.key,
    required this.photoUrl,
    this.size = AppConstants.avatarSizeMedium,
    this.fallbackSvg = AppIcons.personSvg,
    this.fallbackBgColor,
    this.fallbackIconColor,
    this.border,
    this.fallbackImageUrl,
  });

  String _normalize(String? url) {
    if (url == null || url.trim().isEmpty) return '';
    final trimmed = url.trim();
    if (trimmed.startsWith('http://') || trimmed.startsWith('https://')) {
      return trimmed;
    }
    final baseUrl = ApiEndpoints.baseUrl.endsWith('/')
        ? ApiEndpoints.baseUrl.substring(0, ApiEndpoints.baseUrl.length - 1)
        : ApiEndpoints.baseUrl;
    final path = trimmed.startsWith('/') ? trimmed : '/$trimmed';
    return '$baseUrl$path';
  }

  @override
  Widget build(BuildContext context) {
    final String resolvedPhotoUrl = _normalize(photoUrl);
    final String resolvedFallbackUrl = _normalize(fallbackImageUrl);
    final bool hasValidUrl = resolvedPhotoUrl.isNotEmpty;
    final bool hasFallbackUrl = resolvedFallbackUrl.isNotEmpty;

    final Widget defaultFallbackWidget = Container(
      color: fallbackBgColor ?? AppColors.slate200,
      child: Center(
        child: SvgPicture.asset(
          fallbackSvg!,
          width: size * 0.5,
          height: size * 0.5,
          colorFilter: ColorFilter.mode(
            fallbackIconColor ?? AppColors.slate600,
            BlendMode.srcIn,
          ),
        ),
      ),
    );

    Widget avatarChild;

    if (hasValidUrl) {
      final String thumbUrl = ImageUtils.getThumbnailUrl(resolvedPhotoUrl);
      final bool hasThumb = thumbUrl != resolvedPhotoUrl;

      avatarChild = Image.network(
        hasThumb ? thumbUrl : resolvedPhotoUrl,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          // If thumbnail fails to load, fall back to the full resolution URL
          if (hasThumb) {
            return Image.network(
              resolvedPhotoUrl,
              fit: BoxFit.cover,
              errorBuilder: (ctx, err, stack) {
                if (hasFallbackUrl) {
                  return Image.network(
                    resolvedFallbackUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (ctx2, err2, stack2) => defaultFallbackWidget,
                  );
                }
                return defaultFallbackWidget;
              },
            );
          }
          if (hasFallbackUrl) {
            return Image.network(
              resolvedFallbackUrl,
              fit: BoxFit.cover,
              errorBuilder: (ctx, err, stack) => defaultFallbackWidget,
            );
          }
          return defaultFallbackWidget;
        },
      );
    } else if (hasFallbackUrl) {
      avatarChild = Image.network(
        resolvedFallbackUrl,
        fit: BoxFit.cover,
        errorBuilder: (ctx, err, stack) => defaultFallbackWidget,
      );
    } else {
      avatarChild = defaultFallbackWidget;
    }

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(shape: BoxShape.circle, border: border),
      child: ClipOval(child: avatarChild),
    );
  }
}
