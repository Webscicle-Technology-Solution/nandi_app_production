import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class WatchHistoryService {
  final Dio _dio = Dio();
  final baseUrl = dotenv.env['API_BASE_URL'];

  Future<int?> getWatchHistory({
    required String mediaId,
    required String mediaType,
    required String token,
  }) async {
    try {
      final response = await _dio.get(
        '$baseUrl/auth/history/$mediaType/$mediaId',
        options: Options(headers: {
          "Authorization": "Bearer $token",
        }),
      );

      if (response.data["success"] == true &&
          response.data["history"] != null) {
        return (response.data["history"]["watchTime"] as num).floor();
      }
    } catch (e) {
    }
    return null;
  }

  Future<void> updateWatchHistory({
    required String mediaId,
    required String mediaType,
    required double watchTime,
    required double duration,
    String? tvSeriesId,
    required String token,
  }) async {
    try {

      final response = await _dio.post(
        '$baseUrl/auth/history/update',
        data: {
          "mediaId": mediaId,
          "mediaType": tvSeriesId != null && tvSeriesId.isNotEmpty
              ? "tvseries"
              : mediaType,
          "watchTime": watchTime,
          "duration": duration,
          if (tvSeriesId != null) "tvSeriesId": tvSeriesId,
        },
        options: Options(headers: {
          "Authorization": "Bearer $token",
        }),
      );
    } catch (e) {
    }
  }

  Future<Map<String, dynamic>?> getContinueWatching() async {
    final url = '$baseUrl/auth/continuewatching';
    final storage = FlutterSecureStorage();

    String token = await storage.read(key: "accessToken") ?? "";

    try {

      final response = await _dio.get(
        url,
        options: Options(headers: {
          "Authorization": "Bearer $token",
        }),
      );
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
