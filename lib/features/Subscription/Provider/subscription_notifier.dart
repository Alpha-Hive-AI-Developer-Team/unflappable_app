import 'package:dio/dio.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:unflappable/features/Subscription/Provider/subscription_state.dart';
import 'package:unflappable/service/in_app_purchase/in_app_purchase_service.dart';
import 'package:unflappable/service/subscription_service.dart';

class SubscriptionNotifier extends StateNotifier<SubscriptionState> {
  SubscriptionNotifier() : super(const SubscriptionState());

  /// Load subscription plans and current user status
  Future<void> loadInitialData() async {
    if (state.hasLoadedInitialData &&
        state.status == SubscriptionFetchStatus.success) {
      return;
    }

    state = state.copyWith(status: SubscriptionFetchStatus.loading);

    try {
      // Load plans and status in parallel
      final [plansResponse, statusResponse] = await Future.wait([
        SubscriptionService.getSubscriptionPlans(),
        SubscriptionService.getSubscriptionStatus(),
      ]);

      final plans = SubscriptionService.parsePlans(
        plansResponse.data as Map<String, dynamic>,
      );
      final status = SubscriptionService.parseStatus(
        statusResponse.data as Map<String, dynamic>,
      );

      state = state.copyWith(
        status: SubscriptionFetchStatus.success,
        plans: plans,
        currentStatus: status,
        errorMessage: null,
        hasLoadedInitialData: true,
      );
    } on DioException catch (e) {
      state = state.copyWith(
        status: SubscriptionFetchStatus.error,
        errorMessage: _dioErrorMessage(e),
      );
    } catch (e) {
      state = state.copyWith(
        status: SubscriptionFetchStatus.error,
        errorMessage: 'Failed to load subscription data: $e',
      );
    }
  }

  /// Refresh subscription status (call after purchase)
  Future<void> refreshStatus() async {
    try {
      final response = await SubscriptionService.getSubscriptionStatus();
      final status = SubscriptionService.parseStatus(
        response.data as Map<String, dynamic>,
      );

      state = state.copyWith(
        currentStatus: status,
        status: SubscriptionFetchStatus.success,
        errorMessage: null,
      );
    } on DioException catch (e) {
      state = state.copyWith(
        status: SubscriptionFetchStatus.error,
        errorMessage: _dioErrorMessage(e),
      );
    } catch (e) {
      state = state.copyWith(
        status: SubscriptionFetchStatus.error,
        errorMessage: 'Failed to refresh subscription status: $e',
      );
    }
  }

  /// Process a purchase and verify with backend
  Future<void> processPurchase(
    PurchaseDetails purchase,
    InAppPurchaseService iapService,
  ) async {
    try {
      // Get receipt data
      final receipt = await iapService.getReceiptData(purchase);

      if (receipt.isEmpty) {
        throw Exception('Failed to get receipt data');
      }

      // Verify with backend
      final response = await SubscriptionService.verifyReceipt(receipt);

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Mark purchase as complete
        await iapService.completePurchase(purchase);

        // Refresh subscription status
        await refreshStatus();
      } else {
        throw Exception('Receipt verification failed');
      }
    } catch (e) {
      state = state.copyWith(
        status: SubscriptionFetchStatus.error,
        errorMessage: 'Purchase verification failed: $e',
      );
      rethrow;
    }
  }

  Future<void> restorePurchases(InAppPurchaseService iapService) async {
    state = state.copyWith(status: SubscriptionFetchStatus.loading);

    try {
      await iapService.restorePurchases();
    } catch (e) {
      state = state.copyWith(
        status: SubscriptionFetchStatus.error,
        errorMessage: 'Failed to restore purchases: $e',
      );

      rethrow;
    }
  }

  /// Get product details by ID
  ProductDetails? getProductById(String productId) {
    // This would be used if we store products in the state
    // For now, it's handled by InAppPurchaseService
    return null;
  }

  String _dioErrorMessage(DioException e) {
    return e.message ?? 'Network error occurred';
  }
}

final subscriptionProvider =
    StateNotifierProvider<SubscriptionNotifier, SubscriptionState>(
      (ref) => SubscriptionNotifier(),
    );
