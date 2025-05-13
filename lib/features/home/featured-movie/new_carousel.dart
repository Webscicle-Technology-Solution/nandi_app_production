// // In new_carousel.dart

// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:nandiott_flutter/pages/detail_page.dart';
// import 'dart:async';
// import 'package:nandiott_flutter/services/featured_media.dart';
// import 'package:nandiott_flutter/services/getBannerPoster_service.dart';
// import 'package:nandiott_flutter/utils/Device_size.dart';
// import 'package:shimmer/shimmer.dart';

// class SimpleFeaturedCarousel extends StatefulWidget {
//   final String filter;
//   final FocusNode? initialFocusNode;
  
//   const SimpleFeaturedCarousel({
//     Key? key,
//     required this.filter,
//     this.initialFocusNode,
//   }) : super(key: key);

//   @override
//   _SimpleFeaturedCarouselState createState() => _SimpleFeaturedCarouselState();
// }

// class _SimpleFeaturedCarouselState extends State<SimpleFeaturedCarousel> {
//   late PageController _pageController;
//   int _currentIndex = 0;
//   bool _hasFocus = false;
//   final FocusNode _focusNode = FocusNode(debugLabel: 'featured_carousel');
  
//   final _getBannerPosterService = getBannerPosterService();

//   List<dynamic> movies = [];
//   List<String> bannerUrls = [];
//   bool _isLoading = true;

//   @override
//   void initState() {
//     super.initState();
//     _pageController = PageController();
//     fetchFeaturedMovies();
    
//     // Set up focus listener
//     _focusNode.addListener(() {
//       if (mounted) {
//         setState(() {
//           _hasFocus = _focusNode.hasFocus;
//         });
//       }
//     });
//   }

//   @override
//   void didUpdateWidget(SimpleFeaturedCarousel oldWidget) {
//     super.didUpdateWidget(oldWidget);
    
//     // Check if the filter has changed
//     if (oldWidget.filter != widget.filter) {
//       // Reset the state and fetch new movies
//       setState(() {
//         _isLoading = true;
//         movies.clear();
//         bannerUrls.clear();
//         _currentIndex = 0;
//       });

//       // Recreate the page controller
//       _pageController.dispose();
//       _pageController = PageController();

//       // Fetch new movies based on the updated filter
//       fetchFeaturedMovies();
//     }
//   }

//   Future<void> fetchFeaturedMovies() async {
//     try {
//       final filterToMediaTypeMap = {
//         'Movies': 'movie',
//         'Series': 'tvseries',
//         'Short Film': 'shortfilm',
//         'Documentary': 'documentary',
//         'Music': 'videosong',
//       };

//       final mediaType = filterToMediaTypeMap[widget.filter] ?? 'movie';
//       final mediaService = getAllFeaturedMediaService();
//       final response =
//           await mediaService.getAllFeaturedMedia(mediaType: mediaType);

//       if (response != null && response['success']) {
//         if (mounted) {
//           setState(() {
//             movies = response['data'];
//             _isLoading = false;
//           });
//         }

//         // Fetch banner images for each movie
//         await fetchBannerImages();
//       } else {
//         if (mounted) {
//           setState(() {
//             _isLoading = false;
//           });
//         }
//         print("Error fetching featured movies: ${response!['message']}");
//       }
//     } catch (e) {
//       if (mounted) {
//         setState(() {
//           _isLoading = false;
//         });
//       }
//       print("Error fetching data: $e");
//     }
//   }

//   Future<void> fetchBannerImages() async {
//     List<String> urls = [];
//     for (var movie in movies) {
//       final filterToMediaTypeMap = {
//         'Movies': 'movie',
//         'Series': 'tvseries',
//         'Short Film': 'shortfilms',
//         'Documentary': 'documentaries',
//         'Music': 'videosongs',
//       };

//       final mediaType = filterToMediaTypeMap[widget.filter] ?? 'movie';
//       try {
//         // Assuming the movie has an ID field
//         String movieId = movie['contentId']['_id'];

//         // Call the banner poster service with the movie ID
//         final bannerResponse = await _getBannerPosterService.getBanner(
//             mediaType: mediaType, mediaId: movieId);
        
//         if (bannerResponse != null && bannerResponse['success']) {
//           urls.add(bannerResponse['contentUrl'] ?? '');
//         } else {
//           urls.add(''); // Add empty string if no banner found
//         }
//       } catch (e) {
//         urls.add(''); // Add empty string if error occurs
//         print("Error fetching banner for movie: $e");
//       }
//     }

//     if (mounted) {
//       setState(() {
//         bannerUrls = urls;
//       });
//     }
//   }

//   @override
//   void dispose() {
//     _pageController.dispose();
//     _focusNode.dispose();
//     super.dispose();
//   }

//   Widget _buildSkeletonLoader() {
//     return Column(
//       children: [
//         Container(
//           height: 200,
//           child: Shimmer.fromColors(
//             baseColor: Colors.grey[300]!,
//             highlightColor: Colors.grey[100]!,
//             child: Container(
//               margin: EdgeInsets.symmetric(horizontal: 16),
//               decoration: BoxDecoration(
//                 color: Colors.white,
//                 borderRadius: BorderRadius.circular(12),
//               ),
//             ),
//           ),
//         ),
//         Padding(
//           padding: const EdgeInsets.symmetric(vertical: 10),
//           child: Row(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: List.generate(3, (index) {
//               return Container(
//                 margin: EdgeInsets.symmetric(horizontal: 5),
//                 child: Shimmer.fromColors(
//                   baseColor: Colors.grey[300]!,
//                   highlightColor: Colors.grey[100]!,
//                   child: CircleAvatar(
//                     radius: 5,
//                     backgroundColor: Colors.white,
//                   ),
//                 ),
//               );
//             }),
//           ),
//         ),
//       ],
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     final isTV = AppSizes.getDeviceType(context) == DeviceType.tv;
//     final height = isTV ? 240.0 : 200.0;

//     // Show loading indicator when fetching data
//     if (_isLoading) {
//       return _buildSkeletonLoader();
//     }

//     // Show message if no movies are found
//     if (movies.isEmpty) {
//       return Center(
//         child: Text(
//           'No ${widget.filter} found',
//           style: TextStyle(color: Colors.white, fontSize: 16),
//         ),
//       );
//     }

//     return Focus(
//       focusNode: _focusNode,
//       onKey: (FocusNode node, RawKeyEvent event) {
//         if (event is RawKeyDownEvent) {
//           // Handle horizontal navigation
//           if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
//             if (_currentIndex < movies.length - 1) {
//               _pageController.nextPage(
//                 duration: Duration(milliseconds: 300),
//                 curve: Curves.easeInOut,
//               );
              
//               // Very important: make sure to re-request focus after animation
//               Future.delayed(Duration(milliseconds: 300), () {
//                 if (_focusNode.canRequestFocus) {
//                   _focusNode.requestFocus();
//                 }
//               });
//             }
//             return KeyEventResult.handled;
//           } else if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
//             if (_currentIndex > 0) {
//               _pageController.previousPage(
//                 duration: Duration(milliseconds: 300),
//                 curve: Curves.easeInOut,
//               );
              
//               // Very important: make sure to re-request focus after animation
//               Future.delayed(Duration(milliseconds: 300), () {
//                 if (_focusNode.canRequestFocus) {
//                   _focusNode.requestFocus();
//                 }
//               });
//             }
//             return KeyEventResult.handled;
//           } 
//           else if (event.logicalKey == LogicalKeyboardKey.select ||
//               event.logicalKey == LogicalKeyboardKey.enter) {
//             // Handle navigation to movie details here
//             if (_currentIndex >= 0 && _currentIndex < movies.length) {
//               final movie = movies[_currentIndex];
//               final String title = movie['contentId']['title'] ?? 'No Title';
//               final String movieId = movie['contentId']['_id'] ?? "";
//               final String contentType = movie['contentType'] ?? "";
              
//               print("Navigate to movie: $title ($movieId)");
//               Navigator.of(context).push(MaterialPageRoute(
//                       builder: (context) => MovieDetailPage(
//                         movieId: movieId,
//                         mediaType: contentType,
//                         userId: "",
//                       ),
//                     ));
//             }
//             return KeyEventResult.handled;
//           }
          
//           // For vertical navigation, let normal focus handling work
//           // This means we use the default focus traversal system
//         }
//         return KeyEventResult.ignored;
//       },
//       child: Column(
//         children: [
//           Container(
//             height: height,
//             decoration: BoxDecoration(
//               border: _hasFocus 
//                   ? Border.all(color: Colors.amber, width: 2)
//                   : null,
//               borderRadius: BorderRadius.circular(12),
//             ),
//             child: PageView.builder(
//               controller: _pageController,
//               onPageChanged: (index) {
//                 setState(() {
//                   _currentIndex = index;
//                 });
//               },
//               itemCount: movies.length,
//               physics: isTV ? NeverScrollableScrollPhysics() : PageScrollPhysics(),
//               itemBuilder: (context, index) {
//                 final movie = movies[index];
//                 final bannerUrl = index < bannerUrls.length ? bannerUrls[index] : '';
                
//                 return InkWell(
//                   onTap: () {
//                     // Handle tap - navigate to movie details
//                     final String title = movie['contentId']['title'] ?? 'No Title';
//                     final String contentType = movie['contentType'] ?? "";
//                       print("Navigate to details for: $title");
                  
//                   Navigator.of(context).push(MaterialPageRoute(
//                     builder: (context) => MovieDetailPage(
//                       movieId: movie['contentId']['_id'],
//                       mediaType: contentType,
//                       userId: "",
//                     ),
//                   ));
//                   },
//                   child: Container(
//                     margin: const EdgeInsets.symmetric(horizontal: 12),
//                     decoration: BoxDecoration(
//                       image: DecorationImage(
//                         image: bannerUrl.isEmpty
//                             ? const AssetImage('assets/images/placeholder.png')
//                             : NetworkImage(bannerUrl) as ImageProvider,
//                         fit: BoxFit.cover,
//                       ),
//                       borderRadius: BorderRadius.circular(10),
//                     ),
//                     child: Stack(
//                       children: [
//                         Container(
//                           decoration: BoxDecoration(
//                             borderRadius: BorderRadius.circular(10),
//                             gradient: LinearGradient(
//                               begin: Alignment.topCenter,
//                               end: Alignment.bottomCenter,
//                               colors: [
//                                 Colors.transparent,
//                                 Colors.black.withOpacity(0.8)
//                               ],
//                             ),
//                           ),
//                         ),
//                         Column(
//                           mainAxisAlignment: MainAxisAlignment.end,
//                           children: [
//                             Text(
//                               movie['contentId']['title'] ?? 'No Title',
//                               style: TextStyle(
//                                 color: Colors.white,
//                                 fontSize: isTV ? 18.0 : 16.0,
//                                 fontWeight: FontWeight.bold,
//                               ),
//                             ),
//                             const SizedBox(height: 8),
//                             Row(
//                               mainAxisAlignment: MainAxisAlignment.center,
//                               children: [
//                                 const Icon(Icons.play_circle,
//                                     color: Colors.amber, size: 28),
//                                 const SizedBox(width: 5),
//                                 Text(
//                                   'Watch Now',
//                                   style: TextStyle(
//                                     color: Colors.amber,
//                                     fontSize: isTV ? 16.0 : 14.0,
//                                     fontWeight: FontWeight.w700,
//                                   ),
//                                 ),
//                               ],
//                             ),
//                             const SizedBox(height: 10),
//                           ],
//                         ),
                        
//                         // Show directional indicators when focused on TV
//                         if (isTV && _hasFocus)
//                           Positioned(
//                             right: 16,
//                             top: height / 2 - 24,
//                             child: Icon(
//                               Icons.arrow_forward_ios,
//                               color: Colors.amber,
//                               size: 24,
//                             ),
//                           ),
//                         if (isTV && _hasFocus)
//                           Positioned(
//                             left: 16,
//                             top: height / 2 - 24,
//                             child: Icon(
//                               Icons.arrow_back_ios,
//                               color: Colors.amber,
//                               size: 24,
//                             ),
//                           ),
//                       ],
//                     ),
//                   ),
//                 );
//               },
//             ),
//           ),
          
//           // Dots indicator
//           Padding(
//             padding: const EdgeInsets.symmetric(vertical: 10),
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: List.generate(movies.length, (index) {
//                 return AnimatedContainer(
//                   duration: Duration(milliseconds: 300),
//                   margin: EdgeInsets.symmetric(horizontal: 5),
//                   width: 10,
//                   height: 10,
//                   decoration: BoxDecoration(
//                     shape: BoxShape.circle,
//                     color: _currentIndex == index 
//                         ? (_hasFocus ? Colors.amber : Colors.orange)
//                         : Colors.grey,
//                   ),
//                 );
//               }),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// In new_carousel.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nandiott_flutter/pages/detail_page.dart';
import 'dart:async';
import 'package:nandiott_flutter/services/featured_media.dart';
import 'package:nandiott_flutter/services/getBannerPoster_service.dart';
import 'package:nandiott_flutter/utils/Device_size.dart';
import 'package:shimmer/shimmer.dart';

class SimpleFeaturedCarousel extends StatefulWidget {
  final String filter;
  final FocusNode? initialFocusNode;
  
  const SimpleFeaturedCarousel({
    Key? key,
    required this.filter,
    this.initialFocusNode,
  }) : super(key: key);

  @override
  _SimpleFeaturedCarouselState createState() => _SimpleFeaturedCarouselState();
}

class _SimpleFeaturedCarouselState extends State<SimpleFeaturedCarousel> {
  late PageController _pageController;
  int _currentIndex = 0;
  bool _hasFocus = false;
  late FocusNode _focusNode;
  
  final _getBannerPosterService = getBannerPosterService();

  List<dynamic> movies = [];
  List<String> bannerUrls = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    
    // Use the provided initialFocusNode instead of creating a new one if available
    _focusNode = widget.initialFocusNode ?? FocusNode(debugLabel: 'featured_carousel');
    
    // Set up focus listener
    _focusNode.addListener(_handleFocusChange);
    
    fetchFeaturedMovies();
  }

  void _handleFocusChange() {
    if (mounted) {
      setState(() {
        _hasFocus = _focusNode.hasFocus;
      });
    }
  }

  @override
  void didUpdateWidget(SimpleFeaturedCarousel oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // Check if the initialFocusNode has changed
    if (widget.initialFocusNode != oldWidget.initialFocusNode && widget.initialFocusNode != null) {
      _focusNode.removeListener(_handleFocusChange);
      _focusNode = widget.initialFocusNode!;
      _focusNode.addListener(_handleFocusChange);
    }
    
    // Check if the filter has changed
    if (oldWidget.filter != widget.filter) {
      // Reset the state and fetch new movies
      setState(() {
        _isLoading = true;
        movies.clear();
        bannerUrls.clear();
        _currentIndex = 0;
      });

      // Recreate the page controller
      _pageController.dispose();
      _pageController = PageController();

      // Fetch new movies based on the updated filter
      fetchFeaturedMovies();
    }
  }

  Future<void> fetchFeaturedMovies() async {
    try {
      final filterToMediaTypeMap = {
        'Movies': 'movie',
        'Series': 'tvseries',
        'Short Film': 'shortfilm',
        'Documentary': 'documentary',
        'Music': 'videosong',
      };

      final mediaType = filterToMediaTypeMap[widget.filter] ?? 'movie';
      final mediaService = getAllFeaturedMediaService();
      final response =
          await mediaService.getAllFeaturedMedia(mediaType: mediaType);

      if (response != null && response['success']) {
        if (mounted) {
          setState(() {
            movies = response['data'];
            _isLoading = false;
          });
        }

        // Fetch banner images for each movie
        await fetchBannerImages();
      } else {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
        print("Error fetching featured movies: ${response!['message']}");
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
      print("Error fetching data: $e");
    }
  }

  Future<void> fetchBannerImages() async {
    List<String> urls = [];
    for (var movie in movies) {
      final filterToMediaTypeMap = {
        'Movies': 'movie',
        'Series': 'tvseries',
        'Short Film': 'shortfilms',
        'Documentary': 'documentaries',
        'Music': 'videosongs',
      };

      final mediaType = filterToMediaTypeMap[widget.filter] ?? 'movie';
      try {
        // Assuming the movie has an ID field
        String movieId = movie['contentId']['_id'];

        // Call the banner poster service with the movie ID
        final bannerResponse = await _getBannerPosterService.getBanner(
            mediaType: mediaType, mediaId: movieId);
        
        if (bannerResponse != null && bannerResponse['success']) {
          urls.add(bannerResponse['contentUrl'] ?? '');
        } else {
          urls.add(''); // Add empty string if no banner found
        }
      } catch (e) {
        urls.add(''); // Add empty string if error occurs
        print("Error fetching banner for movie: $e");
      }
    }

    if (mounted) {
      setState(() {
        bannerUrls = urls;
      });
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    
    // Only dispose the focus node if we created it (not if it was passed in)
    if (widget.initialFocusNode == null) {
      _focusNode.dispose();
    } else {
      _focusNode.removeListener(_handleFocusChange);
    }
    
    super.dispose();
  }

  Widget _buildSkeletonLoader() {
    return Column(
      children: [
        Container(
          height: 200,
          child: Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(3, (index) {
              return Container(
                margin: EdgeInsets.symmetric(horizontal: 5),
                child: Shimmer.fromColors(
                  baseColor: Colors.grey[300]!,
                  highlightColor: Colors.grey[100]!,
                  child: CircleAvatar(
                    radius: 5,
                    backgroundColor: Colors.white,
                  ),
                ),
              );
            }),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final isTV = AppSizes.getDeviceType(context) == DeviceType.tv;
    final height = isTV ? 240.0 : 200.0;

    // Show loading indicator when fetching data
    if (_isLoading) {
      return _buildSkeletonLoader();
    }

    // Show message if no movies are found
    if (movies.isEmpty) {
      return Center(
        child: Text(
          'No ${widget.filter} found',
          style: TextStyle(color: Colors.white, fontSize: 16),
        ),
      );
    }

    return Focus(
      focusNode: _focusNode,
      onKey: (FocusNode node, RawKeyEvent event) {
        if (event is RawKeyDownEvent) {
          // Handle horizontal navigation
          if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
            if (_currentIndex < movies.length - 1) {
              _pageController.nextPage(
                duration: Duration(milliseconds: 300),
                curve: Curves.easeInOut,
              );
              
              // Very important: make sure to re-request focus after animation
              Future.delayed(Duration(milliseconds: 300), () {
                if (_focusNode.canRequestFocus) {
                  _focusNode.requestFocus();
                }
              });
            }
            return KeyEventResult.handled;
          } else if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
            if (_currentIndex > 0) {
              _pageController.previousPage(
                duration: Duration(milliseconds: 300),
                curve: Curves.easeInOut,
              );
              
              // Very important: make sure to re-request focus after animation
              Future.delayed(Duration(milliseconds: 300), () {
                if (_focusNode.canRequestFocus) {
                  _focusNode.requestFocus();
                }
              });
            }
            return KeyEventResult.handled;
          } 
          else if (event.logicalKey == LogicalKeyboardKey.select ||
              event.logicalKey == LogicalKeyboardKey.enter) {
            // Handle navigation to movie details here
            if (_currentIndex >= 0 && _currentIndex < movies.length) {
              final movie = movies[_currentIndex];
              final String title = movie['contentId']['title'] ?? 'No Title';
              final String movieId = movie['contentId']['_id'] ?? "";
              final String contentType = movie['contentType'] ?? "";
              
              print("Navigate to movie: $title ($movieId)");
              Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => MovieDetailPage(
                        movieId: movieId,
                        mediaType: contentType,
                        userId: "",
                      ),
                    ));
            }
            return KeyEventResult.handled;
          }
          
          // For vertical navigation, let normal focus handling work
          // This means we use the default focus traversal system
        }
        return KeyEventResult.ignored;
      },
      child: Column(
        children: [
          Container(
            height: height,
            decoration: BoxDecoration(
              border: _hasFocus 
                  ? Border.all(color: Colors.amber, width: 2)
                  : null,
              borderRadius: BorderRadius.circular(12),
            ),
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  _currentIndex = index;
                });
              },
              itemCount: movies.length,
              physics: isTV ? NeverScrollableScrollPhysics() : PageScrollPhysics(),
              itemBuilder: (context, index) {
                final movie = movies[index];
                final bannerUrl = index < bannerUrls.length ? bannerUrls[index] : '';
                
                return InkWell(
                  onTap: () {
                    // Handle tap - navigate to movie details
                    final String title = movie['contentId']['title'] ?? 'No Title';
                    final String contentType = movie['contentType'] ?? "";
                      print("Navigate to details for: $title");
                  
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => MovieDetailPage(
                      movieId: movie['contentId']['_id'],
                      mediaType: contentType,
                      userId: "",
                    ),
                  ));
                  },
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: bannerUrl.isEmpty
                            ? const AssetImage('assets/images/placeholder.png')
                            : NetworkImage(bannerUrl) as ImageProvider,
                        fit: BoxFit.cover,
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Stack(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                Colors.black.withOpacity(0.8)
                              ],
                            ),
                          ),
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text(
                              movie['contentId']['title'] ?? 'No Title',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: isTV ? 18.0 : 16.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.play_circle,
                                    color: Colors.amber, size: 28),
                                const SizedBox(width: 5),
                                Text(
                                  'Watch Now',
                                  style: TextStyle(
                                    color: Colors.amber,
                                    fontSize: isTV ? 16.0 : 14.0,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                          ],
                        ),
                        
                        // Show directional indicators when focused on TV
                        if (isTV && _hasFocus)
                          Positioned(
                            right: 16,
                            top: height / 2 - 24,
                            child: Icon(
                              Icons.arrow_forward_ios,
                              color: Colors.amber,
                              size: 24,
                            ),
                          ),
                        if (isTV && _hasFocus)
                          Positioned(
                            left: 16,
                            top: height / 2 - 24,
                            child: Icon(
                              Icons.arrow_back_ios,
                              color: Colors.amber,
                              size: 24,
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          
          // Dots indicator
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(movies.length, (index) {
                return AnimatedContainer(
                  duration: Duration(milliseconds: 300),
                  margin: EdgeInsets.symmetric(horizontal: 5),
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _currentIndex == index 
                        ? (_hasFocus ? Colors.amber : Colors.orange)
                        : Colors.grey,
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}