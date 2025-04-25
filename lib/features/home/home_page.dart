// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:nandiott_flutter/app/widgets/favFilm_card_widget.dart';
// import 'package:nandiott_flutter/app/widgets/film_card_widget.dart';
// import 'package:nandiott_flutter/app/widgets/filterSelector_widget.dart';
// import 'package:nandiott_flutter/app/widgets/skeltonLoader/filmSkelton.dart';
// import 'package:nandiott_flutter/features/home/featured-movie/new_carousel.dart';
// import 'package:nandiott_flutter/features/home/movieRow_widget.dart';
// import 'package:nandiott_flutter/features/home/provider/getContiuneMedia.dart';
// import 'package:nandiott_flutter/features/home/provider/getMedia.dart';
// import 'package:nandiott_flutter/features/profile/watchHistory/historyCard_widget.dart';
// import 'package:nandiott_flutter/models/movie_model.dart';
// import 'package:nandiott_flutter/pages/detail_page.dart';
// import 'package:nandiott_flutter/providers/checkauth_provider.dart';
// import 'package:nandiott_flutter/providers/detail_provider.dart';
// import 'package:nandiott_flutter/providers/filter_fav_provider.dart';
// import 'package:nandiott_flutter/providers/filter_provider.dart';
// import 'package:nandiott_flutter/providers/homecontents_provider.dart';

// class HomePage extends ConsumerStatefulWidget {
//   const HomePage({super.key});

//   @override
//   _HomePageState createState() => _HomePageState();
// }

// class _HomePageState extends ConsumerState<HomePage> {
//   late String userId;

//   @override
//   void initState() {
//     super.initState();
//     userId = "";
//   }

//   @override
//   Widget build(BuildContext context) {
//     // Watch the selected filter state
//     final selectedFilter = ref.watch(selectedFilterProvider);
    
//     // Get API media type for the selected filter
//     final mediaType = getApiMediaType(selectedFilter);
    
//     // Watch section visibility settings for the selected filter
//     final sectionVisibilityAsync = ref.watch(homeSectionVisibilityProvider(selectedFilter));
    
//     // Watch media data based on the selected filter
//     final latestMediaAsync = ref.watch(latestMediaProvider(selectedFilter));
//     final freeMediaAsync = ref.watch(freeMediaProvider(selectedFilter));

//     // Get user for continue watching
//     final userAsyncValue = ref.watch(authUserProvider);
    
//     final continueWatchingState = userAsyncValue.when(
//       data: (user) {
//         if (user != null) {
//           setState(() {
//             userId = user.id;
//           });
//           return ref.watch(continueWatchingProvider);
//         } else {
//           return AsyncValue.data([]);
//         }
//       },
//       loading: () => AsyncValue.loading(),
//       error: (error, stack) => AsyncValue.error(error, stack),
//     );

//     return Scaffold(
//       body: SafeArea(
//         child: SingleChildScrollView(
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               // Dynamic Filter Selector based on API response
//               FilterSelector(
//                 onFilterSelected: (filter) {
//                   ref.read(selectedFilterProvider.notifier).state = filter;
//                 },
//               ),
              
//               SizedBox(height: 5),

//               // Featured Carousel Section
//               Container(
//                 margin: EdgeInsets.only(top: 10),
//                 child: SimpleFeaturedCarousel(filter: selectedFilter)
//               ),
              
//               // Continue Watching Section - Show only if isHistoryVisible is true
//               if (isSectionVisible(sectionVisibilityAsync, 'isHistoryVisible'))
//                 _buildContinueWatchingSection(continueWatchingState, selectedFilter),

//               // New Releases Section - Show only if isLatestVisible is true
//               if (isSectionVisible(sectionVisibilityAsync, 'isLatestVisible'))
//                 _buildMediaSection(
//                   title: 'New Releases',
//                   mediaAsync: latestMediaAsync,
//                   mediaType: mediaType,
//                 ),
                
//               // Free Movies Section - Show only if free movies API returns data
//               if (freeMediaAsync is AsyncData && freeMediaAsync.value != null && freeMediaAsync.value!.isNotEmpty)
//                 _buildMediaSection(
//                   title: 'Free to Watch',
//                   mediaAsync: freeMediaAsync,
//                   mediaType: mediaType,
//                 ),
                
//               // Favorites Section - Show only if isFavoritesVisible is true
//               if (isSectionVisible(sectionVisibilityAsync, 'isFavoritesVisible'))
//                 _buildFavoritesSection(selectedFilter, mediaType)
//             ],
//           ),
//         ),
//       ),
//     );
//   }
  
//   Widget _buildMediaSection({
//     required String title,
//     required AsyncValue<List<Movie>?> mediaAsync,
//     required String mediaType,
//   }) {
//     return mediaAsync.when(
//       data: (movies) {
//         if (movies == null || movies.isEmpty) {
//           return SizedBox.shrink();
//         }
        
//         return Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Padding(
//               padding: const EdgeInsets.only(top: 10.0, left: 10.0, bottom: 5),
//               child: Text(
//                 title,
//                 style: TextStyle(fontWeight: FontWeight.bold),
//               ),
//             ),
//             SizedBox(
//               height: 160, // Adjust height as needed for your cards
//               child: ListView.builder(
//                 scrollDirection: Axis.horizontal,
//                 padding: const EdgeInsets.only(top: 8.0, left: 15),
//                 itemCount: movies.length,
//                 itemBuilder: (context, index) {
//                   final movie = movies[index];
//                   return GestureDetector(
//                     onTap: () => _navigateToMovieDetails(
//                       movie,
//                       mediaType,
//                       userId,
//                       context,
//                     ),
//                     child: Padding(
//                       padding: const EdgeInsets.only(right: 10.0),
//                       child: FilmCard(
//                         film: movie,
//                         mediaType: mediaType,
//                         // userId: userId,
//                       ),
//                     ),
//                   );
//                 },
//               ),
//             ),
//           ],
//         );
//       },
//       loading: () => Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Padding(
//             padding: const EdgeInsets.only(top: 5.0, left: 5.0, bottom: 5),
//             child: Text(title),
//           ),
//           SingleChildScrollView(
//             scrollDirection: Axis.horizontal,
//             child: Padding(
//               padding: const EdgeInsets.only(left: 10),
//               child: Row(
//                 children: List.generate(5, (index) {
//                   return const Padding(
//                     padding: EdgeInsets.only(right: 10.0),
//                     child: SkeletonLoader(),
//                   );
//                 }),
//               ),
//             ),
//           ),
//         ],
//       ),
//       error: (error, stack) => Padding(
//         padding: const EdgeInsets.all(15.0),
//         child: Center(child: Text('Failed to load ${title.toLowerCase()}: $error')),
//       ),
//     );
//   }
  
//   Widget _buildContinueWatchingSection(AsyncValue continueWatchingState, String selectedFilter) {
//     return continueWatchingState.when(
//       data: (watchHistoryItems) {
//         if (watchHistoryItems == null || watchHistoryItems.isEmpty) {
//           return const SizedBox.shrink();
//         }

//         // Create a safe copy of the filter map
//         final filterToMediaTypeMap = {
//           'Movies': 'Movie',
//           'Series': 'TVSeries',
//           'Short Film': 'ShortFilm',
//           'Documentary': 'Documentary',
//           'Music': 'VideoSong',
//         };

//         // Safely get the content type or default to 'Movie'
//         final contentType = filterToMediaTypeMap[selectedFilter] ?? 'Movie';

//         // First filter by content type
//         final typeFilteredHistory = watchHistoryItems.where((item) {
//           return item != null && item.contentType == contentType;
//         }).toList();

//         // Then filter out items where movie details can't be loaded
//         final validHistory = typeFilteredHistory.where((item) {
//           if (item.contentId == null || item.contentType == null) {
//             return false;
//           }

//           final movieDetail = ref.watch(movieDetailProvider(MovieDetailParameter(
//             movieId: item.tvSeriesId ?? item.contentId,
//             mediaType: item.contentType,
//           )));

//           // Consider the item valid if its details are successfully loaded
//           return movieDetail is AsyncData;
//         }).toList();

//         if (validHistory.isEmpty) {
//           return const SizedBox.shrink();
//         }

//         return Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             const Padding(
//               padding: EdgeInsets.only(top: 10.0, left: 10.0, bottom: 5),
//               child: Text(
//                 'Continue Watching',
//                 style: TextStyle(fontWeight: FontWeight.bold),
//               ),
//             ),
//             SizedBox(
//              height: 160, 
//               child: ListView.builder(
//                 scrollDirection: Axis.horizontal,
//                 padding: const EdgeInsets.only(top: 8.0, left: 15),
//                 itemCount: validHistory.length,
//                 itemBuilder: (context, index) {
//                   try {
//                     final item = validHistory[index];
//                     return HistorycardWidget(historyItem: item);
//                   } catch (e) {
//                     print('Error creating history card: $e');
//                     return const SizedBox(width: 120);
//                   }
//                 },
//               ),
//             ),
//           ],
//         );
//       },
//       loading: () {
//         return Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Padding(
//               padding: const EdgeInsets.only(
//                   top: 5.0, left: 5.0, bottom: 5),
//               child: Text('Continue Watching'),
//             ),
//             SingleChildScrollView(
//               scrollDirection: Axis.horizontal,
//               child: Padding(
//                 padding: const EdgeInsets.only(left: 10),
//                 child: Row(
//                   children: List.generate(5, (index) {
//                     return const SkeletonLoader(); // Use skeleton loader
//                   }),
//                 ),
//               ),
//             ),
//           ],
//         );
//       },
//       error: (error, stack) => Padding(
//         padding: const EdgeInsets.all(15.0),
//         child: Center(child: Text('Failed to load: $error')),
//       ),
//     );
//   }
  
//   Widget _buildFavoritesSection(String selectedFilter, String mediaType) {
//     // Check if the user has favorites of this content type
//     final hasFavoritesAsync = ref.watch(hasFavoritesForContentTypeProvider(selectedFilter));
    
//     return hasFavoritesAsync.when(
//       data: (hasFavorites) {
//         if (!hasFavorites) {
//           return SizedBox.shrink(); // Don't show section if no favorites of this type
//         }
        
//         // Fetch the filtered favorites
//         final filteredFavoritesAsync = ref.watch(filteredFavoritesProvider(selectedFilter));
        
//         return filteredFavoritesAsync.when(
//           data: (favoriteDetails) {
//             if (favoriteDetails.isEmpty) {
//               return SizedBox.shrink();
//             }
            
//             return Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 const Padding(
//                   padding: EdgeInsets.only(top: 10.0, left: 10.0, bottom: 5),
//                   child: Text(
//                     'My Wishlist',
//                     style: TextStyle(fontWeight: FontWeight.bold),
//                   ),
//                 ),
//                 SizedBox(
//                   height: 160,  // Adjust based on your card size
//                   child: ListView.builder(
//                     scrollDirection: Axis.horizontal,
//                     padding: const EdgeInsets.only(top: 8.0, left: 15),
//                     itemCount: favoriteDetails.length,
//                     itemBuilder: (context, index) {
//                       final item = favoriteDetails[index];
//                       final favorite = item['favorite'];
//                       final movieDetail = item['movieDetail'];
                      
//                       return GestureDetector(
//                         onTap: () => _navigateToMovieDetails(
//                           movieDetail,
//                           favorite.contentType,
//                           userId,
//                           context,
//                         ),
//                         child: Padding(
//                           padding: const EdgeInsets.only(right: 10.0),
//                           child: FavFilmCard(
//                             film: movieDetail,
//                             mediaType: favorite.contentType,
//                           ),
//                         ),
//                       );
//                     },
//                   ),
//                 ),
//               ],
//             );
//           },
//           loading: () => Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               const Padding(
//                 padding: EdgeInsets.only(top: 10.0, left: 10.0, bottom: 5),
//                 child: Text(
//                   'My Wishlist',
//                   style: TextStyle(fontWeight: FontWeight.bold),
//                 ),
//               ),
//               SingleChildScrollView(
//                 scrollDirection: Axis.horizontal,
//                 child: Padding(
//                   padding: const EdgeInsets.only(left: 10),
//                   child: Row(
//                     children: List.generate(5, (index) {
//                       return const Padding(
//                         padding: EdgeInsets.only(right: 10.0),
//                         child: SkeletonLoader(),
//                       );
//                     }),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//           error: (error, stack) => Padding(
//             padding: const EdgeInsets.all(15.0),
//             child: Center(child: Text('Failed to load wishlist: $error')),
//           ),
//         );
//       },
//       loading: () => SizedBox.shrink(), // Don't show while checking
//       error: (_, __) => SizedBox.shrink(), // Don't show on error
//     );
//   }
  
//   void _navigateToMovieDetails(dynamic movie, String mediaType, String userId, BuildContext context) {
//     String title = movie is Movie ? movie.title : "Movie";
//     print("Navigate to details for: $title");
    
//     Navigator.of(context).push(MaterialPageRoute(
//       builder: (context) => MovieDetailPage(
//         movieId: movie.id,
//         mediaType: mediaType,
//         userId: userId,
//       ),
//     ));
//   }
// }

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
import 'package:nandiott_flutter/providers/detail_provider.dart';
import 'package:nandiott_flutter/providers/filter_fav_provider.dart';
import 'package:nandiott_flutter/providers/filter_provider.dart';
import 'package:nandiott_flutter/providers/homecontents_provider.dart';
import 'package:nandiott_flutter/utils/Device_size.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  late String userId;
  // Simple list of focus nodes for TV navigation
  Map<String, FocusNode> _sectionFocusNodes = {};
  
  // Track first item focus nodes for each section's first row
  Map<String, FocusNode> _firstItemFocusNodes = {};

  
  @override
  void initState() {
    super.initState();
    userId = "";
    
    // Initialize section focus nodes
    _sectionFocusNodes = {
      'continueWatching': FocusNode(),
      'newReleases': FocusNode(),
      'freeToWatch': FocusNode(),
      'favorites': FocusNode(),
    };
    
    // Initialize first item focus nodes
    _firstItemFocusNodes = {
      'continueWatching': FocusNode(),
      'newReleases': FocusNode(),
      'freeToWatch': FocusNode(),
      'favorites': FocusNode(),
    };
       // Set initial focus after the first frame is rendered
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _setInitialFocus();
    });
  }
  void _setInitialFocus() {
    // Get visible sections
    final visibleSections = [
      if (isSectionVisible(ref.read(homeSectionVisibilityProvider(ref.read(selectedFilterProvider))), 'isHistoryVisible')) 'continueWatching',
      if (isSectionVisible(ref.read(homeSectionVisibilityProvider(ref.read(selectedFilterProvider))), 'isLatestVisible')) 'newReleases',
      if (ref.read(freeMediaProvider(ref.read(selectedFilterProvider))) is AsyncData && 
          (ref.read(freeMediaProvider(ref.read(selectedFilterProvider))) as AsyncData).value?.isNotEmpty == true) 'freeToWatch',
      if (isSectionVisible(ref.read(homeSectionVisibilityProvider(ref.read(selectedFilterProvider))), 'isFavoritesVisible')) 'favorites',
    ];

    // Focus the first item in the first visible section
    if (visibleSections.isNotEmpty) {
      final firstSection = visibleSections.first;
      final focusNode = _firstItemFocusNodes[firstSection];
      if (focusNode != null && focusNode.canRequestFocus) {
        focusNode.requestFocus();
      }
    }
  } 

  @override
  void dispose() {
    // Dispose all focus nodes
    _sectionFocusNodes.values.forEach((node) => node.dispose());
    _firstItemFocusNodes.values.forEach((node) => node.dispose());
    super.dispose();
  }

  // Helper method to convert section name to human-readable title
  String _sectionNameToTitle(String sectionName) {
    switch (sectionName) {
      case 'continueWatching':
        return 'Continue Watching';
      case 'newReleases':
        return 'New Releases';
      case 'freeToWatch':
        return 'Free to Watch';
      case 'favorites':
        return 'My Wishlist';
      default:
        return sectionName;
    }
  }
  

  @override
  Widget build(BuildContext context) {
    final isTV = AppSizes.getDeviceType(context) == DeviceType.tv;
    
    
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
    // ✅ DYNAMIC FOCUS LOGIC for FilmCard & HistorycardWidget with optional section support
  // This assumes sections are dynamically controlled via visibility logic
  
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
      body: SafeArea(
        child: FocusTraversalGroup(
          policy: OrderedTraversalPolicy(),
          child: SingleChildScrollView(
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
                  margin: EdgeInsets.only(top: 10),
                  child: SimpleFeaturedCarousel(filter: selectedFilter)
                ),
                
                // Continue Watching Section - Show only if isHistoryVisible is true
                if (visibleSections.contains('continueWatching'))
        buildContinueWatchingSection(selectedFilter, visibleSections),

                // New Releases Section - Show only if isLatestVisible is true
                if (visibleSections.contains('newReleases'))
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text('New Releases', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            ),
            buildMediaSection(
              sectionKey: 'newReleases',
              title: 'New Releases',
              mediaAsync: latestMediaAsync,
              mediaType: getApiMediaType(selectedFilter),
              visibleSections: visibleSections,
            ),
          ],
        ),

      if (visibleSections.contains('freeToWatch'))
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text('Free to Watch', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            ),

            buildMediaSection(
              sectionKey: 'freeToWatch',
              title: 'Free to Watch',
              mediaAsync: freeMediaAsync,
              mediaType: getApiMediaType(selectedFilter),
              visibleSections: visibleSections,
            ),
          ],
        ),
                  
                // Favorites Section - Show only if isFavoritesVisible is true
                if (isSectionVisible(sectionVisibilityAsync, 'isFavoritesVisible'))
                  _buildFavoritesSection(selectedFilter, mediaType)
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  
  
Widget buildMediaSection({
  required String sectionKey,
  required String title,
  required AsyncValue<List<Movie>?> mediaAsync,
  required String mediaType,
  required List<String> visibleSections,
}) {
  final sectionIndex = visibleSections.indexOf(sectionKey);
  final upSection = sectionIndex > 0 ? visibleSections[sectionIndex - 1] : null;
  final downSection = sectionIndex < visibleSections.length - 1
      ? visibleSections[sectionIndex + 1]
      : null;

  return mediaAsync.when(
    data: (movies) {
      if (movies == null || movies.isEmpty) return const SizedBox.shrink();

      return SizedBox(
        height: 160,
        child: ListView.builder(
          key: PageStorageKey('$sectionKey-list'),  // Add key to preserve scroll position
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.only(top: 8.0, left: 15),
          itemCount: movies.length,
          itemBuilder: (context, index) {
            final movie = movies[index];
            final isFirst = index == 0;
            final focusNode = isFirst ? _firstItemFocusNodes[sectionKey] : null;
            
            if (isFirst && focusNode != null) {
              // Configure keyboard navigation for the first item
              focusNode.onKeyEvent = (node, event) {
                if (event is RawKeyDownEvent) {
                  if (event.logicalKey == LogicalKeyboardKey.arrowUp && upSection != null) {
                    // Navigate to the section above
                    final upNode = _firstItemFocusNodes[upSection];
                    if (upNode != null && upNode.canRequestFocus) {
                      upNode.requestFocus();
                      return KeyEventResult.handled;
                    }
                  } else if (event.logicalKey == LogicalKeyboardKey.arrowDown && downSection != null) {
                    // Navigate to the section below
                    final downNode = _firstItemFocusNodes[downSection];
                    if (downNode != null && downNode.canRequestFocus) {
                      downNode.requestFocus();
                      return KeyEventResult.handled;
                    }
                  } else if (event.logicalKey == LogicalKeyboardKey.arrowUp && upSection == null) {
                    // We're at the top, go to filter/featured
                    _sectionFocusNodes['filter']?.requestFocus();
                    return KeyEventResult.handled;
                  }
                }
                return KeyEventResult.ignored;
              };
            }
          
            return GestureDetector(
              onTap: () => _navigateToMovieDetails(
                movie,
                mediaType,
                userId,
                context,
              ),
              child: Focus(
                focusNode: focusNode,
                child: Builder(
                  builder: (context) {
                    final isFocused = Focus.of(context).hasFocus;
                    return FilmCard(
                      film: movie,
                      mediaType: mediaType,
                      index: index,
                      hasFocus: isFocused,
                    );
                  },
                ),
              ),
            );
          },
        ),
      );
    },
      loading: () => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 5.0, left: 5.0, bottom: 5),
            child: Text(title),
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
        child: Center(child: Text('Failed to load ${title.toLowerCase()}: $error')),
      ),
    );
  }
  
// Widget buildContinueWatchingSection(
//   AsyncValue continueWatchingState,
//   String selectedFilter,
//   List<String> visibleSections,
// ) {
//   final sectionKey = 'continueWatching';
//   final sectionIndex = visibleSections.indexOf(sectionKey);
//   final downSection = sectionIndex < visibleSections.length - 1
//       ? visibleSections[sectionIndex + 1]
//       : null;

//   return continueWatchingState.when(
//     data: (watchHistoryItems) {
//       if (watchHistoryItems == null || watchHistoryItems.isEmpty) {
//         return const SizedBox.shrink();
//       }

//       return Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           const Padding(
//             padding: EdgeInsets.only(top: 10.0, left: 10.0, bottom: 5),
//             child: Text(
//               'Continue Watching',
//               style: TextStyle(fontWeight: FontWeight.bold),
//             ),
//           ),
//           SizedBox(
//             height: 160,
//             child: ListView.builder(
//               key: PageStorageKey('continueWatching-list'),  // Add key to preserve scroll position
//               scrollDirection: Axis.horizontal,
//               padding: const EdgeInsets.only(top: 8.0, left: 15),
//               itemCount: watchHistoryItems.length,
//               itemBuilder: (context, index) {
//                 final isFirst = index == 0;
//                 final item = watchHistoryItems[index];
//                 final focusNode = isFirst ? _firstItemFocusNodes[sectionKey] : null;
                
//                 if (isFirst && focusNode != null) {
//                   focusNode.onKeyEvent = (node, event) {
//                     if (event is RawKeyDownEvent) {
//                       if (event.logicalKey == LogicalKeyboardKey.arrowDown && downSection != null) {
//                         // Navigate to the section below
//                         _firstItemFocusNodes[downSection]?.requestFocus();
//                         return KeyEventResult.handled;
//                       } else if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
//                         // Navigate to filter/featured
//                         _sectionFocusNodes['filter']?.requestFocus();
//                         return KeyEventResult.handled;
//                       }
//                     }
//                     return KeyEventResult.ignored;
//                   };
//                 }

//                 return Focus(
//                   focusNode: focusNode,
//                   child: Builder(
//                     builder: (context) {
//                       final isFocused = Focus.of(context).hasFocus;
//                       return HistorycardWidget(
//                         historyItem: item,
//                         index: index,
//                         hasFocus: isFocused,
//                       );
//                     },
//                   ),
//                 );
//               },
//             ),
//           ),
//         ],
//       );
//     },
//       loading: () {
//         return Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Padding(
//               padding: const EdgeInsets.only(
//                   top: 5.0, left: 5.0, bottom: 5),
//               child: Text('Continue Watching'),
//             ),
//             SingleChildScrollView(
//               scrollDirection: Axis.horizontal,
//               child: Padding(
//                 padding: const EdgeInsets.only(left: 10),
//                 child: Row(
//                   children: List.generate(5, (index) {
//                     return const SkeletonLoader(); // Use skeleton loader
//                   }),
//                 ),
//               ),
//             ),
//           ],
//         );
//       },
//       error: (error, stack) => Padding(
//         padding: const EdgeInsets.all(15.0),
//         child: Center(child: Text('Failed to load: $error')),
//       ),
//     );
//   }

Widget buildContinueWatchingSection(
  String selectedFilter,
  List<String> visibleSections,
) {
  final sectionKey = 'continueWatching';
  final sectionIndex = visibleSections.indexOf(sectionKey);
  final downSection = sectionIndex < visibleSections.length - 1
      ? visibleSections[sectionIndex + 1]
      : null;

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
                return const SkeletonLoader(); // Use skeleton loader
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

  return Column(
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
          key: PageStorageKey('continueWatching-list'),
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.only(top: 8.0, left: 15),
          itemCount: watchHistoryItems.length,
          itemBuilder: (context, index) {
            final isFirst = index == 0;
            final item = watchHistoryItems[index];
            final focusNode = isFirst ? _firstItemFocusNodes[sectionKey] : null;
            
            if (isFirst && focusNode != null) {
              focusNode.onKeyEvent = (node, event) {
                if (event is RawKeyDownEvent) {
                  if (event.logicalKey == LogicalKeyboardKey.arrowDown && downSection != null) {
                    // Navigate to the section below
                    _firstItemFocusNodes[downSection]?.requestFocus();
                    return KeyEventResult.handled;
                  } else if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
                    // Navigate to filter/featured
                    _sectionFocusNodes['filter']?.requestFocus();
                    return KeyEventResult.handled;
                  }
                }
                return KeyEventResult.ignored;
              };
            }

            return Focus(
              focusNode: focusNode,
              child: Builder(
                builder: (context) {
                  final isFocused = Focus.of(context).hasFocus;
                  return HistorycardWidget(
                    historyItem: item,
                    index: index,
                    hasFocus: isFocused,
                  );
                },
              ),
            );
          },
        ),
      ),
    ],
  );
}
  
  Widget _buildFavoritesSection(String selectedFilter, String mediaType) {
  final isTV = AppSizes.getDeviceType(context) == DeviceType.tv;
  
  // Check if the user has favorites of this content type
  final hasFavoritesAsync = ref.watch(hasFavoritesForContentTypeProvider(selectedFilter));
  
  return hasFavoritesAsync.when(
    data: (hasFavorites) {
      if (!hasFavorites) {
        return SizedBox.shrink(); // Don't show section if no favorites of this type
      }
      
      // Fetch the filtered favorites
      final filteredFavoritesAsync = ref.watch(filteredFavoritesProvider(selectedFilter));
      
      return filteredFavoritesAsync.when(
        data: (favoriteDetails) {
          if (favoriteDetails.isEmpty) {
            return SizedBox.shrink();
          }
          
          return FocusTraversalOrder(
            order: NumericFocusOrder(4.0), // Last section
            child: Column(
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
                  height: 160,  // Adjust based on your card size
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.only(top: 8.0, left: 15),
                    itemCount: favoriteDetails.length,
                    itemBuilder: (context, index) {
                      final item = favoriteDetails[index];
                      final favorite = item['favorite'];
                      final movieDetail = item['movieDetail'];
                      
                      // Create a focus node for the first item
                      final itemFocusNode = index == 0 ? _firstItemFocusNodes['favorites'] : null;
                      
                      return FocusTraversalOrder(
                        order: NumericFocusOrder(index.toDouble()),
                        child: GestureDetector(
                          onTap: () => _navigateToMovieDetails(
                            movieDetail,
                            favorite.contentType,
                            userId,
                            context,
                          ),
                          child: Padding(
                            padding: const EdgeInsets.only(right: 10.0),
                            child: FavFilmCard(
                              film: movieDetail,
                              mediaType: favorite.contentType,
                              // focusNode: itemFocusNode,
                              // index: index,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
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
    loading: () => SizedBox.shrink(), // Don't show while checking
    error: (_, __) => SizedBox.shrink(), // Don't show on error
  );
}

void _navigateToMovieDetails(dynamic movie, String mediaType, String userId, BuildContext context) {
  
  Navigator.of(context).push(MaterialPageRoute(
    builder: (context) => MovieDetailPage(
      movieId: movie.id,
      mediaType: mediaType,
      userId: userId,
    ),
  ));
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
    loading: () => false, // Default to false while loading
    error: (_, __) => false, // Default to false on error
  );
}
}