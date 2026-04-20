import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:unflappable/features/widgets/Common/error_dialog.dart';

class NetworkStatusService {
  static final Connectivity _connectivity = Connectivity();

  /// Returns true when the device has an active connection.
  static Future<bool> isConnected() async {
    final result = await _connectivity.checkConnectivity();
    return result != ConnectivityResult.none;
  }

  /// Checks connectivity and shows an error dialog when disconnected.
  /// Returns true when the device is connected.
  static Future<bool> checkAndShowDialog(BuildContext context) async {
    final connected = await isConnected();
    if (connected) {
      return true;
    }

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Center(
          child: ErrorDialog(
            title: 'No internet connection',
            message:
                'Please connect to the internet and try again.',
            onTryAgain: () async {
              Navigator.of(context).pop();
              await checkAndShowDialog(context);
            },
          ),
        );
      },
    );
    return false;
  }
}
