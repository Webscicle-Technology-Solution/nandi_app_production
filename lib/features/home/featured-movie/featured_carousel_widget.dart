// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'dart:async';
// import 'package:nandiott_flutter/features/home/featured-movie/featured_movies_widget.dart';
// import 'package:nandiott_flutter/services/featured_media.dart';
// import 'package:nandiott_flutter/services/getBannerPoster_service.dart';
// import 'package:nandiott_flutter/utils/Device_size.dart';
// import 'package:shimmer/shimmer.dart';

// class FeaturedMoviesCarousel extends StatefulWidget {
//   final String filter;
//   final bool onHorizontalNavigation;

//   final FocusNode? focusNode; // Add this
//   FeaturedMoviesCarousel({
//     Key? key,
//     required this.filter,
//     this.onHorizontalNavigation = false,
//     this.focusNode,
//   }) : super(key: key);

//   @override
//   _FeaturedMoviesCarouselState createState() => _FeaturedMoviesCarouselState();
// }

// class _FeaturedMoviesCarouselState extends State<FeaturedMoviesCarousel> {
//   late PageController _pageController;
//   int _currentIndex = 0;
//   late Timer _timer;
//   final _getBannerPosterService = getBannerPosterService();
//   late FocusNode _internalFocusNode;

//   List<dynamic> movies = [];
//   List<String> bannerUrls = [];
//   bool _isLoading = true;

//   @override
//   void initState() {
//     super.initState();
//     _pageController = PageController();
//     fetchFeaturedMovies();
//     _internalFocusNode = FocusNode(); // Always create new
//   }

//   @override
//   void didUpdateWidget(FeaturedMoviesCarousel oldWidget) {
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
//         setState(() {
//           movies = response['data'];
//           _isLoading = false;
//         });

//         // Fetch banner images for each movie
//         await fetchBannerImages();
//       } else {
//         setState(() {
//           _isLoading = false;
//         });
//         print("Error fetching featured movies: ${response!['message']}");
//       }
//     } catch (e) {
//       setState(() {
//         _isLoading = false;
//       });
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
//         print("Movie ID: $movieId");

//         // Call the banner poster service with the movie ID
//         final bannerResponse = await _getBannerPosterService.getBanner(
//             mediaType: mediaType, mediaId: movieId);
//         print("Banner response: $bannerResponse");
//         if (bannerResponse != null && bannerResponse['success']) {
//           // Assuming the banner URL is in bannerResponse['data']['imageUrl']
//           urls.add(bannerResponse['contentUrl'] ?? '');
//           print("Banner URL: ${bannerResponse['contentUrl']}");
//           print("Banner URL added: $urls");
//         } else {
//           urls.add(''); // Add empty string if no banner found
//           print("No banner found for movie: $movieId");
//         }
//       } catch (e) {
//         urls.add(''); // Add empty string if error occurs
//         print("Error fetching banner for movie: $e");
//       }
//     }

//     setState(() {
//       bannerUrls = urls;
//     });
//   }

//   @override
//   void dispose() {
//     _pageController.dispose();
//     if (widget.focusNode == null) {
//       _internalFocusNode.dispose();
//     }
//     super.dispose();
//   }

//   Widget _buildSkeletonLoader() {
//     return Column(
//       children: [
//         // Skeleton Carousel
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

//         // Skeleton Dots Indicator
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

//     return Column(
//       children: [
//         Container(
//           height: isTV ? 240 : 200,
//           child: Focus(
//             focusNode: _internalFocusNode,
//             onKey: (FocusNode node, RawKeyEvent event) {
//               if (event is RawKeyDownEvent) {
//                 if (event.logicalKey == LogicalKeyboardKey.arrowRight &&
//                     _currentIndex < movies.length - 1) {
//                   _pageController.nextPage(
//                     duration: Duration(milliseconds: 300),
//                     curve: Curves.easeInOut,
//                   );
//                   return KeyEventResult.handled;
//                 } else if (event.logicalKey == LogicalKeyboardKey.arrowLeft &&
//                     _currentIndex > 0) {
//                   _pageController.previousPage(
//                     duration: Duration(milliseconds: 300),
//                     curve: Curves.easeInOut,
//                   );
//                   return KeyEventResult.handled;
//                 } else if (event.logicalKey == LogicalKeyboardKey.select ||
//                     event.logicalKey == LogicalKeyboardKey.enter) {
//                   // Handle item selection if needed
//                   return KeyEventResult.handled;
//                 }
//               }
//               return KeyEventResult.ignored;
//             },
//             child: PageView.builder(
//               controller: _pageController,
//               itemCount: movies.length,
//               itemBuilder: (context, index) {
//                 final movie = movies[index];
//                 final bannerUrl =
//                     index < bannerUrls.length ? bannerUrls[index] : '';
//                 return FeaturedMoviesWidget(movie: movie, imageUrl: bannerUrl);
//               },
//               onPageChanged: (index) {
//                 setState(() {
//                   _currentIndex = index;
//                 });
//               },
//             ),
//           ),
//         ),

//         // Dots Indicator
//         Padding(
//           padding: const EdgeInsets.symmetric(vertical: 10),
//           child: Row(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: List.generate(movies.length, (index) {
//               return AnimatedContainer(
//                 duration: Duration(milliseconds: 300),
//                 margin: EdgeInsets.symmetric(horizontal: 5),
//                 width: 10,
//                 height: 10,
//                 decoration: BoxDecoration(
//                   shape: BoxShape.circle,
//                   color: _currentIndex == index ? Colors.amber : Colors.grey,
//                 ),
//               );
//             }),
//           ),
//         ),
//       ],
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'package:nandiott_flutter/features/home/featured-movie/featured_movies_widget.dart';
import 'package:nandiott_flutter/services/featured_media.dart';
import 'package:nandiott_flutter/services/getBannerPoster_service.dart';
import 'package:nandiott_flutter/utils/Device_size.dart';
import 'package:shimmer/shimmer.dart';

class FeaturedMoviesCarousel extends StatefulWidget {
  final String filter;
  final bool onHorizontalNavigation;
  final FocusNode? focusNode;

  FeaturedMoviesCarousel({
    Key? key,
    required this.filter,
    this.onHorizontalNavigation = false,
    this.focusNode,
  }) : super(key: key);

  @override
  _FeaturedMoviesCarouselState createState() => _FeaturedMoviesCarouselState();
}

class _FeaturedMoviesCarouselState extends State<FeaturedMoviesCarousel> {
  late PageController _pageController;
  int _currentIndex = 0;
  late FocusNode _carouselFocusNode;
  bool _hasFocus = false;
  
  final _getBannerPosterService = getBannerPosterService();

  List<dynamic> movies = [];
  List<String> bannerUrls = [];
  bool _isLoading = true;
  bool _isChangingPage = false;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    // Use the provided focus node or create a new one
    _carouselFocusNode = widget.focusNode ?? FocusNode(debugLabel: 'carousel_focus');
    _carouselFocusNode.addListener(_onFocusChange);
    fetchFeaturedMovies();
  }

  void _onFocusChange() {
    if (mounted) {
      setState(() {
        _hasFocus = _carouselFocusNode.hasFocus;
      });
    }
  }

  @override
  void didUpdateWidget(FeaturedMoviesCarousel oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // Handle focus node changes
    if (widget.focusNode != oldWidget.focusNode) {
      if (oldWidget.focusNode == null) {
        // We were using our own focus node, need to dispose it
        _carouselFocusNode.removeListener(_onFocusChange);
        _carouselFocusNode.dispose();
      }
      
      // Use the new focus node
      _carouselFocusNode = widget.focusNode ?? FocusNode(debugLabel: 'carousel_focus');
      _carouselFocusNode.addListener(_onFocusChange);
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
        setState(() {
          movies = response['data'];
          _isLoading = false;
        });

        // Fetch banner images for each movie
        await fetchBannerImages();
      } else {
        setState(() {
          _isLoading = false;
        });
        print("Error fetching featured movies: ${response!['message']}");
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
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
    // Only dispose the focus node if we created it ourselves
    if (widget.focusNode == null) {
      _carouselFocusNode.removeListener(_onFocusChange);
      _carouselFocusNode.dispose();
    }
    super.dispose();
  }

  // Handle page change
  void _handlePageChange(int index) {
    setState(() {
      _currentIndex = index;
      _isChangingPage = false;
    });
  }

  // Go to next page
  void _goToNextPage() {
    if (_currentIndex < movies.length - 1 && !_isChangingPage) {
      setState(() {
        _isChangingPage = true;
      });
      _pageController.nextPage(
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  // Go to previous page
  void _goToPreviousPage() {
    if (_currentIndex > 0 && !_isChangingPage) {
      setState(() {
        _isChangingPage = true;
      });
      _pageController.previousPage(
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  Widget _buildSkeletonLoader() {
    return Column(
      children: [
        // Skeleton Carousel
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

        // Skeleton Dots Indicator
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
    final carouselHeight = isTV ? 240.0 : 200.0;

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

    return Column(
      children: [
        // NOTE: This is the corrected section - no nested Focus widgets
        Container(
          height: carouselHeight,
          // Using a border on the container instead of relying on a nested focus widget
          decoration: BoxDecoration(
            border: isTV && _hasFocus
                ? Border.all(color: Colors.amber, width: 2)
                : null,
            borderRadius: BorderRadius.circular(12),
          ),
          child: KeyboardListener(
            focusNode: _carouselFocusNode,
            onKeyEvent: (event) {
              if (event is KeyDownEvent) {
                if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
                  _goToNextPage();
                } else if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
                  _goToPreviousPage();
                }
              }
            },
            child: GestureDetector(
              onHorizontalDragEnd: (details) {
                if (details.primaryVelocity! > 0) {
                  _goToPreviousPage();
                } else if (details.primaryVelocity! < 0) {
                  _goToNextPage();
                }
              },
              child: PageView.builder(
                controller: _pageController,
                itemCount: movies.length,
                physics: isTV ? NeverScrollableScrollPhysics() : PageScrollPhysics(),
                itemBuilder: (context, index) {
                  final movie = movies[index];
                  final bannerUrl = index < bannerUrls.length ? bannerUrls[index] : '';
                  return FeaturedMoviesWidget(
                    movie: movie, 
                    imageUrl: bannerUrl,
                    isActive: index == _currentIndex && _hasFocus, // Pass focus state to child
                  );
                },
                onPageChanged: _handlePageChange,
              ),
            ),
          ),
        ),

        // Dots Indicator
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
    );
  }
}