import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:nandiott_flutter/models/tvSeries_model.dart';

class GetSeriesService {
  final Dio _dio = Dio();
  final baseUrl = dotenv.env['API_BASE_URL'];
  Future<List<Season>> fetchAllSeasonsPaginated(String seriesId) async {
  final List<Season> allSeasons = [];
  int currentPage = 1;
  int totalPages = 1;

  do {
    final url = '$baseUrl/admin/meta/tvseries/$seriesId/seasons/all?page=$currentPage';
    final response = await _dio.get(url);
    final data = response.data;

    if (data['success'] == true) {
      final result = data['result'];
      totalPages = result['totalPages'];
      final List seasons = result['seasons'];
      allSeasons.addAll(seasons.map((e) => Season.fromJson(e)).toList());
    } else {
      throw Exception(data['message'] ?? 'Failed to load seasons');
    }

    currentPage++;
  } while (currentPage <= totalPages);

  return allSeasons;
}


   Future<Map<String, dynamic>?> getAllEpisode({
  required String seriesId,
  required String seasonId,
  int page = 1,
  int limit = 5,
}) async {
  final url = '$baseUrl/admin/meta/tvseries/$seriesId/episodes/$seasonId/all?page=$page&limit=$limit';

  try {
    final response = await _dio.get(url);
    return response.data;
  } on DioException catch (e) {
    if (e.response?.data['message'] != null) {
      return {'message': e.response?.data['message'], 'success': false};
    } else {
      return {
        'message': 'Something went wrong, please try again later',
        'success': false,
      };
    }
  }
}
  Future<Map<String, dynamic>?> getAEpisodeDetail({
  required String seriesId,
  required String episodeId,
}) async {
  final url = '$baseUrl/admin/meta/tvseries/$seriesId/episodes/$episodeId';

  try {
    final response = await _dio.get(url);
    return response.data;
  } on DioException catch (e) {
    if (e.response?.data['message'] != null) {
      return {'message': e.response?.data['message'], 'success': false};
    } else {
      return {
        'message': 'Something went wrong, please try again later',
        'success': false,
      };
    }
  }
}

  Future <int> getASeasonDetail({
  required String seasonId,
}) async {
  final url = '$baseUrl/admin/meta/tvseries/seasons/$seasonId';

  try {
    final response = await _dio.get(url);
    if(response.data['message'] != null && response.data['success'] == true){
    return response.data['season']['seasonNumber'];  
    }else{
      return 0;
    }
  } on DioException catch (e) {
    if (e.response?.data['message'] != null) {
      return 0;
    } else {
      return 0;
    }
  }
}
}
