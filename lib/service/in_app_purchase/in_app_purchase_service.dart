import 'dart:async';
import 'dart:io';

import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:in_app_purchase_storekit/in_app_purchase_storekit.dart';
import 'package:in_app_purchase_storekit/store_kit_wrappers.dart';

class InAppPurchaseService {
  static final InAppPurchaseService _instance =
      InAppPurchaseService._internal();

  factory InAppPurchaseService() => _instance;

  InAppPurchaseService._internal();

  final InAppPurchase _iap = InAppPurchase.instance;

  StreamSubscription<List<PurchaseDetails>>? _subscription;

  bool _isAvailable = false;

  List<ProductDetails> _products = [];

  bool get isAvailable => _isAvailable;

  List<ProductDetails> get products => _products;

  /// Initialize In-App Purchase
  Future<void> initialize({
    required Function(PurchaseDetails purchase) onPurchaseUpdate,
    required Function(String error) onError,
  }) async {
    try {
      /// Check availability
      _isAvailable = await _iap.isAvailable();

      if (!_isAvailable) {
        onError("In-app purchases are not available");
        return;
      }

      /// iOS specific delegate
      if (Platform.isIOS) {
        final iosPlatformAddition = _iap
            .getPlatformAddition<InAppPurchaseStoreKitPlatformAddition>();

        await iosPlatformAddition.setDelegate(PaymentQueueDelegate());
      }

      /// Listen to purchase updates
      _subscription = _iap.purchaseStream.listen(
        (List<PurchaseDetails> purchases) {
          for (final purchase in purchases) {
            onPurchaseUpdate(purchase);
          }
        },
        onError: (error) {
          onError(error.toString());
        },
        onDone: () {
          _subscription?.cancel();
        },
      );
    } catch (e) {
      onError('Failed to initialize in-app purchases: $e');
    }
  }

  /// Load products from App Store / Play Store
  Future<void> loadProducts(List<String> productIds) async {
    if (!_isAvailable) {
      throw Exception('In-app purchases are not available');
    }

    try {
      final response = await _iap.queryProductDetails(productIds.toSet());

      if (response.error != null) {
        throw Exception(response.error!.message);
      }

      if (response.productDetails.isEmpty) {
        throw Exception(
          'No products found. Check product IDs in App Store Connect.',
        );
      }

      _products = response.productDetails;
    } catch (e) {
      throw Exception('Failed to load products: $e');
    }
  }

  /// Buy subscription product
  Future<void> buyProduct(ProductDetails product) async {
    if (!_isAvailable) {
      throw Exception('In-app purchases are not available');
    }

    try {
      final PurchaseParam purchaseParam = PurchaseParam(
        productDetails: product,
      );

      /// Flutter uses buyNonConsumable for subscriptions
      await _iap.buyNonConsumable(purchaseParam: purchaseParam);
    } catch (e) {
      throw Exception('Failed to purchase product: $e');
    }
  }

  /// Restore previous purchases
  Future<void> restorePurchases() async {
    if (!_isAvailable) {
      throw Exception('In-app purchases are not available');
    }

    try {
      await _iap.restorePurchases();
    } catch (e) {
      throw Exception('Failed to restore purchases: $e');
    }
  }

  /// Complete purchase transaction
  Future<void> completePurchase(PurchaseDetails purchase) async {
    try {
      if (purchase.pendingCompletePurchase) {
        await _iap.completePurchase(purchase);
      }
    } catch (e) {
      throw Exception('Failed to complete purchase: $e');
    }
  }

  /// Get receipt data from purchase
  String getReceiptData(PurchaseDetails purchase) {
    return purchase.verificationData.serverVerificationData;
  }

  /// Dispose stream
  void dispose() {
    _subscription?.cancel();
  }
}

/// iOS payment queue delegate
class PaymentQueueDelegate implements SKPaymentQueueDelegateWrapper {
  @override
  bool shouldContinueTransaction(
    SKPaymentTransactionWrapper transaction,
    SKStorefrontWrapper storefront,
  ) {
    return true;
  }

  @override
  bool shouldShowPriceConsent() {
    return false;
  }
}
