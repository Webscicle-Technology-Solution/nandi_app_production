import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SupportService {
  final Dio _dio = Dio();
  final baseUrl = dotenv.env['API_BASE_URL'];
  final FlutterSecureStorage _secureStorage = FlutterSecureStorage();

  /// Sends a support issue to the admin
  /// Returns a Map with success status and data or error message
 Future<Map<String, dynamic>> sendSupportIssue({
  required String message,
}) async {
  try {
    // Get token from secure storage
    final token = await _secureStorage.read(key: 'accessToken');

    if (token == null || token.isEmpty) {
      return {
        'success': false,
        'message': 'Please login to report an issue',
      };
    }

    final response = await _dio.post(
      '$baseUrl/auth/support/ticket/new',
      data: {
        "message": message,
      },
      options: Options(headers: {
        "Authorization": "Bearer $token",
      }),
    );

    final responseData = response.data;

    // Handle response with success true
    if (responseData is Map<String, dynamic> && responseData['success'] == true) {
      return {
        'success': true,
        'message': 'Issue submitted successfully!',
        'data': responseData['data'],
      };
    }

    // Handle response with only message (e.g., unauthorized)
    if (responseData is Map<String, dynamic> && responseData.containsKey('message')) {
      return {
        'success': false,
        'message': responseData['message'],
      };
    }

    // Fallback error
    return {
      'success': false,
      'message': 'Unexpected response from server.',
    };
  } on DioException catch (e) {
    print("Error sending support issue: $e");

    if (e.response?.statusCode == 401) {
      return {
        'success': false,
        'message': 'Please login to report an issue',
      };
    }

    final errorData = e.response?.data;

    return {
      'success': false,
      'message': errorData is Map && errorData['message'] != null
          ? errorData['message']
          : 'Failed to send your issue. Please try again later.',
    };
  } catch (e) {
    print("Unexpected error sending support issue: $e");
    return {
      'success': false,
      'message': 'An unexpected error occurred. Please try again later.',
    };
  }
}
}