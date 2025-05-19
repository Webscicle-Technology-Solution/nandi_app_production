import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

final watchHistoryProvider = FutureProvider.family<List<WatchHistoryItem>, String>((ref, userId) async {
  final baseUrl = dotenv.env['API_BASE_URL']; // Your base URL from dotenv

  // Validate if userId is available
  if (userId.isEmpty) {
    throw Exception("User ID is not available");
  }

  final storage = FlutterSecureStorage();
  String? accessToken = await storage.read(key: 'accessToken');

  // If accessToken is null or empty, throw an error
  if (accessToken == null || accessToken.isEmpty) {
    throw Exception("Access token is not available or expired");
  }

  try {
    final response = await Dio().get(
      '$baseUrl/auth/history',
      options: Options(headers: {"Authorization": "Bearer $accessToken"}),
    );

    // Check if response is successful and contains history
    if (response.data['success'] == true && response.data['history'] != null) {
      final history = (response.data['history'] as List)
          .map((item) => WatchHistoryItem.fromJson(item))
          .toList();
          
      return history;
    } else {
      return [];
    }
  } catch (e) {
    throw e; // Throw the error so the consumer can handle it
  }
});


class WatchHistoryItem {
  final String contentId;
  final String contentType;
  final bool isCompleted;
  final double watchTime;
  final String? tvSeriesId;

  WatchHistoryItem({
    required this.contentId,
    required this.contentType,
    required this.isCompleted,
    required this.watchTime,
    this.tvSeriesId,
  });

  factory WatchHistoryItem.fromJson(Map<String, dynamic> json) {
    return WatchHistoryItem(
      contentId: json['contentId'] ?? '',  // Default to empty string if contentId is missing
      contentType: json['contentType'] ?? '',
      isCompleted: json['isCompleted'] ?? false,
      watchTime: json['watchTime']?.toDouble() ?? 0.0,  // Safeguard against null values
      tvSeriesId: json['tvSeriesId'],  // tvSeriesId will remain null if it's missing or explicitly null
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'contentId': contentId,
      'contentType': contentType,
      'isCompleted': isCompleted,
      'watchTime': watchTime,
      'tvSeriesId': tvSeriesId,
    };
  }
}


