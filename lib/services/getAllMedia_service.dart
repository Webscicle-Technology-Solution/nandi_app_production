import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class getAllMediaService {
  final Dio _dio = Dio();
  final baseUrl = dotenv.env['API_BASE_URL'];
  Future<Map<String, dynamic>?> getLatestMedia({
    required String mediaType,
  }) async {
    final url = '$baseUrl/admin/meta/user/$mediaType/all';
    try {
      final response = await _dio.get(url);
      print("response in movies latest: $response");
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

  Future<Map<String, dynamic>?> getFreeMedia({
    required String mediaType,
  }) async {
    final url = '$baseUrl/admin/meta/user/$mediaType/all/free';
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
