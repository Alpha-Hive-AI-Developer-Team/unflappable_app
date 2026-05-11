import 'package:unflappable/features/Subscription/Models/subscription_plan.dart';
import 'package:unflappable/features/Subscription/Models/subscription_status.dart';

enum SubscriptionFetchStatus {
  initial,
  loading,
  success,
  error,
}

class SubscriptionState {
  final SubscriptionFetchStatus status;
  final Map<String, SubscriptionPlan> plans;
  final SubscriptionStatus? currentStatus;
  final String? errorMessage;
  final bool hasLoadedInitialData;

  const SubscriptionState({
    this.status = SubscriptionFetchStatus.initial,
    this.plans = const {},
    this.currentStatus,
    this.errorMessage,
    this.hasLoadedInitialData = false,
  });

  bool get isLoading => status == SubscriptionFetchStatus.loading;
  bool get hasError => status == SubscriptionFetchStatus.error;
  bool get isPro => currentStatus?.isPro ?? false;
  bool get hasProPlan => plans.containsKey('pro');
  bool get hasFreePlan => plans.containsKey('free');

  SubscriptionPlan? get freePlan => plans['free'];
  SubscriptionPlan? get proPlan => plans['pro'];

  SubscriptionState copyWith({
    SubscriptionFetchStatus? status,
    Map<String, SubscriptionPlan>? plans,
    SubscriptionStatus? currentStatus,
    String? errorMessage,
    bool? hasLoadedInitialData,
  }) =>
      SubscriptionState(
        status: status ?? this.status,
        plans: plans ?? this.plans,
        currentStatus: currentStatus ?? this.currentStatus,
        errorMessage: errorMessage ?? this.errorMessage,
        hasLoadedInitialData: hasLoadedInitialData ?? this.hasLoadedInitialData,
      );
}
