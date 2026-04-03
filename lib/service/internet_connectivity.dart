import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';

// class NetworkStatusService {
//   // Singleton
//   static final NetworkStatusService _instance =
//       NetworkStatusService._internal();
//   factory NetworkStatusService() => _instance;
//   NetworkStatusService._internal() {
//     _init();
//   }

//   final ValueNotifier<bool> hasConnection = ValueNotifier<bool>(true);
//   late StreamSubscription _subscription;

//   void _init() {
//     _subscription = Connectivity().onConnectivityChanged.listen((status) {
//       hasConnection.value = status != ConnectivityResult.none;
//     });

//     // Check initial status once
//     Connectivity().checkConnectivity().then((status) {
//       hasConnection.value = status != ConnectivityResult.none;
//     });
//   }

//   void dispose() {
//     _subscription.cancel();
//   }
// }
class NetworkStatusService {
  static final Connectivity _connectivity = Connectivity();
  static Stream<List<ConnectivityResult>> get connectivityStream =>
      _connectivity.onConnectivityChanged;

  static Future<bool> isConnected() async {
    final result = await _connectivity.checkConnectivity();
    return !result.contains(ConnectivityResult.none);
  }
}
