import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class PaymentService {
    final Dio dio = Dio();
  final baseUrl = dotenv.env['API_BASE_URL'];
  final storage = FlutterSecureStorage();

    // Fetch rentals
// Future<Map<String, dynamic>> payment(String movieId) async {
//     String accessToken = await storage.read(key: "accessToken") ?? '';
//   final url = '$baseUrl/payments/rent/movie/$movieId';
//   try {
//     dio.options.headers["Autorization"]= 'Bearer $accessToken';
//     final response=await dio.post(url);
//     return response.data;
//   } catch (e) {
    
//   }
// }

Future <Map<String, dynamic>> rentalPaymentService(String movieId,String redirectUrl)async{
  print("movieid and redirecturl in api are ${movieId} and ${redirectUrl}");
  String? accessToken=await storage.read(key: "accessToken");
  print("accestoken in rental payment is${accessToken}");
  final url="$baseUrl/payments/rent/movie/${movieId}";
  try {
      dio.options.headers["Authorization"]="Bearer $accessToken";
  final response= await dio.post(url,data: {
    "redirectUrl":redirectUrl
  });
      print('✅ API Response of rental payment is: ${response.data}');

  return response.data ;
  } on DioException catch (e) {
    print("error response in api in rental payment is ${e.response!.data}");
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
  print("subscriotion plan in api are ${subscriptionplan}}");
  String? accessToken=await storage.read(key: "accessToken");
  print("accestoken in rental payment is${accessToken}");
  final url="$baseUrl/payments/subscribe/${subscriptionplan}";
  try {
      dio.options.headers["Authorization"]="Bearer $accessToken";
  final response= await dio.post(url,data: {
    "redirectUrl":redirectUrl
  });
      print('✅ API Response of subscription payment is: ${response.data}');

  return response.data ;
  } on DioException catch (e) {
    print("error response in api in subscription payment is ${e.response!.data}");
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
