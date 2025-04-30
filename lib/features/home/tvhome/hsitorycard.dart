import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nandiott_flutter/pages/detail_page.dart';
import 'package:nandiott_flutter/services/getBannerPoster_service.dart';
import 'package:nandiott_flutter/providers/checkauth_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TVHistoryCard extends ConsumerStatefulWidget {
  final dynamic historyItem;
  final int index;
  final bool hasFocus;
  final FocusNode? focusNode;

  const TVHistoryCard({
    Key? key,
    required this.historyItem,
    this.index = 0,
    this.hasFocus = false,
    this.focusNode,
  }) : super(key: key);

  @override
  _TVHistoryCardState createState() => _TVHistoryCardState();
}

class _TVHistoryCardState extends ConsumerState<TVHistoryCard> {
  final _getBannerPosterService = getBannerPosterService();
  late FocusNode _focusNode;
  bool _isFocused = false;
  String _posterUrl = "";
  double _progressValue = 0.0;

  @override
  void initState() {
    super.initState();
    _focusNode = widget.focusNode ?? FocusNode(debugLabel: 'history_card_${widget.index}');
    _isFocused = widget.hasFocus;
    
    // Setup focus listener
    _focusNode.addListener(_handleFocusChange);
    
    // Load poster image
    _loadPosterImage();
    
    // Set progress value
    _calculateProgress();
    
    // Request focus if needed
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
      final mediaType = widget.historyItem.contentType ?? 'movie';
      final response = await _getBannerPosterService.getPoster(
        mediaType: mediaType,
        mediaId: widget.historyItem.contentId,
      );
      
      if (mounted) {
        setState(() {
          if (response != null && response['success']) {
            _posterUrl = response['contentUrl'];
          }
        });
      }
    } catch (e) {
      // Handle error silently
    }
  }
  
  void _calculateProgress() {
    try {
      final double currentTime = widget.historyItem.currentTime?.toDouble() ?? 0;
      final double totalDuration = widget.historyItem.totalDuration?.toDouble() ?? 1;
      
      if (totalDuration > 0) {
        setState(() {
          _progressValue = currentTime / totalDuration;
        });
      }
    } catch (e) {
      setState(() {
        _progressValue = 0;
      });
    }
  }

  @override
  void didUpdateWidget(TVHistoryCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // Update focus state
    if (oldWidget.hasFocus != widget.hasFocus) {
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
    
    // Reload data if history item changed
    if (oldWidget.historyItem != widget.historyItem) {
      _loadPosterImage();
      _calculateProgress();
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

  void _navigateToDetails(BuildContext context) {
    final userAsyncValue = ref.read(authUserProvider);
    
    userAsyncValue.when(
      data: (user) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MovieDetailPage(
              movieId: widget.historyItem.contentId,
              mediaType: widget.historyItem.contentType,
              userId: user?.id ?? '',
            ),
          ),
        );
      },
      loading: () {}, // Do nothing while loading
      error: (_, __) {}, // Do nothing on error
    );
  }

  @override
  Widget build(BuildContext context) {
    return Focus(
      focusNode: _focusNode,
      onKey: (node, event) {
        if (event is RawKeyDownEvent) {
          if (event.logicalKey == LogicalKeyboardKey.select || 
              event.logicalKey == LogicalKeyboardKey.enter) {
            _navigateToDetails(context);
            return KeyEventResult.handled;
          }
        }
        return KeyEventResult.ignored;
      },
      child: GestureDetector(
        onTap: () => _navigateToDetails(context),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutCubic,
          margin: const EdgeInsets.only(right: 20, bottom: 20),
          width: _isFocused ? 230 : 200,
          height: _isFocused ? 330 : 280,
          child: Stack(
            children: [
              // Poster image
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
                    child: _posterUrl.isEmpty
                        ? Image.asset(
                            'assets/images/placeholder.png',
                            fit: BoxFit.cover,
                          )
                        : Image.network(
                            _posterUrl,
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
              
              // Progress indicator
              Positioned(
                left: 0,
                right: 0,
                bottom: 45,
                child: Container(
                  margin: EdgeInsets.symmetric(horizontal: 10),
                  height: 5,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(2.5),
                    child: LinearProgressIndicator(
                      value: _progressValue,
                      backgroundColor: Colors.grey[800],
                      valueColor: AlwaysStoppedAnimation<Color>(_isFocused ? Colors.amber : Colors.red),
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
                      widget.historyItem.title ?? 'Unknown Title',
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
                            'Resume',
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
              
              // Resume button that shows on hover/focus
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
                
              // Continue watching badge
              Positioned(
                top: 10,
                right: 10,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    'CONTINUE',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}