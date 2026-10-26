import '../../services/api/api_endpoints.dart';

/// Image Utilities following the DesiLynks Image Optimization Guidelines
class ImageUtils {
  /// Converts a full `.webp` image URL to its 480px thumbnail URL (`_thumb.webp`).
  ///
  /// - New uploads ending in `.webp` have a 480px thumbnail saved alongside:
  ///   e.g. `https://domain.com/uploads/photo.webp` -> `https://domain.com/uploads/photo_thumb.webp`
  /// - Old uploads (`.jpg`, `.png`) or already-thumbnail URLs are returned unchanged.
  static String getThumbnailUrl(String? url) {
    if (url == null || url.trim().isEmpty) return '';
    final trimmed = url.trim();
    if (trimmed.endsWith('_thumb.webp')) return trimmed;
    if (trimmed.endsWith('.webp')) {
      return trimmed.replaceFirst(RegExp(r'\.webp$'), '_thumb.webp');
    }
    return trimmed;
  }

  /// Normalizes any relative or absolute image URL into a full valid HTTP/HTTPS URL.
  /// Handles Strings, Maps (e.g. `{'url': '...'}`), and nested structures.
  static String resolveImageUrl(dynamic source) {
    if (source == null) return '';
    String raw = '';

    if (source is String) {
      raw = source.trim();
    } else if (source is Map) {
      final potentialUrl = source['url'] ??
          source['coverPhoto'] ??
          source['coverImageUrl'] ??
          source['coverPhotoUrl'] ??
          source['imageUrl'] ??
          source['path'] ??
          source['link'] ??
          source['photoUrl'];

      if (potentialUrl is String) {
        raw = potentialUrl.trim();
      } else if (potentialUrl is Map) {
        final nestedUrl = potentialUrl['url'] ?? potentialUrl['path'];
        if (nestedUrl is String) {
          raw = nestedUrl.trim();
        }
      }
    }

    if (raw.isEmpty) return '';

    // If already absolute HTTP / HTTPS URL
    if (raw.startsWith('http://') || raw.startsWith('https://')) {
      return raw;
    }

    // Prepend API base URL
    final baseUrl = ApiEndpoints.baseUrl.endsWith('/')
        ? ApiEndpoints.baseUrl.substring(0, ApiEndpoints.baseUrl.length - 1)
        : ApiEndpoints.baseUrl;
    final path = raw.startsWith('/') ? raw : '/$raw';
    return '$baseUrl$path';
  }

  /// Resolves the cover photo URL from any community group Map or model representation.
  static String resolveGroupCoverUrl(dynamic group) {
    if (group == null) return '';
    if (group is String) return resolveImageUrl(group);

    if (group is Map) {
      // Check if wrapped in a nested membership or container 'group'
      final target = (group['group'] is Map) ? group['group'] as Map : group;

      final dynamic raw = target['coverImageUrl'] ??
          target['coverPhotoUrl'] ??
          target['coverPhoto'] ??
          target['imageUrl'] ??
          target['cover_photo'] ??
          target['image'] ??
          target['photo'];

      return resolveImageUrl(raw);
    }

    return '';
  }
}

