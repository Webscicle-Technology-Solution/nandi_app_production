import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class SubscriptionplanService {
    final Dio dio = Dio();
  final baseUrl = dotenv.env['API_BASE_URL'];
  
    Future<Map<String, dynamic>?> getSubscriptionPlan() async {
    final url = '$baseUrl/payments/subscription/types'; // Endpoint to check session
    try {
      final response = await dio.get(url);
      // No need to pass authorization headers; cookies are managed automatically
      print("Api response of plan detais is ${response.data}");
      return response.data;
    } on DioException catch (e) {
      // print("Error: ${e.response?.data}")
      return {
        'message': e.response?.data['message'] ?? 'Something went wrong,Please try again later',
        'success': false
      };
    }
  }
}