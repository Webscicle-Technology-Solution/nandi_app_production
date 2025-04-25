import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nandiott_flutter/models/watch_progress_model.dart';
import 'package:nandiott_flutter/services/series_service.dart';

// Reuse your existing series service provider
final seriesServiceProvider = Provider((ref) => GetSeriesService());

final tvSeriesWatchProgressProvider = FutureProvider.family<
    TVSeriesWatchProgress?, ({String seriesId, String episodeId})>((ref, args) async {
  final service = ref.read(seriesServiceProvider);

  // Step 1: Get episode detail
  final episodeDetail = await service.getAEpisodeDetail(
    seriesId: args.seriesId,
    episodeId: args.episodeId,
  );

  if (episodeDetail == null || episodeDetail['success'] != true) return null;

  final episodeNumber = episodeDetail['episode']['episodeNumber'] ?? 0;
  final duration = (episodeDetail['episode']['duration'] ?? 0).toDouble();
  final seasonId = episodeDetail['episode']['seasonId'];
  if (seasonId == null) return null;

  // Step 2: Get season number using seasonId
  final seasonDetail = await service.getASeasonDetail(seasonId: seasonId);
print("season detail is ${seasonDetail}");
  if (seasonDetail == 0) return null;

  // final seasonNumber = seasonDetail['seasonNumber'] ?? 0;

  return TVSeriesWatchProgress(
    episodeNumber: episodeNumber,
    duration: duration,
    seasonNumber: seasonDetail,
  );
});
