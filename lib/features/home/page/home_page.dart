import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nandiott_flutter/app/widgets/custombottombar.dart';
import 'package:nandiott_flutter/features/profile/widget/favFilm_card_widget.dart';
import 'package:nandiott_flutter/features/search/widget/film_card_widget.dart';
import 'package:nandiott_flutter/features/home/widget/filterSelector_widget.dart';
import 'package:nandiott_flutter/app/widgets/skeltonLoader/filmSkelton.dart';
import 'package:nandiott_flutter/features/home/widget/featured_carousel_widget.dart';
import 'package:nandiott_flutter/features/home/provider/getContiuneMedia.dart';
import 'package:nandiott_flutter/features/home/provider/getMedia.dart';
import 'package:nandiott_flutter/features/profile/widget/historyCard_widget.dart';
import 'package:nandiott_flutter/features/profile/provider/watchHistory_provider.dart';
import 'package:nandiott_flutter/models/movie_model.dart';
import 'package:nandiott_flutter/models/user_model.dart';
import 'package:nandiott_flutter/features/auth/providers/checkauth_provider.dart';
import 'package:nandiott_flutter/features/home/provider/filter_fav_provider.dart';
import 'package:nandiott_flutter/features/home/provider/filter_provider.dart';
import 'package:nandiott_flutter/utils/Device_size.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends ConsumerState<HomePage> {
  final ScrollController _scrollController = ScrollController();
  final Map<String, GlobalKey> _sectionKeys = {};
  final Map<String, List<FocusNode>> _focusNodes = {};
  final FocusNode _featuredFocusNode =
      FocusNode(debugLabel: 'featuredsection_main');
  bool _isTV = false;
  bool _hasInitialFocus = false;
  bool _isNavigating = false; // Track if we're in the middle of navigation

  // Section keys for navigation
  static const String _featuredKey = 'featured';
  static const String _continueWatchingKey = 'continueWatching';
  static const String _newReleasesKey = 'newReleases';
  static const String _freeToWatchKey = 'freeToWatch';
  static const String _favoritesKey = 'favorites';

  @override
  void initState() {
    super.initState();

    // Initialize section keys
    _sectionKeys[_featuredKey] = GlobalKey();
    _sectionKeys[_continueWatchingKey] = GlobalKey();
    _sectionKeys[_newReleasesKey] = GlobalKey();
    _sectionKeys[_freeToWatchKey] = GlobalKey();
    _sectionKeys[_favoritesKey] = GlobalKey();

    // Initialize focus node lists
    _focusNodes[_featuredKey] = [_featuredFocusNode];
    _focusNodes[_continueWatchingKey] = [];
    _focusNodes[_newReleasesKey] = [];
    _focusNodes[_freeToWatchKey] = [];
    _focusNodes[_favoritesKey] = [];

    // Set up initial focus only once
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        Future.delayed(Duration(milliseconds: 500), () {
          if (mounted && !_hasInitialFocus) {
            _hasInitialFocus = true;
            final isMenuFocused = ref.read(isMenuFocusedProvider);
            _featuredFocusNode.requestFocus();
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _featuredFocusNode.dispose();
    // Dispose all focus nodes
    for (var nodeList in _focusNodes.values) {
      for (var node in nodeList) {
        if (node != _featuredFocusNode) {
          node.dispose();
        }
      }
    }
    super.dispose();
  }

  void _setFocusToSection(String sectionKey, {int itemIndex = 0}) {
    if (_isNavigating) return; // Prevent focus conflicts during navigation
    _isNavigating = true;

    final key = _sectionKeys[sectionKey];
    if (key?.currentContext != null) {
      // First ensure the section is visible
      Scrollable.ensureVisible(
        key!.currentContext!,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        alignment: 0.1,
      ).then((_) {
        // Wait for scroll animation to complete before requesting focus
        Future.delayed(const Duration(milliseconds: 100), () {
          if (mounted) {
            if (sectionKey == _featuredKey) {
              if (_featuredFocusNode.canRequestFocus) {
                _featuredFocusNode.requestFocus();
                setState(() {});
              }
            } else {
              final nodes = _focusNodes[sectionKey];
              if (nodes != null &&
                  nodes.isNotEmpty &&
                  itemIndex < nodes.length) {
                if (nodes[itemIndex].canRequestFocus) {
                  nodes[itemIndex].requestFocus();
                  setState(() {});
                }
              }
            }
            // Reset navigation flag after focus is set
            Future.delayed(Duration(milliseconds: 50), () {
              _isNavigating = false;
            });
          }
        });
      });
    } else {
      _isNavigating = false;
    }
  }

  void _handleKeyEvent(RawKeyEvent event) {
    if (!_isTV || event is! RawKeyDownEvent) return;

    // Get current focus position
    final currentFocus = FocusManager.instance.primaryFocus;
    if (currentFocus == null) return;

    // Special handling for featured carousel
    if (currentFocus == _featuredFocusNode ||
        currentFocus.debugLabel?.contains('featured_carousel') == true) {
      if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
        // Navigate down from featured
        _navigateDown(_featuredKey, 0);
        return;
      }
      // Let the carousel handle left/right navigation internally
      return;
    }

    // Find which section and item is currently focused
    String? currentSection;
    int? currentIndex;
    for (var entry in _focusNodes.entries) {
      final section = entry.key;
      final nodes = entry.value;
      for (int i = 0; i < nodes.length; i++) {
        if (nodes[i] == currentFocus) {
          currentSection = section;
          currentIndex = i;
          break;
        }
      }
      if (currentSection != null) break;
    }

    if (currentSection == null || currentIndex == null) return;

    // Handle navigation
    if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
      _navigateUp(currentSection, currentIndex);
    } else if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
      _navigateDown(currentSection, currentIndex);
    }
  }

  void _navigateUp(String currentSection, int currentIndex) {
    final sectionOrder = _getVisibleSections();
    final currentSectionIndex = sectionOrder.indexOf(currentSection);

    if (currentSectionIndex > 0) {
      // Move to previous section
      final previousSection = sectionOrder[currentSectionIndex - 1];
      if (previousSection == _featuredKey) {
        // Special case for navigating to featured section
        _setFocusToSection(_featuredKey);
      } else {
        final previousNodes = _focusNodes[previousSection];
        if (previousNodes != null && previousNodes.isNotEmpty) {
          // Try to maintain horizontal position or go to closest item
          final targetIndex = currentIndex < previousNodes.length
              ? currentIndex
              : previousNodes.length - 1;
          _setFocusToSection(previousSection, itemIndex: targetIndex);
        }
      }
    }
  }

  void _navigateDown(String currentSection, int currentIndex) {
    final sectionOrder = _getVisibleSections();
    final currentSectionIndex = sectionOrder.indexOf(currentSection);
    if (currentSectionIndex < sectionOrder.length - 1) {
      // Move to next section
      final nextSection = sectionOrder[currentSectionIndex + 1];
      final nextNodes = _focusNodes[nextSection];
      if (nextNodes != null && nextNodes.isNotEmpty) {
        // Try to maintain horizontal position or go to closest item
        final targetIndex = currentIndex < nextNodes.length
            ? currentIndex
            : nextNodes.length - 1;
        _setFocusToSection(nextSection, itemIndex: targetIndex);
      }
    }
  }

  List<String> _getVisibleSections() {
    final selectedFilter = ref.read(selectedFilterProvider);
    final sectionVisibilityAsync =
        ref.read(homeSectionVisibilityProvider(selectedFilter));
    final freeMediaAsync = ref.read(freeMediaProvider(selectedFilter));
    final hasContinueWatchingAsync =
        ref.read(hasContinueWatchingForContentTypeProvider(selectedFilter));

    final sections = <String>[_featuredKey]; // Featured is always visible

    // Check if continue watching has items AND is visible
    if (_isSectionVisible(sectionVisibilityAsync, 'isHistoryVisible') &&
        hasContinueWatchingAsync.whenOrNull(data: (hasItems) => hasItems) ==
            true) {
      sections.add(_continueWatchingKey);
    }

    if (_isSectionVisible(sectionVisibilityAsync, 'isLatestVisible')) {
      sections.add(_newReleasesKey);
    }

    if (freeMediaAsync is AsyncData &&
        freeMediaAsync.value?.isNotEmpty == true) {
      sections.add(_freeToWatchKey);
    }

    if (_isSectionVisible(sectionVisibilityAsync, 'isFavoritesVisible')) {
      sections.add(_favoritesKey);
    }

    return sections;
  }

  @override
  Widget build(BuildContext context) {
    _isTV = AppSizes.getDeviceType(context) == DeviceType.tv;

    // Watch the selected filter state
    final selectedFilter = ref.watch(selectedFilterProvider);

    // Get API media type for the selected filter
    final mediaType = _getApiMediaType(selectedFilter);

    // Watch section visibility settings for the selected filter
    final sectionVisibilityAsync =
        ref.watch(homeSectionVisibilityProvider(selectedFilter));

    // Watch media data based on the selected filter
    final latestMediaAsync = ref.watch(latestMediaProvider(selectedFilter));
    final freeMediaAsync = ref.watch(freeMediaProvider(selectedFilter));

    // Build list of visible sections
    final visibleSections = <String>[];
    if (_isSectionVisible(sectionVisibilityAsync, 'isHistoryVisible')) {
      visibleSections.add(_continueWatchingKey);
    }

    if (_isSectionVisible(sectionVisibilityAsync, 'isLatestVisible')) {
      visibleSections.add(_newReleasesKey);
    }

    if (freeMediaAsync is AsyncData &&
        freeMediaAsync.value?.isNotEmpty == true) {
      visibleSections.add(_freeToWatchKey);
    }

    if (_isSectionVisible(sectionVisibilityAsync, 'isFavoritesVisible')) {
      visibleSections.add(_favoritesKey);
    }

    // Get current auth user - Key change here to refresh when user state changes
    final userAsyncValue = ref.watch(authUserProvider);

    return Scaffold(
      body: RawKeyboardListener(
        focusNode: FocusNode(),
        onKey: _handleKeyEvent,
        child: SafeArea(
          child: SingleChildScrollView(
            controller: _scrollController,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Dynamic Filter Selector based on API response
                FilterSelector(
                  onFilterSelected: (filter) {
                    ref.read(selectedFilterProvider.notifier).state = filter;
                  },
                ),
                SizedBox(height: 5),

                // Featured Carousel Section
                Container(
                  key: _sectionKeys[_featuredKey],
                  margin: EdgeInsets.only(top: 10),
                  child: SimpleFeaturedCarousel(
                    filter: selectedFilter,
                    initialFocusNode: _featuredFocusNode,
                  ),
                ),

                // Continue Watching Section
                // This now properly depends on userAsyncValue, causing it to rebuild when auth changes
                if (visibleSections.contains(_continueWatchingKey))
                  _buildContinueWatchingSection(selectedFilter, userAsyncValue),

                // New Releases Section
                if (visibleSections.contains(_newReleasesKey))
                  Column(
                    key: _sectionKeys[_newReleasesKey],
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text('New Releases',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 15)),
                      ),
                      _buildMediaSection(
                        mediaAsync: latestMediaAsync,
                        mediaType: _getApiMediaType(selectedFilter),
                        sectionKey: _newReleasesKey,
                      ),
                    ],
                  ),

                // Free to Watch Section
                if (visibleSections.contains(_freeToWatchKey))
                  Column(
                    key: _sectionKeys[_freeToWatchKey],
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text('Free to Watch',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 15)),
                      ),
                      _buildMediaSection(
                        mediaAsync: freeMediaAsync,
                        mediaType: _getApiMediaType(selectedFilter),
                        sectionKey: _freeToWatchKey,
                      ),
                    ],
                  ),

                // Favorites Section
                if (_isSectionVisible(
                    sectionVisibilityAsync, 'isFavoritesVisible'))
                  _buildFavoritesSection(selectedFilter, mediaType),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMediaSection({
    required AsyncValue<List<Movie>?> mediaAsync,
    required String mediaType,
    required String sectionKey,
  }) {
    return mediaAsync.when(
      data: (movies) {
        if (movies == null || movies.isEmpty) return const SizedBox.shrink();

        // Initialize focus nodes for this section if needed
        if (_focusNodes[sectionKey]!.length < movies.length) {
          for (int i = _focusNodes[sectionKey]!.length;
              i < movies.length;
              i++) {
            _focusNodes[sectionKey]!.add(FocusNode(
              debugLabel: '${sectionKey}_item_$i',
            ));
          }
        }

        return SizedBox(
          height: 160,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.only(top: 8.0, left: 15),
            itemCount: movies.length,
            itemBuilder: (context, index) {
              final movie = movies[index];
              if (index >= _focusNodes[sectionKey]!.length) {
                return Container(); // Safety check
              }
              final focusNode = _focusNodes[sectionKey]![index];

              return FilmCard(
                film: movie,
                mediaType: mediaType,
                index: index,
                focusNode: focusNode,
                hasFocus: false,
                isLastItem: movies.length - 1 == index,
                onFocused: () {
                  // Update current item index when focus changes
                  if (!_isNavigating) {
                    setState(() {});
                  }
                },
              );
            },
          ),
        );
      },
      loading: () => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Padding(
              padding: const EdgeInsets.only(left: 10),
              child: Row(
                children: List.generate(5, (index) {
                  return const Padding(
                    padding: EdgeInsets.only(right: 10.0),
                    child: SkeletonLoader(),
                  );
                }),
              ),
            ),
          ),
        ],
      ),
      error: (error, stack) => Padding(
        padding: const EdgeInsets.all(15.0),
        child: Center(child: Text('Failed to load: $error')),
      ),
    );
  }

  // Updated continue watching section that properly depends on userAsyncValue
  Widget _buildContinueWatchingSection(
      String selectedFilter, AsyncValue<User?> userAsyncValue) {
    return userAsyncValue.when(
      data: (user) {
        if (user == null) {
          return const SizedBox.shrink(); // No user, no continue watching
        }

        // Now check if there are items for this user and filter
        final hasContinueWatchingAsync = ref
            .watch(hasContinueWatchingForContentTypeProvider(selectedFilter));

        // If we're still loading the check, show loading indicator
        if (hasContinueWatchingAsync is AsyncLoading) {
          return _buildLoadingContinueWatching();
        }

        // If there was an error or we know there are no items, show nothing
        if (hasContinueWatchingAsync is AsyncError ||
            (hasContinueWatchingAsync is AsyncData &&
                hasContinueWatchingAsync.value == false)) {
          return const SizedBox.shrink();
        }

        // We know there are items, so get the filtered list
        // Key change: Use the user.id to refresh continue watching data
        final filteredContinueWatchingAsync =
            ref.watch(filteredContinueWatchingProvider(selectedFilter));

        return _buildContinueWatchingContent(filteredContinueWatchingAsync);
      },
      loading: () => _buildLoadingContinueWatching(),
      error: (error, stack) => const SizedBox.shrink(),
    );
  }

  Widget _buildLoadingContinueWatching() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 5.0, left: 5.0, bottom: 5),
          child: Text('Continue Watching',
              style: TextStyle(fontWeight: FontWeight.bold)),
        ),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Padding(
            padding: const EdgeInsets.only(left: 10),
            child: Row(
              children: List.generate(5, (index) {
                return const Padding(
                  padding: EdgeInsets.only(right: 10.0),
                  child: SkeletonLoader(),
                );
              }),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildContinueWatchingContent(
      AsyncValue<List<WatchHistoryItem>> filteredContinueWatchingAsync) {
    return filteredContinueWatchingAsync.when(
      data: (watchHistoryItems) {
        if (watchHistoryItems.isEmpty) {
          return const SizedBox.shrink();
        }

        // Initialize focus nodes for this section if needed
        if (_focusNodes[_continueWatchingKey]!.length <
            watchHistoryItems.length) {
          for (int i = _focusNodes[_continueWatchingKey]!.length;
              i < watchHistoryItems.length;
              i++) {
            _focusNodes[_continueWatchingKey]!.add(FocusNode(
              debugLabel: '${_continueWatchingKey}_item_$i',
            ));
          }
        }

        return Column(
          key: _sectionKeys[_continueWatchingKey],
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.only(top: 10.0, left: 10.0, bottom: 5),
              child: Text(
                'Continue Watching',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(
              height: 160,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.only(top: 8.0, left: 15),
                itemCount: watchHistoryItems.length,
                itemBuilder: (context, index) {
                  final item = watchHistoryItems[index];
                  final focusNode = _focusNodes[_continueWatchingKey]![index];

                  return HistorycardWidget(
                      historyItem: item,
                      index: index,
                      focusNode: focusNode,
                      hasFocus: false,
                      isLastItem: watchHistoryItems.length - 1 == index,
                      onFocused: () {
                        // Update current item index when focus changes
                        if (!_isNavigating) {
                          setState(() {});
                        }
                      });
                },
              ),
            ),
          ],
        );
      },
      loading: () => _buildLoadingContinueWatching(),
      error: (error, stack) => Padding(
        padding: const EdgeInsets.all(15.0),
        child: Center(child: Text('Failed to load: $error')),
      ),
    );
  }

  Widget _buildFavoritesSection(String selectedFilter, String mediaType) {
    // Check if the user has favorites of this content type
    final hasFavoritesAsync =
        ref.watch(hasFavoritesForContentTypeProvider(selectedFilter));

    return hasFavoritesAsync.when(
      data: (hasFavorites) {
        if (!hasFavorites) {
          return SizedBox.shrink();
        }

        // Fetch the filtered favorites
        final filteredFavoritesAsync =
            ref.watch(filteredFavoritesProvider(selectedFilter));

        return filteredFavoritesAsync.when(
          data: (favoriteDetails) {
            if (favoriteDetails.isEmpty) {
              return SizedBox.shrink();
            }

            // Initialize focus nodes for this section if needed
            if (_focusNodes[_favoritesKey]!.length < favoriteDetails.length) {
              for (int i = _focusNodes[_favoritesKey]!.length;
                  i < favoriteDetails.length;
                  i++) {
                _focusNodes[_favoritesKey]!.add(FocusNode(
                  debugLabel: '${_favoritesKey}_item_$i',
                ));
              }
            }

            return Column(
              key: _sectionKeys[_favoritesKey],
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.only(top: 10.0, left: 10.0, bottom: 5),
                  child: Text(
                    'My Wishlist',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                SizedBox(
                  height: 160,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.only(top: 8.0, left: 15),
                    itemCount: favoriteDetails.length,
                    itemBuilder: (context, index) {
                      final item = favoriteDetails[index];
                      if (index >= _focusNodes[_favoritesKey]!.length) {
                        return Container(); // Safety check
                      }
                      final focusNode = _focusNodes[_favoritesKey]![index];
                      final favorite = item['favorite'];
                      final movieDetail = item['movieDetail'];

                      return Padding(
                        padding: const EdgeInsets.only(right: 10.0),
                        child: FavFilmCard(
                          film: movieDetail,
                          mediaType: favorite.contentType,
                          index: index,
                          focusNode: focusNode,
                          hasFocus: false,
                          isLastItem: favoriteDetails.length - 1 == index,
                          onFocused: () {
                            // Update current item index when focus changes
                            if (!_isNavigating) {
                              setState(() {});
                            }
                          },
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          },
          loading: () => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.only(top: 10.0, left: 10.0, bottom: 5),
                child: Text(
                  'My Wishlist',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Padding(
                  padding: const EdgeInsets.only(left: 10),
                  child: Row(
                    children: List.generate(5, (index) {
                      return const Padding(
                        padding: EdgeInsets.only(right: 10.0),
                        child: SkeletonLoader(),
                      );
                    }),
                  ),
                ),
              ),
            ],
          ),
          error: (error, stack) => Padding(
            padding: const EdgeInsets.all(15.0),
            child: Center(child: Text('Failed to load wishlist: $error')),
          ),
        );
      },
      loading: () => SizedBox.shrink(),
      error: (_, __) => SizedBox.shrink(),
    );
  }

  // Helper function to get the appropriate media type for API calls
  String _getApiMediaType(String filter) {
    switch (filter) {
      case 'Movies':
        return 'movie';
      case 'Series':
        return 'tvseries';
      case 'Short Film':
        return 'shortfilm';
      case 'Documentary':
        return 'documentary';
      case 'Music':
        return 'videosong';
      default:
        return 'movie';
    }
  }

  // Helper function to check if a section should be visible
  bool _isSectionVisible(
      AsyncValue<Map<String, dynamic>?> sectionVisibilityAsync,
      String sectionKey) {
    return sectionVisibilityAsync.when(
      data: (visibilityMap) {
        if (visibilityMap == null) return false;
        return visibilityMap[sectionKey] ?? false;
      },
      loading: () => false,
      error: (_, __) => false,
    );
  }
}
