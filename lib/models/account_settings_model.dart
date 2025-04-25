class AccountSettings {
  final String name;              // User's name
  final String email;             // User's email address
  final String phone;             // User's phone number
  final String subscriptionPlan;  // User's subscription plan (e.g., Free, Basic, Premium)
  final String? profilePicture;   // Path to the profile picture (nullable)
  final String? message;

  AccountSettings({
    required this.name,
    required this.email,
    required this.phone,
    required this.subscriptionPlan,
    this.profilePicture,
    this.message
  });

  // Create a copy of the current instance with updated fields
  AccountSettings copyWith({
    String? name,
    String? email,
    String? phone,
    String? subscriptionPlan,
    String? profilePicture,
    String? message
  }) {
    return AccountSettings(
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      subscriptionPlan: subscriptionPlan ?? this.subscriptionPlan,
      profilePicture: profilePicture ?? this.profilePicture,
      message: message ?? this.message
    );
  }
}
