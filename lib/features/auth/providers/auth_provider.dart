import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:nandiott_flutter/services/auth_service.dart';

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(AuthService());
});

class AuthState {
  final bool isAuthenticated;
  final bool isLoading;
  final String? errorMessage;
  late final String? successMessage;

  AuthState(
      {this.isLoading = false,
      this.errorMessage,
      this.successMessage,
      this.isAuthenticated = false});

  AuthState copyWith(
      {bool? isLoading,
      String? errorMessage,
      String? successMessage,
      bool? isAuthenticated}) {
    return AuthState(
        isLoading: isLoading ?? this.isLoading,
        errorMessage: errorMessage ?? this.errorMessage,
        successMessage: successMessage ?? this.successMessage,
        isAuthenticated: isAuthenticated ?? this.isAuthenticated);
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthService _authService;
  static const storage = FlutterSecureStorage();

  AuthNotifier(this._authService) : super(AuthState());
// Future <void> checkAuthentication() async {
//     String value = await storage.read(key: "accessToken") ?? '';
//     if (value.isNotEmpty) {
//       state = state.copyWith(isAuthenticated: true);
//     }else{
//       state = state.copyWith(isAuthenticated: false);
//     }
// }

  Future<void> loginUser(String email, String password) async {
    state = state.copyWith(isLoading: true);
    try {
      final response =
          await _authService.loginUser(email: email, password: password);

      state = state.copyWith(isLoading: false);

      if (response == null) {
        state = state.copyWith(errorMessage: "Login failed. Please try again.");
      } else if (response['success'] == false) {
        state = state.copyWith(errorMessage: response['message']);
      } else if (response['success'] == true) {
        state = state.copyWith(successMessage: "Login successful");
        await storage.write(key: "accessToken", value: response['accessToken']);
        state = state.copyWith(errorMessage: null);
      }
    } catch (e) {
      state = state.copyWith(
          errorMessage: "Login failed. Please try again.", isLoading: false);
    }
  }
    Future<void> registerUser(String name,String email, String phone,String states,String city,String pincode, String otp,String deviceToken) async {
    state = state.copyWith(isLoading: true);
    final response = await _authService.registerUser(email: email, otp: otp, name: name, phone: phone, states: states, city: city, pincode: pincode,deviceToken: deviceToken);
    
    state = state.copyWith(isLoading: false);

    if (response == null) {
      state = state.copyWith(errorMessage: "Login failed. Please try again.");
    } else if (response['success'] == false) {
      state = state.copyWith(errorMessage: response['message']);
    } else if (response['success'] == true) {
      state = state.copyWith(successMessage: "Login successful");
      await storage.write(key: "accessToken", value: response['accessToken']);
      state = state.copyWith(errorMessage: null);
    }
  }
}
