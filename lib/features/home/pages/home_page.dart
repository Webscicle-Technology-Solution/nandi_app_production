import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nandiott_flutter/app/widgets/custombottombar.dart';
import 'package:nandiott_flutter/app/widgets/favFilm_card_widget.dart';
import 'package:nandiott_flutter/app/widgets/film_card_widget.dart';
import 'package:nandiott_flutter/app/widgets/filterSelector_widget.dart';
import 'package:nandiott_flutter/app/widgets/skeltonLoader/filmSkelton.dart';
import 'package:nandiott_flutter/features/home/featured-movie/new_carousel.dart';
import 'package:nandiott_flutter/features/home/provider/getContiuneMedia.dart';
import 'package:nandiott_flutter/features/home/provider/getMedia.dart';
import 'package:nandiott_flutter/features/profile/watchHistory/historyCard_widget.dart';
import 'package:nandiott_flutter/models/movie_model.dart';
import 'package:nandiott_flutter/pages/detail_page.dart';
import 'package:nandiott_flutter/providers/checkauth_provider.dart';
import 'package:nandiott_flutter/providers/filter_fav_provider.dart';
import 'package:nandiott_flutter/providers/filter_provider.dart';
import 'package:nandiott_flutter/utils/Device_size.dart';


class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  late String userId;
  final ScrollController _scrollController = ScrollController();
  final Map<String, GlobalKey> _sectionKeys = {};
  final Map<String, List<FocusNode>> _focusNodes = {};
  final FocusNode _featuredFocusNode = FocusNode(debugLabel: 'featured_section_main');
  int _currentSectionIndex = 0;
  int _currentItemIndex = 0;
  bool _isTV = false;
  bool _isInitialized = false;
  bool _hasInitialFocus = false;
  bool _isNavigating = false; // Track if we're in the middle of navigation

    // Route observer for focus restoration
  RouteObserver<ModalRoute<void>>? _routeObserver;
  
  // Track the last focused section and item for restoration
  String? _lastFocusedSection;
  int? _lastFocusedItemIndex;
  
  // Section keys for navigation
  static const String _featuredKey = 'featured';
  static const String _continueWatchingKey = 'continueWatching';
  static const String _newReleasesKey = 'newReleases';
  static const String _freeToWatchKey = 'freeToWatch';
  static const String _favoritesKey = 'favorites';
  
  @override
  void initState() {
    super.initState();
    userId = "";
    
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
            _isInitialized = true;
            
            final isMenuFocused = ref.read(isMenuFocusedProvider);
            // if (!isMenuFocused && FocusManager.instance.primaryFocus == null) {
              print("HOME: Setting initial focus to featured section");
              _featuredFocusNode.requestFocus();
            // }
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
      print("Setting focus to section: $sectionKey, item: $itemIndex");
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
                setState(() {
                  _currentSectionIndex = _getVisibleSections().indexOf(sectionKey);
                  _currentItemIndex = 0;
                });
              }
            } else {
              final nodes = _focusNodes[sectionKey];
              if (nodes != null && nodes.isNotEmpty && itemIndex < nodes.length) {
                if (nodes[itemIndex].canRequestFocus) {
                  nodes[itemIndex].requestFocus();
                  setState(() {
                    _currentSectionIndex = _getVisibleSections().indexOf(sectionKey);
                    _currentItemIndex = itemIndex;
                  });
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
  
  void _ensureVisible(String sectionKey, int itemIndex) {
    _setFocusToSection(sectionKey, itemIndex: itemIndex);
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
        print("HOME: Navigating down from featured section");
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
      print("HOME: Navigating up from section: $currentSection");
      _navigateUp(currentSection, currentIndex);
    } else if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
      print("HOME: Navigating down from section: $currentSection");
      _navigateDown(currentSection, currentIndex);
    }
  }
  
  void _navigateUp(String currentSection, int currentIndex) {
    final sectionOrder = _getVisibleSections();
    final currentSectionIndex = sectionOrder.indexOf(currentSection);
    
    print("HOME: Current section index: $currentSectionIndex, sections: $sectionOrder");
    
    if (currentSectionIndex > 0) {
      // Move to previous section
      final previousSection = sectionOrder[currentSectionIndex - 1];
      print("HOME: Moving to previous section: $previousSection");
      
      if (previousSection == _featuredKey) {
        // Special case for navigating to featured section
        _setFocusToSection(_featuredKey);
      } else {
        final previousNodes = _focusNodes[previousSection];
        if (previousNodes != null && previousNodes.isNotEmpty) {
          // Try to maintain horizontal position or go to closest item
          final targetIndex = currentIndex < previousNodes.length ? currentIndex : previousNodes.length - 1;
          _setFocusToSection(previousSection, itemIndex: targetIndex);
        }
      }
    }
  }
  
  void _navigateDown(String currentSection, int currentIndex) {
    final sectionOrder = _getVisibleSections();
    final currentSectionIndex = sectionOrder.indexOf(currentSection);
    
    print("HOME: Current section index: $currentSectionIndex, sections: $sectionOrder");
    
    if (currentSectionIndex < sectionOrder.length - 1) {
      // Move to next section
      final nextSection = sectionOrder[currentSectionIndex + 1];
      print("HOME: Moving to next section: $nextSection");
      
      final nextNodes = _focusNodes[nextSection];
      
      if (nextNodes != null && nextNodes.isNotEmpty) {
        // Try to maintain horizontal position or go to closest item
        final targetIndex = currentIndex < nextNodes.length ? currentIndex : nextNodes.length - 1;
        _setFocusToSection(nextSection, itemIndex: targetIndex);
      }
    }
  }
  
  List<String> _getVisibleSections() {
    final selectedFilter = ref.read(selectedFilterProvider);
    final sectionVisibilityAsync = ref.read(homeSectionVisibilityProvider(selectedFilter));
    final freeMediaAsync = ref.read(freeMediaProvider(selectedFilter));
    final hasContinueWatchingAsync = ref.read(hasContinueWatchingForContentTypeProvider(selectedFilter));
    
    final sections = <String>[_featuredKey]; // Featured is always visible
    
    // Check if continue watching has items AND is visible
    if (isSectionVisible(sectionVisibilityAsync, 'isHistoryVisible') &&
        hasContinueWatchingAsync.whenOrNull(data: (hasItems) => hasItems) == true) {
      sections.add(_continueWatchingKey);
    }
    
    if (isSectionVisible(sectionVisibilityAsync, 'isLatestVisible')) {
      sections.add(_newReleasesKey);
    }
    
    if (freeMediaAsync is AsyncData && freeMediaAsync.value?.isNotEmpty == true) {
      sections.add(_freeToWatchKey);
    }
    
    if (isSectionVisible(sectionVisibilityAsync, 'isFavoritesVisible')) {
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
    final mediaType = getApiMediaType(selectedFilter);
    
    // Watch section visibility settings for the selected filter
    final sectionVisibilityAsync = ref.watch(homeSectionVisibilityProvider(selectedFilter));
    
    // Watch media data based on the selected filter
    final latestMediaAsync = ref.watch(latestMediaProvider(selectedFilter));
    final freeMediaAsync = ref.watch(freeMediaProvider(selectedFilter));

    // Get user for continue watching
    final userAsyncValue = ref.watch(authUserProvider);
  
    // Build list of visible sections
    final visibleSections = <String>[];
    if (isSectionVisible(sectionVisibilityAsync, 'isHistoryVisible')) {
      visibleSections.add('continueWatching');
    }
    if (isSectionVisible(sectionVisibilityAsync, 'isLatestVisible')) {
      visibleSections.add('newReleases');
    }
    if (freeMediaAsync is AsyncData && freeMediaAsync.value?.isNotEmpty == true) {
      visibleSections.add('freeToWatch');
    }
    if (isSectionVisible(sectionVisibilityAsync, 'isFavoritesVisible')) {
      visibleSections.add('favorites');
    }
    
    final continueWatchingState = userAsyncValue.when(
      data: (user) {
        if (user != null) {
          setState(() {
            userId = user.id;
          });
          return ref.watch(continueWatchingProvider);
        } else {
          return AsyncValue.data([]);
        }
      },
      loading: () => AsyncValue.loading(),
      error: (error, stack) => AsyncValue.error(error, stack),
    );

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
                if (visibleSections.contains('continueWatching'))
                  buildContinueWatchingSection(selectedFilter,_continueWatchingKey),

                // New Releases Section
                if (visibleSections.contains('newReleases'))
                  Column(
                    key: _sectionKeys[_newReleasesKey],
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text('New Releases', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                      ),
                      buildMediaSection(
                        mediaAsync: latestMediaAsync,
                        mediaType: getApiMediaType(selectedFilter),
                        sectionKey: _newReleasesKey,
                      ),
                    ],
                  ),

                // Free to Watch Section
                if (visibleSections.contains('freeToWatch'))
                  Column(
                    key: _sectionKeys[_freeToWatchKey],
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text('Free to Watch', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                      ),
                      buildMediaSection(
                        mediaAsync: freeMediaAsync,
                        mediaType: getApiMediaType(selectedFilter),
                        sectionKey: _freeToWatchKey,
                      ),
                    ],
                  ),
                  
                // Favorites Section
                if (isSectionVisible(sectionVisibilityAsync, 'isFavoritesVisible'))
                  _buildFavoritesSection(selectedFilter, mediaType,_favoritesKey)
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildMediaSection({
    required AsyncValue<List<Movie>?> mediaAsync,
    required String mediaType,
    required String sectionKey,
  }) {
    return mediaAsync.when(
      data: (movies) {
        if (movies == null || movies.isEmpty) return const SizedBox.shrink();

        // Initialize focus nodes for this section if needed
        if (_focusNodes[sectionKey]!.length < movies.length) {
          for (int i = _focusNodes[sectionKey]!.length; i < movies.length; i++) {
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
                    setState(() {
                      _currentSectionIndex = _getVisibleSections().indexOf(sectionKey);
                      _currentItemIndex = index;
                    });
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


  Widget buildContinueWatchingSection(String selectedFilter,String sectionKey) {
    // Use the provider that checks if there are items for this filter
    final hasContinueWatchingAsync = ref.watch(hasContinueWatchingForContentTypeProvider(selectedFilter));
    
    // If we're still loading the check, show nothing to prevent flicker
    if (hasContinueWatchingAsync is AsyncLoading) {
      return const SizedBox.shrink();
    }
    
    // If there was an error or we know there are no items, show nothing
    if (hasContinueWatchingAsync is AsyncError || 
        (hasContinueWatchingAsync is AsyncData && hasContinueWatchingAsync.value == false)) {
      return const SizedBox.shrink();
    }
    
    // We know there are items, so get the filtered list
    final filteredContinueWatchingAsync = ref.watch(filteredContinueWatchingProvider(selectedFilter));
    
    // If we're still loading the filtered list, show a loading indicator
    if (filteredContinueWatchingAsync is AsyncLoading) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 5.0, left: 5.0, bottom: 5),
            child: Text('Continue Watching'),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Padding(
              padding: const EdgeInsets.only(left: 10),
              child: Row(
                children: List.generate(5, (index) {
                  return const SkeletonLoader();
                }),
              ),
            ),
          ),
        ],
      );
    }
    
    // If there was an error, show an error message
    if (filteredContinueWatchingAsync is AsyncError) {
      return Padding(
        padding: const EdgeInsets.all(15.0),
        child: Center(child: Text('Failed to load: ${filteredContinueWatchingAsync.error}')),
      );
    }
    
    // We have data, so show the list
    final watchHistoryItems = (filteredContinueWatchingAsync as AsyncData).value;
    
    if (watchHistoryItems.isEmpty) {
      return const SizedBox.shrink();
    }

    // Initialize focus nodes for this section if needed
    // if (_focusNodes[_continueWatchingKey]!.length < watchHistoryItems.length) {
    //   for (int i = _focusNodes[_continueWatchingKey]!.length; i < watchHistoryItems.length; i++) {
    //     _focusNodes[_continueWatchingKey]!.add(FocusNode(
    //       debugLabel: 'continue_watching_item_$i',
    //     ));
    //   }
    // }
    if (_focusNodes[sectionKey]!.length < watchHistoryItems.length) {
          for (int i = _focusNodes[sectionKey]!.length; i < watchHistoryItems.length; i++) {
            _focusNodes[sectionKey]!.add(FocusNode(
              debugLabel: '${sectionKey}_item_$i',
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
                    setState(() {
                      _currentSectionIndex = _getVisibleSections().indexOf(sectionKey);
                      _currentItemIndex = index;
                    });
                  }
                }
                // onFocused: () {
                //   // Update current indices when focus changes
                //   if (!_isNavigating) {
                //     setState(() {
                //       _currentSectionIndex = _getVisibleSections().indexOf(_continueWatchingKey);
                //       _currentItemIndex = index;
                //     });
                //   }
                // },
              );
            },
          ),
        ),
      ],
    );
  }
  
  Widget _buildFavoritesSection(String selectedFilter, String mediaType,String sectionKey,) {
    // Check if the user has favorites of this content type
    final hasFavoritesAsync = ref.watch(hasFavoritesForContentTypeProvider(selectedFilter));
    
    return hasFavoritesAsync.when(
      data: (hasFavorites) {
        if (!hasFavorites) {
          return SizedBox.shrink();
        }
        
        
        // Fetch the filtered favorites
        final filteredFavoritesAsync = ref.watch(filteredFavoritesProvider(selectedFilter));
        
        return filteredFavoritesAsync.when(
          data: (favoriteDetails) {
            if (favoriteDetails.isEmpty) {
              return SizedBox.shrink();
            }
            
            // Initialize focus nodes for this section if needed
            // if (_focusNodes[_favoritesKey]!.length < favoriteDetails.length) {
            //   for (int i = _focusNodes[_favoritesKey]!.length; i < favoriteDetails.length; i++) {
            //     _focusNodes[_favoritesKey]!.add(FocusNode(
            //       debugLabel: 'favorites_item_$i',
            //     ));
            //   }
            // }
            if (_focusNodes[sectionKey]!.length < favoriteDetails.length) {
          for (int i = _focusNodes[sectionKey]!.length; i < favoriteDetails.length; i++) {
            _focusNodes[sectionKey]!.add(FocusNode(
              debugLabel: '${sectionKey}_item_$i',
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
                      if (index >= _focusNodes[sectionKey]!.length) {
                return Container(); // Safety check
              }
              final focusNode = _focusNodes[sectionKey]![index];
                      final favorite = item['favorite'];
                      final movieDetail = item['movieDetail'];
                      // final focusNode = _focusNodes[_favoritesKey]![index];
                      
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
                                        setState(() {
                                          _currentSectionIndex = _getVisibleSections().indexOf(sectionKey);
                                          _currentItemIndex = index;
                                        });
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
  String getApiMediaType(String filter) {
    switch (filter) {
      case 'Movies': return 'movie';
      case 'Series': return 'tvseries';
      case 'Short Film': return 'shortfilm';
      case 'Documentary': return 'documentary';
      case 'Music': return 'videosong';
      default: return 'movie';
    }
  }

  // Helper function to check if a section should be visible
  bool isSectionVisible(AsyncValue<Map<String, dynamic>?> sectionVisibilityAsync, String sectionKey) {
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