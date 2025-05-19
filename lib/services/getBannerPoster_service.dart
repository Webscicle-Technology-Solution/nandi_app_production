import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class getBannerPosterService {
  // Mapping of media types to their correct API values
  final Map<String, String> mediaTypeMap = {
    'videosongs': 'videosong',
    'shortfilms': 'shortfilm',
    'documentaries': 'documentary',
    'episodes': 'episode',
    'movies': 'movie',
    'tvseries': 'tvseries', // Keeping 'tvseries' unchanged
  };
  final Dio _dio = Dio();
  final baseUrl = dotenv.env['API_BASE_URL'];

  Future<Map<String, dynamic>?> getPoster({
    required String mediaType,
    required String mediaId,
  }) async {
    // Convert mediaType if it exists in the map, otherwise keep it unchanged
    final transformedMediaType = mediaTypeMap[mediaType] ?? mediaType;
    final url = '$baseUrl/content/poster/$transformedMediaType/$mediaId';
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

  Future<Map<String, dynamic>?> getBanner(
      {required String mediaType, required String mediaId}) async {
    // Convert mediaType if it exists in the map, otherwise keep it unchanged
    final transformedMediaType = mediaTypeMap[mediaType] ?? mediaType;

    final url = '$baseUrl/content/banner/$transformedMediaType/$mediaId';
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