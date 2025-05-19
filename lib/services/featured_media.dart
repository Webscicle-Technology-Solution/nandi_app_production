import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class getAllFeaturedMediaService {
  final Dio _dio = Dio();
  final baseUrl = dotenv.env['API_BASE_URL'];
  Future<Map<String, dynamic>?> getAllFeaturedMedia({
    required String mediaType,
  }) async {
    final url = '$baseUrl/admin/meta/featured/$mediaType';
    try {
      final response = await _dio.get(url);
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
}
