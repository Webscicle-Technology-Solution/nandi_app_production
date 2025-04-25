  // import 'package:flutter_riverpod/flutter_riverpod.dart';
  // import 'package:nandiott_flutter/services/getAllMedia_service.dart';
  // import 'package:nandiott_flutter/models/movie_model.dart';

  // // Provider for the selected filter
  // final filterProvider = StateProvider<String>((ref) => 'Movies'); // 

  // final mediaProvider = FutureProvider.family<List<dynamic>, String>((ref, filter) async {
    
  //   final mediaService = getAllMediaService();

  //       final filterToMediaTypeMap = {
  //       'Movies': 'movies',
  //       'Series': 'tvseries',
  //       'Short Film': 'shortfilms',
  //       'Documentary': 'documentaries',
  //       'Music': 'videosongs',
  //     };

  //     final mediaType = filterToMediaTypeMap[filter] ?? 'movies'; // Default to 'movie

  //   final response = await mediaService.getLatestMedia(mediaType: mediaType);

  //   if (response != null && response['success']) {
  //     // if (filter == 'Movies') {
  //     //   // Handle movies
  //     //   return (response['data']['items'] as List)
  //     //       .map((movieData) => Movie.fromJson(movieData))
  //     //       .toList();
  //     // } else if (filter == 'Series') {
  //     //   print("callinf the tvseries section ${response}");
  //     //   // Handle TV Series
  //     //   return (response['result']['tvSeries'] as List)
  //     //       .map((tvData) => Movie.fromJson(tvData))
  //     //       .toList();
  //     // } else if(filter == 'Short Film'){
  //     //   return (response['result']['shortFilms'] as List)
  //     //       .map((movieData) => Movie.fromJson(movieData))
  //     //       .toList();
  //     // }else if(filter == 'Documentary'){
  //     //   return (response['result']['documentaries'] as List)
  //     //       .map((movieData) => Movie.fromJson(movieData))
  //     //       .toList();
  //     // }else if(filter == 'Music'){
  //     //   return (response['result']['videoSongs'] as List)
  //     //       .map((movieData) => Movie.fromJson(movieData))
  //     //       .toList();
  //     // }
  //     // else {
  //     //   throw Exception('Unsupported filter type');
  //     // }
  //     return (response['data']['items'] as List)
  //         .map((movieData) => Movie.fromJson(movieData))
  //         .toList();
          
  //   } else {
  //     throw Exception('Failed to load $filter');
  //   }
  // });

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nandiott_flutter/models/movie_model.dart';
import 'package:nandiott_flutter/services/contentType_service.dart';
import 'package:nandiott_flutter/services/getAllMedia_service.dart';


// Provider for media service
final mediaServiceProvider = Provider((ref) => getAllMediaService());

// Provider for content service that fetches section visibility
final contentServiceProvider = Provider((ref) => ContentService());

// Provider to get home section visibility settings for the current filter
final homeSectionVisibilityProvider = FutureProvider.family<Map<String, dynamic>?, String>((ref, filter) async {
  final contentService = ref.watch(contentServiceProvider);
  
  // Map display filter name to API parameter
  final filterToMediaTypeMap = {
    'Movies': 'movie',
    'Series': 'tvseries',
    'Short Film': 'shortfilm',
    'Documentary': 'documentary',
    'Music': 'videosong',
  };
  
  final mediaType = filterToMediaTypeMap[filter] ?? 'movie';
  
  try {
    final settings = await contentService.getHomeContentSettings(mediaType);
    return settings;
  } catch (e) {
    print('Error fetching home content settings: $e');
    return null;
  }
});

// Provider for latest media (New Releases)
final latestMediaProvider = FutureProvider.family<List<Movie>, String>((ref, filter) async {
  final mediaService = ref.watch(mediaServiceProvider);
  
  final filterToMediaTypeMap = {
    'Movies': 'movies',
    'Series': 'tvseries',
    'Short Film': 'shortfilms',
    'Documentary': 'documentaries',
    'Music': 'videosongs',
  };
  
  final mediaType = filterToMediaTypeMap[filter] ?? 'movies';
  
  final response = await mediaService.getLatestMedia(mediaType: mediaType);
  
  if (response != null && response['success']) {
    // if (filter == 'Movies') {
    //   return (response['result']['movies'] as List)
    //       .map((movieData) => Movie.fromJson(movieData))
    //       .toList();
    // } else if (filter == 'Series') {
    //   return (response['result']['tvSeries'] as List)
    //       .map((tvData) => Movie.fromJson(tvData))
    //       .toList();
    // } else if (filter == 'Short Film') {
    //   return (response['result']['shortFilms'] as List)
    //       .map((movieData) => Movie.fromJson(movieData))
    //       .toList();
    // } else if (filter == 'Documentary') {
    //   return (response['result']['documentaries'] as List)
    //       .map((movieData) => Movie.fromJson(movieData))
    //       .toList();
    // } else if (filter == 'Music') {
    //   return (response['result']['videoSongs'] as List)
    //       .map((movieData) => Movie.fromJson(movieData))
    //       .toList();
    // } else {
    //   return [];
    // }
    
    return (response['data']['items'] as List)
        .map((movieData) => Movie.fromJson(movieData))
        .toList();
  } else {
    throw Exception('Failed to load latest $filter');
  }
});

// Provider for free media
final freeMediaProvider = FutureProvider.family<List<Movie>, String>((ref, filter) async {
  final mediaService = ref.watch(mediaServiceProvider);
  
  final filterToMediaTypeMap = {
    'Movies': 'movies',
    'Series': 'tvseries',
    'Short Film': 'shortfilms',
    'Documentary': 'documentaries',
    'Music': 'videosongs',
  };
  
  final mediaType = filterToMediaTypeMap[filter] ?? 'movies';
  
  final response = await mediaService.getFreeMedia(mediaType: mediaType);
  
  if (response != null && response['success']) {
    if (filter == 'Movies') {
      return (response['data']['movies'] as List)
          .map((movieData) => Movie.fromJson(movieData))
          .toList();
    } 
    // else if (filter == 'Series') {
    //   return (response['data']['tvSeries'] as List)
    //       .map((tvData) => Movie.fromJson(tvData))
    //       .toList();
    // } else if (filter == 'Short Film') {
    //   return (response['data']['shortFilms'] as List)
    //       .map((movieData) => Movie.fromJson(movieData))
    //       .toList();
    // } else if (filter == 'Documentary') {
    //   return (response['data']['documentaries'] as List)
    //       .map((movieData) => Movie.fromJson(movieData))
    //       .toList();
    // } else if (filter == 'Music') {
    //   return (response['data']['videoSongs'] as List)
    //       .map((movieData) => Movie.fromJson(movieData))
    //       .toList();
    // } 
    else {
      return [];
    }
  } else {
    throw Exception('Failed to load free $filter');
  }
});

// Provider for trending media (can be added similarly)
// final trendingMediaProvider = ...

// Helper function to check if a section should be visible
bool isSectionVisible(AsyncValue<Map<String, dynamic>?> sectionVisibility, String sectionKey) {
  return sectionVisibility.when(
    data: (data) => data != null && data[sectionKey] == true,
    loading: () => false, 
    error: (_, __) => false,
  );
}