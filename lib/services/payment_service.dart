import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class PaymentService {
    final Dio dio = Dio();
  final baseUrl = dotenv.env['API_BASE_URL'];
  final storage = const FlutterSecureStorage();

Future <Map<String, dynamic>> rentalPaymentService(String movieId,String redirectUrl)async{
  String? accessToken=await storage.read(key: "accessToken");
  final url="$baseUrl/payments/rent/movie/${movieId}";
  try {
      dio.options.headers["Authorization"]="Bearer $accessToken";
  final response= await dio.post(url,data: {
    "redirectUrl":redirectUrl
  });

  return response.data ;
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



Future <Map<String, dynamic>> subscriptionPaymentService(String subscriptionplan,String redirectUrl)async{
  String? accessToken=await storage.read(key: "accessToken");
  final url="$baseUrl/payments/subscribe/${subscriptionplan}";
  try {
      dio.options.headers["Authorization"]="Bearer $accessToken";
  final response= await dio.post(url,data: {
    "redirectUrl":redirectUrl
  });

  return response.data ;
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
