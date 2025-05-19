import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nandiott_flutter/features/auth/providers/checkauth_provider.dart';
import 'package:nandiott_flutter/features/movieDetails/provider/detail_provider.dart';
import 'package:nandiott_flutter/features/profile/provider/favourite_provider.dart';

// Mapping of display filter names to API content types
final filterToContentTypeMap = {
  'Movies': 'movie',
  'Series': 'tvseries',
  'Short Film': 'shortfilm',
  'Documentary': 'documentary',
  'Music': 'videosong',
};

// Provider that filters favorites by the selected content type
final filteredFavoritesProvider = FutureProvider.family<List<Map<String, dynamic>>, String>((ref, selectedFilter) async {
  final user = await ref.watch(authUserProvider.future);
  if (user == null) return [];

  // Get all favorites
  final favorites = await ref.watch(favoritesProvider.future);
  if (favorites.isEmpty) return [];
  
  // Get the API content type for the selected filter
  final contentType = filterToContentTypeMap[selectedFilter] ?? '';
  
  // Filter favorites by content type
  final filteredFavorites = favorites.where((favorite) => 
    favorite.contentType.toLowerCase() == contentType.toLowerCase()
  ).toList();
  
  if (filteredFavorites.isEmpty) return [];

  // Fetch details for each favorite
  List<Map<String, dynamic>> favoriteDetails = [];
  
  for (var favorite in filteredFavorites) {
    try {
      final params = MovieDetailParameter(
        movieId: favorite.contentId,
        mediaType: favorite.contentType,
      );

      final movieDetail = await ref.watch(movieDetailProvider(params).future);

      if (movieDetail != null) {
        favoriteDetails.add({
          'favorite': favorite,
          'movieDetail': movieDetail,
        });
      }
    } catch (e) {
      // Continue to next item
    }
  }

  return favoriteDetails;
});

// Provider to determine if there are favorites for a specific content type 
// (used to decide whether to show the section)
final hasFavoritesForContentTypeProvider = FutureProvider.family<bool, String>((ref, selectedFilter) async {
  final user = await ref.watch(authUserProvider.future);
  if (user == null) return false;

  // Get all favorites
  final favorites = await ref.watch(favoritesProvider.future);
  if (favorites.isEmpty) return false;
  
  // Get the API content type for the selected filter
  final contentType = filterToContentTypeMap[selectedFilter] ?? '';
  
  // Check if there are any favorites with this content type
  return favorites.any((favorite) => 
    favorite.contentType.toLowerCase() == contentType.toLowerCase()
  );
});