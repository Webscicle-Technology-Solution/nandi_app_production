class Subscription {
  final String id;
  final String userId;
  final SubscriptionType subscriptionType;
  final String endDate;
  final String status;
  final String? paymentId;
  final String startDate;

  Subscription({
    required this.id,
    required this.userId,
    required this.subscriptionType,
    required this.endDate,
    required this.status,
    required this.startDate,
    this.paymentId,
  });

  factory Subscription.fromJson(Map<String, dynamic> json) {
    return Subscription(
      id: json["_id"] ?? "", // Default to empty string if null
      userId: json["user"] ?? "", // Default to empty string if null
      subscriptionType: SubscriptionType.fromJson(json["subscriptionType"] ?? {}),
      endDate: json["endDate"] ?? "", // Default to empty string if null
      status: json["status"] ?? "", // Default to empty string if null
      startDate: json["startDate"] ?? "", // Default to empty string if null
      paymentId: json["paymentId"], // This is nullable, so we leave it as is
    );
  }
}

class SubscriptionType {
  final String id;
  final String name;
  final int price;
  final String description;
  final bool adEnabled;

  SubscriptionType({
    required this.id,
    required this.name,
    required this.price,
    required this.description,
    required this.adEnabled,
  });

  factory SubscriptionType.fromJson(Map<String, dynamic> json) {
    return SubscriptionType(
      id: json["_id"] ?? "", // Default to empty string if null
      name: json["name"] ?? "Free", // Default to "Free" if name is null
      price: json["price"] ?? 0, // Default to 0 if price is null
      description: json["description"] ?? "", // Default to empty string if null
      adEnabled: json["ad_enabled"] ?? false, // Default to false if null
    );
  }
}
