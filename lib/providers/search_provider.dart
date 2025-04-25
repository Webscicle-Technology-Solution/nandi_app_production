// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:nandiott_flutter/services/search_service.dart';
// import 'package:nandiott_flutter/models/movie_model.dart';

// final searchQueryProvider = StateProvider<String>((ref) => '');

// final searchPaginationProvider = StateNotifierProvider<SearchPaginationNotifier, SearchPaginationState>(
//   (ref) => SearchPaginationNotifier(),
// );

// class SearchPaginationNotifier extends StateNotifier<SearchPaginationState> {
//   SearchPaginationNotifier() : super(SearchPaginationState());

//   final SearchService _searchService = SearchService();

//   Future<void> fetchSearchResults(String mediaType) async {
//     if (state.isLoading || state.isLastPage || state.query.isEmpty) return;

//     state = state.copyWith(isLoading: true);

//     try {
//       final response = await _searchService.searchMedia(
//         mediaType: mediaType,
//         query: state.query,
//         page: state.page, // Add pagination
//       );

//       if (response != null && response['success']) {
//         final results = response['results'][mediaType] as List<dynamic>;
//         final movies = results.map((movieData) => Movie.fromJson(movieData)).toList();

//         if (movies.isEmpty) {
//           state = state.copyWith(isLastPage: true);
//         } else {
//           state = state.copyWith(
//             movies: [...state.movies, ...movies],
//             page: state.page + 1,
//           );
//         }
//       }
//     } catch (e) {
//       state = state.copyWith(errorMessage: 'Error fetching search results: $e');
//     }

//     state = state.copyWith(isLoading: false);
//   }

//   void updateQuery(String query) {
//     state = SearchPaginationState(query: query);
//   }
// }

// class SearchPaginationState {
//   final List<Movie> movies;
//   final String query;
//   final int page;
//   final bool isLoading;
//   final bool isLastPage;
//   final String? errorMessage;

//   SearchPaginationState({
//     this.movies = const [],
//     this.query = '',
//     this.page = 1,
//     this.isLoading = false,
//     this.isLastPage = false,
//     this.errorMessage,
//   });

//   SearchPaginationState copyWith({
//     List<Movie>? movies,
//     String? query,
//     int? page,
//     bool? isLoading,
//     bool? isLastPage,
//     String? errorMessage,
//   }) {
//     return SearchPaginationState(
//       movies: movies ?? this.movies,
//       query: query ?? this.query,
//       page: page ?? this.page,
//       isLoading: isLoading ?? this.isLoading,
//       isLastPage: isLastPage ?? this.isLastPage,
//       errorMessage: errorMessage ?? this.errorMessage,
//     );
//   }
// }

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nandiott_flutter/services/search_service.dart';
import 'package:nandiott_flutter/models/movie_model.dart';

/// 🆕 Independent filter for SearchPage
final searchFilterProvider = StateProvider<String>((ref) => 'Movies');

/// Search query
final searchQueryProvider = StateProvider<String>((ref) => '');

/// Search state + logic
final searchPaginationProvider = StateNotifierProvider<SearchPaginationNotifier, SearchPaginationState>(
  (ref) => SearchPaginationNotifier(),
);

final searchTextControllerProvider = Provider.autoDispose<TextEditingController>((ref) {
  final controller = TextEditingController();

  // Keep the provider state in sync with text changes
  controller.addListener(() {
    ref.read(searchQueryProvider.notifier).state = controller.text;
  });

  return controller;
});

class SearchPaginationNotifier extends StateNotifier<SearchPaginationState> {
  SearchPaginationNotifier() : super(SearchPaginationState());

  final SearchService _searchService = SearchService();

  Future<void> fetchSearchResults(String mediaType, {bool reset = false}) async {
    if (state.isLoading || state.isLastPage || state.query.isEmpty) return;

    if (reset) {
      state = SearchPaginationState(query: state.query); // Reset state but keep query
    }

    state = state.copyWith(isLoading: true);

    try {
      final response = await _searchService.searchMedia(
        mediaType: mediaType,
        query: state.query,
        page: state.page,
      );

      if (response != null && response['success']) {
        final results = response['results'][mediaType] as List<dynamic>;
        final movies = results.map((movieData) => Movie.fromJson(movieData)).toList();

        if (movies.isEmpty) {
          state = state.copyWith(isLastPage: true);
        } else {
          state = state.copyWith(
            movies: [...state.movies, ...movies],
            page: state.page + 1,
          );
        }
      }
    } catch (e) {
      state = state.copyWith(errorMessage: 'Error fetching search results: $e');
    }

    state = state.copyWith(isLoading: false);
  }

  void updateQuery(String query) {
    state = SearchPaginationState(query: query); // Resets everything on new query
  }
}

class SearchPaginationState {
  final List<Movie> movies;
  final String query;
  final int page;
  final bool isLoading;
  final bool isLastPage;
  final String? errorMessage;

  SearchPaginationState({
    this.movies = const [],
    this.query = '',
    this.page = 1,
    this.isLoading = false,
    this.isLastPage = false,
    this.errorMessage,
  });

  SearchPaginationState copyWith({
    List<Movie>? movies,
    String? query,
    int? page,
    bool? isLoading,
    bool? isLastPage,
    String? errorMessage,
  }) {
    return SearchPaginationState(
      movies: movies ?? this.movies,
      query: query ?? this.query,
      page: page ?? this.page,
      isLoading: isLoading ?? this.isLoading,
      isLastPage: isLastPage ?? this.isLastPage,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
