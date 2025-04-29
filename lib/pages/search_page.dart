import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nandiott_flutter/app/widgets/customappbar.dart';
import 'package:nandiott_flutter/app/widgets/film_card_widget.dart';
import 'package:nandiott_flutter/app/widgets/filterSelector_widget.dart';
import 'package:nandiott_flutter/providers/filter_provider.dart';
import 'package:nandiott_flutter/providers/search_provider.dart';
import 'package:nandiott_flutter/utils/appstyle.dart';
import 'dart:async';

class SearchPage extends ConsumerStatefulWidget {
  const SearchPage({super.key});

  @override
  ConsumerState<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends ConsumerState<SearchPage> {
  final Map<String, String> mediaTypeMap = {
    'Movies': 'movies',
    'Series': 'tvseries',
    'Short Film': 'shortfilms',
    'Documentary': 'documentaries',
    'Music': 'videosongs',
  };

  final _debounceDuration = Duration(milliseconds: 800);
  Timer? _debounceTimer;

  bool _isEditing = false;

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final selectedFilter = ref.watch(searchFilterProvider);
    final mediaType = mediaTypeMap[selectedFilter] ?? 'movies';
    final searchController = ref.watch(searchTextControllerProvider);
    final searchState = ref.watch(searchPaginationProvider);
    final searchNotifier = ref.read(searchPaginationProvider.notifier);

    ref.listen<String>(searchFilterProvider, (previous, next) {
      final query = ref.read(searchQueryProvider);
      if (query.isNotEmpty) {
        final newMediaType = mediaTypeMap[next] ?? 'movies';
        searchNotifier.fetchSearchResults(newMediaType, reset: true);
      }
    });

    return Scaffold(
      appBar: const CustomAppBar(
          title: 'Search', showBackButton: true, showActionIcon: false),
      body: Column(
        children: [
          FilterSelector(
            onFilterSelected: (filter) {
              ref.read(selectedFilterProvider.notifier).state = filter;
            },
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: TextFormField(
              controller: searchController,
              autofocus: true,
              onChanged: (value) {
                _debounceTimer?.cancel();
                ref.read(searchQueryProvider.notifier).state = value;

                _debounceTimer = Timer(_debounceDuration, () {
                  searchNotifier.updateQuery(value);
                  searchNotifier.fetchSearchResults(mediaType, reset: true);
                });
              },
              onEditingComplete: () {
                FocusScope.of(context).unfocus();
              },
              decoration: InputDecoration(
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search,
                      size: 30, color: AppStyles.primaryColor),
                  onPressed: () {
                    final trimmed = searchController.text.trim();
                    ref.read(searchQueryProvider.notifier).state = trimmed;
                    searchNotifier.updateQuery(trimmed);
                    searchNotifier.fetchSearchResults(mediaType, reset: true);
                  },
                ),
                labelText: 'Search your favorite $mediaType',
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              child: NotificationListener<ScrollNotification>(
                onNotification: (scrollInfo) {
                  if (scrollInfo.metrics.pixels ==
                          scrollInfo.metrics.maxScrollExtent &&
                      !searchState.isLastPage &&
                      !searchState.isLoading) {
                    searchNotifier.fetchSearchResults(mediaType);
                  }
                  return false;
                },
                child: searchState.isLoading && searchState.movies.isEmpty
                    ? const Center(child: CircularProgressIndicator())
                    : searchState.movies.isEmpty &&
                            searchState.query.isNotEmpty
                        ? const Center(
                            child: Text("No results found",
                                style: TextStyle(fontSize: 18)))
                        : GridView.builder(
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 3,
                              childAspectRatio: 0.75,
                              crossAxisSpacing: 2.0,
                              mainAxisSpacing: 8.0,
                            ),
                            itemCount: searchState.movies.length +
                                (searchState.isLoading ? 1 : 0),
                            itemBuilder: (context, index) {
                              if (index == searchState.movies.length) {
                                return const Center(
                                    child: CircularProgressIndicator());
                              }
                              return FilmCard(
                                key: ValueKey(searchState.movies[index].id),
                                film: searchState.movies[index],
                                mediaType: mediaType,
                              );
                            },
                          ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
