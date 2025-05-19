import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nandiott_flutter/features/search/widget/film_card_widget.dart';
import 'package:nandiott_flutter/models/movie_model.dart';
import 'package:nandiott_flutter/features/movieDetails/page/detail_page.dart';
import 'package:nandiott_flutter/features/search/provider/search_provider.dart';

// Providers
final searchQueryProvider = StateProvider<String>((ref) => '');
final searchFilterProvider = StateProvider<String>((ref) => 'Movies');
final searchTextControllerProvider = Provider<TextEditingController>((ref) {
  final controller = TextEditingController();
  ref.onDispose(() => controller.dispose());
  return controller;
});

// Focus section tracking
enum TVSearchSection { filters, searchBox, keyboard, results }

final currentSearchSectionProvider =
    StateProvider<TVSearchSection>((ref) => TVSearchSection.keyboard);

class TVSearchPage extends ConsumerStatefulWidget {
  const TVSearchPage({super.key});

  @override
  ConsumerState<TVSearchPage> createState() => _TVSearchPageState();
}

class _TVSearchPageState extends ConsumerState<TVSearchPage> {
  final Map<String, String> mediaTypeMap = {
    'Movies': 'movies',
    'Series': 'tvseries',
    'Short Film': 'shortfilms',
    'Documentary': 'documentaries',
    'Music': 'videosongs',
  };

  // Parent focus node for the entire search page
  final _pageFocusNode = FocusNode(debugLabel: 'tv_search_page');

  // Section focus nodes
  final _filterSectionFocus = FocusNode(debugLabel: 'filter_section');
  final _searchBoxFocus = FocusNode(debugLabel: 'search_box');
  final _keyboardSectionFocus = FocusNode(debugLabel: 'keyboard_section');
  final _resultsSectionFocus = FocusNode(debugLabel: 'results_section');

  // Individual filter focus nodes
  late final List<FocusNode> _filterFocusNodes;

  // Individual keyboard key focus nodes
  late final List<FocusNode> _keyFocusNodes;

  // Result grid items focus nodes
  final List<FocusNode> _resultFocusNodes = [];

  final _debounceDuration = const Duration(milliseconds: 800);
  Timer? _debounceTimer;

  String _localQuery = '';
  int _selectedFilterIndex = 0;
  int _selectedKeyIndex = 0;
  int _focusedResultIndex = 0;

  // Keys for virtual keyboard
  final List<String> keys = [
    'A',
    'B',
    'C',
    'D',
    'E',
    'F',
    'G',
    'H',
    'I',
    'J',
    'K',
    'L',
    'M',
    'N',
    'O',
    'P',
    'Q',
    'R',
    'S',
    'T',
    'U',
    'V',
    'W',
    'X',
    'Y',
    'Z',
    'SPACE',
    'DEL',
    'SEARCH'
  ];

  @override
  void initState() {
    super.initState();

    // Initialize filter focus nodes
    _filterFocusNodes = List.generate(
      mediaTypeMap.length,
      (index) => FocusNode(debugLabel: 'filter_$index'),
    );

    // Initialize keyboard focus nodes
    _keyFocusNodes = List.generate(
      keys.length,
      (index) => FocusNode(debugLabel: 'key_${keys[index]}'),
    );

    // Set up focus change listeners
    _filterSectionFocus.addListener(_onFilterSectionFocusChange);
    _searchBoxFocus.addListener(_onSearchBoxFocusChange);
    _keyboardSectionFocus.addListener(_onKeyboardSectionFocusChange);
    _resultsSectionFocus.addListener(_onResultsSectionFocusChange);

    // Set initial focus after build is complete
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Default to keyboard section
      _keyFocusNodes[_selectedKeyIndex].requestFocus();
      ref.read(currentSearchSectionProvider.notifier).state =
          TVSearchSection.keyboard;
    });
  }

  @override
  void dispose() {
    _pageFocusNode.dispose();
    _filterSectionFocus.dispose();
    _searchBoxFocus.dispose();
    _keyboardSectionFocus.dispose();
    _resultsSectionFocus.dispose();

    for (final node in _filterFocusNodes) {
      node.dispose();
    }

    for (final node in _keyFocusNodes) {
      node.dispose();
    }

    for (final node in _resultFocusNodes) {
      node.dispose();
    }

    _debounceTimer?.cancel();
    super.dispose();
  }

  // Focus change listeners to track active section
  void _onFilterSectionFocusChange() {
    if (_filterSectionFocus.hasFocus) {
      ref.read(currentSearchSectionProvider.notifier).state =
          TVSearchSection.filters;
    }
  }

  void _onSearchBoxFocusChange() {
    if (_searchBoxFocus.hasFocus) {
      ref.read(currentSearchSectionProvider.notifier).state =
          TVSearchSection.searchBox;
    }
  }

  void _onKeyboardSectionFocusChange() {
    if (_keyboardSectionFocus.hasFocus) {
      ref.read(currentSearchSectionProvider.notifier).state =
          TVSearchSection.keyboard;
    }
  }

  void _onResultsSectionFocusChange() {
    if (_resultsSectionFocus.hasFocus) {
      ref.read(currentSearchSectionProvider.notifier).state =
          TVSearchSection.results;
    }
  }

  // Handle key press on virtual keyboard
  void _handleKeyPress(
      String key, String mediaType, TextEditingController controller) {
    if (key == 'SPACE') {
      _localQuery += ' ';
    } else if (key == 'DEL') {
      if (_localQuery.isNotEmpty) {
        _localQuery = _localQuery.substring(0, _localQuery.length - 1);
      }
    } else if (key == 'SEARCH') {
      _triggerSearch(mediaType, controller);
      // Move focus to results after search
      _resultsSectionFocus.requestFocus();
      if (_resultFocusNodes.isNotEmpty) {
        _resultFocusNodes[0].requestFocus();
        _focusedResultIndex = 0;
      }
      return;
    } else {
      _localQuery += key;
    }

    controller.text = _localQuery;
    ref.read(searchQueryProvider.notifier).state = _localQuery;

    _debounceTimer?.cancel();
    _debounceTimer = Timer(_debounceDuration, () {
      _triggerSearch(mediaType, controller);
    });
    setState(() {});
  }

  void _triggerSearch(String mediaType, TextEditingController controller) {
    final notifier = ref.read(searchPaginationProvider.notifier);
    final query = controller.text.trim();
    ref.read(searchQueryProvider.notifier).state = query;
    notifier.updateQuery(query);
    notifier.fetchSearchResults(mediaType, reset: true);
  }

  // Move focus between sections based on directional inputs
  KeyEventResult _handleDirectionalNavigation(RawKeyEvent event) {
    if (event is! RawKeyDownEvent) return KeyEventResult.ignored;

    final currentSection = ref.read(currentSearchSectionProvider);

    // Handle section navigation
    if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
      switch (currentSection) {
        case TVSearchSection.results:
          // Move from results to keyboard
          _keyboardSectionFocus.requestFocus();
          _keyFocusNodes[_selectedKeyIndex].requestFocus();
          return KeyEventResult.handled;
        case TVSearchSection.keyboard:
          // Move from keyboard to search box
          _searchBoxFocus.requestFocus();
          return KeyEventResult.handled;
        case TVSearchSection.searchBox:
          // Move from search box to filters
          _filterSectionFocus.requestFocus();
          _filterFocusNodes[_selectedFilterIndex].requestFocus();
          return KeyEventResult.handled;
        default:
          return KeyEventResult.ignored;
      }
    } else if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
      switch (currentSection) {
        case TVSearchSection.filters:
          // Move from filters to search box
          _searchBoxFocus.requestFocus();
          return KeyEventResult.handled;
        case TVSearchSection.searchBox:
          // Move from search box to keyboard
          _keyboardSectionFocus.requestFocus();
          _keyFocusNodes[_selectedKeyIndex].requestFocus();
          return KeyEventResult.handled;
        case TVSearchSection.keyboard:
          // Move from keyboard to results if we have results
          if (_resultFocusNodes.isNotEmpty) {
            _resultsSectionFocus.requestFocus();
            _resultFocusNodes[_focusedResultIndex].requestFocus();
            return KeyEventResult.handled;
          }
        default:
          return KeyEventResult.ignored;
      }
    }

    return KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context) {
    final selectedFilter = ref.watch(searchFilterProvider);
    final mediaType = mediaTypeMap[selectedFilter] ?? 'movies';
    final controller = ref.watch(searchTextControllerProvider);
    final searchState = ref.watch(searchPaginationProvider);
    final searchNotifier = ref.read(searchPaginationProvider.notifier);

    // Update result focus nodes when results change
    if (_resultFocusNodes.length != searchState.movies.length) {
      // Clear old focus nodes
      for (final node in _resultFocusNodes) {
        node.dispose();
      }
      _resultFocusNodes.clear();

      // Create new focus nodes
      for (int i = 0; i < searchState.movies.length; i++) {
        _resultFocusNodes.add(FocusNode(debugLabel: 'result_$i'));
      }
    }

    // Listen to filter changes and trigger search
    ref.listen<String>(searchFilterProvider, (prev, next) {
      _triggerSearch(mediaTypeMap[next] ?? 'movies', controller);
    });

    return Focus(
      focusNode: _pageFocusNode,
      onKey: (node, event) => _handleDirectionalNavigation(event),
      child: Scaffold(
        body: Row(
          children: [
            // LEFT SIDE - Search controls
            Container(
              width: 500,
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Filter section
                  Focus(
                    focusNode: _filterSectionFocus,
                    child: Container(
                      height: 50,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: mediaTypeMap.length,
                        // Add controller to enable programmatic scrolling
                        controller: ScrollController(),
                        // Add padding to ensure items are fully visible
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        itemBuilder: (context, index) {
                          final filter = mediaTypeMap.keys.elementAt(index);
                          final isSelected = selectedFilter == filter;

                          return Padding(
                            padding: const EdgeInsets.only(right: 10),
                            child: Focus(
                              focusNode: _filterFocusNodes[index],
                              onFocusChange: (hasFocus) {
                                if (hasFocus) {
                                  _selectedFilterIndex = index;
                                  // Ensure the focused filter is visible by scrolling to it
                                  (context as Element)
                                      .findRenderObject()
                                      ?.showOnScreen(
                                        descendant: _filterFocusNodes[index]
                                            .context
                                            ?.findRenderObject(),
                                        rect: Rect.fromLTWH(0, 0, 150,
                                            50), // Approximate size of the filter
                                      );
                                }
                              },
                              onKey: (node, event) {
                                if (event is RawKeyDownEvent) {
                                  // Select filter on Enter/Select
                                  if (event.logicalKey ==
                                          LogicalKeyboardKey.select ||
                                      event.logicalKey ==
                                          LogicalKeyboardKey.enter) {
                                    ref
                                        .read(searchFilterProvider.notifier)
                                        .state = filter;
                                    return KeyEventResult.handled;
                                  }

                                  // Handle left/right navigation between filters
                                  if (event.logicalKey ==
                                      LogicalKeyboardKey.arrowLeft) {
                                    if (index > 0) {
                                      _filterFocusNodes[index - 1]
                                          .requestFocus();
                                      setState(() {});
                                      return KeyEventResult.handled;
                                    } else {
                                      
                                      return KeyEventResult.handled;
                                    }
                                  } else if (event.logicalKey ==
                                      LogicalKeyboardKey.arrowRight) {
                                    if (index < mediaTypeMap.length - 1) {
                                      _filterFocusNodes[index + 1]
                                          .requestFocus();
                                      setState(() {});
                                      return KeyEventResult.handled;
                                    }
                                  }
                                }
                                return KeyEventResult.ignored;
                              },
                              child: SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: NewFilterContainer(
                                  filterOption: filter,
                                  isSelected: isSelected,
                                  hasFocus: _filterFocusNodes[index].hasFocus,
                                  onTap: () {
                                    ref
                                        .read(searchFilterProvider.notifier)
                                        .state = filter;
                                  },
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Search box
                  Focus(
                    focusNode: _searchBoxFocus,
                    onKey: (node, event) {
                      if (event is RawKeyDownEvent) {
                        if (event.logicalKey == LogicalKeyboardKey.select ||
                            event.logicalKey == LogicalKeyboardKey.enter) {
                          // Move to keyboard on Enter
                          _keyboardSectionFocus.requestFocus();
                          _keyFocusNodes[_selectedKeyIndex].requestFocus();
                          return KeyEventResult.handled;
                        }
                      }
                      return KeyEventResult.ignored;
                    },
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      width: double.infinity,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: _searchBoxFocus.hasFocus
                              ? Colors.amber
                              : Colors.grey,
                          width: _searchBoxFocus.hasFocus ? 3 : 1,
                        ),
                        borderRadius: BorderRadius.circular(10),
                        color: Theme.of(context).primaryColorLight,
                      ),
                      child: Text(
                        _localQuery.isEmpty ? "Search..." : _localQuery,
                        style: TextStyle(
                          fontSize: 20,
                          color: _localQuery.isEmpty
                              ? Colors.grey
                              : Theme.of(context).primaryColorDark,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Virtual keyboard
                  Expanded(
                    child: Focus(
                      focusNode: _keyboardSectionFocus,
                      child: GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: keys.length,
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 9,
                          mainAxisSpacing: 8,
                          crossAxisSpacing: 8,
                          childAspectRatio: 1.2,
                        ),
                        itemBuilder: (context, index) {
                          final key = keys[index];
                          final isSpecialKey =
                              key == 'SPACE' || key == 'DEL' || key == 'SEARCH';

                          return Focus(
                            focusNode: _keyFocusNodes[index],
                            onFocusChange: (hasFocus) {
                              if (hasFocus) {
                                _selectedKeyIndex = index;
                                setState(() {});
                              }
                            },
                            onKey: (node, event) {
                              if (event is RawKeyDownEvent) {
                                if (event.logicalKey ==
                                        LogicalKeyboardKey.select ||
                                    event.logicalKey ==
                                        LogicalKeyboardKey.enter) {
                                  _handleKeyPress(key, mediaType, controller);
                                  return KeyEventResult.handled;
                                }

                                // Handle keyboard grid navigation
                                final int row = index ~/ 9;
                                final int col = index % 9;

                                if (event.logicalKey ==
                                    LogicalKeyboardKey.arrowLeft) {
                                  if (col > 0) {
                                    _keyFocusNodes[index - 1].requestFocus();
                                    return KeyEventResult.handled;
                                  }
                                } else if (event.logicalKey ==
                                    LogicalKeyboardKey.arrowRight) {
                                  if (col < 8 && index < keys.length - 1) {
                                    _keyFocusNodes[index + 1].requestFocus();
                                    return KeyEventResult.handled;
                                  }
                                } else if (event.logicalKey ==
                                    LogicalKeyboardKey.arrowUp) {
                                  if (row > 0) {
                                    final targetIndex = index - 9;
                                    if (targetIndex >= 0) {
                                      _keyFocusNodes[targetIndex]
                                          .requestFocus();
                                      return KeyEventResult.handled;
                                    }
                                  }
                                } else if (event.logicalKey ==
                                    LogicalKeyboardKey.arrowDown) {
                                  final targetIndex = index + 9;
                                  if (targetIndex < keys.length) {
                                    _keyFocusNodes[targetIndex].requestFocus();
                                    return KeyEventResult.handled;
                                  } else if (searchState.movies.isNotEmpty) {
                                    // Move to results grid if we're on the bottom row
                                    _resultsSectionFocus.requestFocus();
                                    _resultFocusNodes[0].requestFocus();
                                    _focusedResultIndex = 0;
                                    return KeyEventResult.handled;
                                  }
                                }
                              }
                              return KeyEventResult.ignored;
                            },
                            child: KeyboardKey(
                              text: key,
                              isSelected: _keyFocusNodes[index].hasFocus,
                              isSpecial: isSpecialKey,
                              onTap: () =>
                                  _handleKeyPress(key, mediaType, controller),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // RIGHT SIDE - Results grid
            Expanded(
              child: Focus(
                focusNode: _resultsSectionFocus,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Results heading
                      Text(
                        searchState.query.isEmpty
                            ? "Search Results"
                            : 'Results for "${searchState.query}"',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).primaryColorDark,
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Results grid
                      Expanded(
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
                          child: searchState.isLoading &&
                                  searchState.movies.isEmpty
                              ? const Center(
                                  child: CircularProgressIndicator(
                                      color: Colors.amber))
                              : searchState.movies.isEmpty &&
                                      searchState.query.isNotEmpty
                                  ? Center(
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(Icons.search_off,
                                              size: 80, color: Colors.grey),
                                          SizedBox(height: 16),
                                          Text(
                                            "No results found for \"${searchState.query}\"",
                                            style: TextStyle(
                                                fontSize: 18,
                                                color: Colors.grey),
                                          ),
                                        ],
                                      ),
                                    )
                                  : GridView.builder(
                                      gridDelegate:
                                          const SliverGridDelegateWithFixedCrossAxisCount(
                                        crossAxisCount: 3,
                                        childAspectRatio: 0.75,
                                        crossAxisSpacing: 8.0,
                                        mainAxisSpacing: 14.0,
                                      ),
                                      itemCount: searchState.movies.length +
                                          (searchState.isLoading ? 1 : 0),
                                      itemBuilder: (context, index) {
                                        if (index ==
                                            searchState.movies.length) {
                                          return const Center(
                                              child: CircularProgressIndicator(
                                                  color: Colors.amber));
                                        }

                                        return Focus(
                                          focusNode: _resultFocusNodes[index],
                                          onFocusChange: (hasFocus) {
                                            if (hasFocus) {
                                              _focusedResultIndex = index;
                                              // Ensure the film card is visible when focused
                                              (context as Element)
                                                  .findRenderObject()
                                                  ?.showOnScreen(
                                                    descendant:
                                                        _resultFocusNodes[index]
                                                            .context
                                                            ?.findRenderObject(),
                                                  );
                                            }
                                          },
                                          onKey: (node, event) {
                                            if (event is RawKeyDownEvent) {
                                              if (event.logicalKey ==
                                                      LogicalKeyboardKey
                                                          .select ||
                                                  event.logicalKey ==
                                                      LogicalKeyboardKey
                                                          .enter) {
                                                // Handle selection
                                                // Navigate to movie details page
                                                _navigateToMovieDetails(
                                                  searchState.movies[index],
                                                  mediaType,
                                                  context,
                                                );
                                                return KeyEventResult.handled;
                                              }

                                              // Fix grid navigation calculations
                                              // Calculate rows and columns based on the actual grid layout
                                              final int row = index ~/
                                                  4; // Using 4 as the crossAxisCount
                                              final int col = index % 4;

                                              if (event.logicalKey ==
                                                  LogicalKeyboardKey
                                                      .arrowLeft) {
                                                if (col > 0) {
                                                  _resultFocusNodes[index - 1]
                                                      .requestFocus();
                                                  setState(() {});
                                                  return KeyEventResult.handled;
                                                } else {
                                                  // If we're at the leftmost edge of results grid,
                                                  // move focus to the left side controls
                                                  _keyboardSectionFocus
                                                      .requestFocus();
                                                  _keyFocusNodes[
                                                          _selectedKeyIndex]
                                                      .requestFocus();
                                                  setState(() {});
                                                  return KeyEventResult.handled;
                                                }
                                              } else if (event.logicalKey ==
                                                  LogicalKeyboardKey
                                                      .arrowRight) {
                                                if (col < 3 &&
                                                    index <
                                                        searchState
                                                                .movies.length -
                                                            1) {
                                                  setState(() {});
                                                  _resultFocusNodes[index + 1]
                                                      .requestFocus();
                                                  return KeyEventResult.handled;
                                                }
                                              } else if (event.logicalKey ==
                                                  LogicalKeyboardKey.arrowUp) {
                                                if (row > 0) {
                                                  final targetIndex = index - 4;
                                                  if (targetIndex >= 0) {
                                                    setState(() {});
                                                    _resultFocusNodes[
                                                            targetIndex]
                                                        .requestFocus();
                                                    return KeyEventResult
                                                        .handled;
                                                  }
                                                } else {
                                                  setState(() {});
                                                  // Move to keyboard if on top row
                                                  _keyboardSectionFocus
                                                      .requestFocus();
                                                  _keyFocusNodes[
                                                          _selectedKeyIndex]
                                                      .requestFocus();
                                                  return KeyEventResult.handled;
                                                }
                                              } else if (event.logicalKey ==
                                                  LogicalKeyboardKey
                                                      .arrowDown) {
                                                final targetIndex = index + 4;
                                                if (targetIndex <
                                                    searchState.movies.length) {
                                                  setState(() {});
                                                  _resultFocusNodes[targetIndex]
                                                      .requestFocus();
                                                  return KeyEventResult.handled;
                                                } else if (!searchState
                                                        .isLoading &&
                                                    !searchState.isLastPage) {
                                                  // User is on the last row, try to fetch more results
                                                  searchNotifier
                                                      .fetchSearchResults(
                                                          mediaType);
                                                  return KeyEventResult.handled;
                                                }
                                              }
                                            }
                                            return KeyEventResult.ignored;
                                          },
                                          child: FilmCard(
                                            film: searchState.movies[index],
                                            mediaType: mediaType,
                                            hasFocus: _resultFocusNodes[index]
                                                .hasFocus,
                                          ),
                                        );
                                      },
                                    ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Custom keyboard key widget
class KeyboardKey extends StatelessWidget {
  final String text;
  final bool isSelected;
  final bool isSpecial;
  final VoidCallback onTap;

  const KeyboardKey({
    Key? key,
    required this.text,
    required this.isSelected,
    required this.isSpecial,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Widget content;

    switch (text) {
      case 'DEL':
        content = const Icon(Icons.backspace, color: Colors.white);
        break;
      case 'SEARCH':
        content = const Icon(Icons.search, color: Colors.white);
        break;
      case 'SPACE':
        content = const Icon(Icons.space_bar, color: Colors.white);
        break;
      default:
        content = Text(
          text,
          style: TextStyle(
            color: isSelected ? Colors.black : Colors.white,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        );
        break;
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected ? Colors.amber : Colors.grey[850],
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: isSelected ? Colors.white : Colors.transparent,
            width: isSelected ? 2 : 0,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.amber.withOpacity(0.6),
                    blurRadius: 10,
                    spreadRadius: 2,
                  )
                ]
              : null,
        ),
        child: content,
      ),
    );
  }
}

void _navigateToMovieDetails(
    Movie movie, String mediatype, BuildContext context) {
  // Implement navigation to movie details
  Navigator.of(context).push(MaterialPageRoute(
    builder: (context) => MovieDetailPage(
      movieId: movie.id,
      mediaType: mediatype,
      userId: '',
    ),
  ));
}

// Custom filter container with focus support
class NewFilterContainer extends StatelessWidget {
  final String filterOption;
  final bool isSelected;
  final bool hasFocus;
  final VoidCallback onTap;

  const NewFilterContainer({
    Key? key,
    required this.filterOption,
    required this.isSelected,
    this.hasFocus = false,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: isSelected ? Colors.amber : Colors.transparent,
          border: Border.all(
            color: hasFocus && !isSelected ? Colors.amber : Colors.transparent,
            width: 2,
          ),
        ),
        child: Text(
          filterOption,
          style: TextStyle(
            color: isSelected
                ? Colors.black
                : hasFocus
                    ? Colors.amber
                    : Theme.of(context).primaryColorDark,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}