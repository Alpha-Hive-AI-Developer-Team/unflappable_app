// PRO FEATURE — disabled for the current free-only release.
// Commented out (not deleted) so it can be restored when the Pro tier
// relaunches. Only consumer was pricing_notifier.dart via apple_receipt.dart.
/*
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
*/
