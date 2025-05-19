import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ContentService {
  final baseUrl = dotenv.env['API_BASE_URL'];
  final Dio _dio = Dio();

  // Mapping of API parameters to content types
  final Map<String, String> apiToContentType = {
    'movie': 'Movie',
    'tvseries': 'TVSeries',
    'shortfilm': 'ShortFilm',
    'documentary': 'Documentary',
    'videosong': 'VideoSong',
  };

  // Fetch visibility settings for a specific content type
  Future<Map<String, dynamic>?> getHomeContentSettings(String mediaType) async {
    try {
      final response = await _dio.get('$baseUrl/admin/meta/sections/$mediaType');

      if (response.statusCode == 200) {
        final responseData = response.data;
        if (responseData['success'] == true && responseData['data'] != null) {
          return responseData['data'];
        }
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // Fetch all available content types with their visibility settings
  Future<List<Map<String, dynamic>>> getVisibleContentTypes() async {
    List<Map<String, dynamic>> visibleContentTypes = [];
    
    // List of all possible media types in API format
    final List<String> allMediaTypes = ['movie', 'tvseries', 'shortfilm', 'documentary', 'videosong'];
    
    for (String mediaType in allMediaTypes) {
      try {
        final settings = await getHomeContentSettings(mediaType);
        if (settings != null) {
          bool isVisible = settings['isCategoriesVisible'] == true;
          
          if (isVisible) {
            visibleContentTypes.add({
              'mediaType': mediaType,               // API parameter (e.g., 'movie')
              'contentType': apiToContentType[mediaType] ?? mediaType, // Internal content type (e.g., 'Movie')
              'settings': settings,
            });
          }
        }
      } catch (e) {
      }
    }
    
    return visibleContentTypes;
  }
}