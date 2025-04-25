import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
//import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class DetailService {
  final Dio _dio = Dio();
  final baseUrl = dotenv.env['API_BASE_URL'];
    final storage = FlutterSecureStorage();


  Future<Map<String, dynamic>?> getMovieDetail({
    required String mediaType,
    required String movieId,
  }) async {
     // String value = await storage.read(key: "refreshToken")??'';
//print('refreshToken is:--${value}--');
    print("Mediatype in api is ${mediaType}");

    final url = '$baseUrl/admin/meta/$mediaType/$movieId';
    
   // print('🔍 Fetching Movie Details: $url'); // Debug Print

    try {
      final response = await _dio.get(url);
     // print('✅ API Response: ${response.data}'); // Debug Print
      return response.data;
    } on DioException catch (e) {
      print('❌ API Error: ${e.response?.data ?? e.message}'); // Debug Error
      return {
        'message': 'Something went wrong',
        'success': false
      };
    }
  }



    Future<Map<String, dynamic>?> postMovieRating({
    required String mediaType,
    required String movieId,

    required num rating
  }) async {
     // String value = await storage.read(key: "refreshToken")??'';
//print('refreshToken is:--${value}--');
    print("Mediatype in api is ${mediaType}");
          String accessToken = await storage.read(key: "accessToken") ?? '';

    final url = '$baseUrl/admin/meta/rating';
   
   // print('🔍 Fetching Movie Details: $url'); // Debug Print

    try {
             _dio.options.headers['Authorization'] = 'Bearer $accessToken';

      final response = await _dio.post(url,data: {
            "contentType":"$mediaType",
            "contentId":"$movieId",
            "rating":rating
            
      });
      print('✅ API Response for rating: ${response.data}'); // Debug Print
      return response.data;
    } on DioException catch (e) {
      print('❌ API Error: ${e.response?.data ?? e.message}'); // Debug Error
      return {
        'message': ' ${e.response!.data['message']}',
        'success': false
      };
    }
  }
}
