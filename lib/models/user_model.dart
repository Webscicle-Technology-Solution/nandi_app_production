class User {
  final String id;
  final String name;
  final String state;
  final String city;
  final int pincode;
  final String email;
  final String phone;
  final String createdAt;
  final String updatedAt;
  final String subscriptionId;

  User({
    required this.id,
    required this.name,
    required this.state,
    required this.city,
    required this.pincode,
    required this.email,
    required this.phone,
    required this.createdAt,
    required this.updatedAt,
    required this.subscriptionId,
  });

  // Factory constructor to parse from JSON
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json["_id"] ?? "",
      name: json["name"] ?? "",
      state: json["state"] ?? "",
      city: json["city"] ?? "",
      pincode: json["pincode"] ?? 0,
      email: json["email"] ?? "",
      phone: json["phone"] ?? "",
      createdAt: json["createdAt"] ?? "",
      updatedAt: json["updatedAt"] ?? "",
      subscriptionId: json["subscriptionId"] ?? "",
    );
  }

  // Convert UserModel to JSON
  Map<String, dynamic> toJson() {
    return {
      "_id": id,
      "name": name,
      "state": state,
      "city": city,
      "pincode": pincode,
      "email": email,
      "phone": phone,
      "createdAt": createdAt,
      "updatedAt": updatedAt,
      "subscriptionId": subscriptionId,
    };
  }
}
