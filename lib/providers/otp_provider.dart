import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nandiott_flutter/services/auth_service.dart';

final otpServiceProvider = Provider((ref) => AuthService());

//Provider for send otp
final sentOtpProvider =
    FutureProvider.family<String?, OtpDetailParameter>((ref, params) async {
  final otpService = ref.watch(otpServiceProvider);

  // Call the API with movieId and redirectUrl
  final response = await otpService.sendOtpRegister(phone: params.phone!,
  //email: params.email!
  );

  if (response!['success'] == true) {
    print("✅🔔 otp provider Response: ${response}");
    return response['message'];
  } else {
    return response['message'];
  }
});

final sentOtpProviderLogin =
    FutureProvider.family<String?, OtpDetailParameter>((ref, params) async {
  final otpService = ref.watch(otpServiceProvider);

  // Call the API with movieId and redirectUrl
  final response = await otpService.sendOtpLogin(phone: params.phone!);

  if (response!['success'] == true) {
    print("✅🔔 otp provider Response: ${response}");
    return response['message'];
  } else {
    throw Exception(response?['message'] ?? 'Failed to send otp');
  }
});

class OtpDetailParameter extends Equatable {
  final String? phone;
 // final String? email;

  const OtpDetailParameter({this.phone,
  //this.email
  });

  @override
  List<Object?> get props => [phone,
 // email
  ];
}

final verifyOtpProviderLogin =
    FutureProvider.family<Map<String, dynamic>?, VerifyOtpParameter>(
        (ref, params) async {
  final otpService = ref.watch(otpServiceProvider);

  // Call the login API with phone and OTP
  final response = await otpService.loginUserPhone(
    phone: params.phone,
    otp: params.otp,
    deviceToken: params.deviceToken!
    
  );

  if (response != null && response['success'] == true) {
    print("✅🔔 Verification Response: $response");
    return response;
  } else {
    throw Exception(response?['message'] ?? 'Failed to verify OTP');
  }
});

class VerifyOtpParameter extends Equatable {
  final String phone;
  final String otp;
  final String? deviceToken;

  const VerifyOtpParameter({
    this.deviceToken,
    required this.phone,
    required this.otp,
    
  });

  @override
  List<Object> get props => [phone, otp,deviceToken!];
}
