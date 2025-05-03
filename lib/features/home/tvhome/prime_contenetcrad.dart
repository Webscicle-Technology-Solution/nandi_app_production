import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nandiott_flutter/models/movie_model.dart';
import 'package:nandiott_flutter/services/getBannerPoster_service.dart';

class PrimeContentCard extends StatefulWidget {
  final Movie item;
  final int index;
  final FocusNode focusNode;
  final bool hasFocus;
  final String rowType; // 'standard', 'history', 'favorites'
  final String mediaType;
  final VoidCallback onTap;

  const PrimeContentCard({
    Key? key,
    required this.item,
    required this.index,
    required this.focusNode,
    this.hasFocus = false,
    required this.rowType,
    required this.mediaType,
    required this.onTap,
  }) : super(key: key);

  @override
  _PrimeContentCardState createState() => _PrimeContentCardState();
}

class _PrimeContentCardState extends State<PrimeContentCard> with SingleTickerProviderStateMixin {
  final _getBannerPosterService = getBannerPosterService();
  bool _isFocused = false;
  String _posterUrl = "";
  String _bannerUrl = "";
  bool _isLoading = true;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;
  
  // Progress for history items
  double _progressValue = 0.0;

  @override
  void initState() {
    super.initState();
    _isFocused = widget.hasFocus;

    widget.focusNode.addListener(() {
    if (widget.focusNode.hasFocus) {
      print("CARD FOCUS: Card ${widget.index} in row ${widget.rowType} gained focus");
    } else {
      print("CARD FOCUS: Card ${widget.index} in row ${widget.rowType} lost focus");
    }
  }); 
    
    // Initialize animations
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
    );
    
    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    
    // Set initial animation state
    if (widget.hasFocus) {
      _animationController.value = 1.0;
    }
    
    // Add focus listener
    widget.focusNode.addListener(_handleFocusChange);
    
    // Load images
    _loadImages();
    
    // Set progress for history items
    if (widget.rowType == 'history') {
      _calculateProgress();
    }
  }
  
  void _handleFocusChange() {
    if (mounted && widget.focusNode.hasFocus != _isFocused) {
      setState(() {
        _isFocused = widget.focusNode.hasFocus;
      });
      
      if (widget.focusNode.hasFocus) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    }
  }
  
  Future<void> _loadImages() async {
    try {
      // Determine the correct content ID and media type based on row type
      String contentId=widget.item.id;
      // String contentType;
      
      // if (widget.rowType == 'favorites') {
      //   contentId = widget.item.id;
      //   contentType = ;
      // } else if (widget.rowType == 'history') {
      //   contentId = widget.item.id;
      //   contentType = widget.item.genre??"movies";
      // } else {
      //   contentId = widget.item.id;
      //   contentType = widget.mediaType;
      // }
      
      // Get poster image
      final posterResponse = await _getBannerPosterService.getPoster(
        mediaType: widget.mediaType,
        mediaId: contentId,
      );
      
      if (posterResponse != null && posterResponse['success'] && mounted) {
        setState(() {
          _posterUrl = posterResponse['contentUrl'] ?? '';
        });
      }
      
      // Get banner image
      final bannerResponse = await _getBannerPosterService.getBanner(
        mediaType: widget.mediaType,
        mediaId: contentId,
      );
      
      if (bannerResponse != null && bannerResponse['success'] && mounted) {
        setState(() {
          _bannerUrl = bannerResponse['contentUrl'] ?? '';
        });
      }
      
      if (mounted) {
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
  
  void _calculateProgress() {
    try {
      // if (widget.rowType == 'history') {
      //   // final double currentTime = widget.item.?.toDouble() ?? 0;
      //   // final double totalDuration = widget.item.totalDuration?.toDouble() ?? 1;
        
      //   if (totalDuration > 0) {
      //     setState(() {
      //       _progressValue = currentTime / totalDuration;
      //     });
      //   }
      // }
    } catch (e) {
      // Handle error silently
      setState(() {
        _progressValue = 0;
      });
    }
  }

  @override
  void didUpdateWidget(PrimeContentCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // Update focus state
    if (oldWidget.hasFocus != widget.hasFocus) {
      setState(() {
        _isFocused = widget.hasFocus;
      });
      
      if (widget.hasFocus) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    }
    
    // Reload images if item changed
    if (oldWidget.item != widget.item || 
        oldWidget.rowType != widget.rowType ||
        oldWidget.mediaType != widget.mediaType) {
      setState(() {
        _isLoading = true;
        _posterUrl = '';
        _bannerUrl = '';
      });
      
      _loadImages();
      
      if (widget.rowType == 'history') {
        _calculateProgress();
      }
    }
  }

  @override
  void dispose() {
    widget.focusNode.removeListener(_handleFocusChange);
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Get title based on row type
      String title = '';
  if (widget.rowType == 'favorites') {
    title = widget.item.title;
  } else if (widget.rowType == 'history') {
    title = widget.item.title ?? 'Unknown';
  } else {
    title = widget.item.title ?? 'Unknown';
  }
    
return Focus(
    focusNode: widget.focusNode,
    onKey: (node, event) {
      if (event is RawKeyDownEvent) {
        if (event.logicalKey == LogicalKeyboardKey.select ||
            event.logicalKey == LogicalKeyboardKey.enter) {
          widget.onTap();
          return KeyEventResult.handled;
        }
        
        // Allow vertical navigation to propagate to parent handlers
        if (event.logicalKey == LogicalKeyboardKey.arrowUp ||
            event.logicalKey == LogicalKeyboardKey.arrowDown) {
          return KeyEventResult.ignored;
        }
      }
      return KeyEventResult.ignored;
    },
    child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: 10),
                width: 180,
                height: 30,
                child: Stack(
                  children: [
                    // Poster image
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: _isFocused 
                              ? [BoxShadow(
                                  color: Colors.amber.withOpacity(0.6),
                                  blurRadius: 15,
                                  spreadRadius: 2
                                )]
                              : null,
                          border: _isFocused
                              ? Border.all(color: Colors.amber, width: 3)
                              : null,
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: _isLoading
                              ? Container(color: Colors.grey[800])
                              : Image.network(
                                  _posterUrl.isNotEmpty
                                      ? _posterUrl
                                      : 'https://via.placeholder.com/160x240',
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, _, __) => Container(
                                    color: Colors.grey[800],
                                    child: Icon(
                                      Icons.image_not_supported,
                                      color: Colors.white38,
                                      size: 40,
                                    ),
                                  ),
                                ),
                        ),
                      ),
                    ),
                    
                    // Gradient overlay for text visibility
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(6),
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withOpacity(0.8),
                            ],
                            stops: const [0.7, 1.0],
                          ),
                        ),
                      ),
                    ),
                    
                    // Title at bottom
                    Positioned(
                      left: 10,
                      right: 10,
                      bottom: 10,
                      child: Text(
                        title,
                        style: TextStyle(
                          color: _isFocused ? Colors.amber : Colors.white,
                          fontSize: 14,
                          fontWeight: _isFocused ? FontWeight.bold : FontWeight.normal,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    
                    // Progress indicator for history items
                    if (widget.rowType == 'history')
                      Positioned(
                        left: 10,
                        right: 10,
                        bottom: 40,
                        child: Container(
                          height: 3,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(1.5),
                            child: LinearProgressIndicator(
                              value: _progressValue,
                              backgroundColor: Colors.grey[800],
                              valueColor: AlwaysStoppedAnimation<Color>(
                                _isFocused ? Colors.amber : Colors.red
                              ),
                            ),
                          ),
                        ),
                      ),
                    
                    // "Continue" badge for history items
                    if (widget.rowType == 'history')
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(3),
                          ),
                          child: Text(
                            'CONTINUE',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 8,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      
                    // "Free" badge for free content if available
                    // if (widget.rowType == 'standard' && 
                    //     widget.item.isFree != null && 
                    //     widget.item.isFree == true)
                      Positioned(
                        top: 8,
                        left: 8,
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.blue,
                            borderRadius: BorderRadius.circular(3),
                          ),
                          child: Text(
                            widget.mediaType,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 8,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    
                    // Play button overlay when focused
                    if (_isFocused)
                      FadeTransition(
                        opacity: _opacityAnimation,
                        child: Center(
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: Colors.amber,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.play_arrow,
                              color: Colors.black,
                              size: 24,
                            ),
                          ),
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
  }
}