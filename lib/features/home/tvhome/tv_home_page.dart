import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nandiott_flutter/app/widgets/custombottombar.dart';
import 'package:nandiott_flutter/features/home/tvhome/featured_carsoule_widget.dart';
import 'package:nandiott_flutter/features/home/tvhome/prime_row.dart';
import 'package:nandiott_flutter/features/home/tvhome/tvfilter_selector_widget.dart';
import 'package:nandiott_flutter/pages/detail_page.dart';
import 'package:nandiott_flutter/providers/filter_provider.dart';
import 'package:nandiott_flutter/features/home/provider/getMedia.dart';
import 'package:nandiott_flutter/features/home/provider/getContiuneMedia.dart';
import 'package:nandiott_flutter/providers/filter_fav_provider.dart';
import 'package:nandiott_flutter/providers/checkauth_provider.dart';

// State provider to track which item is currently focused
final focusedSectionProvider = StateProvider<String>((ref) => 'featured');
final expandedCardProvider = StateProvider<Map<String, dynamic>>((ref) => {});

class PrimeTVHomePage extends ConsumerStatefulWidget {
  final VoidCallback? onLeftEdgeFocus;
  final VoidCallback? onRightEdgeFocus;
  final VoidCallback? onContentFocus;

  const PrimeTVHomePage({
    Key? key,
    this.onLeftEdgeFocus,
    this.onRightEdgeFocus,
    this.onContentFocus,
  }) : super(key: key);

  @override
  _PrimeTVHomePageState createState() => _PrimeTVHomePageState();
}

class _PrimeTVHomePageState extends ConsumerState<PrimeTVHomePage> {
  // Main focus node for the entire page
  final _pageFocusNode = FocusNode();

  final ScrollController _mainScrollController = ScrollController();

  // Individual section focus nodes
  final Map<String, FocusNode> _sectionFocusNodes = {};

  // Current active section
  String _activeSection = 'featured';

  // Controls if the featured section is expanded (full-screen) or compact
  bool _featuredExpanded = true;

  // User ID for API calls
  String _userId = '';

  // Background image for the focused content
  String _backgroundImage = '';

  @override
  void initState() {
    super.initState();
    void _setupFocusLogging(String name, FocusNode node) {
      node.addListener(() {
        if (node.hasFocus) {
          print("FOCUS: $name has received focus");
        } else {
          print("FOCUS: $name has lost focus");
        }
      });
    }

    // // Initialize focus nodes
    // _sectionFocusNodes['filter'] = FocusNode(debugLabel: 'filter_section');
    // _sectionFocusNodes['featured'] = FocusNode(debugLabel: 'featured_section');
    // _sectionFocusNodes['continueWatching'] = FocusNode(debugLabel: 'continue_section');
    // _sectionFocusNodes['newReleases'] = FocusNode(debugLabel: 'new_releases_section');
    // _sectionFocusNodes['freeToWatch'] = FocusNode(debugLabel: 'free_section');
    // _sectionFocusNodes['favorites'] = FocusNode(debugLabel: 'favorites_section');
    _sectionFocusNodes['filter'] = FocusNode(debugLabel: 'filter_section');
    _setupFocusLogging('filter', _sectionFocusNodes['filter']!);

    _sectionFocusNodes['featured'] = FocusNode(debugLabel: 'featured_section');
    _setupFocusLogging('featured', _sectionFocusNodes['featured']!);

    _sectionFocusNodes['continueWatching'] =
        FocusNode(debugLabel: 'continue_section');
    _setupFocusLogging(
        'continueWatching', _sectionFocusNodes['continueWatching']!);

    _sectionFocusNodes['newReleases'] =
        FocusNode(debugLabel: 'new_releases_section');
    _setupFocusLogging('newReleases', _sectionFocusNodes['newReleases']!);

    _sectionFocusNodes['freeToWatch'] = FocusNode(debugLabel: 'free_section');
    _setupFocusLogging('freeToWatch', _sectionFocusNodes['freeToWatch']!);

    _sectionFocusNodes['favorites'] =
        FocusNode(debugLabel: 'favorites_section');
    _setupFocusLogging('favorites', _sectionFocusNodes['favorites']!);

    // Set up focus listeners
    for (final entry in _sectionFocusNodes.entries) {
      entry.value.addListener(() {
        if (entry.value.hasFocus && mounted) {
          _updateActiveSection(entry.key);
        }
      });
    }

    // Set initial focus to featured section
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _sectionFocusNodes['featured']?.requestFocus();
    });
  }

  void _updateActiveSection(String section) {
    if (_activeSection != section) {
      setState(() {
        _activeSection = section;

        // Collapse featured section when focus moves to content rows
        if (section != 'featured' && section != 'filter') {
          _featuredExpanded = false;
        } else if (section == 'featured') {
          _featuredExpanded = true;
        }
      });

      // Update the global focused section
      ref.read(focusedSectionProvider.notifier).state = section;

      // Clear expanded card data when moving between major sections
      if (section == 'filter' || section == 'featured') {
        ref.read(expandedCardProvider.notifier).state = {};
      }
    }
  }

  void _updateBackgroundImage(String imageUrl) {
    if (_backgroundImage != imageUrl) {
      setState(() {
        _backgroundImage = imageUrl;
      });
    }
  }

  @override
  void dispose() {
    // Dispose all focus nodes
    for (final node in _sectionFocusNodes.values) {
      node.dispose();
    }
    _pageFocusNode.dispose();
    super.dispose();
  }

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

  void _handleKeyEvents(RawKeyEvent event, String section) {
    if (event is RawKeyDownEvent) {
      if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
        // Check if we're at the leftmost item
        bool isAtLeftEdge = false;
        
        if (section == 'filter') {
          // For filter, always consider it at left edge
          isAtLeftEdge = true;
        } 
        else if (section == 'featured') {
          // For featured, check if we're at the first card
          // final featuredProvider = ref.read(featuredMediaProvider(ref.read(selectedFilterProvider)));
          final featuredIndex = 0;
          
          // If we're at the first item, consider it at left edge
          if (featuredIndex == 0) {
            isAtLeftEdge = true;
          }
        }
        else {
          // For other content rows, check if we're at the first item
          final expandedCard = ref.read(expandedCardProvider);
          if (expandedCard.isEmpty || expandedCard['index'] == 0) {
            isAtLeftEdge = true;
          }
        }
        
        // If we're at the left edge, signal to navigate to the menu
        if (isAtLeftEdge) {
          if (widget.onLeftEdgeFocus != null) {
            widget.onLeftEdgeFocus!();
          }
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Screen dimensions
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    // Get the selected filter from Riverpod
    final selectedFilter = ref.watch(selectedFilterProvider);
    final mediaType = _getApiMediaType(selectedFilter);

    // Get section visibility settings
    final sectionVisibilityAsync =
        ref.watch(homeSectionVisibilityProvider(selectedFilter));

    // Media data providers
    final latestMediaAsync = ref.watch(latestMediaProvider(selectedFilter));
    final freeMediaAsync = ref.watch(freeMediaProvider(selectedFilter));

    // User data for continue watching
    final userAsyncValue = ref.watch(authUserProvider);

    // Get the currently expanded card data (if any)
    final expandedCard = ref.watch(expandedCardProvider);

    // Build list of visible sections - only include sections that should be visible based on API response
    final List<String> visibleSections = [];
    final sectionVisibility = sectionVisibilityAsync.when(
      data: (visibilityMap) => visibilityMap ?? {},
      loading: () => <String, dynamic>{},
      error: (_, __) => <String, dynamic>{},
    );

    // Check if history section is visible and user is logged in
    final isUserLoggedIn = userAsyncValue.whenOrNull(
          data: (user) => user != null,
        ) ??
        false;

    if (isUserLoggedIn && (sectionVisibility['isHistoryVisible'] ?? false)) {
      visibleSections.add('continueWatching');
    }

    // Check other sections
    if (sectionVisibility['isLatestVisible'] ?? false) {
      visibleSections.add('newReleases');
    }

    // Check if free media is available and visible
    final hasFreeContent = freeMediaAsync.whenOrNull(
          data: (items) => items != null && items.isNotEmpty,
        ) ??
        false;

    if (hasFreeContent) {
      visibleSections.add('freeToWatch');
    }

    // Check if favorites section is visible
    if (isUserLoggedIn && (sectionVisibility['isFavoritesVisible'] ?? false)) {
      final hasFavorites = ref
              .watch(hasFavoritesForContentTypeProvider(selectedFilter))
              .whenOrNull(
                data: (hasItems) => hasItems,
              ) ??
          false;

      if (hasFavorites) {
        visibleSections.add('favorites');
      }
    }

    // Initialize section focus nodes for the available sections
    for (final section in ['filter', 'featured', ...visibleSections]) {
      if (!_sectionFocusNodes.containsKey(section)) {
        _sectionFocusNodes[section] =
            FocusNode(debugLabel: '${section}_section');
        _sectionFocusNodes[section]!.addListener(() {
          if (_sectionFocusNodes[section]!.hasFocus && mounted) {
            _updateActiveSection(section);
          }
        });
      }
    }

    // Get continue watching data - only if user is logged in and section is visible
    final continueWatchingState = userAsyncValue.when(
      data: (user) {
        if (user != null && visibleSections.contains('continueWatching')) {
          setState(() {
            _userId = user.id;
          });
          return ref.watch(filteredContinueWatchingProvider(selectedFilter));
        } else {
          return const AsyncValue.data([]);
        }
      },
      loading: () => AsyncValue.loading(),
      error: (error, stack) => AsyncValue.error(error, stack),
    );

    return RawKeyboardListener(
      focusNode: _pageFocusNode,
      onKey: (RawKeyEvent event) {
        // Only handle key down events
        if (event is RawKeyDownEvent) {
          // Check if left arrow was pressed
          if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
            // Check which section is active
            if (_activeSection == 'filter' || 
                _activeSection == 'featured' || 
                expandedCard.isNotEmpty && (expandedCard['index'] == 0)) {
              
              // If we're at the left edge, call the callback
              if (widget.onLeftEdgeFocus != null) {
                widget.onLeftEdgeFocus!();
              }
            }
          }
        }
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          children: [
            // Dynamic background that changes based on focused content
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 500),
              child: Container(
                key: ValueKey<String>(_backgroundImage),
                width: screenWidth,
                height: screenHeight,
                decoration: BoxDecoration(
                  image: _backgroundImage.isNotEmpty
                      ? DecorationImage(
                          image: NetworkImage(_backgroundImage),
                          fit: BoxFit.cover,
                          opacity: 0.4,
                        )
                      : null,
                  color: Colors.black,
                ),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(0.7),
                        Colors.black,
                      ],
                      stops: const [0.0, 0.5, 0.8],
                    ),
                  ),
                ),
              ),
            ),
      
            // Main content
            FocusScope(
      onFocusChange: (hasFocus) {
        if (!hasFocus && mounted) {
      // final isNavFocus = ref.read(navigationIsFocusedProvider);
      // if (isNavFocus) {
      //   debugPrint("Home lost focus but navigation has it. Skipping reclaim.");
      //   return;
      // }
      
      // Avoid reclaiming focus if some other component has taken over
      final newFocus = FocusManager.instance.primaryFocus;
      if (newFocus != null &&
          newFocus.debugLabel != null &&
          newFocus.debugLabel!.contains('navigation')) {
        return;
      }
      
      // Reclaim focus only if no other valid component owns it
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_sectionFocusNodes[_activeSection]?.canRequestFocus ?? false) {
          _sectionFocusNodes[_activeSection]!.requestFocus();
        }
      });
        }
      },
      
      
              onKey: (FocusNode node, RawKeyEvent event) {
                if (event is RawKeyDownEvent) {
                  // Global keyboard navigation between sections
                  if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
                    _handleVerticalNavigation(true); // Move up
                    return KeyEventResult.handled;
                  } else if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
                    _handleVerticalNavigation(false); // Move down
                    return KeyEventResult.handled;
                  }
                }
                return KeyEventResult.ignored;
              },
              child: SafeArea(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Filter bar at the top with improved animations
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      height: _activeSection == 'filter' ||
                              _activeSection == 'featured'
                          ? 70
                          : 0,
                      child: AnimatedOpacity(
                        duration: const Duration(milliseconds: 200),
                        opacity: _activeSection == 'filter' ||
                                _activeSection == 'featured'
                            ? 1.0
                            : 0.0,
                        child: Focus(
                          focusNode: _sectionFocusNodes['filter']!,
                          child: PrimeFilterBar(
                            onFilterSelected: (filter) {
                              ref.read(selectedFilterProvider.notifier).state =
                                  filter;
                            },
                            hasFocus: _activeSection == 'filter',
                            onLeftEdgeFocus: () {
                              if (widget.onLeftEdgeFocus != null) {
                                widget.onLeftEdgeFocus!();
                              }
                            },
                          ),
                        ),
                      ),
                    ),
      
                    // Featured section with improved collapse animation
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 400),
                      curve: Curves.easeInOutCubic,
                      height: _featuredExpanded
                          ? screenHeight * 0.6
                          : _activeSection == 'featured'
                              ? screenHeight * 0.25
                              : 0, // Hide completely when not in focus
                      child: Focus(
                        focusNode: _sectionFocusNodes['featured']!,
                        child: PrimeFeaturedSection(
                          filter: selectedFilter,
                          hasFocus: _activeSection == 'featured',
                          isExpanded: _featuredExpanded,
                          onBackgroundImageChanged: _updateBackgroundImage,
                          onLeftEdgeFocus: () {
                            if (widget.onLeftEdgeFocus != null)
                              widget.onLeftEdgeFocus!();
                          },
                          onRightEdgeFocus: () {
                            if (widget.onRightEdgeFocus != null)
                              widget.onRightEdgeFocus!();
                          },
                          onContentFocus: () {
                            if (widget.onContentFocus != null)
                              widget.onContentFocus!();
                          },
                        ),
                      ),
                    ),
      
                    // Small spacer to create separation between featured and content rows
                    // SizedBox(height: 10),
      
                    // Content rows
                    Expanded(
                      child: visibleSections.isEmpty
                          ? Center(
                              child: Text(
                                'No content available for this category',
                                style: TextStyle(
                                    color: Colors.white70, fontSize: 16),
                              ),
                            )
                          : ListView.builder(
                              controller: _mainScrollController,
                              padding: EdgeInsets
                                  .zero, // Tighter padding for better scrolling
                              physics: const AlwaysScrollableScrollPhysics(),
                              itemCount: visibleSections.length,
                              itemBuilder: (context, index) {
                                final section = visibleSections[index];
      
                                // Skip filter and featured sections in ListView
                                if (section == 'filter' ||
                                    section == 'featured') {
                                  return SizedBox.shrink();
                                }
      
                                // Build the appropriate row based on section type
                                switch (section) {
                                  case 'continueWatching':
                                    return Focus(
                                      focusNode:
                                          _sectionFocusNodes['continueWatching']!,
                                      child: PrimeContentRow(
                                        title: 'Continue Watching',
                                        mediaAsync: continueWatchingState
                                            as AsyncValue<List<dynamic>>,
                                        rowType: 'history',
                                        mediaType: mediaType,
                                        hasFocus:
                                            _activeSection == 'continueWatching',
                                        userId: _userId,
                                        onBackgroundImageChanged:
                                            _updateBackgroundImage,
                                        onLeftEdgeFocus: () {
                                          if (widget.onLeftEdgeFocus != null)
                                            widget.onLeftEdgeFocus!();
                                        },
                                        onRightEdgeFocus: () {
                                          if (widget.onRightEdgeFocus != null)
                                            widget.onRightEdgeFocus!();
                                        },
                                        onContentFocus: () {
                                          if (widget.onContentFocus != null)
                                            widget.onContentFocus!();
                                        },
                                      ),
                                    );
      
                                  case 'newReleases':
                                    return Focus(
                                      focusNode:
                                          _sectionFocusNodes['newReleases']!,
                                      child: PrimeContentRow(
                                        title: 'New Releases',
                                        mediaAsync: latestMediaAsync,
                                        rowType: 'standard',
                                        mediaType: mediaType,
                                        hasFocus: _activeSection == 'newReleases',
                                        userId: _userId,
                                        onBackgroundImageChanged:
                                            _updateBackgroundImage,
                                        onLeftEdgeFocus: () {
                                          if (widget.onLeftEdgeFocus != null)
                                            widget.onLeftEdgeFocus!();
                                        },
                                        onRightEdgeFocus: () {
                                          if (widget.onRightEdgeFocus != null)
                                            widget.onRightEdgeFocus!();
                                        },
                                        onContentFocus: () {
                                          if (widget.onContentFocus != null)
                                            widget.onContentFocus!();
                                        },
                                      ),
                                    );
      
                                  case 'freeToWatch':
                                    return Focus(
                                      focusNode:
                                          _sectionFocusNodes['freeToWatch']!,
                                      child: PrimeContentRow(
                                        title: 'Free to Watch',
                                        mediaAsync: freeMediaAsync,
                                        rowType: 'standard',
                                        mediaType: mediaType,
                                        hasFocus: _activeSection == 'freeToWatch',
                                        userId: _userId,
                                        onBackgroundImageChanged:
                                            _updateBackgroundImage,
                                        onLeftEdgeFocus: () {
                                          if (widget.onLeftEdgeFocus != null)
                                            widget.onLeftEdgeFocus!();
                                        },
                                        onRightEdgeFocus: () {
                                          if (widget.onRightEdgeFocus != null)
                                            widget.onRightEdgeFocus!();
                                        },
                                        onContentFocus: () {
                                          if (widget.onContentFocus != null)
                                            widget.onContentFocus!();
                                        },
                                      ),
                                    );
      
                                  case 'favorites':
                                    return Focus(
                                      focusNode: _sectionFocusNodes['favorites']!,
                                      child: PrimeContentRow(
                                        title: 'My Wishlist',
                                        mediaAsync: ref.watch(
                                            filteredFavoritesProvider(
                                                selectedFilter)),
                                        rowType: 'favorites',
                                        mediaType: mediaType,
                                        hasFocus: _activeSection == 'favorites',
                                        userId: _userId,
                                        onBackgroundImageChanged:
                                            _updateBackgroundImage,
                                        onLeftEdgeFocus: () {
                                          if (widget.onLeftEdgeFocus != null)
                                            widget.onLeftEdgeFocus!();
                                        },
                                        onRightEdgeFocus: () {
                                          if (widget.onRightEdgeFocus != null)
                                            widget.onRightEdgeFocus!();
                                        },
                                        onContentFocus: () {
                                          if (widget.onContentFocus != null)
                                            widget.onContentFocus!();
                                        },
                                      ),
                                    );
      
                                  default:
                                    return SizedBox.shrink();
                                }
                              },
                            ),
                    ),
                  ],
                ),
              ),
            ),
      
            // Expanded card overlay (when a card is focused)
            if (expandedCard.isNotEmpty)
              _buildExpandedCardOverlay(expandedCard, context),
          ],
        ),
      ),
    );
  }

  Widget _buildExpandedCardOverlay(
      Map<String, dynamic> cardData, BuildContext context) {
    final posterUrl = cardData['posterUrl'] ?? '';
    final bannerUrl = cardData['bannerUrl'] ?? '';
    final title = cardData['title'] ?? 'No Title';
    final description = cardData['description'] ?? '';
    final mediaType = cardData['mediaType'] ?? '';
    final contentId = cardData['contentId'] ?? '';

    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: Container(
        height: MediaQuery.of(context).size.height * 0.4,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.transparent,
              Colors.black.withOpacity(0.7),
              Colors.black,
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Poster
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  width: 200,
                  height: 300,
                  decoration: BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.5),
                        blurRadius: 10,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: posterUrl.isNotEmpty
                      ? Image.network(
                          posterUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (context, _, __) => Container(
                            color: Colors.grey[900],
                            child: const Icon(
                              Icons.image_not_supported,
                              color: Colors.white54,
                              size: 40,
                            ),
                          ),
                        )
                      : Container(
                          color: Colors.grey[900],
                          child: const Icon(
                            Icons.image_not_supported,
                            color: Colors.white54,
                            size: 40,
                          ),
                        ),
                ),
              ),

              // Content details
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left: 30.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 15),

                      // Content metadata
                      Row(
                        children: [
                          // Content type badge
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 3),
                            decoration: BoxDecoration(
                              color: Colors.amber,
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: Text(
                              mediaType == 'movie'
                                  ? 'Movie'
                                  : mediaType == 'tvseries'
                                      ? 'TV Series'
                                      : mediaType == 'shortfilm'
                                          ? 'Short Film'
                                          : mediaType == 'documentary'
                                              ? 'Documentary'
                                              : 'Music',
                              style: const TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(width: 15),

                          // Rating if available
                          if (cardData['rating'] != null) ...[
                            const Icon(Icons.star,
                                color: Colors.amber, size: 20),
                            const SizedBox(width: 5),
                            Text(
                              cardData['rating'].toString(),
                              style: TextStyle(color: Colors.white),
                            ),
                            const SizedBox(width: 15),
                          ],

                          // Year if available
                          if (cardData['year'] != null)
                            Text(
                              cardData['year'].toString(),
                              style: TextStyle(color: Colors.white),
                            ),
                        ],
                      ),

                      const SizedBox(height: 20),

                      // Description
                      Text(
                        description,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 16,
                        ),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),

                      const SizedBox(height: 25),

                      // Action buttons
                      Row(
                        children: [
                          ElevatedButton.icon(
                            onPressed: () {
                              Navigator.of(context).push(MaterialPageRoute(
                                builder: (context) => MovieDetailPage(
                                  movieId: contentId,
                                  mediaType: mediaType,
                                  userId: _userId,
                                ),
                              ));
                            },
                            icon: const Icon(Icons.play_arrow, size: 30),
                            label: const Text(
                              'Watch Now',
                              style: TextStyle(fontSize: 18),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.amber,
                              foregroundColor: Colors.black,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 25,
                                vertical: 15,
                              ),
                            ),
                          ),
                          const SizedBox(width: 15),
                          ElevatedButton.icon(
                            onPressed: () {
                              Navigator.of(context).push(MaterialPageRoute(
                                builder: (context) => MovieDetailPage(
                                  movieId: contentId,
                                  mediaType: mediaType,
                                  userId: _userId,
                                ),
                              ));
                            },
                            icon: const Icon(Icons.info_outline),
                            label: const Text('Details'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.black54,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 15,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFavoritesRow(String selectedFilter, String mediaType) {
    // Check if user has favorites of this content type
    final hasFavoritesAsync =
        ref.watch(hasFavoritesForContentTypeProvider(selectedFilter));

    return hasFavoritesAsync.when(
      data: (hasFavorites) {
        if (!hasFavorites) {
          return const SizedBox.shrink();
        }

        // Get the filtered favorites
        final filteredFavoritesAsync =
            ref.watch(filteredFavoritesProvider(selectedFilter));

        return PrimeContentRow(
          title: 'My Wishlist',
          mediaAsync: filteredFavoritesAsync,
          rowType: 'favorites',
          mediaType: mediaType,
          hasFocus: _activeSection == 'favorites',
          userId: _userId,
          onBackgroundImageChanged: _updateBackgroundImage,
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  void _handleVerticalNavigation(bool moveUp) {
    // Only consider visible sections in navigation
    final List<String> allSections = [
      'filter',
      'featured',
      'continueWatching',
      'newReleases',
      'freeToWatch',
      'favorites'
    ];
    final List<String> visibleSections = ['filter', 'featured'];

    // Add visible sections
    for (final section in allSections.skip(2)) {
      if (_sectionFocusNodes.containsKey(section)) {
        visibleSections.add(section);
      }
    }

    // Find current section index
    final currentIndex = visibleSections.indexOf(_activeSection);
    if (currentIndex == -1) return;

    print(
        "Current section: $_activeSection, Index: $currentIndex, Moving up: $moveUp");

    if (moveUp) {
      // Moving up logic
      if (currentIndex > 0) {
        final previousSection = visibleSections[currentIndex - 1];
        print("Moving up to section: $previousSection");

        // Special handling for moving to featured
        if (previousSection == 'featured') {
          // Clear expanded card data
          ref.read(expandedCardProvider.notifier).state = {};

          // Expand featured and update state
          setState(() {
            _featuredExpanded = true;
            _activeSection = previousSection;
          });

          // Update provider state
          ref.read(focusedSectionProvider.notifier).state = previousSection;

          // Request focus after animation
          Future.delayed(Duration(milliseconds: 150), () {
            if (mounted &&
                _sectionFocusNodes[previousSection]!.canRequestFocus) {
              _sectionFocusNodes[previousSection]!.requestFocus();

              // Scroll to top
              if (_mainScrollController.hasClients) {
                _mainScrollController.animateTo(0,
                    duration: Duration(milliseconds: 300),
                    curve: Curves.easeOutCubic);
              }
            }
          });
        } else {
          // Regular upward navigation
          setState(() {
            _activeSection = previousSection;
          });

          // Update provider state
          ref.read(focusedSectionProvider.notifier).state = previousSection;

          // Request focus
          if (_sectionFocusNodes[previousSection]!.canRequestFocus) {
            _sectionFocusNodes[previousSection]!.requestFocus();
          }

          // IMPROVED: Only scroll when the section is above the fold
          if (_mainScrollController.hasClients) {
            // Calculate position based on section index
            final sectionIndex = currentIndex - 1;
            // Only sections after featured need scrolling
            if (sectionIndex > 1) {
              // The key improvement - scroll to the section ONLY, not past it
              double offset = (sectionIndex - 2) * 300.0;
              _mainScrollController.animateTo(offset,
                  duration: Duration(milliseconds: 300),
                  curve: Curves.easeOutCubic);
            } else {
              // For filter or featured, scroll to top
              _mainScrollController.animateTo(0,
                  duration: Duration(milliseconds: 300),
                  curve: Curves.easeOutCubic);
            }
          }
        }
      }
    } else {
      // Moving down logic
      if (currentIndex < visibleSections.length - 1) {
        final nextSection = visibleSections[currentIndex + 1];
        print("Moving down to section: $nextSection");

        // Special handling for moving from featured
        if (currentIndex == 1 && _activeSection == 'featured') {
          // Collapse featured and update state
          setState(() {
            _featuredExpanded = false;
            _activeSection = nextSection;
          });

          // Update provider state
          ref.read(focusedSectionProvider.notifier).state = nextSection;

          // CRITICAL: Adding a delay to ensure UI updates first
          Future.delayed(Duration(milliseconds: 200), () {
            if (mounted && _sectionFocusNodes[nextSection]!.canRequestFocus) {
              _sectionFocusNodes[nextSection]!.requestFocus();

              // After focus, scroll to hide featured completely
              if (_mainScrollController.hasClients) {
                // The 80.0 offset ensures featured is completely hidden
                _mainScrollController.animateTo(80.0,
                    duration: Duration(milliseconds: 300),
                    curve: Curves.easeOutCubic);
              }
            }
          });
        } else {
          // Regular downward navigation between content rows
          setState(() {
            _activeSection = nextSection;
          });

          // Update provider state
          ref.read(focusedSectionProvider.notifier).state = nextSection;

          // Request focus
          if (_sectionFocusNodes[nextSection]!.canRequestFocus) {
            _sectionFocusNodes[nextSection]!.requestFocus();
          }

          // IMPROVED: Scroll to reveal the next section ONLY when focus is already there
          if (_mainScrollController.hasClients) {
            // Calculate section position
            final sectionIndex = currentIndex + 1;
            // Only scroll content rows (after featured)
            if (sectionIndex > 1) {
              // This IMPROVED calculation scrolls just enough to show the newly focused row
              // without unnecessarily showing the next row
              double offset = (sectionIndex - 2) * 300.0;

              // Add a bit more offset to ensure current row is fully visible
              // but not so much that it shows too much of the next row
              offset += 80.0;

              _mainScrollController.animateTo(offset,
                  duration: Duration(milliseconds: 300),
                  curve: Curves.easeOutCubic);
            }
          }
        }
      }
    }
  }
}
