import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class SearchService {
  final Dio _dio = Dio();
  final String? baseUrl = dotenv.env['API_BASE_URL'];

Future<Map<String, dynamic>?> searchMedia({
  required String mediaType,
  required String query,
  int page = 1, // Add page parameter
}) async {
  final url = '$baseUrl/admin/meta/search/$mediaType?query=$query&page=$page'; // Include page
  try {
    final response = await _dio.get(url);
    return response.data;
  } on DioException catch (e) {
    return {
      'message': e.response?.data['message'] ?? 'Something went wrong',
      'success': false,
    };
  }
}

}
