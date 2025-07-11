import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:nandiott_flutter/models/fav_movie.dart';

class FavoritesService {
  final Dio _dio = Dio();
  final baseUrl = dotenv.env['API_BASE_URL'];
  static const storage = FlutterSecureStorage();

  Future<FavoriteMoviesResponse?> getFavorites() async {
    final accessToken = await storage.read(key: "accessToken");
    _dio.options.headers['Authorization'] = 'Bearer $accessToken';
    final url = '$baseUrl/auth/favorites';

    try {
      final response = await _dio.get(url);
      return FavoriteMoviesResponse.fromJson(response.data);
    } on DioException catch (e) {
      return null;
    }
  }

  Future<bool> updateFavorite(String movieId, String type) async {
    final accessToken = await storage.read(key: "accessToken");
    _dio.options.headers['Authorization'] = 'Bearer $accessToken';
    final url = '$baseUrl/auth/favorites';

    // Prepare the request body data
    final data = {
      "mediaId": movieId,
      "contentType": type,
    };
    try {
      final response =
          await _dio.put(url, data: data); // Send the data in the request body
      return response.statusCode == 200;
    } on DioException catch (e) {
      return false;
    }
  }
}
