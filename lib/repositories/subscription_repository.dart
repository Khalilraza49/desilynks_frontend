import 'dart:convert';
import '../services/api/api_endpoints.dart';
import '../services/api/api_service.dart';

class SubscriptionPlan {
  final String id;
  final String title;
  final String price;
  final String billingPeriod;
  final String description;
  final List<String> features;
  final bool isPopular;

  SubscriptionPlan({
    required this.id,
    required this.title,
    required this.price,
    required this.billingPeriod,
    required this.description,
    required this.features,
    this.isPopular = false,
  });

  factory SubscriptionPlan.fromJson(Map<String, dynamic> json) {
    return SubscriptionPlan(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      price: json['price'] as String? ?? '€0',
      billingPeriod: json['billingPeriod'] as String? ?? '/month',
      description: json['description'] as String? ?? '',
      features:
          (json['features'] as List?)?.map((e) => e.toString()).toList() ?? [],
      isPopular: json['isPopular'] as bool? ?? false,
    );
  }
}

class SubscriptionRepository {
  final ApiService _apiService;

  SubscriptionRepository(this._apiService);

  /// Fetch Available Membership & Boost Plans
  Future<List<SubscriptionPlan>> getPlans() async {
    try {
      final response = await _apiService.get(
        ApiEndpoints.subscriptionsEndpoint,
      );
      final Map<String, dynamic> resBody = jsonDecode(response.body);
      final List<dynamic> dataList = resBody['data'] as List? ?? [];
      return dataList
          .map((e) => SubscriptionPlan.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  /// Process Subscription / Boost Plan Checkout
  Future<bool> processCheckout({
    required String planId,
    required String paymentMethod,
    String? couponCode,
    String? targetAdId,
  }) async {
    final response = await _apiService.post(ApiEndpoints.checkoutEndpoint, {
      'planId': planId,
      'paymentMethod': paymentMethod,
      if (couponCode != null && couponCode.isNotEmpty) 'couponCode': couponCode,
      if (targetAdId != null && targetAdId.isNotEmpty) 'targetAdId': targetAdId,
    });

    final Map<String, dynamic> resBody = jsonDecode(response.body);
    return resBody['success'] as bool? ?? true;
  }
}
