import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthService {
  final Dio dio = Dio();
  final baseUrl = dotenv.env['API_BASE_URL'];
  final FlutterSecureStorage secureStorage = const FlutterSecureStorage();

  Future<void> saveRefreshToken(String token) async {
    await secureStorage.write(key: 'refreshToken', value: token);
  }

  Future<Map<String, dynamic>?> sendOtpRegister(
      {required String phone,
    //   required String email
       }) async {
    final url = '$baseUrl/auth/register/otp-generate';
    try {
      final response =
          await dio.post(url, data: {"phone": phone,
        //   "email": email
           });
      return response.data;
    } on DioException catch (e) {
      if (e.response?.data['message'] != null) {
        return {'message': e.response?.data['message'], 'success': false};
      } else {
        return {
          'message': 'Something went wrong,Please try again later',
          'success': false
        };
      }
    }
  }

  Future<Map<String, dynamic>?> sendOtpLogin({required String phone}) async {
    final url = '$baseUrl/auth/login/otp-generate';
    try {
      final response = await dio.post(url, data: {"phone": phone});
      return response.data;
    } on DioException catch (e) {
      if (e.response?.data['message'] != null) {
        return {'message': e.response?.data['message'], 'success': false};
      } else {
        return {
          'message': 'Something went wrong,Please try again later',
          'success': false
        };
      }
    }
  }

  Future<Map<String, dynamic>?> registerUser(
      {required String name,
      required String email,
      required String phone,
      required String states,
      required String city,
      required String pincode,
      required String otp,
      required String deviceToken

      // required String confirmpassword
      }) async {
    final url = '$baseUrl/auth/register?deviceToken=$deviceToken';
    try {
      final response = await dio.post(url, data: {
        "name": name,
        "phone": phone,
        "email": email,
        "code": otp,
        "state": states,
        "city": city,
        "pincode": pincode,
        // "confirmpassword": confirmpassword
      });
      // If the response contains a refresh token, save it
      if (response.headers['set-cookie'] != null) {
        // Extract refresh token from cookies (you may need to adjust this based on your response structure)
        final cookies = response.headers['set-cookie'];
        final refreshToken = _extractRefreshTokenFromCookies(cookies);
        if (refreshToken != null) {
          await saveRefreshToken(refreshToken);
        }
      }
      return response.data;
    } on DioException catch (e) {
      if (e.response?.data['message'] != null) {
        return {'message': e.response?.data['message'], 'success': false};
      } else {
        return {
          'message': 'Something went wrong,Please try again later',
          'success': false
        };
      }
    }
  }

  //**********************LOGIN WITH EEMAIL */

  // Future<Map<String, dynamic>?> loginUser({
  //   required String email,
  //   required String password,
  // }) async {
  //   final url = '$baseUrl/auth/login';
  //   try {
  //     final response = await dio.post(url, // Your login API endpoint
  //         data: jsonEncode(
  //           {
  //             'email': email,
  //             'password': password,
  //           },
  //         ));

  //     // If the response contains a refresh token, save it
  //     if (response.headers['set-cookie'] != null) {
  //       // Extract refresh token from cookies (you may need to adjust this based on your response structure)
  //       final cookies = response.headers['set-cookie'];
  //       final refreshToken = _extractRefreshTokenFromCookies(cookies);
  //       if (refreshToken != null) {
  //         await saveRefreshToken(refreshToken);
  //       }
  //     }
  //     // Handle response
  //     return response.data;
  //   } on DioException catch (e) {
  //     if (e.response?.data['message'] != null) {
  //       return {'message': e.response?.data['message'], 'success': false};
  //     } else {
  //       return {
  //         'message': 'Something went wrong,Please try again later',
  //         'success': false
  //       };
  //     }
  //   }
  // }

//***********************/


//*********************************** */

  //old-backend code if primary is not working

  // Future<Map<String, dynamic>?> loginUserPhone(
  //     {required String phone,
  //     required String otp,
  //     }) async {
  //   final url = '$baseUrl/auth/login';
  //   try {
  //     final response = await dio.post(url, // Your login API endpoint
  //         data: jsonEncode(
  //           {
  //             'phone': phone.trim(),
  //             'code': otp.trim(),
  //           },
  //         ));

  //     // If the response contains a refresh token, save it
  //     if (response.headers['set-cookie'] != null) {
  //       // Extract refresh token from cookies (you may need to adjust this based on your response structure)
  //       final cookies = response.headers['set-cookie'];
  //       final refreshToken = _extractRefreshTokenFromCookies(cookies);
  //       if (refreshToken != null) {
  //         await saveRefreshToken(refreshToken);
  //       }
  //     }

  //     // Handle response
  //     return response.data;
  //   } on DioException catch (e) {
  //     if (e.response?.data['message'] != null) {
  //       return {'message': e.response?.data['message'], 'success': false};
  //     } else {
  //       return {
  //         'message': 'Something went wrong,Please try again later',
  //         'success': false
  //       };
  //     }
  //   }
  // }
//*********************************** */

  Future<Map<String, dynamic>?> loginUserPhone(
      {required String phone,
      required String otp,
      required String deviceToken}) async {
    final url = '$baseUrl/auth/login?deviceToken=$deviceToken';
    try {
      final response = await dio.post(url, // Your login API endpoint
          data: jsonEncode(
            {
              'phone': phone.trim(),
              'code': otp.trim(),
            },
          ));
print("response : $response");
      // If the response contains a refresh token, save it
      if (response.headers['set-cookie'] != null) {
        print("reepsonse cookie : ${response.headers['set-cookie']}");
        // Extract refresh token from cookies (you may need to adjust this based on your response structure)
        final cookies = response.headers['set-cookie'];
        final refreshToken = _extractRefreshTokenFromCookies(cookies);
        print("refreseh token : $refreshToken");
        if (refreshToken != null) {
          await saveRefreshToken(refreshToken);
        }
      }

      // Handle response
      return response.data;
    } on DioException catch (e) {
      if (e.response?.data['message'] != null) {
        return {'message': e.response?.data['message'], 'success': false};
      } else {
        return {
          'message': 'Something went wrong,Please try again later',
          'success': false
        };
      }
    }
  }

  Future<Map<String, dynamic>> tvLoginStatus({required String code}) async {
    final url = '$baseUrl/auth/tv/pair-status?code=$code';
    try {
      final response = await dio.get(url);

      // If the response contains a refresh token, save it
      if (response.headers['set-cookie'] != null) {
        // Extract refresh token from cookies (you may need to adjust this based on your response structure)
        final cookies = response.headers['set-cookie'];
        final refreshToken = _extractRefreshTokenFromCookies(cookies);
        if (refreshToken != null) {
          await saveRefreshToken(refreshToken);
        }
      }
      // Handle response
      return response.data;
    } on DioException catch (e) {
      final errorMessage =
          e.response?.data?['message'] ?? "Failed to login qr user";
      throw Exception(errorMessage);
    }
  }

  Future<Map<String, dynamic>> checkAuthUser() async {
    final accessToken = await secureStorage.read(key: "accessToken");
    final refreshToken = await secureStorage.read(key: "refreshToken");
    final url = '$baseUrl/auth/checkauth';

    try {
      dio.options.headers['Cookie'] = 'refreshToken=${refreshToken}';
      dio.options.headers['Authorization'] = 'Bearer $accessToken';
      final response = await dio.get(url);
       print("response checkauth in service:$response");
      // If the response contains a refresh token, save it
      if (response.headers['set-cookie'] != null) {
        // Extract refresh token from cookies (you may need to adjust this based on your response structure)
        print("response of response header:${response.headers['set-cookie']}");
        final cookies = response.headers['set-cookie'];
        
        final refreshToken = _extractRefreshTokenFromCookies(cookies);
        if (refreshToken != null) {
          await saveRefreshToken(refreshToken);
        }
      }

      // ✅ Store the new accessToken if provided
      if (response.data["success"] == true &&
          response.data.containsKey("accessToken")) {
        await secureStorage.write(
            key: "accessToken", value: response.data["accessToken"]);
      }

      return response.data;
    } on DioException catch (e) {
      final errorMessage =
          e.response?.data?['message'] ?? "Failed to authenticate user";
                print("checkauth error${errorMessage}");

      throw Exception(errorMessage);
    }
  }

  Future<Map<String, dynamic>> logout() async {
    final refreshToken = await secureStorage.read(key: "refreshToken");
    final url = "$baseUrl/auth/logout";
    dio.options.headers['Cookie'] = 'refreshToken=${refreshToken}';
        await secureStorage.delete(key: "accessToken");
        await secureStorage.delete(key: "refreshToken");
    try {
      final response = await dio.post(url);
      if (response.data['success'] == true) {
        await secureStorage.delete(key: "accessToken");
        await secureStorage.delete(key: "refreshToken");
        return response.data;
      } else {
        return response.data;
      }
    } on DioException catch (e) {
      final errorMessage = e.response?.data?['message'] ?? e.message;
      throw errorMessage; // Throw exception instead of returning null
    }
  }
}

// Utility function to extract refresh token from cookies (this can vary based on how your backend sends it)
String? _extractRefreshTokenFromCookies(List<String>? cookies) {
  if (cookies == null) return null;
  for (var cookie in cookies) {
    if (cookie.contains('refreshToken=')) {
      // You can extract the value here
      final token = cookie.split('refreshToken=')[1];
      print("token in extract method : $token");
      return token.split(';')[0]; // Remove any trailing characters like ';'
    }
  }
  return null;
}
