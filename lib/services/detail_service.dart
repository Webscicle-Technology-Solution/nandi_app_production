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

    final url = '$baseUrl/admin/meta/$mediaType/$movieId';
    

    try {
      final response = await dio.get(url);
      return response.data;
    } on DioException catch (e) {
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
          String accessToken = await storage.read(key: "accessToken") ?? '';

    final url = '$baseUrl/admin/meta/rating';
    try {
             dio.options.headers['Authorization'] = 'Bearer $accessToken';

      final response = await dio.post(url,data: {
            "contentType":"$mediaType",
            "contentId":"$movieId",
            "rating":rating
            
      });

      return response.data;
    } on DioException catch (e) {
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
          String accessToken = await storage.read(key: "accessToken") ?? '';
           final url = '$baseUrl/admin/meta/rating/${mediaType}/${movieId}';
           try {
            //   dio.options.headers['Authorization'] = 'Bearer $accessToken';
               final response=await  dio.get(url);
               return response.data;

           }on DioException catch (e) {
      return {
        'message': ' ${e.response!.data['message']}',
        'success': false
      };
    }

   
    }

}
