import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class HomecontentsService {
  final Dio dio=Dio();
  final String? baseUrl=dotenv.env['API_BASE_URL'];

  Future<Map<String, dynamic>?> getHomeContents(
     String mediaType
)async{
    final url = '$baseUrl/admin/meta/sections/$mediaType'; 
    try {
      final response=await dio.get(url);
      return response.data;
      
    }on DioException catch (e) {
          return {
      'message': e.response?.data['message'] ?? 'Something went wrong',
      'success': false,
    };
    }

}
}