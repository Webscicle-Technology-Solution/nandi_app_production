import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nandiott_flutter/features/movieDetails/provider/detail_provider.dart';
import 'package:nandiott_flutter/services/getBannerPoster_service.dart';

final bannerProvider = FutureProvider.family<String?, MovieDetailParameter>((ref, params) async {
  final bannerService = getBannerPosterService();

  final response = await bannerService.getBanner(
    mediaType: params.mediaType,
    mediaId: params.movieId,
  );

  // Check if the response has a valid content URL
  if (response != null && response['success'] == true) {
    return response['contentUrl'];
  } else {
    return null; // Return null if the banner image isn't found
  }
});

final PosterProvider = FutureProvider.family<String?, MovieDetailParameter>((ref, params) async {
  final bannerService = getBannerPosterService();

  final response = await bannerService.getPoster(
    mediaType: params.mediaType,
    mediaId: params.movieId,
  );

  // Check if the response has a valid content URL
  if (response != null && response['success'] == true) {
    return response['contentUrl'];
  } else {
    return null; // Return null if the banner image isn't found
  }
});
