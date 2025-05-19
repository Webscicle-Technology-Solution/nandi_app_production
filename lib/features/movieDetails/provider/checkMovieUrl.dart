import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

final trailerUrlValidityProvider =
    FutureProvider.family<String, dynamic>((ref, url) async {
  Dio dio = Dio();

  final secureStorage = FlutterSecureStorage();
  String? accessToken = await secureStorage.read(key: 'accessToken');

try {
    // If accessToken is provided, add it to the headers
    if (accessToken != null && accessToken.isNotEmpty) {
      dio.options.headers['Authorization'] = 'Bearer $accessToken';
    }
  
    // Making the request to the provided URL
    final response = await dio.get(url);

    // Check if the response status code is 200
    if (response.statusCode == 200) {
      return url; // Return the valid URL
    } else {
      return ''; // Invalid URL or some issue
    }
  } catch (e) {
    // If an error occurs (like network issues or invalid URL), return empty string
    return '';
  }
});
