import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class getAllFeaturedMediaService {
  final Dio _dio = Dio();
  final baseUrl = dotenv.env['API_BASE_URL'];
  Future<Map<String, dynamic>?> getAllFeaturedMedia({
    required String mediaType,
  }) async {
    print("calling api $mediaType");
    final url = '$baseUrl/admin/meta/featured/$mediaType';
    try {
      // print('calling api ${url}');
      final response = await _dio.get(url);
      print('response data featured :${response.data}');
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
