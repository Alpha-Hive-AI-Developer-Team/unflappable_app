import 'package:unflappable/features/Subscription/models/subscription_models.dart';

enum PricingStatus { idle, loading, success, failure }

enum BillingCycle { monthly, yearly }

class PricingPlansState {
  final BillingCycle billingCycle;
  final PricingStatus status;
  final String? errorMessage;
  final SubscriptionPlansPayload? plans;
  final String? plansLoadError;
  final bool isRestoring;

  const PricingPlansState({
    this.billingCycle = BillingCycle.monthly,
    this.status = PricingStatus.idle,
    this.errorMessage,
    this.plans,
    this.plansLoadError,
    this.isRestoring = false,
  });

  bool get isYearly => billingCycle == BillingCycle.yearly;
  bool get isLoading => status == PricingStatus.loading;
  bool get showFailureOverlay => status == PricingStatus.failure;
  bool get hasPlans => plans != null;

  /// Shown when [showFailureOverlay] is true — distinguishes auth gating from StoreKit.
  String get failureDialogTitle {
    final msg = errorMessage;
    if (msg != null && msg.contains('Unflappable account')) {
      return 'Account required';
    }
    return 'Purchase Failure';
  }

  /// Log in / sign up with email (or Apple on the login screen), then return here for IAP.
  bool get showLoginFromPricingFailure =>
      errorMessage?.contains('Unflappable account') ?? false;

  String get price {
    final pro = plans?.pro;
    if (pro != null) {
      if (isYearly) {
        return pro.yearlyMonthlyEquivalent ?? pro.yearlyPrice ?? r'$19/mth';
      }
      return pro.monthlyPrice ?? r'$24/mth';
    }
    return isYearly ? r'$19/mth' : r'$24/mth';
  }

  String get billingLabel {
    if (isYearly) {
      final y = plans?.pro.yearlyPrice;
      if (y != null && y.isNotEmpty) {
        return '$y when billed annually.';
      }
      return 'Billed annually.';
    }
    return 'Billed monthly.';
  }

  PricingPlansState copyWith({
    BillingCycle? billingCycle,
    PricingStatus? status,
    String? errorMessage,
    SubscriptionPlansPayload? plans,
    String? plansLoadError,
    bool? isRestoring,
    bool clearErrorMessage = false,
    bool clearPlansError = false,
    bool clearPlans = false,
  }) => PricingPlansState(
    billingCycle: billingCycle ?? this.billingCycle,
    status: status ?? this.status,
    errorMessage: clearErrorMessage
        ? null
        : (errorMessage ?? this.errorMessage),
    plans: clearPlans ? null : (plans ?? this.plans),
    plansLoadError: clearPlansError
        ? null
        : (plansLoadError ?? this.plansLoadError),
    isRestoring: isRestoring ?? this.isRestoring,
  );
}
