import 'package:flutter/material.dart';
import '../services/connectivity_service.dart';
import '../views/network/network_error_screen.dart';

/// Wraps the entire [MaterialApp] child tree and shows a full-screen
/// [NetworkErrorScreen] overlay whenever the device is offline.
///
/// When the connection is restored the overlay automatically disappears
/// and the user is returned to exactly where they left off.
class ConnectivityWrapper extends StatelessWidget {
  final Widget child;

  const ConnectivityWrapper({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: ConnectivityService.instance.isConnected,
      builder: (context, isConnected, _) {
        return Stack(
          children: [
            // The actual app content is always in the tree so that state
            // is preserved while the error screen is showing.
            child,

            // Slide the error screen over when offline
            if (!isConnected)
              const Positioned.fill(
                child: NetworkErrorScreen(),
              ),
          ],
        );
      },
    );
  }
}
