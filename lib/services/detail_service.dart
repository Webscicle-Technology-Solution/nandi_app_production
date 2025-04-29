import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
//import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class DetailService {
  final Dio dio = Dio();
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
      final response = await dio.get(url);
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
             dio.options.headers['Authorization'] = 'Bearer $accessToken';

      final response = await dio.post(url,data: {
            "contentType":"$mediaType",
            "contentId":"$movieId",
            "rating":rating
            
      });
      print("contenttye and id when rating is $mediaType,$movieId");
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

    Future<Map<String, dynamic>?> getMovieRating({
          required String mediaType,
    required String movieId,
    })async{
      print("mediatype and movieid are $mediaType,$movieId");
          String accessToken = await storage.read(key: "accessToken") ?? '';
           final url = '$baseUrl/admin/meta/rating/${mediaType}/${movieId}';
           try {
            //   dio.options.headers['Authorization'] = 'Bearer $accessToken';
               print("accesstoken in movie rated is${accessToken}");
               final response=await  dio.get(url);
               print("api response of movie rated is ${response.data}");
               return response.data;

           }on DioException catch (e) {
      print('❌ API Error in rated: ${e.response?.data ?? e.message}'); // Debug Error
      return {
        'message': ' ${e.response!.data['message']}',
        'success': false
      };
    }

   
    }

}
