import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nandiott_flutter/pages/detail_page.dart';
import 'package:nandiott_flutter/services/featured_media.dart';
import 'package:nandiott_flutter/services/getBannerPoster_service.dart';
import 'package:shimmer/shimmer.dart';


class PrimeFeaturedSection extends StatefulWidget {
  final String filter;
  final bool hasFocus;
  final bool isExpanded;
  final Function(String) onBackgroundImageChanged;
  final VoidCallback? onLeftEdgeFocus;
  final VoidCallback? onRightEdgeFocus;
  final VoidCallback? onContentFocus;
  
  const PrimeFeaturedSection({
    Key? key,
    required this.filter,
    this.hasFocus = false,
    this.isExpanded = true,
    required this.onBackgroundImageChanged,
    this.onLeftEdgeFocus,
    this.onRightEdgeFocus,
    this.onContentFocus,
  }) : super(key: key);

  @override
  _PrimeFeaturedSectionState createState() => _PrimeFeaturedSectionState();
}

class _PrimeFeaturedSectionState extends State<PrimeFeaturedSection> with SingleTickerProviderStateMixin {
  late PageController _pageController;
  int _currentIndex = 0;
  bool _hasFocus = false;
  late FocusNode _focusNode;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  
  final _getBannerPosterService = getBannerPosterService();
  final _featuredMediaService = getAllFeaturedMediaService();

  List<dynamic> _featuredItems = [];
  List<String> _bannerUrls = [];
  List<String> _posterUrls = [];
  bool _isLoading = true;
  bool _isAutoScrolling = true;
  int _autoScrollInterval = 8; // seconds
  
  // Timer for auto-scrolling
  DateTime? _lastUserInteraction;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _focusNode = FocusNode(debugLabel: 'prime_featured_section');
    _hasFocus = widget.hasFocus;
    
    // Initialize animation controller
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
    );
    
    // Setup focus listener
    _focusNode.addListener(_handleFocusChange);
    
    // Fetch featured content
    _fetchFeaturedContent();
    
    // Request focus if needed
    if (widget.hasFocus) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_focusNode.canRequestFocus) {
          _focusNode.requestFocus();
        }
      });
    }
    
    // Ensure expanded state is reflected in animation
    if (widget.isExpanded) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }
    
    // Start auto-scroll timer
    _setupAutoScroll();
  }
  
  void _handleFocusChange() {
    if (mounted && _focusNode.hasFocus != _hasFocus) {
      setState(() {
        _hasFocus = _focusNode.hasFocus;
      });
      
      // Handle animation
      if (_focusNode.hasFocus) {
        _animationController.forward();
        // Pause auto-scrolling when focused
        setState(() {
          _isAutoScrolling = false;
        });
      } else {
        _animationController.reverse();
        // Resume auto-scrolling when not focused
        Future.delayed(Duration(seconds: 2), () {
          if (mounted && !_focusNode.hasFocus) {
            setState(() {
              _isAutoScrolling = true;
            });
          }
        });
      }
    }
  }
  
  void _setupAutoScroll() {
    // Check every second if we should advance the carousel
    Future.delayed(Duration(seconds: 1), () {
      if (!mounted) return;
      
      if (_isAutoScrolling && 
          _featuredItems.isNotEmpty && 
          (_lastUserInteraction == null ||
          DateTime.now().difference(_lastUserInteraction!) > Duration(seconds: _autoScrollInterval))) {
        
        // Only advance if we're not at the end
        if (_currentIndex < _featuredItems.length - 1) {
          _pageController.nextPage(
            duration: Duration(milliseconds: 800),
            curve: Curves.easeInOut,
          );
        } else {
          // Return to first item
          _pageController.animateToPage(
            0,
            duration: Duration(milliseconds: 800),
            curve: Curves.easeInOut,
          );
        }
      }
      
      // Continue the auto-scroll check
      _setupAutoScroll();
    });
  }

  @override
  void didUpdateWidget(PrimeFeaturedSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // Refetch content if filter changed
    if (oldWidget.filter != widget.filter) {
      setState(() {
        _isLoading = true;
        _featuredItems = [];
        _bannerUrls = [];
        _posterUrls = [];
        _currentIndex = 0;
      });
      
      // Reset page controller
      _pageController.dispose();
      _pageController = PageController();
      
      // Fetch new content
      _fetchFeaturedContent();
    }
    
    // Update focus state
    if (oldWidget.hasFocus != widget.hasFocus) {
      setState(() {
        _hasFocus = widget.hasFocus;
      });
      
      if (widget.hasFocus && !_focusNode.hasFocus) {
        // Use delayed focus to ensure proper focus management
        Future.delayed(Duration(milliseconds: 100), () {
          if (mounted && _focusNode.canRequestFocus) {
            _focusNode.requestFocus();
            
            // Ensure auto-scrolling is disabled when focused
            setState(() {
              _isAutoScrolling = false;
              _lastUserInteraction = DateTime.now();
            });
          }
        });
      } else if (!widget.hasFocus && oldWidget.hasFocus) {
        // Resume auto-scrolling after losing focus
        Future.delayed(Duration(seconds: 2), () {
          if (mounted && !_focusNode.hasFocus) {
            setState(() {
              _isAutoScrolling = true;
            });
          }
        });
      }
    }
    
    // Update animations based on expanded state
    if (oldWidget.isExpanded != widget.isExpanded) {
      if (widget.isExpanded) {
        _animationController.forward();
        
        // If expanded and has focus, ensure it's properly scrolled to current item
        if (widget.hasFocus) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (_pageController.hasClients && _currentIndex > 0) {
              _pageController.jumpToPage(_currentIndex);
            }
          });
        }
      } else {
        _animationController.reverse();
      }
    }
  }
  
  String _getMediaType() {
    final Map<String, String> mediaTypeMap = {
      'Movies': 'movie',
      'Series': 'tvseries',
      'Short Film': 'shortfilm',
      'Documentary': 'documentary',
      'Music': 'videosong',
    };
    
    return mediaTypeMap[widget.filter] ?? 'movie';
  }
  
  Future<void> _fetchFeaturedContent() async {
    try {
      final mediaType = _getMediaType();
      final response = await _featuredMediaService.getAllFeaturedMedia(mediaType: mediaType);
      
      if (response != null && response['success'] && mounted) {
        final items = response['data'];
        
        setState(() {
          _featuredItems = items;
          _isLoading = false;
        });
        
        // Fetch banner images
        await _loadMediaImages();
        
        // Set initial background image
        if (_bannerUrls.isNotEmpty && _bannerUrls[0].isNotEmpty) {
          widget.onBackgroundImageChanged(_bannerUrls[0]);
        }
      } else if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
  
  Future<void> _loadMediaImages() async {
    final mediaType = _getMediaType();
    final List<String> banners = [];
    final List<String> posters = [];
    
    for (final item in _featuredItems) {
      try {
        // Get banner image
        final bannerResponse = await _getBannerPosterService.getBanner(
          mediaType: mediaType,
          mediaId: item['contentId']['_id'],
        );
        
        if (bannerResponse != null && bannerResponse['success']) {
          banners.add(bannerResponse['contentUrl'] ?? '');
        } else {
          banners.add('');
        }
        
        // Get poster image
        final posterResponse = await _getBannerPosterService.getPoster(
          mediaType: mediaType,
          mediaId: item['contentId']['_id'],
        );
        
        if (posterResponse != null && posterResponse['success']) {
          posters.add(posterResponse['contentUrl'] ?? '');
        } else {
          posters.add('');
        }
      } catch (e) {
        banners.add('');
        posters.add('');
      }
    }
    
    if (mounted) {
      setState(() {
        _bannerUrls = banners;
        _posterUrls = posters;
      });
    }
  }
  
  void _handleUserInteraction() {
    setState(() {
      _lastUserInteraction = DateTime.now();
      _isAutoScrolling = false;
    });
    
    // Resume auto-scrolling after delay
    Future.delayed(Duration(seconds: _autoScrollInterval), () {
      if (mounted && !_hasFocus) {
        setState(() {
          _isAutoScrolling = true;
        });
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _focusNode.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Show loading indicator while fetching data
    if (_isLoading) {
      return _buildSkeletonLoader();
    }
    
    // Show message if no content found
    if (_featuredItems.isEmpty) {
      return Center(
        child: Text(
          'No featured ${widget.filter} available',
          style: TextStyle(color: Theme.of(context).primaryColorDark, fontSize: 18),
        ),
      );
    }
    
    return Focus(
  focusNode: _focusNode,
  onKey: (FocusNode node, RawKeyEvent event) {
    if (event is RawKeyDownEvent) {
      _handleUserInteraction();
      
      if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
        if (_currentIndex < _featuredItems.length - 1) {
          _pageController.nextPage(
            duration: Duration(milliseconds: 400),
            curve: Curves.easeOutCubic,
          );
          return KeyEventResult.handled;
        } else {
          // Last item - prevent focus leaving
          if (widget.onRightEdgeFocus != null) {
            widget.onRightEdgeFocus!();
          }
          return KeyEventResult.handled;
        }
      } else if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
        if (_currentIndex > 0) {
          // Not at first item - stay within carousel
          _pageController.previousPage(
            duration: Duration(milliseconds: 400),
            curve: Curves.easeOutCubic,
          );
          return KeyEventResult.handled;
        } else {
          // First item - move to menu
          print("FEATURED: At first item, moving focus to menu");
          if (widget.onLeftEdgeFocus != null) {
            widget.onLeftEdgeFocus!();
          }
          return KeyEventResult.ignored; // Match your content row behavior
        }
      } else if (event.logicalKey == LogicalKeyboardKey.select ||
          event.logicalKey == LogicalKeyboardKey.enter) {
        _navigateToMovieDetails();
        return KeyEventResult.handled;
      } else if (event.logicalKey == LogicalKeyboardKey.arrowDown ||
                event.logicalKey == LogicalKeyboardKey.arrowUp) {
        // Allow vertical navigation
        return KeyEventResult.ignored;
      }
    }
    return KeyEventResult.ignored;
  },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOutCubic,
        child: Stack(
          children: [
            // PageView for horizontal scrolling
            PageView.builder(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  _currentIndex = index;
                });
                
                // Update background image when page changes
                if (_bannerUrls.isNotEmpty && 
                    index < _bannerUrls.length && 
                    _bannerUrls[index].isNotEmpty) {
                  widget.onBackgroundImageChanged(_bannerUrls[index]);
                }
              },
              itemCount: _featuredItems.length,
              physics: const PageScrollPhysics(),
              itemBuilder: (context, index) {
                final item = _featuredItems[index];
                // final bannerUrl = index < _bannerUrls.length ? _bannerUrls[index] : '';
                final title = item['contentId']['title'] ?? 'No Title';
                final description = item['contentId']['description'] ?? 'No description available';
                
                return GestureDetector(
                  onTap: _navigateToMovieDetails,
                  child: AnimatedBuilder(
                    animation: _animationController,
                    builder: (context, child) {
                      // Only scale if this is the current index and has focus
                      final shouldScale = _hasFocus && index == _currentIndex;
                      final scale = shouldScale ? _scaleAnimation.value : 1.0;
                      
                      return Transform.scale(
                        scale: scale,
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 20),
                          child: Stack(
                            alignment: Alignment.centerLeft,
                            children: [
                              // Content info panel
                              Positioned(
                                left: 60,
                                bottom: widget.isExpanded ? 60 : 30,
                                right: MediaQuery.of(context).size.width * 0.4,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                
                                    Text(
                                      title,
                                      style: TextStyle(
                                        color: Theme.of(context).primaryColorDark,
                                        fontSize: widget.isExpanded ? 44 : 30,
                                        fontWeight: FontWeight.bold,
                                        shadows: [
                                          Shadow(
                                            color: Theme.of(context).primaryColorLight,
                                            blurRadius: 10,
                                          ),
                                        ],
                                      ),
                                    ),
                                    
                                    if (widget.isExpanded) ...[
                                      SizedBox(height: 15),
                                      Text(
                                        description,
                                        style: TextStyle(
                                          color: Theme.of(context).primaryColorDark.withOpacity(0.9),
                                          fontSize: 16,
                                          shadows: [
                                            Shadow(
                                              color: Theme.of(context).primaryColorLight,
                                              blurRadius: 5,
                                            ),
                                          ],
                                        ),
                                        maxLines: 3,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      SizedBox(height: 25),
                                      
                                      Row(
                                        children: [
                                          ElevatedButton.icon(
                                            onPressed: _navigateToMovieDetails,
                                            icon: Icon(Icons.play_arrow, size: 30),
                                            label: Text(
                                              'Watch Now',
                                              style: TextStyle(fontSize: 18),
                                            ),
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.amber,
                                              foregroundColor: Theme.of(context).primaryColorLight,
                                              padding: EdgeInsets.symmetric(
                                                horizontal: 25,
                                                vertical: 15,
                                              ),
                                            ),
                                          ),
                                          SizedBox(width: 15),
                                          ElevatedButton.icon(
                                            onPressed: _navigateToMovieDetails,
                                            icon: Icon(Icons.info_outline),
                                            label: Text('Details'),
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Theme.of(context).primaryColorLight,
                                              foregroundColor: Theme.of(context).primaryColorDark,
                                              padding: EdgeInsets.symmetric(
                                                horizontal: 20,
                                                vertical: 15,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ] else ...[
                                      SizedBox(height: 10),
                                      ElevatedButton.icon(
                                        onPressed: _navigateToMovieDetails,
                                        icon: Icon(Icons.play_arrow),
                                        label: Text('Watch'),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.amber,
                                          foregroundColor: Theme.of(context).primaryColorLight,
                                          padding: EdgeInsets.symmetric(
                                            horizontal: 15,
                                            vertical: 8,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                              
                              // Navigation indicators when focused
                              if (_hasFocus && widget.isExpanded) ...[
                                Positioned(
                                  left: 15,
                                  top: 0,
                                  bottom: 0,
                                  child: Center(
                                    child: Container(
                                      padding: EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: Theme.of(context).primaryColorLight.withOpacity(0.6),
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(
                                        Icons.arrow_back_ios,
                                        color: Colors.amber,
                                        size: 24,
                                      ),
                                    ),
                                  ),
                                ),
                                Positioned(
                                  right: 15,
                                  top: 0,
                                  bottom: 0,
                                  child: Center(
                                    child: Container(
                                      padding: EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: Theme.of(context).primaryColorLight.withOpacity(0.6),
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(
                                        Icons.arrow_forward_ios,
                                        color: Colors.amber,
                                        size: 24,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
            
            // Dots indicator (only visible when expanded)
            if (widget.isExpanded)
              Positioned(
                bottom: 20,
                left: 0,
                right: 0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(_featuredItems.length, (index) {
                    return AnimatedContainer(
                      duration: Duration(milliseconds: 300),
                      margin: EdgeInsets.symmetric(horizontal: 5),
                      width: _currentIndex == index ? 20 : 10,
                      height: 10,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5),
                        color: _currentIndex == index
                            ? Colors.amber
                            : Colors.grey.withOpacity(0.5),
                      ),
                    );
                  }),
                ),
              ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildSkeletonLoader() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[800]!,
      highlightColor: Colors.grey[700]!,
      child: Container(
        margin: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.grey[800],
          borderRadius: BorderRadius.circular(15),
        ),
      ),
    );
  }
  
  void _navigateToMovieDetails() {
    if (_currentIndex >= 0 && _currentIndex < _featuredItems.length) {
      final item = _featuredItems[_currentIndex];
      final movieId = item['contentId']['_id'];
      final contentType = item['contentType'] ?? _getMediaType();
      
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => MovieDetailPage(
            movieId: movieId,
            mediaType: contentType,
            userId: "",
          ),
        ),
      );
    }
  }
}