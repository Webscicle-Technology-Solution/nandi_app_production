import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SubscriptionService {
  final Dio _dio = Dio();
  final baseUrl = dotenv.env['API_BASE_URL'];
  final storage = FlutterSecureStorage();

  // Fetch rentals
  Future<Map<String, dynamic>?> getSubscriptionDetail(String userId) async {
    String accessToken = await storage.read(key: "accessToken") ?? '';
    print('sub userId${userId}');
    final url = '$baseUrl/payments/subscription/$userId';
    print('sub url$url');

    try {
      _dio.options.headers['Authorization'] = 'Bearer $accessToken';
      final response = await _dio.get(url);
      return response.data; // Return the successful response
    } on DioException catch (e) {
      print("print subscription ");
      final errorMessage = e.response?.data?['message'] ?? e.message;
      print("sub error:$errorMessage");
      throw errorMessage; // Throw exception instead of returning null
    }
  }
}
