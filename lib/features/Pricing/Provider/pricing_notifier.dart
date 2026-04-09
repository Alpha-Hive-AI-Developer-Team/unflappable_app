import 'package:unflappable/export.dart';
import 'package:unflappable/features/Auth/providers/user_notifier.dart';
import 'package:unflappable/features/Pricing/Provider/pricing_state.dart';

class PricingPlansNotifier extends Notifier<PricingPlansState> {
  @override
  PricingPlansState build() => const PricingPlansState();

  void setBillingCycle(BillingCycle cycle) {
    state = state.copyWith(billingCycle: cycle);
  }

  Future<void> upgrade() async {
    if (state.isLoading) return;

    state = state.copyWith(status: PricingStatus.loading);

    try {
      // Delegates to UserNotifier which handles the API call + user state update
      await ref.read(userProvider.notifier).updateProStatus(true);

      final userState = ref.read(userProvider);

      if (userState.isPro) {
        state = state.copyWith(status: PricingStatus.success);
      } else {
        // UserNotifier set an error
        state = state.copyWith(
          status: PricingStatus.failure,
          errorMessage:
              userState.errorMessage ?? 'Purchase failed. Please try again.',
        );
      }
    } catch (e) {
      state = state.copyWith(
        status: PricingStatus.failure,
        errorMessage: e.toString(),
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
