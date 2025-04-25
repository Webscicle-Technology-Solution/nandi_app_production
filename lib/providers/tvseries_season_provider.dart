import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nandiott_flutter/models/tvSeries_model.dart';
import 'package:nandiott_flutter/providers/epsidoe_notifier.dart';
import 'package:nandiott_flutter/services/getBannerPoster_service.dart';
import 'package:nandiott_flutter/services/series_service.dart';

// Service Instance
final seriesServiceProvider = Provider((ref) => GetSeriesService());

final seasonsProvider =
    FutureProvider.family<List<Season>, String>((ref, seriesId) async {
  final service = GetSeriesService();
  return service.fetchAllSeasonsPaginated(seriesId);
});

// Season selector notifier
final selectedSeasonProvider = StateProvider<Season?>((ref) => null);

final paginatedEpisodesProvider = StateNotifierProvider.family<EpisodeNotifier,
    EpisodesState, ({String seriesId})>(
  (ref, args) {
    final service = ref.read(seriesServiceProvider);
    final season = ref.watch(selectedSeasonProvider);
    if (season == null) return EpisodeNotifier(service, args.seriesId,'');
    return EpisodeNotifier(service, args.seriesId, season.id);
  },
);

final posterProvider =
    FutureProvider.family<String?, String>((ref, episodeId) async {
  final service = getBannerPosterService();
  final response =
      await service.getPoster(mediaType: 'episode', mediaId: episodeId);
  if (response == null) return null;

  if (response['success'] == true && response['contentUrl'] != null) {
    return response['contentUrl'];
  }
  return null;
});
