import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:unflappable/export.dart';
import 'package:unflappable/features/Auth/providers/user_notifier.dart';
import 'package:unflappable/features/Pricing/Provider/pricing_state.dart';
import 'package:unflappable/features/Subscription/apple_receipt.dart';
import 'package:unflappable/features/Subscription/models/subscription_models.dart';
import 'package:unflappable/service/subscription_service.dart';

class PricingPlansNotifier extends Notifier<PricingPlansState> {
  @override
  PricingPlansState build() => const PricingPlansState();

  void _syncBillingCycleFromActiveSubscription() {
    final user = ref.read(userProvider).user;
    if (user == null || !user.isPro) return;
    if (!ProProductIds.isYearlyProductId(user.proProductId)) return;
    if (state.billingCycle == BillingCycle.yearly) return;
    state = state.copyWith(billingCycle: BillingCycle.yearly);
  }

  void setBillingCycle(BillingCycle cycle) {
    final user = ref.read(userProvider).user;
    if (cycle == BillingCycle.monthly &&
        user != null &&
        user.isPro &&
        ProProductIds.isYearlyProductId(user.proProductId)) {
      return;
    }
    state = state.copyWith(billingCycle: cycle);
  }

  Future<void> loadPlans() async {
    _syncBillingCycleFromActiveSubscription();
    if (state.plans != null) return;

    state = state.copyWith(clearPlansError: true);

    try {
      final plans = await SubscriptionService.fetchPlans();
      state = state.copyWith(plans: plans, plansLoadError: null);
      _syncBillingCycleFromActiveSubscription();
    } catch (e) {
      state = state.copyWith(plansLoadError: e.toString());
    }
  }

  /// Call after logout or when forcing a refresh of catalog copy and product IDs.
  void resetPlansCache() {
    state = state.copyWith(clearPlans: true, clearPlansError: true);
  }

  Future<void> upgrade() async {
    if (state.isLoading || state.isRestoring) return;

    final userState = ref.read(userProvider);
    if (!userState.isAuthenticated || userState.user == null) {
      state = state.copyWith(
        status: PricingStatus.failure,
        errorMessage:
            'Sign in to your Unflappable account first (email/password or '
            'Sign in with Apple on the Log In screen). Then open Manage again '
            'and tap Upgrade — the Apple payment sheet will appear for Pro. '
            'Your Unflappable account is what links the purchase to this app; '
            'Apple ID alone is not enough.',
      );
      return;
    }

    state = state.copyWith(
      status: PricingStatus.loading,
      clearErrorMessage: true,
    );

    try {
      _syncBillingCycleFromActiveSubscription();
      final userAfterSync = ref.read(userProvider).user;
      if (userAfterSync != null &&
          userAfterSync.isPro &&
          ProProductIds.isYearlyProductId(userAfterSync.proProductId) &&
          !state.isYearly) {
        state = state.copyWith(
          status: PricingStatus.failure,
          errorMessage:
              'You already have Pro Yearly. Monthly billing is not available '
              'for your account. Use App Store subscription settings if you '
              'need to change plans.',
        );
        return;
      }

      if (state.plans == null) {
        final fetched = await SubscriptionService.fetchPlans();
        state = state.copyWith(plans: fetched);
      }
      final plans = state.plans;
      if (plans == null) {
        throw StateError('Unable to load subscription plans.');
      }

      final storeKitIds = _appleStoreKitProductIds(plans.pro.productIds);
      final productId = state.isYearly
          ? storeKitIds.yearly
          : storeKitIds.monthly;
      if (productId.isEmpty) {
        throw StateError('Missing subscription product id from server.');
      }

      final iap = InAppPurchase.instance;
      if (!await iap.isAvailable()) {
        throw StateError('Store is not available. Please try again later.');
      }

      final response = await iap.queryProductDetails({productId});
      if (response.error != null) {
        throw StateError(response.error!.message);
      }
      if (response.productDetails.isEmpty) {
        throw StateError(
          'Product "$productId" was not found in the App Store. '
          'Check App Store Connect and the signed bundle id.',
        );
      }

      final productDetails = response.productDetails.first;
      final purchaseDetails = await _waitForPurchase(
        iap: iap,
        productId: productId,
        triggerPurchase: () => iap.buyNonConsumable(
          purchaseParam: PurchaseParam(productDetails: productDetails),
        ),
      );

      final receiptData = await loadAppleReceiptDataForBackend();
      await SubscriptionService.verify(receiptData: receiptData);
      await InAppPurchase.instance.completePurchase(purchaseDetails);

      await ref.read(userProvider.notifier).syncSubscriptionFromApi();
      _syncBillingCycleFromActiveSubscription();

      final updated = ref.read(userProvider);
      if (updated.isPro) {
        state = state.copyWith(status: PricingStatus.success);
      } else {
        state = state.copyWith(
          status: PricingStatus.failure,
          errorMessage:
              'Purchase completed but Pro was not activated. '
              'Pull to refresh or contact support.',
        );
      }
    } catch (e) {
      state = state.copyWith(
        status: PricingStatus.failure,
        errorMessage: _formatError(e),
      );
    }
  }

  Future<void> restorePurchases() async {
    if (state.isLoading || state.isRestoring) return;

    final userState = ref.read(userProvider);
    if (!userState.isAuthenticated || userState.user == null) {
      state = state.copyWith(
        status: PricingStatus.failure,
        errorMessage:
            'Sign in to your Unflappable account first, then use Restore purchases. '
            'Use the same email (or Apple) you used when you subscribed.',
      );
      return;
    }

    state = state.copyWith(isRestoring: true, clearErrorMessage: true);

    try {
      _syncBillingCycleFromActiveSubscription();
      final iap = InAppPurchase.instance;
      if (!await iap.isAvailable()) {
        throw StateError('Store is not available. Please try again later.');
      }

      await iap.restorePurchases();
      await Future<void>.delayed(const Duration(milliseconds: 600));

      final receiptData = await loadAppleReceiptDataForBackend();
      await SubscriptionService.restore(receiptData: receiptData);
      await ref.read(userProvider.notifier).syncSubscriptionFromApi();
      _syncBillingCycleFromActiveSubscription();

      final updated = ref.read(userProvider);
      if (!updated.isPro) {
        throw StateError('No active Pro subscription found for this Apple ID.');
      }

      state = state.copyWith(status: PricingStatus.success, isRestoring: false);
    } catch (e) {
      state = state.copyWith(
        status: PricingStatus.failure,
        errorMessage: _formatError(e),
        isRestoring: false,
      );
    }
  }

  void clearError() {
    state = state.copyWith(status: PricingStatus.idle, clearErrorMessage: true);
  }

  static ProProductIds _appleStoreKitProductIds(ProProductIds raw) {
    if (kIsWeb) return raw;
    switch (defaultTargetPlatform) {
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
        return raw.forAppleStoreKit();
      default:
        return raw;
    }
  }

  static String _formatError(Object e) {
    if (e is IAPError) {
      return e.message;
    }
    if (e is DioException) {
      final data = e.response?.data;
      if (data is Map) {
        final msg = data['message'];
        final appleStatus = data['appleStatus'];
        if (msg is String && msg.trim().isNotEmpty) {
          if (appleStatus != null) {
            final hint = _appleReceiptStatusHint(appleStatus);
            if (hint != null) {
              return '$msg\n\n$hint';
            }
            return '$msg (Apple status $appleStatus)';
          }
          return msg;
        }
      }
      return e.message ?? e.toString();
    }
    return e.toString();
  }

  /// https://developer.apple.com/documentation/appstorereceipts/status
  static String? _appleReceiptStatusHint(Object code) {
    final n = code is num ? code.toInt() : int.tryParse(code.toString());
    switch (n) {
      case 21004:
        return 'The App Store shared secret on the server does not match '
            'App Store Connect (or the receipt was validated with the wrong '
            'environment). Fix backend env APPLE_SHARED_SECRET and sandbox '
            'vs production verify URL.';
      case 21007:
        return 'This is a sandbox receipt; the server must validate it '
            "against Apple's sandbox verifyReceipt endpoint.";
      case 21008:
        return 'This is a production receipt; the server must use the '
            'production verifyReceipt endpoint.';
      default:
        return null;
    }
  }

  static Future<PurchaseDetails> _waitForPurchase({
    required InAppPurchase iap,
    required String productId,
    required Future<bool> Function() triggerPurchase,
  }) async {
    final completer = Completer<PurchaseDetails>();
    late final StreamSubscription<List<PurchaseDetails>> sub;

    sub = iap.purchaseStream.listen((purchases) {
      for (final p in purchases) {
        if (p.productID != productId) continue;
        switch (p.status) {
          case PurchaseStatus.pending:
            break;
          case PurchaseStatus.purchased:
          case PurchaseStatus.restored:
            if (!completer.isCompleted) completer.complete(p);
            break;
          case PurchaseStatus.error:
            if (!completer.isCompleted) {
              completer.completeError(
                p.error ?? StateError('Purchase failed.'),
              );
            }
            break;
          case PurchaseStatus.canceled:
            if (!completer.isCompleted) {
              completer.completeError(StateError('Purchase was canceled.'));
            }
            break;
        }
      }
    }, onError: completer.completeError);

    // Let the StoreKit broadcast stream attach before starting the sheet
    // (avoids rare missed updates right after listen).
    await Future<void>.delayed(Duration.zero);

    try {
      final started = await triggerPurchase();
      if (!started) {
        throw StateError('Unable to start purchase.');
      }
      return await completer.future.timeout(
        const Duration(minutes: 2),
        onTimeout: () =>
            throw TimeoutException('Purchase timed out. Please try again.'),
      );
    } finally {
      await sub.cancel();
    }
  }
}

final pricingPlansProvider =
    NotifierProvider<PricingPlansNotifier, PricingPlansState>(
      PricingPlansNotifier.new,
    );
