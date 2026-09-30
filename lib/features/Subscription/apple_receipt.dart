// PRO FEATURE — disabled for the current free-only release.
// Commented out (not deleted) so it can be restored when the Pro tier
// relaunches. Conditional export for `loadAppleReceiptDataForBackend`
// (apple_receipt_io.dart on native platforms, apple_receipt_stub.dart
// elsewhere). Only consumer was pricing_notifier.dart, which is disabled too.
// export 'apple_receipt_stub.dart'
//     if (dart.library.io) 'apple_receipt_io.dart';
