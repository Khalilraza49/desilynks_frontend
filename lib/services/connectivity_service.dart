import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';

/// A service that monitors network connectivity in real-time
/// using only built-in dart:io — no external packages required.
///
/// Exposes a [ValueNotifier<bool>] that is `true` when the device has
/// an active internet connection and `false` otherwise.
class ConnectivityService {
  ConnectivityService._();
  static final ConnectivityService instance = ConnectivityService._();

  /// `true` → online, `false` → offline
  final ValueNotifier<bool> isConnected = ValueNotifier<bool>(true);

  Timer? _pollingTimer;
  bool _initialized = false;

  /// Call once at app startup (idempotent).
  Future<void> init() async {
    if (_initialized) return;
    _initialized = true;

    // Perform initial check
    isConnected.value = await _hasInternet();

    // Poll every 4 seconds to detect connectivity changes quickly
    _pollingTimer = Timer.periodic(
      const Duration(seconds: 4),
      (_) => _poll(),
    );
  }

  Future<void> _poll() async {
    final online = await _hasInternet();
    if (isConnected.value != online) {
      isConnected.value = online;
    }
  }

  /// Lightweight DNS lookup to verify real internet access.
  Future<bool> _hasInternet() async {
    try {
      final result = await InternetAddress.lookup('google.com')
          .timeout(const Duration(seconds: 3));
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } on SocketException catch (_) {
      return false;
    } on TimeoutException catch (_) {
      return false;
    }
  }

  /// Manually re-check connectivity (e.g. from a "Retry" button).
  Future<void> recheckConnectivity() async {
    isConnected.value = await _hasInternet();
  }

  void dispose() {
    _pollingTimer?.cancel();
    isConnected.dispose();
  }
}
