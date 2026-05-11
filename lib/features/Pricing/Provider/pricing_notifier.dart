import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:unflappable/export.dart';
import 'package:unflappable/features/Pricing/Provider/pricing_state.dart';
import 'package:unflappable/features/Subscription/Provider/subscription_notifier.dart';
import 'package:unflappable/service/in_app_purchase/in_app_purchase_service.dart';

class PricingPlansNotifier extends Notifier<PricingPlansState> {
  late InAppPurchaseService _iapService;

  @override
  PricingPlansState build() {
    _iapService = InAppPurchaseService();
    return const PricingPlansState();
  }

  void setBillingCycle(BillingCycle cycle) {
    state = state.copyWith(billingCycle: cycle);
  }

  /// Main upgrade method called from the UI
  /// This is called when user clicks "Upgrade" button
  Future<void> upgrade() async {
    if (state.isLoading) return;

    state = state.copyWith(status: PricingStatus.loading);

    try {
      final subscriptionState = ref.read(subscriptionProvider);
      final proPlan = subscriptionState.proPlan;

      if (proPlan?.productIds == null) {
        throw Exception('Pro plan not available');
      }

      // Select product ID based on billing cycle
      final productId = state.isYearly
          ? proPlan!.productIds!['yearly']
          : proPlan!.productIds!['monthly'];

      if (productId == null) {
        throw Exception('Product ID not found for selected billing cycle');
      }

      // Load products first if not already loaded
      await loadProducts();

      // Find and purchase the product
      final product = _iapService.products.firstWhere(
        (p) => p.id == productId,
        orElse: () => throw Exception('Product not found: $productId'),
      );

      await _iapService.buyProduct(product);

      // The purchase stream will handle the rest
      state = state.copyWith(status: PricingStatus.idle);
    } catch (e) {
      state = state.copyWith(
        status: PricingStatus.failure,
        errorMessage: e.toString(),
      );
    }
  }

  /// Load available products from App Store
  Future<void> loadProducts() async {
    if (state.isLoading) return;

    state = state.copyWith(status: PricingStatus.loading);

    try {
      final subscriptionState = ref.read(subscriptionProvider);

      // Get product IDs from subscription plans
      final productIds = <String>[];
      final proPlan = subscriptionState.proPlan;

      if (proPlan?.productIds != null) {
        productIds.addAll(proPlan!.productIds!.values);
      }

      if (productIds.isEmpty) {
        throw Exception('No product IDs available');
      }

      await _iapService.loadProducts(productIds);
      state = state.copyWith(status: PricingStatus.idle);
    } catch (e) {
      state = state.copyWith(
        status: PricingStatus.failure,
        errorMessage: 'Failed to load pricing: $e',
      );
    }
  }

  /// Purchase a subscription product
  Future<void> purchaseProduct(String productId) async {
    if (state.isLoading) return;

    state = state.copyWith(status: PricingStatus.loading);

    try {
      final product = _iapService.products.firstWhere(
        (p) => p.id == productId,
        orElse: () => throw Exception('Product not found'),
      );

      await _iapService.buyProduct(product);
    } catch (e) {
      state = state.copyWith(
        status: PricingStatus.failure,
        errorMessage: 'Failed to start purchase: $e',
      );
    }
  }

  /// Verify purchase and update subscription status
  Future<void> verifyAndUpdateSubscription(PurchaseDetails purchase) async {
    state = state.copyWith(status: PricingStatus.loading);

    try {
      final subscriptionNotifier = ref.read(subscriptionProvider.notifier);

      // Process the purchase with backend verification
      await subscriptionNotifier.processPurchase(purchase, _iapService);

      // If successful, the subscription status will be updated
      final updatedState = ref.read(subscriptionProvider);

      if (updatedState.isPro) {
        state = state.copyWith(status: PricingStatus.success);
      } else {
        state = state.copyWith(
          status: PricingStatus.failure,
          errorMessage: 'Purchase verification failed',
        );
      }
    } catch (e) {
      state = state.copyWith(
        status: PricingStatus.failure,
        errorMessage: 'Purchase verification failed: $e',
      );
    }
  }

  /// Restore previous purchases
  Future<void> restorePurchases() async {
    if (state.isLoading) return;

    state = state.copyWith(status: PricingStatus.loading);

    try {
      final subscriptionNotifier = ref.read(subscriptionProvider.notifier);

      await subscriptionNotifier.restorePurchases(_iapService);

      final updatedState = ref.read(subscriptionProvider);

      if (updatedState.isPro) {
        state = state.copyWith(status: PricingStatus.success);
      } else {
        state = state.copyWith(status: PricingStatus.idle, errorMessage: null);
      }
    } catch (e) {
      state = state.copyWith(
        status: PricingStatus.failure,
        errorMessage: 'Failed to restore purchases: $e',
      );
    }
  }

  void clearError() {
    state = state.copyWith(status: PricingStatus.idle, errorMessage: null);
  }
}

// ---------------------------------------------------------------------------
// Provider
// ---------------------------------------------------------------------------

final pricingPlansProvider =
    NotifierProvider<PricingPlansNotifier, PricingPlansState>(
      PricingPlansNotifier.new,
    );
