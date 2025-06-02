import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:nandiott_flutter/services/auth_service.dart';
import 'package:nandiott_flutter/models/user_model.dart';

// Secure Storage instance
final secureStorageProvider = Provider((ref) => const FlutterSecureStorage());

// Provider for AuthService
final authServiceProvider = Provider((ref) => AuthService());

// Provider to fetch authenticated user details
final authUserProvider = FutureProvider<User?>((ref) async {
  final authService = ref.watch(authServiceProvider);
  final storage = ref.watch(secureStorageProvider);

  try {
    final response = await authService.checkAuthUser();
    print("resposne of checkauth in provider : $response");

    if (response["success"] == true && response["user"] != null) {
      final accessToken = response["accessToken"];
      
      if (accessToken != null) {
        await storage.write(key: "accessToken", value: accessToken); // ✅ Save new token
      }
      return User.fromJson(response["user"]);
    } else {
      return null; // ✅ Return null instead of throwing an error
    }
  } catch (e) {
    return null; // ✅ Return null instead of throwing an error
  }
});
