import 'package:dio/dio.dart';
import 'package:unflappable/features/Subscription/Models/subscription_plan.dart';
import 'package:unflappable/features/Subscription/Models/subscription_status.dart';
import 'package:unflappable/service/dio_helper.dart';
import 'package:unflappable/service/endpoint/endpoint.dart';

abstract final class SubscriptionService {
  /// Fetches available subscription plans
  /// Returns: { "free": {...}, "pro": {...} }
  static Future<Response> getSubscriptionPlans() async {
    return DioHelper.getData(
      endPoint: EndPoints.subscription.plans,
    );
  }

  /// Fetches the current user's subscription status
  /// Returns subscription plan, pro status, entitlements
  static Future<Response> getSubscriptionStatus() async {
    return DioHelper.getData(
      endPoint: EndPoints.subscription.status,
    );
  }

  /// Verifies an Apple App Store receipt
  /// [receiptData] - Base64 encoded receipt string from Apple
  static Future<Response> verifyReceipt(String receiptData) async {
    return DioHelper.postData(
      endPoint: EndPoints.subscription.verify,
      data: {
        'receiptData': receiptData,
      },
    );
  }

  /// Restores previous purchases using Apple receipt
  /// [receiptData] - Base64 encoded receipt string from Apple
  static Future<Response> restorePurchases(String receiptData) async {
    return DioHelper.postData(
      endPoint: EndPoints.subscription.restore,
      data: {
        'receiptData': receiptData,
      },
    );
  }

  /// Parses subscription plans from API response
  static Map<String, SubscriptionPlan> parsePlans(
    Map<String, dynamic> data,
  ) {
    final plans = <String, SubscriptionPlan>{};
    final planData = data['data'] ?? data;

    if (planData is Map<String, dynamic>) {
      for (final entry in planData.entries) {
        try {
          if (entry.value is Map<String, dynamic>) {
            final plan = SubscriptionPlan.fromJson(
              entry.key,
              entry.value as Map<String, dynamic>,
            );
            plans[entry.key] = plan;
          }
        } catch (_) {
          // Skip invalid plans
        }
      }
    }

    return plans;
  }

  /// Parses subscription status from API response
  static SubscriptionStatus parseStatus(Map<String, dynamic> data) {
    final statusData = data['data'] as Map<String, dynamic>? ?? data;
    return SubscriptionStatus.fromJson(
      Map<String, dynamic>.from(statusData),
    );
  }
}
