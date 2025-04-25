import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nandiott_flutter/models/fav_movie.dart';
import 'package:nandiott_flutter/providers/checkauth_provider.dart';
import 'package:nandiott_flutter/providers/detail_provider.dart';
import 'package:nandiott_flutter/services/favorites_service.dart';

// Async Notifier to manage the favorites state
class FavoritesNotifier extends AsyncNotifier<List<FavoriteMovie>> {
  final FavoritesService _favoritesService = FavoritesService();

@override
Future<List<FavoriteMovie>> build() async {
  final user = await ref.watch(authUserProvider.future);

  if (user == null) {
    return []; // Not logged in, return empty
  }

  final response = await _favoritesService.getFavorites();

  if (response != null && response.success) {
    // ⬇️ Fix here: return empty list if content is null
    return response.content ?? [];
  } else {
    return [];
  }
}


  Future<void> toggleFavorite(String movieId, String type) async {
    // Normalize content type for API compatibility
    Map<String, String> mediaCategoryApiMap = {
      'Movies': 'movie',
      'Movie': 'movie',
      'TVSeries': 'tvseries',
      'Series': 'tvseries',
      'tvseries': 'tvseries',
      'Short Film': 'shortfilm',
      'ShortFilm': 'shortfilm',
      'shortfilm': 'shortfilm',
      'Documentary': 'documentary',
      'documentary': 'documentary',
      'Music': 'videosong',
      'videosong': 'videosong',
      'VideoSong': 'videosong',
    };

    final apiMediaType = mediaCategoryApiMap[type] ?? type;

    final currentState = state.value ?? [];
    final isCurrentlyFavorite =
        currentState.any((movie) => movie.contentId == movieId);

    // Optimistic UI update
    if (isCurrentlyFavorite) {
      state = AsyncData(
        currentState.where((movie) => movie.contentId != movieId).toList(),
      );
    } else {
      state = AsyncData([
        ...currentState,
        FavoriteMovie(
          contentId: movieId,
          contentType: type,
        ),
      ]);
    }

    // Make actual API call
    final success =
        await _favoritesService.updateFavorite(movieId, apiMediaType);

    if (!success) {
      // Revert on failure
      state = AsyncData(currentState);
    }
  }
}

// Main favorites provider
final favoritesProvider =
    AsyncNotifierProvider<FavoritesNotifier, List<FavoriteMovie>>(() {
  return FavoritesNotifier();
});

// Check if a movie is in favorites
final isMovieFavoriteProvider = Provider.family<bool, String>((ref, contentId) {
  final favoritesAsync = ref.watch(favoritesProvider);

  return favoritesAsync.when(
    data: (favoriteMovies) =>
        favoriteMovies.any((movie) => movie.contentId == contentId),
    loading: () => false,
    error: (_, __) => false,
  );
});

// For profile: Get favorite movies with their detailed info
final favoritesWithDetailsProvider =
    FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final user = await ref.watch(authUserProvider.future);
  if (user == null) return [];

  final favorites = await ref.watch(favoritesProvider.future);

  List<Map<String, dynamic>> moviesWithDetails = [];

  for (var favorite in favorites) {
    try {
      final params = MovieDetailParameter(
        movieId: favorite.contentId,
        mediaType: favorite.contentType,
      );

      final movieDetail = await ref.watch(movieDetailProvider(params).future);

      if (movieDetail != null) {
        moviesWithDetails.add({
          'favorite': favorite,
          'movieDetail': movieDetail,
        });
      }
    } catch (e) {
      print('Error fetching details for movie ${favorite.contentId}: $e');
      // Continue to next
    }
  }

  return moviesWithDetails;
});
