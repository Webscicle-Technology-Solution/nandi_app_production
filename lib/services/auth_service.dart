// import 'dart:convert';

// import 'package:dio/dio.dart';
// import 'package:flutter_dotenv/flutter_dotenv.dart';
// import 'package:flutter_secure_storage/flutter_secure_storage.dart';

// class AuthService {
//   final Dio _dio = Dio();
//   final baseUrl = dotenv.env['API_BASE_URL'];
//   final FlutterSecureStorage secureStorage = FlutterSecureStorage();

//   Future<void> saveRefreshToken(String token) async {
//     await secureStorage.write(key: 'refreshToken', value: token);
//   }

//   Future<Map<String, dynamic>?> registerUser({
//     required String name,
//     required String email,
//     required String phone,
//     required String states,
//     required String city,
//     required String pincode,
//     required String password,
//     // required String confirmpassword
//   }) async {
//     final url = '$baseUrl/auth/register';
//     try {
//       final response = await _dio.post(url, data: {
//         "name": "name",
//         "phone": phone,
//         "email": email,
//         "password": password,
//         "state": states,
//         "city": city,
//         "pincode": pincode,
//         // "confirmpassword": confirmpassword
//       });
//       // If the response contains a refresh token, save it
//       if (response.headers['set-cookie'] != null) {
//         // Extract refresh token from cookies (you may need to adjust this based on your response structure)
//         final cookies = response.headers['set-cookie'];
//         final refreshToken = _extractRefreshTokenFromCookies(cookies);
//         if (refreshToken != null) {
//           await saveRefreshToken(refreshToken);
//         }
//       }
//       return response.data;
//     } on DioException catch (e) {
//       if (e.response?.data['message'] != null) {
//         return {'message': e.response?.data['message'], 'success': false};
//       } else {
//         return {
//           'message': 'Something went wrong,Please try again later',
//           'success': false
//         };
//       }
//     }
//   }

//   Future<Map<String, dynamic>?> loginUser({
//     required String email,
//     required String password,
//   }) async {
//     final url = '$baseUrl/auth/login';
//     try {
//       print("calling response , ${url}");
//       final response = await _dio.post(url, // Your login API endpoint
//           data: jsonEncode(
//             {
//               'email': email,
//               'password': password,
//             },
//           ));

//       // If the response contains a refresh token, save it
//       if (response.headers['set-cookie'] != null) {
//         // Extract refresh token from cookies (you may need to adjust this based on your response structure)
//         final cookies = response.headers['set-cookie'];
//         final refreshToken = _extractRefreshTokenFromCookies(cookies);
//         if (refreshToken != null) {
//           await saveRefreshToken(refreshToken);
//         }
//       }

//       // Handle response
//       // print('User logged in successfully: ${response.data}');
//       return response.data;
//     } on DioException catch (e) {
//       print("error ${e}");
//       if (e.response?.data['message'] != null) {
//         return {'message': e.response?.data['message'], 'success': false};
//       } else {
//         return {
//           'message': 'Something went wrong,Please try again later',
//           'success': false
//         };
//       }
//     }
//   }

//   Future<Map<String, dynamic>> checkAuthUser() async {
//     final accessToken = await secureStorage.read(key: "accessToken");
//     final refreshToken = await secureStorage.read(key: "refreshToken");
//     final url = '$baseUrl/auth/checkauth';

//     try {
//       print("refreshtoken in checkauth is ${refreshToken}");
//       _dio.options.headers['Cookie'] = 'refreshToken=${refreshToken}';
//       _dio.options.headers['Authorization'] = 'Bearer $accessToken';
//       final response = await _dio.get(url);
//       // If the response contains a refresh token, save it
//       if (response.headers['set-cookie'] != null) {
//         // Extract refresh token from cookies (you may need to adjust this based on your response structure)
//         final cookies = response.headers['set-cookie'];
//         final refreshToken = _extractRefreshTokenFromCookies(cookies);
//         if (refreshToken != null) {
//           await saveRefreshToken(refreshToken);
//         }
//       }
//       print('✅ API Response of checkauth: ${response.data}');

//       // ✅ Store the new accessToken if provided
//       if (response.data["success"] == true &&
//           response.data.containsKey("accessToken")) {
//         await secureStorage.write(
//             key: "accessToken", value: response.data["accessToken"]);
//       }

//       return response.data;
//     } on DioException catch (e) {
//       final errorMessage =
//           e.response?.data?['message'] ?? "Failed to authenticate user";
//       print('❌ API Error: $errorMessage');
//       throw Exception(errorMessage);
//     }
//   }
// }

// // Utility function to extract refresh token from cookies (this can vary based on how your backend sends it)
// String? _extractRefreshTokenFromCookies(List<String>? cookies) {
//   if (cookies == null) return null;
//   for (var cookie in cookies) {
//     if (cookie.contains('refreshToken=')) {
//       // You can extract the value here
//       final token = cookie.split('refreshToken=')[1];
//       return token.split(';')[0]; // Remove any trailing characters like ';'
//     }
//   }
//   return null;
// }

// // //new auth api with auto cookie management

// // import 'dart:convert';
// // import 'package:dio/dio.dart';
// // import 'package:flutter_dotenv/flutter_dotenv.dart';
// // import 'package:dio_cookie_manager/dio_cookie_manager.dart';
// // import 'package:cookie_jar/cookie_jar.dart';

// // class AuthService {
// //   final Dio _dio = Dio();
// //   final baseUrl = dotenv.env['API_BASE_URL'];
// //   late final CookieJar _cookieJar;

// //   // Initialize the CookieJar and Dio client
// //   AuthService() {
// //     _cookieJar = CookieJar();
// //     _dio.interceptors.add(CookieManager(_cookieJar));
// //   }

// //   Future<Map<String, dynamic>?> registerUser({
// //     required String name,
// //     required String email,
// //     required String phone,
// //     required String password,
// //   }) async {
// //     final url = '$baseUrl/auth/register';
// //     try {
// //       final response = await _dio.post(url, data: {
// //         "name": name,
// //         "phone": phone,
// //         "email": email,
// //         "password": password,
// //       });
// //       return response.data;
// //     } on DioException catch (e) {
// //       if (e.response?.data['message'] != null) {
// //         return {'message': e.response?.data['message'], 'success': false};
// //       } else {
// //         return {
// //           'message': 'Something went wrong,Please try again later',
// //           'success': false
// //         };
// //       }
// //     }
// //   }

// //   Future<Map<String, dynamic>?> loginUser({
// //     required String email,
// //     required String password,
// //   }) async {
// //     final url = '$baseUrl/auth/login';
// //     try {
// //       final response = await _dio.post(
// //         url,
// //         data: jsonEncode({
// //           'email': email,
// //           'password': password,
// //         }),
// //       );

// //       // Automatically store cookies (including the access token and refresh token)
// //       return response.data;

// //     } on DioException catch (e) {
// //       print("error ${e}");
// //       if (e.response?.data['message'] != null) {
// //         return {'message': e.response?.data['message'], 'success': false};
// //       } else {
// //         return {
// //           'message': 'Something went wrong,Please try again later',
// //           'success': false
// //         };
// //       }
// //     }
// //   }

// //   // Method to check if the user is authenticated (check cookies)

// // }

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
      print("phonenumber in otp api is ${phone}, email is email");
      final response =
          await dio.post(url, data: {"phone": phone,
        //   "email": email
           });

      print("OTP API RESPONS ${response.data}");

      return response.data;
    } on DioException catch (e) {
      print("OTP API ERROR $e");
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
      print("phonenumber in otp api is ${phone}");
      final response = await dio.post(url, data: {"phone": phone});

      print("OTP API RESPONS ${response.data}");

      return response.data;
    } on DioException catch (e) {
      print("OTP API ERROR $e");
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
    print("deviceToken in register api is $deviceToken");
    final url = '$baseUrl/auth/register?deviceToken=$deviceToken';
    print(
        "body in register api are $name,$email,$phone,$states,$city,$pincode,$otp");
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
      print("response in regiser page is${response.data}");
      return response.data;
    } on DioException catch (e) {
      print("in register api error");
      print("error response in register api is${e.response!.statusMessage}");
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

  Future<Map<String, dynamic>?> loginUser({
    required String email,
    required String password,
  }) async {
    final url = '$baseUrl/auth/login';
    try {
      print("calling response , ${url}");
      final response = await dio.post(url, // Your login API endpoint
          data: jsonEncode(
            {
              'email': email,
              'password': password,
            },
          ));

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
      // print('User logged in successfully: ${response.data}');
      return response.data;
    } on DioException catch (e) {
      print("error ${e}");
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

  Future<Map<String, dynamic>?> loginUserPhone(
      {required String phone,
      required String otp,
      required String deviceToken}) async {
    print("the token in loginUser api =$deviceToken");
    final url = '$baseUrl/auth/login?deviceToken=$deviceToken';
    try {
      print("calling response , ${url}");
      final response = await dio.post(url, // Your login API endpoint
          data: jsonEncode(
            {
              'phone': phone.trim(),
              'code': otp.trim(),
            },
          ));

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
      // print('User logged in successfully: ${response.data}');
      return response.data;
    } on DioException catch (e) {
      print("error ${e}");
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
      print("[${DateTime.now().toIso8601String()}] calling response , $url");
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
      print("result of checking is login using qr is ${response.data}");
      // Handle response
      // print('User logged in successfully: ${response.data}');
      return response.data;
    } on DioException catch (e) {
      final errorMessage =
          e.response?.data?['message'] ?? "Failed to login qr user";
      print('❌ API Error: $errorMessage');
      throw Exception(errorMessage);
    }
  }

  Future<Map<String, dynamic>> checkAuthUser() async {
    final accessToken = await secureStorage.read(key: "accessToken");
    final refreshToken = await secureStorage.read(key: "refreshToken");
    final url = '$baseUrl/auth/checkauth';

    try {
      print("refreshtoken in checkauth is ${refreshToken}");
      dio.options.headers['Cookie'] = 'refreshToken=${refreshToken}';
      dio.options.headers['Authorization'] = 'Bearer $accessToken';
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
      print('✅ API Response of checkauth: ${response.data}');

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
      print('❌ API Error: $errorMessage');
      throw Exception(errorMessage);
    }
  }

  Future<Map<String, dynamic>> logout() async {
    final refreshToken = await secureStorage.read(key: "refreshToken");
    print("refreshtoken for logout is $refreshToken");
    final url = "$baseUrl/auth/logout";
    dio.options.headers['Cookie'] = 'refreshToken=${refreshToken}';
        await secureStorage.delete(key: "accessToken");
        await secureStorage.delete(key: "refreshToken");
    try {
      final response = await dio.post(url);
      if (response.data['success'] == true) {
        await secureStorage.delete(key: "accessToken");
        await secureStorage.delete(key: "refreshToken");
        print('✅ API Response when logout is: ${response.data}');

        return response.data;
      } else {
        return response.data;
      }
    } on DioException catch (e) {
      final errorMessage = e.response?.data?['message'] ?? e.message;
      print('❌Logout API Error: $errorMessage');
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
      return token.split(';')[0]; // Remove any trailing characters like ';'
    }
  }
  return null;
}
