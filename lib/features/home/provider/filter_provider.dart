import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nandiott_flutter/services/contentType_service.dart';

// Provider for the content service
final contentServiceProvider = Provider((ref) => ContentService());

// Provider to fetch all visible content types based on API responses
final visibleContentTypesProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final contentService = ref.watch(contentServiceProvider);
  try {
    final visibleContentTypes = await contentService.getVisibleContentTypes();
    if (visibleContentTypes.isNotEmpty) {
      return visibleContentTypes;
    }
  } catch (e) {
  }
  
  // Fallback with default visibility if API calls fail
  return [
    {'mediaType': 'movie', 'contentType': 'Movie', 'settings': {'isCategoriesVisible': true}},
    {'mediaType': 'tvseries', 'contentType': 'TVSeries', 'settings': {'isCategoriesVisible': true}},
    {'mediaType': 'shortfilm', 'contentType': 'ShortFilm', 'settings': {'isCategoriesVisible': true}},
    {'mediaType': 'documentary', 'contentType': 'Documentary', 'settings': {'isCategoriesVisible': true}},
    {'mediaType': 'videosong', 'contentType': 'VideoSong', 'settings': {'isCategoriesVisible': true}},
  ];
});

// Provider to track the currently selected filter
// Default to the first available content type or 'Movies' if none
final selectedFilterProvider = StateProvider<String>((ref) {
  final visibleContentTypesAsync = ref.watch(visibleContentTypesProvider);
  return visibleContentTypesAsync.when(
    data: (contentTypes) {
      if (contentTypes.isNotEmpty) {
        return contentTypeDisplayNames[contentTypes.first['contentType']] ?? 'Movies';
      }
      return 'Movies';
    },
    loading: () => 'Movies',
    error: (_, __) => 'Movies',
  );
});

// Mapping for display names (API content type to display name)
final contentTypeDisplayNames = {
  'Movie': 'Movies',
  'TVSeries': 'Series',
  'ShortFilm': 'Short Film',
  'Documentary': 'Documentary',
  'VideoSong': 'Music',
};

// Mapping content type display names back to API media type parameters
final displayToApiMediaTypeMap = {
  'Movies': 'movie',
  'Series': 'tvseries',
  'Short Film': 'shortfilm',
  'Documentary': 'documentary',
  'Music': 'videosong',
};

// Get the API media type for a display name
String getApiMediaType(String displayName) {
  return displayToApiMediaTypeMap[displayName] ?? 'movie';
}

// Get the display name for a content type
String getDisplayName(String contentType) {
  return contentTypeDisplayNames[contentType] ?? contentType;
}