import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nandiott_flutter/models/tvSeries_model.dart';
import 'package:nandiott_flutter/services/series_service.dart';

class EpisodesState {
  final List<Episode> episodes;
  final int currentPage;
  final int totalPages;
  final bool isLoading;
  final bool hasError;

  EpisodesState({
    required this.episodes,
    required this.currentPage,
    required this.totalPages,
    this.isLoading = false,
    this.hasError = false,
  });

  EpisodesState copyWith({
    List<Episode>? episodes,
    int? currentPage,
    int? totalPages,
    bool? isLoading,
    bool? hasError,
  }) {
    return EpisodesState(
      episodes: episodes ?? this.episodes,
      currentPage: currentPage ?? this.currentPage,
      totalPages: totalPages ?? this.totalPages,
      isLoading: isLoading ?? this.isLoading,
      hasError: hasError ?? this.hasError,
    );
  }
}

class EpisodeNotifier extends StateNotifier<EpisodesState> {
  final GetSeriesService service;
  final String seriesId;
  final String seasonId;

  EpisodeNotifier(this.service, this.seriesId, this.seasonId)
      : super(EpisodesState(episodes: [], currentPage: 0, totalPages: 1)) {
    fetchNextPage(); // load the first page
  }

  Future<void> fetchNextPage() async {
    if (state.isLoading || state.currentPage >= state.totalPages) return;

    state = state.copyWith(isLoading: true, hasError: false);

    final nextPage = state.currentPage + 1;
    final res = await service.getAllEpisode(
      seriesId: seriesId,
      seasonId: seasonId,
      page: nextPage,
      limit: 5,
    );

    if (res?['success'] == true) {
      final episodesJson = res!['result']['episodes'] as List;
      final newEpisodes = episodesJson.map((e) => Episode.fromJson(e)).toList();

      state = state.copyWith(
        episodes: [...state.episodes, ...newEpisodes],
        currentPage: res['result']['currentPage'],
        totalPages: res['result']['totalPages'],
        isLoading: false,
      );
    } else {
      state = state.copyWith(isLoading: false, hasError: true);
    }
  }
}
