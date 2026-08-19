import 'dart:convert';

class SubscriptionModel {
  final List<String> commonFeatures;
  final Map<String, PlanConfig> plans;

  SubscriptionModel({required this.commonFeatures, required this.plans});

  factory SubscriptionModel.fromJson(Map<String, dynamic> json) {
    return SubscriptionModel(
      commonFeatures: List<String>.from(json['common_features'] ?? []),
      plans: (json['plans'] as Map<String, dynamic>).map(
        (key, value) => MapEntry(key, PlanConfig.fromJson(value)),
      ),
    );
  }

  static SubscriptionModel fromString(String source) {
    return SubscriptionModel.fromJson(jsonDecode(source));
  }
}

class PlanConfig {
  final String badge;
  final String bonusCoins;
  final String discountText;
  final String validity;

  PlanConfig({
    required this.badge,
    required this.bonusCoins,
    required this.discountText,
    required this.validity,
  });

  factory PlanConfig.fromJson(Map<String, dynamic> json) {
    return PlanConfig(
      badge: json['badge'] ?? '',
      bonusCoins: json['bonus_coins'] ?? '',
      discountText: json['discount_text'] ?? '',
      validity: json['validity'] ?? '',
    );
  }
}
