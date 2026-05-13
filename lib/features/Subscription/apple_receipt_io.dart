import 'dart:io';

import 'package:in_app_purchase_storekit/store_kit_wrappers.dart';

Future<String> loadAppleReceiptDataForBackend() async {
  if (!Platform.isIOS) {
    throw UnsupportedError(
      'Apple receipt verification is only supported on iOS.',
    );
  }
  var receipt = await SKReceiptManager.retrieveReceiptData();
  if (receipt.isEmpty) {
    await SKRequestMaker().startRefreshReceiptRequest();
    receipt = await SKReceiptManager.retrieveReceiptData();
  }
  if (receipt.isEmpty) {
    throw StateError(
      'Missing App Store receipt. Try again from a device with the App Store.',
    );
  }
  return receipt;
}
