import 'package:nandiott_flutter/services/getBannerPoster_service.dart';

class PosterHelper {
  final getBannerPosterService _getBannerPosterService;

  PosterHelper(this._getBannerPosterService);

  Future<String> getPosterImage({required String mediaType, required String mediaId}) async {
    final response = await _getBannerPosterService.getPoster(mediaType: mediaType, mediaId: mediaId);

    if (response != null && response['success']) {
      return response['contentUrl'];
    } else {
      return "";
    }
  }

  Future<String> getBannerImage({required String mediaType, required String mediaId}) async {
    final response = await _getBannerPosterService.getBanner(mediaType: mediaType, mediaId: mediaId);

    if (response != null && response['success']) {
      return response['contentUrl'];
    } else {
      return "";
    }
  }


}
