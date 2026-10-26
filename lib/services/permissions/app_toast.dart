import 'package:fluttertoast/fluttertoast.dart';
import '../../core/constants/app_colors.dart';

/// Centralized toast notification utility using [fluttertoast].
class AppToast {
  AppToast._();

  /// Show a general informational toast
  static void show(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: AppColors.slate900.withValues(alpha: 0.9),
      textColor: AppColors.white,
      fontSize: 14.0,
    );
  }

  /// Show a warning toast (e.g. permission required)
  static void showWarning(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: AppColors.amberOrange,
      textColor: AppColors.white,
      fontSize: 14.0,
    );
  }

  /// Show a success toast
  static void showSuccess(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: AppColors.successGreen,
      textColor: AppColors.white,
      fontSize: 14.0,
    );
  }

  /// Show an error toast
  static void showError(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: AppColors.primaryRed,
      textColor: AppColors.white,
      fontSize: 14.0,
    );
  }
}
