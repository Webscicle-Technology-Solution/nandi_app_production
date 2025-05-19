import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class RentalService {
  final Dio _dio = Dio();
  final baseUrl = dotenv.env['API_BASE_URL'];
  final storage = const FlutterSecureStorage();

  // Fetch rentals
Future<Map<String, dynamic>> getRentals() async {
  String accessToken = await storage.read(key: "accessToken") ?? '';
  final url = '$baseUrl/payments/rentals/active';

  try {
    _dio.options.headers['Authorization'] = 'Bearer $accessToken';
    final response = await _dio.get(url);
    return response.data; // Return the successful response
  } on DioException catch (e) {
    final errorMessage = e.response?.data?['message'] ?? e.message;
    throw errorMessage; // Throw exception instead of returning null
  }
}

  // Fetch movie details by id from rental
  Future<Map<String, dynamic>> getMovieDetail(String movieId) async {
    final url = '$baseUrl/admin/meta/movies/$movieId';
    try {
      final response = await _dio.get(url);

      return response.data; // Returning the response as a map
    } on DioException catch (e) {
      throw Exception('Failed to load movie details');
    }
  }
}
