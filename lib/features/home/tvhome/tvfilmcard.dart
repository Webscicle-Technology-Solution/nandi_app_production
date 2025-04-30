import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nandiott_flutter/services/getBannerPoster_service.dart';

class TVFilmCard extends StatefulWidget {
  final dynamic film;
  final String mediaType;
  final bool hasFocus;
  final int index;
  final VoidCallback? onTap;
  final FocusNode? focusNode;

  const TVFilmCard({
    Key? key,
    required this.film,
    required this.mediaType,
    this.hasFocus = false,
    this.index = 0,
    this.onTap,
    this.focusNode,
  }) : super(key: key);

  @override
  _TVFilmCardState createState() => _TVFilmCardState();
}

class _TVFilmCardState extends State<TVFilmCard> {
  final _getBannerPosterService = getBannerPosterService();
  late FocusNode _focusNode;
  bool _isFocused = false;
  String _posterUrl = "";
  String _bannerUrl = "";
  bool _isLoadingPoster = true;
  bool _isLoadingBanner = true;

  @override
  void initState() {
    super.initState();
    _focusNode = widget.focusNode ?? FocusNode(debugLabel: 'tv_film_card_${widget.index}');
    _isFocused = widget.hasFocus;
    
    // Listen for focus changes
    _focusNode.addListener(_handleFocusChange);
    
    // Load images
    _loadPosterImage();
    _loadBannerImage();
    
    // Request focus if this card should have initial focus
    if (widget.hasFocus) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _focusNode.requestFocus();
      });
    }
  }

  void _handleFocusChange() {
    if (mounted && _focusNode.hasFocus != _isFocused) {
      setState(() {
        _isFocused = _focusNode.hasFocus;
      });
    }
  }

  Future<void> _loadPosterImage() async {
    try {
      final response = await _getBannerPosterService.getPoster(
        mediaType: widget.mediaType,
        mediaId: widget.film.id.toString(),
      );

      if (mounted) {
        setState(() {
          if (response != null && response['success']) {
            _posterUrl = response['contentUrl'];
          }
          _isLoadingPoster = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingPoster = false;
        });
      }
    }
  }

  Future<void> _loadBannerImage() async {
    try {
      final response = await _getBannerPosterService.getBanner(
        mediaType: widget.mediaType,
        mediaId: widget.film.id.toString(),
      );

      if (mounted) {
        setState(() {
          if (response != null && response['success']) {
            _bannerUrl = response['contentUrl'];
          }
          _isLoadingBanner = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingBanner = false;
        });
      }
    }
  }

  @override
  void didUpdateWidget(TVFilmCard oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Handle media type or film changes
    if (oldWidget.mediaType != widget.mediaType || oldWidget.film.id != widget.film.id) {
      setState(() {
        _posterUrl = "";
        _bannerUrl = "";
        _isLoadingPoster = true;
        _isLoadingBanner = true;
      });
      _loadPosterImage();
      _loadBannerImage();
    }

    // Update focus if needed
    if (widget.hasFocus != oldWidget.hasFocus) {
      setState(() {
        _isFocused = widget.hasFocus;
      });
      
      if (widget.hasFocus && !_focusNode.hasFocus) {
        _focusNode.requestFocus();
      }
    }
    
    // Update focus node if provided externally
    if (widget.focusNode != null && widget.focusNode != _focusNode) {
      _focusNode.removeListener(_handleFocusChange);
      _focusNode = widget.focusNode!;
      _focusNode.addListener(_handleFocusChange);
    }
  }

  @override
  void dispose() {
    _focusNode.removeListener(_handleFocusChange);
    if (widget.focusNode == null) {
      _focusNode.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Focus(
      focusNode: _focusNode,
      onKey: (node, event) {
        if (event is RawKeyDownEvent) {
          if (event.logicalKey == LogicalKeyboardKey.select || 
              event.logicalKey == LogicalKeyboardKey.enter) {
            if (widget.onTap != null) {
              widget.onTap!();
            }
            return KeyEventResult.handled;
          }
        }
        return KeyEventResult.ignored;
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        margin: const EdgeInsets.only(right: 20, bottom: 20),
        width: _isFocused ? 230 : 200,
        height: _isFocused ? 330 : 280,
        child: Stack(
          children: [
            // Base poster card
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: _isFocused 
                      ? [BoxShadow(
                          color: Colors.amber.withOpacity(0.6),
                          blurRadius: 15,
                          spreadRadius: 2
                        )]
                      : null,
                  border: _isFocused 
                      ? Border.all(color: Colors.amber, width: 4)
                      : null,
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: _isLoadingPoster
                      ? Container(color: Colors.grey[800])
                      : Image.network(
                          _posterUrl.isNotEmpty 
                              ? _posterUrl
                              : 'https://via.placeholder.com/200x300',
                          fit: BoxFit.cover,
                          errorBuilder: (context, _, __) => Image.asset(
                            'assets/images/placeholder.png',
                            fit: BoxFit.cover,
                          ),
                        ),
                ),
              ),
            ),
            
            // Gradient overlay for text visibility
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
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
            
            // Title at the bottom
            Positioned(
              left: 10,
              right: 10,
              bottom: 10,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.film.title,
                    style: TextStyle(
                      color: _isFocused ? Colors.amber : Colors.white,
                      fontSize: _isFocused ? 18 : 16,
                      fontWeight: _isFocused ? FontWeight.bold : FontWeight.normal,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  
                  if (_isFocused) ...[
                    const SizedBox(height: 5),
                    Row(
                      children: [
                        const Icon(
                          Icons.play_circle_outline,
                          color: Colors.amber,
                          size: 18,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          'Watch Now',
                          style: TextStyle(
                            color: Colors.amber,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            
            // Expanded preview overlay that appears when focused
            if (_isFocused && _bannerUrl.isNotEmpty)
              Positioned(
                left: -300,
                right: 230,
                top: 0,
                bottom: 0,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.horizontal(
                      left: Radius.circular(10)
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.8),
                        blurRadius: 10,
                        spreadRadius: 2
                      )
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: const BorderRadius.horizontal(
                      left: Radius.circular(10)
                    ),
                    child: Stack(
                      children: [
                        // Banner image
                        Positioned.fill(
                          child: _isLoadingBanner
                              ? Container(color: Colors.grey[900])
                              : Image.network(
                                  _bannerUrl,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, _, __) => Container(
                                    color: Colors.grey[900],
                                  ),
                                ),
                        ),
                        
                        // Gradient overlay
                        Positioned.fill(
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                                colors: [
                                  Colors.black.withOpacity(0.8),
                                  Colors.transparent,
                                ],
                              ),
                            ),
                          ),
                        ),
                        
                        // Content info
                        Positioned(
                          left: 30,
                          bottom: 30,
                          right: 20,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.film.title,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 10),
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.amber.withOpacity(0.8),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      widget.mediaType == 'movie' ? 'Movie' : 
                                      widget.mediaType == 'tvseries' ? 'TV Series' :
                                      widget.mediaType == 'shortfilm' ? 'Short Film' :
                                      widget.mediaType == 'documentary' ? 'Documentary' : 'Music',
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Icon(
                                    Icons.star, 
                                    color: Colors.amber, 
                                    size: 16
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    widget.film.rating != null ? 
                                    (widget.film.rating is String ? 
                                      widget.film.rating : 
                                      widget.film.rating.toString()) : 
                                    'N/A',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 15),
                              ElevatedButton.icon(
                                onPressed: widget.onTap,
                                icon: Icon(Icons.play_arrow),
                                label: Text('Watch Now'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.amber,
                                  foregroundColor: Colors.black,
                                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              
            // Play button that shows on hover/focus
            if (_isFocused)
              Positioned.fill(
                child: Center(
                  child: Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.amber,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.play_arrow,
                      color: Colors.black,
                      size: 30,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}