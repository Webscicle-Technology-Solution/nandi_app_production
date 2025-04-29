import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nandiott_flutter/features/home/provider/getContiuneMedia.dart';
import 'package:nandiott_flutter/features/home/provider/getMedia.dart';
import 'package:nandiott_flutter/models/movie_model.dart';
import 'package:nandiott_flutter/pages/detail_page.dart';
import 'package:nandiott_flutter/providers/checkauth_provider.dart';
import 'package:nandiott_flutter/providers/filter_fav_provider.dart';
import 'package:nandiott_flutter/providers/filter_provider.dart';

// Import your existing providers
// The below are just placeholders - use your actual imports
// import 'package:nandiott_flutter/utils/Device_size.dart';
// import 'package:nandiott_flutter/features/home/providers/providers.dart';
// import 'package:nandiott_flutter/features/movie_detail/movie_detail_page.dart';

class TVHomePage extends ConsumerStatefulWidget {
  const TVHomePage({super.key});

  @override
  _TVHomePageState createState() => _TVHomePageState();
}

class _TVHomePageState extends ConsumerState<TVHomePage> {
  // Track the currently focused content
  Movie? _featuredContent;
  String userId = "";
  
  // Focus management
  Map<String, FocusNode> _sectionFocusNodes = {};
  Map<String, List<FocusNode>> _itemFocusNodes = {};
  
  // Track visible sections
  List<String> _visibleSections = [];
  
  @override
  void initState() {
    super.initState();
    
    // Initialize section focus nodes
    _sectionFocusNodes = {
      'continueWatching': FocusNode(),
      'newReleases': FocusNode(),
      'freeToWatch': FocusNode(),
      'favorites': FocusNode(),
    };
    
    // Initialize empty lists for item focus nodes
    _itemFocusNodes = {
      'continueWatching': [],
      'newReleases': [],
      'freeToWatch': [],
      'favorites': [],
    };
    
    // Set initial focus after the first frame is rendered
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _setupVisibleSections();
      _setInitialFocus();
    });
  }
  
  @override
  void dispose() {
    // Dispose all focus nodes
    _sectionFocusNodes.values.forEach((node) => node.dispose());
    _itemFocusNodes.forEach((key, nodes) {
      for (var node in nodes) {
        node.dispose();
      }
    });
    super.dispose();
  }

  // Setup visible sections based on data availability
  void _setupVisibleSections() {
    final selectedFilter = ref.read(selectedFilterProvider);
    final sectionVisibility = ref.read(homeSectionVisibilityProvider(selectedFilter));
    
    setState(() {
      _visibleSections = [];
      
      // Add sections that should be visible
      if (isSectionVisible(sectionVisibility, 'isHistoryVisible')) {
        _visibleSections.add('continueWatching');
      }
      
      if (isSectionVisible(sectionVisibility, 'isLatestVisible')) {
        _visibleSections.add('newReleases');
      }
      
      final freeMediaState = ref.read(freeMediaProvider(selectedFilter));
      if (freeMediaState is AsyncData && 
          (freeMediaState as AsyncData).value?.isNotEmpty == true) {
        _visibleSections.add('freeToWatch');
      }
      
      if (isSectionVisible(sectionVisibility, 'isFavoritesVisible')) {
        _visibleSections.add('favorites');
      }
    });
  }
  
  // Set initial focus to the first item in the first visible section
  void _setInitialFocus() {
    if (_visibleSections.isNotEmpty) {
      final firstSection = _visibleSections.first;
      
      // Request focus for the section
      final sectionNode = _sectionFocusNodes[firstSection];
      if (sectionNode != null && sectionNode.canRequestFocus) {
        sectionNode.requestFocus();
      }
      
      // If there are items in this section, focus the first one
      if (_itemFocusNodes[firstSection]!.isNotEmpty) {
        final firstItemNode = _itemFocusNodes[firstSection]![0];
        if (firstItemNode.canRequestFocus) {
          firstItemNode.requestFocus();
        }
      }
    }
  }
  
  // Update featured content when a new item is focused
  void _updateFeaturedContent(Movie movie) {
    setState(() {
      _featuredContent = movie;
    });
  }
  
  @override
  Widget build(BuildContext context) {
    // Watch the selected filter state - using your existing provider
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
    
    // Get continue watching data
    final continueWatchingState = userAsyncValue.when(
      data: (user) {
        if (user != null) {
          setState(() {
            userId = user.id;
          });
          return ref.watch(filteredContinueWatchingProvider(selectedFilter));
        } else {
          return AsyncValue.data([]);
        }
      },
      loading: () => AsyncValue.loading(),
      error: (error, stack) => AsyncValue.error(error, stack),
    );
    
    // Rebuild visible sections when data changes
    if (_visibleSections.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _setupVisibleSections();
      });
    }
    
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            // Featured content hero banner
            _buildHeroBanner(),
            
            // Content sections
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Continue Watching Section
                    if (_visibleSections.contains('continueWatching'))
                      _buildContinueWatchingSection(continueWatchingState, selectedFilter),
                    
                    // New Releases Section
                    if (_visibleSections.contains('newReleases'))
                      _buildMediaSection(
                        title: 'New Releases', 
                        sectionKey: 'newReleases',
                        mediaAsync: latestMediaAsync, 
                        mediaType: mediaType
                      ),
                    
                    // Free to Watch Section
                    if (_visibleSections.contains('freeToWatch'))
                      _buildMediaSection(
                        title: 'Free to Watch', 
                        sectionKey: 'freeToWatch',
                        mediaAsync: freeMediaAsync, 
                        mediaType: mediaType
                      ),
                    
                    // Favorites Section
                    if (_visibleSections.contains('favorites'))
                      _buildFavoritesSection(selectedFilter, mediaType),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildHeroBanner() {
    if (_featuredContent == null) {
      // Default banner when no content is focused
      return Container(
        height: 350,
        width: double.infinity,
        color: Colors.black45,
        child: const Center(
          child: Text(
            'Welcome to Nandi OTT',
            style: TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      );
    }
    
    // Banner with featured content
    return Container(
      height: 350,
      width: double.infinity,
      decoration: BoxDecoration(
        image: DecorationImage(
          image: NetworkImage( ''),
          fit: BoxFit.cover,
          colorFilter: ColorFilter.mode(
            Colors.black.withOpacity(0.4),
            BlendMode.darken,
          ),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _featuredContent!.title ?? 'Unknown Title',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Text(
                  '',
                  style: const TextStyle(color: Colors.white70),
                ),
                const SizedBox(width: 16),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.white70),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    'U/A',
                    style: const TextStyle(color: Colors.white70),
                  ),
                ),
                const SizedBox(width: 16),
                const Icon(Icons.star, color: Colors.amber, size: 16),
                const SizedBox(width: 4),
                Text(
                  '0',
                  style: const TextStyle(color: Colors.white70),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'No description available',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.black,
                    backgroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                  icon: const Icon(Icons.play_arrow),
                  label: const Text('Play'),
                  onPressed: () {
                    // Navigate to play the content
                    if (_featuredContent != null) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => MovieDetailPage(
                            movieId: _featuredContent!.id,
                            mediaType: getApiMediaType(ref.read(selectedFilterProvider)),
                            userId: userId,
                          ),
                        ),
                      );
                    }
                  },
                ),
                const SizedBox(width: 16),
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: Colors.white),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                  icon: const Icon(Icons.add),
                  label: const Text('Watchlist'),
                  onPressed: () {
                    // Add to watchlist functionality
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildMediaSection({
    required String title,
    required String sectionKey,
    required AsyncValue<List<Movie>?> mediaAsync,
    required String mediaType,
  }) {
    final sectionIndex = _visibleSections.indexOf(sectionKey);
    final upSection = sectionIndex > 0 ? _visibleSections[sectionIndex - 1] : null;
    final downSection = sectionIndex < _visibleSections.length - 1
        ? _visibleSections[sectionIndex + 1]
        : null;
        
    return mediaAsync.when(
      data: (movies) {
        if (movies == null || movies.isEmpty) {
          return const SizedBox.shrink();
        }
        
        // Create focus nodes for each item if not already created
        if (_itemFocusNodes[sectionKey]!.length != movies.length) {
          _itemFocusNodes[sectionKey] = List.generate(
            movies.length, 
            (i) => FocusNode(debugLabel: '$sectionKey-item-$i')
          );
        }
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
              child: Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(
              height: 200,
              child: ListView.builder(
                key: PageStorageKey('$sectionKey-list'),
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.only(left: 24),
                itemCount: movies.length,
                itemBuilder: (context, index) {
                  final movie = movies[index];
                  final focusNode = _itemFocusNodes[sectionKey]![index];
                  
                  // Set up directional focus handling
                  focusNode.onKeyEvent = (node, event) {
                    if (event is RawKeyDownEvent) {
                      if (event.logicalKey == LogicalKeyboardKey.arrowUp && upSection != null) {
                        // Try to find an appropriate node in the section above
                        if (_itemFocusNodes[upSection]!.isNotEmpty) {
                          final upIndex = index < _itemFocusNodes[upSection]!.length 
                              ? index 
                              : _itemFocusNodes[upSection]!.length - 1;
                          _itemFocusNodes[upSection]![upIndex].requestFocus();
                          return KeyEventResult.handled;
                        }
                      } else if (event.logicalKey == LogicalKeyboardKey.arrowDown && downSection != null) {
                        // Try to find an appropriate node in the section below
                        if (_itemFocusNodes[downSection]!.isNotEmpty) {
                          final downIndex = index < _itemFocusNodes[downSection]!.length 
                              ? index 
                              : _itemFocusNodes[downSection]!.length - 1;
                          _itemFocusNodes[downSection]![downIndex].requestFocus();
                          return KeyEventResult.handled;
                        }
                      }
                    }
                    return KeyEventResult.ignored;
                  };
                  
                  return Padding(
                    padding: const EdgeInsets.only(right: 16, top: 8, bottom: 8),
                    child: Focus(
                      focusNode: focusNode,
                      onFocusChange: (hasFocus) {
                        if (hasFocus) {
                          _updateFeaturedContent(movie);
                        }
                      },
                      child: Builder(
                        builder: (context) {
                          final isFocused = Focus.of(context).hasFocus;
                          
                          return GestureDetector(
                            onTap: () => _navigateToMovieDetails(movie, mediaType),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              width: 130,
                              height: 180,
                              margin: EdgeInsets.only(
                                top: isFocused ? 0 : 10,
                                bottom: isFocused ? 10 : 0,
                              ),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                boxShadow: isFocused
                                    ? [
                                        BoxShadow(
                                          color: Colors.amber.withOpacity(0.6),
                                          spreadRadius: 2,
                                          blurRadius: 8,
                                        )
                                      ]
                                    : [],
                                border: isFocused
                                    ? Border.all(color: Colors.amber, width: 3)
                                    : null,
                                image: DecorationImage(
                                  image: NetworkImage( ''),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
      loading: () => _buildLoadingSection(title),
      error: (error, stack) => Padding(
        padding: const EdgeInsets.all(24.0),
        child: Center(
          child: Text(
            'Failed to load $title: $error',
            style: const TextStyle(color: Colors.white70),
          ),
        ),
      ),
    );
  }
  
  Widget _buildContinueWatchingSection(AsyncValue continueWatchingState, String selectedFilter) {
    final sectionKey = 'continueWatching';
    final sectionIndex = _visibleSections.indexOf(sectionKey);
    final downSection = sectionIndex < _visibleSections.length - 1
        ? _visibleSections[sectionIndex + 1]
        : null;
    
    return continueWatchingState.when(
      data: (watchHistoryItems) {
        if (watchHistoryItems == null || watchHistoryItems.isEmpty) {
          return const SizedBox.shrink();
        }
        
        // Create focus nodes for each item if not already created
        if (_itemFocusNodes[sectionKey]!.length != watchHistoryItems.length) {
          _itemFocusNodes[sectionKey] = List.generate(
            watchHistoryItems.length, 
            (i) => FocusNode(debugLabel: '$sectionKey-item-$i')
          );
        }
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(24, 16, 24, 8),
              child: Text(
                'Continue Watching',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(
              height: 200,
              child: ListView.builder(
                key: PageStorageKey('continue-watching-list'),
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.only(left: 24),
                itemCount: watchHistoryItems.length,
                itemBuilder: (context, index) {
                  final item = watchHistoryItems[index];
                  final focusNode = _itemFocusNodes[sectionKey]![index];
                  final progress = item.playbackPosition / item.duration;
                  final movie = item.movieDetail;
                  
                  // Set up directional focus handling
                  focusNode.onKeyEvent = (node, event) {
                    if (event is RawKeyDownEvent) {
                      if (event.logicalKey == LogicalKeyboardKey.arrowDown && downSection != null) {
                        // Try to find an appropriate node in the section below
                        if (_itemFocusNodes[downSection]!.isNotEmpty) {
                          final downIndex = index < _itemFocusNodes[downSection]!.length 
                              ? index 
                              : _itemFocusNodes[downSection]!.length - 1;
                          _itemFocusNodes[downSection]![downIndex].requestFocus();
                          return KeyEventResult.handled;
                        }
                      }
                    }
                    return KeyEventResult.ignored;
                  };
                  
                  return Padding(
                    padding: const EdgeInsets.only(right: 16, top: 8, bottom: 8),
                    child: Focus(
                      focusNode: focusNode,
                      onFocusChange: (hasFocus) {
                        if (hasFocus) {
                          _updateFeaturedContent(movie);
                        }
                      },
                      child: Builder(
                        builder: (context) {
                          final isFocused = Focus.of(context).hasFocus;
                          
                          return GestureDetector(
                            onTap: () => _navigateToMovieDetails(movie, item.contentType),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              width: 200,
                              height: 180,
                              margin: EdgeInsets.only(
                                top: isFocused ? 0 : 10,
                                bottom: isFocused ? 10 : 0,
                              ),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                boxShadow: isFocused
                                    ? [
                                        BoxShadow(
                                          color: Colors.amber.withOpacity(0.6),
                                          spreadRadius: 2,
                                          blurRadius: 8,
                                        )
                                      ]
                                    : [],
                                border: isFocused
                                    ? Border.all(color: Colors.amber, width: 3)
                                    : null,
                                image: DecorationImage(
                                  image: NetworkImage(movie.posterPath ?? ''),
                                  fit: BoxFit.cover,
                                ),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.end,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        begin: Alignment.topCenter,
                                        end: Alignment.bottomCenter,
                                        colors: [
                                          Colors.transparent,
                                          Colors.black.withOpacity(0.7),
                                        ],
                                      ),
                                    ),
                                    padding: const EdgeInsets.all(8),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          movie.title ?? 'Unknown',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 4),
                                        // Progress indicator
                                        LinearProgressIndicator(
                                          value: progress,
                                          backgroundColor: Colors.grey[800],
                                          valueColor: const AlwaysStoppedAnimation<Color>(Colors.amber),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          '${_formatDuration(item.playbackPosition)} / ${_formatDuration(item.duration)}',
                                          style: const TextStyle(
                                            color: Colors.white70,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
      loading: () => _buildLoadingSection('Continue Watching'),
      error: (error, stack) => Padding(
        padding: const EdgeInsets.all(24.0),
        child: Center(
          child: Text(
            'Failed to load continue watching: $error',
            style: const TextStyle(color: Colors.white70),
          ),
        ),
      ),
    );
  }
  
  Widget _buildFavoritesSection(String selectedFilter, String mediaType) {
    final sectionKey = 'favorites';
    final sectionIndex = _visibleSections.indexOf(sectionKey);
    final upSection = sectionIndex > 0 ? _visibleSections[sectionIndex - 1] : null;
    
    // Check if the user has favorites of this content type
    final hasFavoritesAsync = ref.watch(hasFavoritesForContentTypeProvider(selectedFilter));
    
    return hasFavoritesAsync.when(
      data: (hasFavorites) {
        if (!hasFavorites) {
          return const SizedBox.shrink();
        }
        
        // Fetch the filtered favorites
        final filteredFavoritesAsync = ref.watch(filteredFavoritesProvider(selectedFilter));
        
        return filteredFavoritesAsync.when(
          data: (favoriteDetails) {
            if (favoriteDetails.isEmpty) {
              return const SizedBox.shrink();
            }
            
            // Create focus nodes for each item if not already created
            if (_itemFocusNodes[sectionKey]!.length != favoriteDetails.length) {
              _itemFocusNodes[sectionKey] = List.generate(
                favoriteDetails.length, 
                (i) => FocusNode(debugLabel: '$sectionKey-item-$i')
              );
            }
            
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.fromLTRB(24, 16, 24, 8),
                  child: Text(
                    'My Watchlist',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(
                  height: 200,
                  child: ListView.builder(
                    key: PageStorageKey('favorites-list'),
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.only(left: 24),
                    itemCount: favoriteDetails.length,
                    itemBuilder: (context, index) {
                      final item = favoriteDetails[index];
                      final favorite = item['favorite'];
                      final movie = item['movieDetail'];
                      final focusNode = _itemFocusNodes[sectionKey]![index];
                      
                      // Set up directional focus handling
                      focusNode.onKeyEvent = (node, event) {
                        if (event is RawKeyDownEvent) {
                          if (event.logicalKey == LogicalKeyboardKey.arrowUp && upSection != null) {
                            // Try to find an appropriate node in the section above
                            if (_itemFocusNodes[upSection]!.isNotEmpty) {
                              final upIndex = index < _itemFocusNodes[upSection]!.length 
                                  ? index 
                                  : _itemFocusNodes[upSection]!.length - 1;
                              _itemFocusNodes[upSection]![upIndex].requestFocus();
                              return KeyEventResult.handled;
                            }
                          }
                        }
                        return KeyEventResult.ignored;
                      };
                      
                      return Padding(
                        padding: const EdgeInsets.only(right: 16, top: 8, bottom: 8),
                        child: Focus(
                          focusNode: focusNode,
                          onFocusChange: (hasFocus) {
                            if (hasFocus) {
                              _updateFeaturedContent(movie);
                            }
                          },
                          child: Builder(
                            builder: (context) {
                              final isFocused = Focus.of(context).hasFocus;
                              
                              return GestureDetector(
                                onTap: () => _navigateToMovieDetails(movie, favorite.contentType),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  width: 130,
                                  height: 180,
                                  margin: EdgeInsets.only(
                                    top: isFocused ? 0 : 10,
                                    bottom: isFocused ? 10 : 0,
                                  ),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                    boxShadow: isFocused
                                        ? [
                                            BoxShadow(
                                              color: Colors.amber.withOpacity(0.6),
                                              spreadRadius: 2,
                                              blurRadius: 8,
                                            )
                                          ]
                                        : [],
                                    border: isFocused
                                        ? Border.all(color: Colors.amber, width: 3)
                                        : null,
                                    image: DecorationImage(
                                      image: NetworkImage(movie.posterPath ?? ''),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          },
          loading: () => _buildLoadingSection('My Watchlist'),
          error: (error, stack) => Padding(
            padding: const EdgeInsets.all(24.0),
            child: Center(
              child: Text(
                'Failed to load watchlist: $error',
                style: const TextStyle(color: Colors.white70),
              ),
            ),
          ),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
  
  Widget _buildLoadingSection(String title) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
          child: Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        SizedBox(
          height: 200,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.only(left: 24),
            itemCount: 5,
            itemBuilder: (context, index) {
              return const Padding(
                padding: EdgeInsets.only(right: 16),
                child: SkeletonLoader(width: 130, height: 180),
              );
            },
          ),
        ),
      ],
    );
  }
  
  void _navigateToMovieDetails(dynamic movie, String mediaType) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MovieDetailPage(
          movieId: movie.id,
          mediaType: mediaType,
          userId: userId,
        ),
      ),
    );
  }
  
  // Helper method to format duration in MM:SS format
  String _formatDuration(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '$minutes:${remainingSeconds.toString().padLeft(2, '0')}';
  }
}

// Simple skeleton loader for TV UI
class SkeletonLoader extends StatelessWidget {
  final double width;
  final double height;
  
  const SkeletonLoader({
    Key? key,
    this.width = 130,
    this.height = 180,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.grey[800],
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }
}