import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../app/routes.dart';
import '../../core/constants/app_icons.dart';
import 'app_toast.dart';
import 'permission_dialogs.dart';

/// Centralized service to check and request camera and media storage permissions.
class PermissionService {
  PermissionService._();

  static final DeviceInfoPlugin _deviceInfo = DeviceInfoPlugin();

  /// Check and request Camera permission.
  /// If granted -> returns `true`.
  /// If permanently denied -> shows Settings Dialog with SVG icon and returns `false`.
  /// If denied -> shows non-blocking [AppToast] and returns `false`.
  static Future<bool> requestCamera([BuildContext? context]) async {
    return _handleSinglePermission(
      permission: Permission.camera,
      title: 'Camera Access Required',
      description:
          'Desi Connect needs access to your camera to take photos. Please enable camera access in your device settings.',
      svgIconPath: AppIcons.cameraSvg,
    );
  }

  /// Check and request Gallery / Photos permission.
  /// - On Android 13+ (API 33+): checks and requests [Permission.photos] (READ_MEDIA_IMAGES).
  /// - On Android 12 and below: checks and requests [Permission.storage] (READ_EXTERNAL_STORAGE).
  /// - On iOS: checks and requests [Permission.photos].
  ///
  /// Strictly returns `true` ONLY if permission has been granted or limited.
  /// If denied or not allowed -> returns `false` (no picture will be uploaded).
  /// If permanently denied -> displays Settings Dialog with SVG icon and returns `false`.
  static Future<bool> requestGallery([BuildContext? context]) async {
    Permission permission = Permission.photos;
    if (Platform.isAndroid) {
      try {
        final androidInfo = await _deviceInfo.androidInfo;
        if (androidInfo.version.sdkInt >= 33) {
          permission = Permission.photos;
        } else {
          permission = Permission.storage;
        }
      } catch (_) {
        permission = Permission.photos;
      }
    }

    return _handleSinglePermission(
      permission: permission,
      title: 'Photos Access Required',
      description:
          'Desi Connect needs access to your photos and videos to select media. Please enable permission in your device settings.',
      svgIconPath: AppIcons.gallerySvg,
    );
  }

  /// Check and request Video permission.
  /// - On Android 13+ (API 33+): checks and requests [Permission.videos] (READ_MEDIA_VIDEO).
  /// - On Android 12 and below: checks and requests [Permission.storage] (READ_EXTERNAL_STORAGE).
  /// - On iOS: checks and requests [Permission.photos].
  static Future<bool> requestVideo([BuildContext? context]) async {
    Permission permission = Permission.photos;
    if (Platform.isAndroid) {
      try {
        final androidInfo = await _deviceInfo.androidInfo;
        if (androidInfo.version.sdkInt >= 33) {
          permission = Permission.videos;
        } else {
          permission = Permission.storage;
        }
      } catch (_) {
        permission = Permission.videos;
      }
    }

    return _handleSinglePermission(
      permission: permission,
      title: 'Videos Access Required',
      description:
          'Desi Connect needs access to your videos to select media. Please enable permission in your device settings.',
      svgIconPath: AppIcons.gallerySvg,
    );
  }

  /// Internal handler for single permission requests.
  static Future<bool> _handleSinglePermission({
    required Permission permission,
    required String title,
    required String description,
    required String svgIconPath,
  }) async {
    BuildContext? getNavigatorContext() {
      final navCtx = AppRoutes.navigatorKey.currentContext;
      if (navCtx != null && navCtx.mounted) return navCtx;
      return null;
    }

    final status = await permission.status;

    // 1. Already granted or limited (iOS partial access / Android 14 selected photos)
    if (status.isGranted || status.isLimited) {
      return true;
    }

    // 2. Permanently denied
    if (status.isPermanentlyDenied) {
      final ctx = getNavigatorContext();
      if (ctx != null && ctx.mounted) {
        // ignore: use_build_context_synchronously
        await PermissionDialogs.showSettingsDialog(
          context: ctx,
          title: title,
          description: description,
          svgIconPath: svgIconPath,
        );
      } else {
        AppToast.showWarning('$title. Please enable it in device Settings.');
      }
      return false;
    }

    // 3. Request permission from OS
    final result = await permission.request();

    if (result.isGranted || result.isLimited) {
      return true;
    }

    // 4. Denied after request
    if (result.isPermanentlyDenied) {
      final ctx = getNavigatorContext();
      if (ctx != null && ctx.mounted) {
        // ignore: use_build_context_synchronously
        await PermissionDialogs.showSettingsDialog(
          context: ctx,
          title: title,
          description: description,
          svgIconPath: svgIconPath,
        );
      } else {
        AppToast.showWarning('$title. Please enable it in device Settings.');
      }
    } else {
      AppToast.showWarning('$title is required to proceed.');
    }

    return false;
  }
}
