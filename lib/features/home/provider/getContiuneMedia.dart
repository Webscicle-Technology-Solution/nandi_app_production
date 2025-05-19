import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nandiott_flutter/features/profile/provider/watchHistory_provider.dart';
import 'package:nandiott_flutter/services/watchhistory_service.dart';


// Define the Continue Watching provider
final continueWatchingProvider = FutureProvider<List<WatchHistoryItem>>((ref) async {
  final continueWatchingService = WatchHistoryService();
  final response = await continueWatchingService.getContinueWatching();  
  if (response != null && response['success']) {
    // Parse the data and return a list of WatchHistoryItem
    return (response['watchHistory'] as List)
        .map((historyItemData) => WatchHistoryItem.fromJson(historyItemData))
        .toList();
  } else {
    throw Exception('Failed to load continue watching data');
  }
});


// continue_watching_filter_provider.dart
// Reuse the same mapping from favorites

final filterToContentTypeMap = {
  'Movies': 'movie',
  'Series': 'tvseries',
  'Short Film': 'shortfilm',
  'Documentary': 'documentary',
  'Music': 'videosong',
};

// This provider only fetches the data once and caches it
final allContinueWatchingProvider = FutureProvider<List<WatchHistoryItem>>((ref) async {
  // Keep the original implementation but add caching
  final continueWatchingService = WatchHistoryService();
  final response = await continueWatchingService.getContinueWatching();
  
  if (response != null && response['success']) {
    return (response['watchHistory'] as List)
        .map((historyItemData) => WatchHistoryItem.fromJson(historyItemData))
        .toList();
  } else {
    throw Exception('Failed to load continue watching data');
  }
});

// Provider that filters continue watching by the selected content type
// This uses the cached data and just does the filtering
final filteredContinueWatchingProvider = Provider.family<AsyncValue<List<WatchHistoryItem>>, String>(
  (ref, selectedFilter) {
    final watchHistoryAsync = ref.watch(allContinueWatchingProvider);
    
    return watchHistoryAsync.when(
      data: (watchHistory) {
        // Get the API content type for the selected filter
        final contentType = filterToContentTypeMap[selectedFilter] ?? '';
        
        // If no specific filter is selected or 'All' is selected, return all items
        if (contentType.isEmpty) {
          return AsyncValue.data(watchHistory);
        }
        
        // Filter watch history by content type
        final filteredWatchHistory = watchHistory.where((item) => 
          item.contentType.toLowerCase() == contentType.toLowerCase()
        ).toList();
        
        return AsyncValue.data(filteredWatchHistory);
      },
      loading: () => const AsyncValue.loading(),
      error: (error, stack) => AsyncValue.error(error, stack),
    );
  }
);

// Provider to determine if there are continue watching items for a specific content type
// This also uses the cached data
final hasContinueWatchingForContentTypeProvider = Provider.family<AsyncValue<bool>, String>(
  (ref, selectedFilter) {
    final watchHistoryAsync = ref.watch(allContinueWatchingProvider);
    
    return watchHistoryAsync.when(
      data: (watchHistory) {
        if (watchHistory.isEmpty) {
          return const AsyncValue.data(false);
        }
        
        // Get the API content type for the selected filter
        final contentType = filterToContentTypeMap[selectedFilter] ?? '';
        
        // If no specific filter is selected or 'All' is selected, return true if there are any items
        if (contentType.isEmpty) {
          return AsyncValue.data(watchHistory.isNotEmpty);
        }
        
        // Check if there are any items with this content type
        final hasItems = watchHistory.any((item) => 
          item.contentType.toLowerCase() == contentType.toLowerCase()
        );
        
        return AsyncValue.data(hasItems);
      },
      loading: () => const AsyncValue.loading(),
      error: (error, stack) => AsyncValue.error(error, stack),
    );
  }
);