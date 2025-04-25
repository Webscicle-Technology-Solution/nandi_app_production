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
  final url = '$baseUrl/payments/subscription/$userId';

  try {
    _dio.options.headers['Authorization'] = 'Bearer $accessToken';
    final response = await _dio.get(url);
    print('✅🔔 API Response of Subscription detail is: ${response.data}');

    // // Check if success is false
    // if (response.data == null || response.data['success'] == false) {
    //   final errorMessage = response.data?['message'] ?? "Failed to fetch rentals";
    //   print('❌ API Error: $errorMessage');
    //   throw Exception(errorMessage); // Throw an exception with the error message
    // }

    return response.data; // Return the successful response
  } on DioException catch (e) {
    final errorMessage = e.response?.data?['message'] ?? e.message;
    print('❌🔔 Subscription API Error: $errorMessage');
    throw errorMessage; // Throw exception instead of returning null
  }
}

  // Fetch movie details by id from rental

  // Future<Map<String, dynamic>> getMovieDetail(String movieId) async {
  //   final url = '$baseUrl/admin/meta/movies/$movieId';
  //   try {
  //     final response = await _dio.get(url);
  //           print('✅ API Response of movie details in rentals is: ${response.data}');

  //     return response.data; // Returning the response as a map
  //   } on DioException catch (e) {
  //     print('❌ API Error: ${e.response?.data ?? e.message}');
  //     throw Exception('Failed to load movie details');
  //   }
  // }
}
