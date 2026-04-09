enum PricingStatus { idle, loading, success, failure }

enum BillingCycle { monthly, yearly }

class PricingPlansState {
  final BillingCycle billingCycle;
  final PricingStatus status;
  final String? errorMessage;

  const PricingPlansState({
    this.billingCycle = BillingCycle.monthly,
    this.status = PricingStatus.idle,
    this.errorMessage,
  });

  bool get isYearly => billingCycle == BillingCycle.yearly;
  bool get isLoading => status == PricingStatus.loading;
  bool get showFailureOverlay => status == PricingStatus.failure;

  String get price => isYearly ? r'$19/mth' : r'$24/mth';
  String get billingLabel => isYearly ? 'Billed annually.' : 'Billed monthly.';

  PricingPlansState copyWith({
    BillingCycle? billingCycle,
    PricingStatus? status,
    String? errorMessage,
  }) => PricingPlansState(
    billingCycle: billingCycle ?? this.billingCycle,
    status: status ?? this.status,
    errorMessage: errorMessage ?? this.errorMessage,
  );
}
