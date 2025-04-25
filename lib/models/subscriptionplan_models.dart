class SubscriptionPlan {
  String id;
  String name;
  int price;
  String description;
  List<String> benefits;
  bool adEnabled;
  DateTime createdAt;
  DateTime updatedAt;

  SubscriptionPlan({
    required this.id,
    required this.name,
    required this.price,
    required this.description,
    required this.benefits,
    required this.adEnabled,
    required this.createdAt,
    required this.updatedAt,
  });

  // Factory constructor to create an instance from JSON
  factory SubscriptionPlan.fromJson(Map<String, dynamic> json) {
    return SubscriptionPlan(
      id: json['_id'],
      name: json['name'],
      price: json['price'],
      description: json['description'],
      benefits: List<String>.from(json['benefits'] ?? []),
      adEnabled: json['ad_enabled'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  // Method to convert an instance to JSON
  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'price': price,
      'description': description,
      'benefits': benefits,
      'ad_enabled': adEnabled,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}
