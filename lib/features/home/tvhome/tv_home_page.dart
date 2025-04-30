// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:nandiott_flutter/features/home/provider/getContiuneMedia.dart';
// import 'package:nandiott_flutter/features/home/provider/getMedia.dart';
// import 'package:nandiott_flutter/models/movie_model.dart';
// import 'package:nandiott_flutter/pages/detail_page.dart';
// import 'package:nandiott_flutter/providers/checkauth_provider.dart';
// import 'package:nandiott_flutter/providers/filter_fav_provider.dart';
// import 'package:nandiott_flutter/providers/filter_provider.dart';

// // Import your existing providers
// // The below are just placeholders - use your actual imports
// // import 'package:nandiott_flutter/utils/Device_size.dart';
// // import 'package:nandiott_flutter/features/home/providers/providers.dart';
// // import 'package:nandiott_flutter/features/movie_detail/movie_detail_page.dart';

// class TVHomePage extends ConsumerStatefulWidget {
//   const TVHomePage({super.key});

//   @override
//   _TVHomePageState createState() => _TVHomePageState();
// }

// class _TVHomePageState extends ConsumerState<TVHomePage> {
//   // Track the currently focused content
//   Movie? _featuredContent;
//   String userId = "";
  
//   // Focus management
//   Map<String, FocusNode> _sectionFocusNodes = {};
//   Map<String, List<FocusNode>> _itemFocusNodes = {};
  
//   // Track visible sections
//   List<String> _visibleSections = [];
  
//   @override
//   void initState() {
//     super.initState();
    
//     // Initialize section focus nodes
//     _sectionFocusNodes = {
//       'continueWatching': FocusNode(),
//       'newReleases': FocusNode(),
//       'freeToWatch': FocusNode(),
//       'favorites': FocusNode(),
//     };
    
//     // Initialize empty lists for item focus nodes
//     _itemFocusNodes = {
//       'continueWatching': [],
//       'newReleases': [],
//       'freeToWatch': [],
//       'favorites': [],
//     };
    
//     // Set initial focus after the first frame is rendered
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       _setupVisibleSections();
//       _setInitialFocus();
//     });
//   }
  
//   @override
//   void dispose() {
//     // Dispose all focus nodes
//     _sectionFocusNodes.values.forEach((node) => node.dispose());
//     _itemFocusNodes.forEach((key, nodes) {
//       for (var node in nodes) {
//         node.dispose();
//       }
//     });
//     super.dispose();
//   }

//   // Setup visible sections based on data availability
//   void _setupVisibleSections() {
//     final selectedFilter = ref.read(selectedFilterProvider);
//     final sectionVisibility = ref.read(homeSectionVisibilityProvider(selectedFilter));
    
//     setState(() {
//       _visibleSections = [];
      
//       // Add sections that should be visible
//       if (isSectionVisible(sectionVisibility, 'isHistoryVisible')) {
//         _visibleSections.add('continueWatching');
//       }
      
//       if (isSectionVisible(sectionVisibility, 'isLatestVisible')) {
//         _visibleSections.add('newReleases');
//       }
      
//       final freeMediaState = ref.read(freeMediaProvider(selectedFilter));
//       if (freeMediaState is AsyncData && 
//           (freeMediaState as AsyncData).value?.isNotEmpty == true) {
//         _visibleSections.add('freeToWatch');
//       }
      
//       if (isSectionVisible(sectionVisibility, 'isFavoritesVisible')) {
//         _visibleSections.add('favorites');
//       }
//     });
//   }
  
//   // Set initial focus to the first item in the first visible section
//   void _setInitialFocus() {
//     if (_visibleSections.isNotEmpty) {
//       final firstSection = _visibleSections.first;
      
//       // Request focus for the section
//       final sectionNode = _sectionFocusNodes[firstSection];
//       if (sectionNode != null && sectionNode.canRequestFocus) {
//         sectionNode.requestFocus();
//       }
      
//       // If there are items in this section, focus the first one
//       if (_itemFocusNodes[firstSection]!.isNotEmpty) {
//         final firstItemNode = _itemFocusNodes[firstSection]![0];
//         if (firstItemNode.canRequestFocus) {
//           firstItemNode.requestFocus();
//         }
//       }
//     }
//   }
  
//   // Update featured content when a new item is focused
//   void _updateFeaturedContent(Movie movie) {
//     setState(() {
//       _featuredContent = movie;
//     });
//   }
  
//   @override
//   Widget build(BuildContext context) {
//     // Watch the selected filter state - using your existing provider
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
    
//     // Get continue watching data
//     final continueWatchingState = userAsyncValue.when(
//       data: (user) {
//         if (user != null) {
//           setState(() {
//             userId = user.id;
//           });
//           return ref.watch(filteredContinueWatchingProvider(selectedFilter));
//         } else {
//           return AsyncValue.data([]);
//         }
//       },
//       loading: () => AsyncValue.loading(),
//       error: (error, stack) => AsyncValue.error(error, stack),
//     );
    
//     // Rebuild visible sections when data changes
//     if (_visibleSections.isEmpty) {
//       WidgetsBinding.instance.addPostFrameCallback((_) {
//         _setupVisibleSections();
//       });
//     }
    
//     return Scaffold(
//       backgroundColor: Colors.black,
//       body: SafeArea(
//         child: Column(
//           children: [
//             // Featured content hero banner
//             _buildHeroBanner(),
            
//             // Content sections
//             Expanded(
//               child: SingleChildScrollView(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     // Continue Watching Section
//                     if (_visibleSections.contains('continueWatching'))
//                       _buildContinueWatchingSection(continueWatchingState, selectedFilter),
                    
//                     // New Releases Section
//                     if (_visibleSections.contains('newReleases'))
//                       _buildMediaSection(
//                         title: 'New Releases', 
//                         sectionKey: 'newReleases',
//                         mediaAsync: latestMediaAsync, 
//                         mediaType: mediaType
//                       ),
                    
//                     // Free to Watch Section
//                     if (_visibleSections.contains('freeToWatch'))
//                       _buildMediaSection(
//                         title: 'Free to Watch', 
//                         sectionKey: 'freeToWatch',
//                         mediaAsync: freeMediaAsync, 
//                         mediaType: mediaType
//                       ),
                    
//                     // Favorites Section
//                     if (_visibleSections.contains('favorites'))
//                       _buildFavoritesSection(selectedFilter, mediaType),
//                   ],
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
  
//   Widget _buildHeroBanner() {
//     if (_featuredContent == null) {
//       // Default banner when no content is focused
//       return Container(
//         height: 350,
//         width: double.infinity,
//         color: Colors.black45,
//         child: const Center(
//           child: Text(
//             'Welcome to Nandi OTT',
//             style: TextStyle(
//               color: Colors.white,
//               fontSize: 32,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//         ),
//       );
//     }
    
//     // Banner with featured content
//     return Container(
//       height: 350,
//       width: double.infinity,
//       decoration: BoxDecoration(
//         image: DecorationImage(
//           image: NetworkImage( ''),
//           fit: BoxFit.cover,
//           colorFilter: ColorFilter.mode(
//             Colors.black.withOpacity(0.4),
//             BlendMode.darken,
//           ),
//         ),
//       ),
//       child: Padding(
//         padding: const EdgeInsets.all(24.0),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.end,
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               _featuredContent!.title ?? 'Unknown Title',
//               style: const TextStyle(
//                 color: Colors.white,
//                 fontSize: 32,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//             const SizedBox(height: 8),
//             Row(
//               children: [
//                 Text(
//                   '',
//                   style: const TextStyle(color: Colors.white70),
//                 ),
//                 const SizedBox(width: 16),
//                 Container(
//                   padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
//                   decoration: BoxDecoration(
//                     border: Border.all(color: Colors.white70),
//                     borderRadius: BorderRadius.circular(4),
//                   ),
//                   child: Text(
//                     'U/A',
//                     style: const TextStyle(color: Colors.white70),
//                   ),
//                 ),
//                 const SizedBox(width: 16),
//                 const Icon(Icons.star, color: Colors.amber, size: 16),
//                 const SizedBox(width: 4),
//                 Text(
//                   '0',
//                   style: const TextStyle(color: Colors.white70),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 12),
//             Text(
//               'No description available',
//               maxLines: 2,
//               overflow: TextOverflow.ellipsis,
//               style: const TextStyle(color: Colors.white70),
//             ),
//             const SizedBox(height: 24),
//             Row(
//               children: [
//                 ElevatedButton.icon(
//                   style: ElevatedButton.styleFrom(
//                     foregroundColor: Colors.black,
//                     backgroundColor: Colors.white,
//                     padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
//                   ),
//                   icon: const Icon(Icons.play_arrow),
//                   label: const Text('Play'),
//                   onPressed: () {
//                     // Navigate to play the content
//                     if (_featuredContent != null) {
//                       Navigator.push(
//                         context,
//                         MaterialPageRoute(
//                           builder: (context) => MovieDetailPage(
//                             movieId: _featuredContent!.id,
//                             mediaType: getApiMediaType(ref.read(selectedFilterProvider)),
//                             userId: userId,
//                           ),
//                         ),
//                       );
//                     }
//                   },
//                 ),
//                 const SizedBox(width: 16),
//                 OutlinedButton.icon(
//                   style: OutlinedButton.styleFrom(
//                     foregroundColor: Colors.white,
//                     side: const BorderSide(color: Colors.white),
//                     padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
//                   ),
//                   icon: const Icon(Icons.add),
//                   label: const Text('Watchlist'),
//                   onPressed: () {
//                     // Add to watchlist functionality
//                   },
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }
  
//   Widget _buildMediaSection({
//     required String title,
//     required String sectionKey,
//     required AsyncValue<List<Movie>?> mediaAsync,
//     required String mediaType,
//   }) {
//     final sectionIndex = _visibleSections.indexOf(sectionKey);
//     final upSection = sectionIndex > 0 ? _visibleSections[sectionIndex - 1] : null;
//     final downSection = sectionIndex < _visibleSections.length - 1
//         ? _visibleSections[sectionIndex + 1]
//         : null;
        
//     return mediaAsync.when(
//       data: (movies) {
//         if (movies == null || movies.isEmpty) {
//           return const SizedBox.shrink();
//         }
        
//         // Create focus nodes for each item if not already created
//         if (_itemFocusNodes[sectionKey]!.length != movies.length) {
//           _itemFocusNodes[sectionKey] = List.generate(
//             movies.length, 
//             (i) => FocusNode(debugLabel: '$sectionKey-item-$i')
//           );
//         }
        
//         return Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Padding(
//               padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
//               child: Text(
//                 title,
//                 style: const TextStyle(
//                   color: Colors.white,
//                   fontSize: 20,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//             ),
//             SizedBox(
//               height: 200,
//               child: ListView.builder(
//                 key: PageStorageKey('$sectionKey-list'),
//                 scrollDirection: Axis.horizontal,
//                 padding: const EdgeInsets.only(left: 24),
//                 itemCount: movies.length,
//                 itemBuilder: (context, index) {
//                   final movie = movies[index];
//                   final focusNode = _itemFocusNodes[sectionKey]![index];
                  
//                   // Set up directional focus handling
//                   focusNode.onKeyEvent = (node, event) {
//                     if (event is RawKeyDownEvent) {
//                       if (event.logicalKey == LogicalKeyboardKey.arrowUp && upSection != null) {
//                         // Try to find an appropriate node in the section above
//                         if (_itemFocusNodes[upSection]!.isNotEmpty) {
//                           final upIndex = index < _itemFocusNodes[upSection]!.length 
//                               ? index 
//                               : _itemFocusNodes[upSection]!.length - 1;
//                           _itemFocusNodes[upSection]![upIndex].requestFocus();
//                           return KeyEventResult.handled;
//                         }
//                       } else if (event.logicalKey == LogicalKeyboardKey.arrowDown && downSection != null) {
//                         // Try to find an appropriate node in the section below
//                         if (_itemFocusNodes[downSection]!.isNotEmpty) {
//                           final downIndex = index < _itemFocusNodes[downSection]!.length 
//                               ? index 
//                               : _itemFocusNodes[downSection]!.length - 1;
//                           _itemFocusNodes[downSection]![downIndex].requestFocus();
//                           return KeyEventResult.handled;
//                         }
//                       }
//                     }
//                     return KeyEventResult.ignored;
//                   };
                  
//                   return Padding(
//                     padding: const EdgeInsets.only(right: 16, top: 8, bottom: 8),
//                     child: Focus(
//                       focusNode: focusNode,
//                       onFocusChange: (hasFocus) {
//                         if (hasFocus) {
//                           _updateFeaturedContent(movie);
//                         }
//                       },
//                       child: Builder(
//                         builder: (context) {
//                           final isFocused = Focus.of(context).hasFocus;
                          
//                           return GestureDetector(
//                             onTap: () => _navigateToMovieDetails(movie, mediaType),
//                             child: AnimatedContainer(
//                               duration: const Duration(milliseconds: 200),
//                               width: 130,
//                               height: 180,
//                               margin: EdgeInsets.only(
//                                 top: isFocused ? 0 : 10,
//                                 bottom: isFocused ? 10 : 0,
//                               ),
//                               decoration: BoxDecoration(
//                                 borderRadius: BorderRadius.circular(8),
//                                 boxShadow: isFocused
//                                     ? [
//                                         BoxShadow(
//                                           color: Colors.amber.withOpacity(0.6),
//                                           spreadRadius: 2,
//                                           blurRadius: 8,
//                                         )
//                                       ]
//                                     : [],
//                                 border: isFocused
//                                     ? Border.all(color: Colors.amber, width: 3)
//                                     : null,
//                                 image: DecorationImage(
//                                   image: NetworkImage( ''),
//                                   fit: BoxFit.cover,
//                                 ),
//                               ),
//                             ),
//                           );
//                         },
//                       ),
//                     ),
//                   );
//                 },
//               ),
//             ),
//           ],
//         );
//       },
//       loading: () => _buildLoadingSection(title),
//       error: (error, stack) => Padding(
//         padding: const EdgeInsets.all(24.0),
//         child: Center(
//           child: Text(
//             'Failed to load $title: $error',
//             style: const TextStyle(color: Colors.white70),
//           ),
//         ),
//       ),
//     );
//   }
  
//   Widget _buildContinueWatchingSection(AsyncValue continueWatchingState, String selectedFilter) {
//     final sectionKey = 'continueWatching';
//     final sectionIndex = _visibleSections.indexOf(sectionKey);
//     final downSection = sectionIndex < _visibleSections.length - 1
//         ? _visibleSections[sectionIndex + 1]
//         : null;
    
//     return continueWatchingState.when(
//       data: (watchHistoryItems) {
//         if (watchHistoryItems == null || watchHistoryItems.isEmpty) {
//           return const SizedBox.shrink();
//         }
        
//         // Create focus nodes for each item if not already created
//         if (_itemFocusNodes[sectionKey]!.length != watchHistoryItems.length) {
//           _itemFocusNodes[sectionKey] = List.generate(
//             watchHistoryItems.length, 
//             (i) => FocusNode(debugLabel: '$sectionKey-item-$i')
//           );
//         }
        
//         return Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             const Padding(
//               padding: EdgeInsets.fromLTRB(24, 16, 24, 8),
//               child: Text(
//                 'Continue Watching',
//                 style: TextStyle(
//                   color: Colors.white,
//                   fontSize: 20,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//             ),
//             SizedBox(
//               height: 200,
//               child: ListView.builder(
//                 key: PageStorageKey('continue-watching-list'),
//                 scrollDirection: Axis.horizontal,
//                 padding: const EdgeInsets.only(left: 24),
//                 itemCount: watchHistoryItems.length,
//                 itemBuilder: (context, index) {
//                   final item = watchHistoryItems[index];
//                   final focusNode = _itemFocusNodes[sectionKey]![index];
//                   final progress = item.playbackPosition / item.duration;
//                   final movie = item.movieDetail;
                  
//                   // Set up directional focus handling
//                   focusNode.onKeyEvent = (node, event) {
//                     if (event is RawKeyDownEvent) {
//                       if (event.logicalKey == LogicalKeyboardKey.arrowDown && downSection != null) {
//                         // Try to find an appropriate node in the section below
//                         if (_itemFocusNodes[downSection]!.isNotEmpty) {
//                           final downIndex = index < _itemFocusNodes[downSection]!.length 
//                               ? index 
//                               : _itemFocusNodes[downSection]!.length - 1;
//                           _itemFocusNodes[downSection]![downIndex].requestFocus();
//                           return KeyEventResult.handled;
//                         }
//                       }
//                     }
//                     return KeyEventResult.ignored;
//                   };
                  
//                   return Padding(
//                     padding: const EdgeInsets.only(right: 16, top: 8, bottom: 8),
//                     child: Focus(
//                       focusNode: focusNode,
//                       onFocusChange: (hasFocus) {
//                         if (hasFocus) {
//                           _updateFeaturedContent(movie);
//                         }
//                       },
//                       child: Builder(
//                         builder: (context) {
//                           final isFocused = Focus.of(context).hasFocus;
                          
//                           return GestureDetector(
//                             onTap: () => _navigateToMovieDetails(movie, item.contentType),
//                             child: AnimatedContainer(
//                               duration: const Duration(milliseconds: 200),
//                               width: 200,
//                               height: 180,
//                               margin: EdgeInsets.only(
//                                 top: isFocused ? 0 : 10,
//                                 bottom: isFocused ? 10 : 0,
//                               ),
//                               decoration: BoxDecoration(
//                                 borderRadius: BorderRadius.circular(8),
//                                 boxShadow: isFocused
//                                     ? [
//                                         BoxShadow(
//                                           color: Colors.amber.withOpacity(0.6),
//                                           spreadRadius: 2,
//                                           blurRadius: 8,
//                                         )
//                                       ]
//                                     : [],
//                                 border: isFocused
//                                     ? Border.all(color: Colors.amber, width: 3)
//                                     : null,
//                                 image: DecorationImage(
//                                   image: NetworkImage(movie.posterPath ?? ''),
//                                   fit: BoxFit.cover,
//                                 ),
//                               ),
//                               child: Column(
//                                 mainAxisAlignment: MainAxisAlignment.end,
//                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                 children: [
//                                   Container(
//                                     decoration: BoxDecoration(
//                                       gradient: LinearGradient(
//                                         begin: Alignment.topCenter,
//                                         end: Alignment.bottomCenter,
//                                         colors: [
//                                           Colors.transparent,
//                                           Colors.black.withOpacity(0.7),
//                                         ],
//                                       ),
//                                     ),
//                                     padding: const EdgeInsets.all(8),
//                                     child: Column(
//                                       crossAxisAlignment: CrossAxisAlignment.start,
//                                       children: [
//                                         Text(
//                                           movie.title ?? 'Unknown',
//                                           style: const TextStyle(
//                                             color: Colors.white,
//                                             fontWeight: FontWeight.bold,
//                                           ),
//                                           maxLines: 1,
//                                           overflow: TextOverflow.ellipsis,
//                                         ),
//                                         const SizedBox(height: 4),
//                                         // Progress indicator
//                                         LinearProgressIndicator(
//                                           value: progress,
//                                           backgroundColor: Colors.grey[800],
//                                           valueColor: const AlwaysStoppedAnimation<Color>(Colors.amber),
//                                         ),
//                                         const SizedBox(height: 4),
//                                         Text(
//                                           '${_formatDuration(item.playbackPosition)} / ${_formatDuration(item.duration)}',
//                                           style: const TextStyle(
//                                             color: Colors.white70,
//                                             fontSize: 12,
//                                           ),
//                                         ),
//                                       ],
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             ),
//                           );
//                         },
//                       ),
//                     ),
//                   );
//                 },
//               ),
//             ),
//           ],
//         );
//       },
//       loading: () => _buildLoadingSection('Continue Watching'),
//       error: (error, stack) => Padding(
//         padding: const EdgeInsets.all(24.0),
//         child: Center(
//           child: Text(
//             'Failed to load continue watching: $error',
//             style: const TextStyle(color: Colors.white70),
//           ),
//         ),
//       ),
//     );
//   }
  
//   Widget _buildFavoritesSection(String selectedFilter, String mediaType) {
//     final sectionKey = 'favorites';
//     final sectionIndex = _visibleSections.indexOf(sectionKey);
//     final upSection = sectionIndex > 0 ? _visibleSections[sectionIndex - 1] : null;
    
//     // Check if the user has favorites of this content type
//     final hasFavoritesAsync = ref.watch(hasFavoritesForContentTypeProvider(selectedFilter));
    
//     return hasFavoritesAsync.when(
//       data: (hasFavorites) {
//         if (!hasFavorites) {
//           return const SizedBox.shrink();
//         }
        
//         // Fetch the filtered favorites
//         final filteredFavoritesAsync = ref.watch(filteredFavoritesProvider(selectedFilter));
        
//         return filteredFavoritesAsync.when(
//           data: (favoriteDetails) {
//             if (favoriteDetails.isEmpty) {
//               return const SizedBox.shrink();
//             }
            
//             // Create focus nodes for each item if not already created
//             if (_itemFocusNodes[sectionKey]!.length != favoriteDetails.length) {
//               _itemFocusNodes[sectionKey] = List.generate(
//                 favoriteDetails.length, 
//                 (i) => FocusNode(debugLabel: '$sectionKey-item-$i')
//               );
//             }
            
//             return Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 const Padding(
//                   padding: EdgeInsets.fromLTRB(24, 16, 24, 8),
//                   child: Text(
//                     'My Watchlist',
//                     style: TextStyle(
//                       color: Colors.white,
//                       fontSize: 20,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                 ),
//                 SizedBox(
//                   height: 200,
//                   child: ListView.builder(
//                     key: PageStorageKey('favorites-list'),
//                     scrollDirection: Axis.horizontal,
//                     padding: const EdgeInsets.only(left: 24),
//                     itemCount: favoriteDetails.length,
//                     itemBuilder: (context, index) {
//                       final item = favoriteDetails[index];
//                       final favorite = item['favorite'];
//                       final movie = item['movieDetail'];
//                       final focusNode = _itemFocusNodes[sectionKey]![index];
                      
//                       // Set up directional focus handling
//                       focusNode.onKeyEvent = (node, event) {
//                         if (event is RawKeyDownEvent) {
//                           if (event.logicalKey == LogicalKeyboardKey.arrowUp && upSection != null) {
//                             // Try to find an appropriate node in the section above
//                             if (_itemFocusNodes[upSection]!.isNotEmpty) {
//                               final upIndex = index < _itemFocusNodes[upSection]!.length 
//                                   ? index 
//                                   : _itemFocusNodes[upSection]!.length - 1;
//                               _itemFocusNodes[upSection]![upIndex].requestFocus();
//                               return KeyEventResult.handled;
//                             }
//                           }
//                         }
//                         return KeyEventResult.ignored;
//                       };
                      
//                       return Padding(
//                         padding: const EdgeInsets.only(right: 16, top: 8, bottom: 8),
//                         child: Focus(
//                           focusNode: focusNode,
//                           onFocusChange: (hasFocus) {
//                             if (hasFocus) {
//                               _updateFeaturedContent(movie);
//                             }
//                           },
//                           child: Builder(
//                             builder: (context) {
//                               final isFocused = Focus.of(context).hasFocus;
                              
//                               return GestureDetector(
//                                 onTap: () => _navigateToMovieDetails(movie, favorite.contentType),
//                                 child: AnimatedContainer(
//                                   duration: const Duration(milliseconds: 200),
//                                   width: 130,
//                                   height: 180,
//                                   margin: EdgeInsets.only(
//                                     top: isFocused ? 0 : 10,
//                                     bottom: isFocused ? 10 : 0,
//                                   ),
//                                   decoration: BoxDecoration(
//                                     borderRadius: BorderRadius.circular(8),
//                                     boxShadow: isFocused
//                                         ? [
//                                             BoxShadow(
//                                               color: Colors.amber.withOpacity(0.6),
//                                               spreadRadius: 2,
//                                               blurRadius: 8,
//                                             )
//                                           ]
//                                         : [],
//                                     border: isFocused
//                                         ? Border.all(color: Colors.amber, width: 3)
//                                         : null,
//                                     image: DecorationImage(
//                                       image: NetworkImage(movie.posterPath ?? ''),
//                                       fit: BoxFit.cover,
//                                     ),
//                                   ),
//                                 ),
//                               );
//                             },
//                           ),
//                         ),
//                       );
//                     },
//                   ),
//                 ),
//               ],
//             );
//           },
//           loading: () => _buildLoadingSection('My Watchlist'),
//           error: (error, stack) => Padding(
//             padding: const EdgeInsets.all(24.0),
//             child: Center(
//               child: Text(
//                 'Failed to load watchlist: $error',
//                 style: const TextStyle(color: Colors.white70),
//               ),
//             ),
//           ),
//         );
//       },
//       loading: () => const SizedBox.shrink(),
//       error: (_, __) => const SizedBox.shrink(),
//     );
//   }
  
//   Widget _buildLoadingSection(String title) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Padding(
//           padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
//           child: Text(
//             title,
//             style: const TextStyle(
//               color: Colors.white,
//               fontSize: 20,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//         ),
//         SizedBox(
//           height: 200,
//           child: ListView.builder(
//             scrollDirection: Axis.horizontal,
//             padding: const EdgeInsets.only(left: 24),
//             itemCount: 5,
//             itemBuilder: (context, index) {
//               return const Padding(
//                 padding: EdgeInsets.only(right: 16),
//                 child: SkeletonLoader(width: 130, height: 180),
//               );
//             },
//           ),
//         ),
//       ],
//     );
//   }
  
//   void _navigateToMovieDetails(dynamic movie, String mediaType) {
//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (context) => MovieDetailPage(
//           movieId: movie.id,
//           mediaType: mediaType,
//           userId: userId,
//         ),
//       ),
//     );
//   }
  
//   // Helper method to format duration in MM:SS format
//   String _formatDuration(int seconds) {
//     final minutes = seconds ~/ 60;
//     final remainingSeconds = seconds % 60;
//     return '$minutes:${remainingSeconds.toString().padLeft(2, '0')}';
//   }
// }

// // Simple skeleton loader for TV UI
// class SkeletonLoader extends StatelessWidget {
//   final double width;
//   final double height;
  
//   const SkeletonLoader({
//     Key? key,
//     this.width = 130,
//     this.height = 180,
//   }) : super(key: key);
  
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       width: width,
//       height: height,
//       decoration: BoxDecoration(
//         color: Colors.grey[800],
//         borderRadius: BorderRadius.circular(8),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
    
    // Initialize focus nodes
    _sectionFocusNodes['filter'] = FocusNode(debugLabel: 'filter_section');
    _sectionFocusNodes['featured'] = FocusNode(debugLabel: 'featured_section');
    _sectionFocusNodes['continueWatching'] = FocusNode(debugLabel: 'continue_section');
    _sectionFocusNodes['newReleases'] = FocusNode(debugLabel: 'new_releases_section');
    _sectionFocusNodes['freeToWatch'] = FocusNode(debugLabel: 'free_section');
    _sectionFocusNodes['favorites'] = FocusNode(debugLabel: 'favorites_section');
    
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
      case 'Movies': return 'movie';
      case 'Series': return 'tvseries';
      case 'Short Film': return 'shortfilm';
      case 'Documentary': return 'documentary';
      case 'Music': return 'videosong';
      default: return 'movie';
    }
  }
  
  bool _isSectionVisible(AsyncValue<Map<String, dynamic>?> sectionVisibilityAsync, String sectionKey) {
    return sectionVisibilityAsync.when(
      data: (visibilityMap) {
        if (visibilityMap == null) return false;
        return visibilityMap[sectionKey] ?? false;
      },
      loading: () => false,
      error: (_, __) => false,
    );
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
    final sectionVisibilityAsync = ref.watch(homeSectionVisibilityProvider(selectedFilter));
    
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
    ) ?? false;
    
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
    ) ?? false;
    
    if (hasFreeContent) {
      visibleSections.add('freeToWatch');
    }
    
    // Check if favorites section is visible
    if (isUserLoggedIn && (sectionVisibility['isFavoritesVisible'] ?? false)) {
      final hasFavorites = ref.watch(hasFavoritesForContentTypeProvider(selectedFilter)).whenOrNull(
        data: (hasItems) => hasItems,
      ) ?? false;
      
      if (hasFavorites) {
        visibleSections.add('favorites');
      }
    }
    
    // Initialize section focus nodes for the available sections
    for (final section in ['filter', 'featured', ...visibleSections]) {
      if (!_sectionFocusNodes.containsKey(section)) {
        _sectionFocusNodes[section] = FocusNode(debugLabel: '${section}_section');
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
          return AsyncValue.data([]);
        }
      },
      loading: () => AsyncValue.loading(),
      error: (error, stack) => AsyncValue.error(error, stack),
    );

    return Scaffold(
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
          Focus(
            focusNode: _pageFocusNode,
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
                  // Filter bar at the top (completely hidden when not in focus or near focus)
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    height: _activeSection == 'filter' || _activeSection == 'featured' ? 70 : 0,
                    child: AnimatedOpacity(
                      duration: const Duration(milliseconds: 200),
                      opacity: _activeSection == 'filter' || _activeSection == 'featured' ? 1.0 : 0.0,
                      child: Focus(
                        focusNode: _sectionFocusNodes['filter']!,
                        child: PrimeFilterBar(
                          onFilterSelected: (filter) {
                            ref.read(selectedFilterProvider.notifier).state = filter;
                          },
                          hasFocus: _activeSection == 'filter',
                        ),
                      ),
                    ),
                  ),
                  
                  // Featured section (expands/collapses based on focus)
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 400),
                    curve: Curves.easeInOutCubic,
                    height: _featuredExpanded ? screenHeight * 0.6 : screenHeight * 0.25,
                    child: Focus(
                      focusNode: _sectionFocusNodes['featured']!,
                      child: PrimeFeaturedSection(
                        filter: selectedFilter,
                        hasFocus: _activeSection == 'featured',
                        isExpanded: _featuredExpanded,
                        onBackgroundImageChanged: _updateBackgroundImage,
                      ),
                    ),
                  ),
                  
                  // Small spacer to create separation between featured and content rows
                  SizedBox(height: 10),
                  
                  // Content rows
                  Expanded(
                    child: visibleSections.isEmpty
                      ? Center(
                          child: Text(
                            'No content available for this category',
                            style: TextStyle(color: Colors.white70, fontSize: 16),
                          ),
                        )
                      : ListView.builder(
                          padding: EdgeInsets.zero,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: visibleSections.length,
                          itemBuilder: (context, index) {
                            final section = visibleSections[index];
                            
                            // Build the appropriate row based on section type
                            switch (section) {
                              case 'continueWatching':
                                return Focus(
                                  focusNode: _sectionFocusNodes['continueWatching']!,
                                  child: PrimeContentRow(
                                    title: 'Continue Watching',
                                    mediaAsync: continueWatchingState,
                                    rowType: 'history',
                                    mediaType: mediaType,
                                    hasFocus: _activeSection == 'continueWatching',
                                    userId: _userId,
                                    onBackgroundImageChanged: _updateBackgroundImage,
                                    onLeftEdgeFocus: () {
                                      if (widget.onLeftEdgeFocus != null) widget.onLeftEdgeFocus!();
                                    },
                                    onRightEdgeFocus: () {
                                      if (widget.onRightEdgeFocus != null) widget.onRightEdgeFocus!();
                                    },
                                    onContentFocus: () {
                                      if (widget.onContentFocus != null) widget.onContentFocus!();
                                    },
                                  ),
                                );
                                
                              case 'newReleases':
                                return Focus(
                                  focusNode: _sectionFocusNodes['newReleases']!,
                                  child: PrimeContentRow(
                                    title: 'New Releases',
                                    mediaAsync: latestMediaAsync,
                                    rowType: 'standard',
                                    mediaType: mediaType,
                                    hasFocus: _activeSection == 'newReleases',
                                    userId: _userId,
                                    onBackgroundImageChanged: _updateBackgroundImage,
                                    onLeftEdgeFocus: () {
                                      if (widget.onLeftEdgeFocus != null) widget.onLeftEdgeFocus!();
                                    },
                                    onRightEdgeFocus: () {
                                      if (widget.onRightEdgeFocus != null) widget.onRightEdgeFocus!();
                                    },
                                    onContentFocus: () {
                                      if (widget.onContentFocus != null) widget.onContentFocus!();
                                    },
                                  ),
                                );
                                
                              case 'freeToWatch':
                                return Focus(
                                  focusNode: _sectionFocusNodes['freeToWatch']!,
                                  child: PrimeContentRow(
                                    title: 'Free to Watch',
                                    mediaAsync: freeMediaAsync,
                                    rowType: 'standard',
                                    mediaType: mediaType,
                                    hasFocus: _activeSection == 'freeToWatch',
                                    userId: _userId,
                                    onBackgroundImageChanged: _updateBackgroundImage,
                                    onLeftEdgeFocus: () {
                                      if (widget.onLeftEdgeFocus != null) widget.onLeftEdgeFocus!();
                                    },
                                    onRightEdgeFocus: () {
                                      if (widget.onRightEdgeFocus != null) widget.onRightEdgeFocus!();
                                    },
                                    onContentFocus: () {
                                      if (widget.onContentFocus != null) widget.onContentFocus!();
                                    },
                                  ),
                                );
                                
                              case 'favorites':
                                return Focus(
                                  focusNode: _sectionFocusNodes['favorites']!,
                                  child: PrimeContentRow(
                                    title: 'My Wishlist',
                                    mediaAsync: ref.watch(filteredFavoritesProvider(selectedFilter)),
                                    rowType: 'favorites',
                                    mediaType: mediaType,
                                    hasFocus: _activeSection == 'favorites',
                                    userId: _userId,
                                    onBackgroundImageChanged: _updateBackgroundImage,
                                    onLeftEdgeFocus: () {
                                      if (widget.onLeftEdgeFocus != null) widget.onLeftEdgeFocus!();
                                    },
                                    onRightEdgeFocus: () {
                                      if (widget.onRightEdgeFocus != null) widget.onRightEdgeFocus!();
                                    },
                                    onContentFocus: () {
                                      if (widget.onContentFocus != null) widget.onContentFocus!();
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
    );
  }
  
  Widget _buildExpandedCardOverlay(Map<String, dynamic> cardData, BuildContext context) {
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
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                            decoration: BoxDecoration(
                              color: Colors.amber,
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: Text(
                              mediaType == 'movie' ? 'Movie'
                                : mediaType == 'tvseries' ? 'TV Series'
                                : mediaType == 'shortfilm' ? 'Short Film'
                                : mediaType == 'documentary' ? 'Documentary'
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
                            const Icon(Icons.star, color: Colors.amber, size: 20),
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
    final hasFavoritesAsync = ref.watch(hasFavoritesForContentTypeProvider(selectedFilter));
    
    return hasFavoritesAsync.when(
      data: (hasFavorites) {
        if (!hasFavorites) {
          return const SizedBox.shrink();
        }
        
        // Get the filtered favorites
        final filteredFavoritesAsync = ref.watch(filteredFavoritesProvider(selectedFilter));
        
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
    final List<String> allSections = ['filter', 'featured', 'continueWatching', 'newReleases', 'freeToWatch', 'favorites'];
    final List<String> visibleSections = ['filter', 'featured'];
    
    // Add the currently active content sections based on what's visible in the UI
    for (final section in allSections.skip(2)) { // Skip filter and featured
      if (_sectionFocusNodes.containsKey(section)) {
        visibleSections.add(section);
      }
    }
    
    // Find current section index in visible sections
    final currentIndex = visibleSections.indexOf(_activeSection);
    if (currentIndex == -1) return;
    
    if (moveUp) {
      // Moving up in the UI
      if (currentIndex > 0) {
        final previousSection = visibleSections[currentIndex - 1];
        
        // Special handling when moving up from content rows to featured
        if (currentIndex >= 2 && previousSection == 'featured') { // Going from content to featured
          // Clear any expanded card data for smooth transition
          ref.read(expandedCardProvider.notifier).state = {};
          
          // Expand the featured section first
          setState(() {
            _featuredExpanded = true;
          });
          
          // Request focus with a slight delay to allow animations to complete
          Future.delayed(Duration(milliseconds: 150), () {
            if (mounted && _sectionFocusNodes[previousSection]!.canRequestFocus) {
              _sectionFocusNodes[previousSection]!.requestFocus();
            }
          });
        } else {
          // Standard up navigation
          if (_sectionFocusNodes[previousSection]!.canRequestFocus) {
            _sectionFocusNodes[previousSection]!.requestFocus();
          }
        }
      }
    } else {
      // Moving down in the UI
      if (currentIndex < visibleSections.length - 1) {
        final nextSection = visibleSections[currentIndex + 1];
        
        // Special handling when moving from featured to first content row
        if (currentIndex == 1 && _activeSection == 'featured') { // Going from featured to content
          // Collapse featured section first
          setState(() {
            _featuredExpanded = false;
            // Pre-emptively update active section to avoid focus issues
            _activeSection = nextSection;
          });
          
          // Update global focus state
          ref.read(focusedSectionProvider.notifier).state = nextSection;
          
          // Request focus with a slight delay to allow animations to complete
          Future.delayed(Duration(milliseconds: 150), () {
            if (mounted && _sectionFocusNodes[nextSection]!.canRequestFocus) {
              _sectionFocusNodes[nextSection]!.requestFocus();
            }
          });
        } else {
          // Standard down navigation
          if (_sectionFocusNodes[nextSection]!.canRequestFocus) {
            _sectionFocusNodes[nextSection]!.requestFocus();
          }
        }
      }
    }
  }
}