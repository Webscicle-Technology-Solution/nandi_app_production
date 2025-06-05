
import 'dart:async';
import 'dart:io';
import 'package:better_player_plus/better_player_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nandiott_flutter/services/watchhistory_service.dart';

class BetterVideoPlayer extends StatefulWidget {
  final String videoUrl;
  final bool isTrailer;
  final String? posterUrl;
  final bool autoPlay;
  final bool fullScreen;
  final String? auth;
  final String? mediaId;
  final String? mediaType;
  final String? tvSeriesId;

  const BetterVideoPlayer({
    Key? key,
    required this.videoUrl,
    this.isTrailer = false,
    this.posterUrl,
    this.autoPlay = false,
    this.fullScreen = false,
    this.auth,
    this.mediaId,
    this.mediaType,
    this.tvSeriesId,
  }) : super(key: key);

  @override
  _BetterVideoPlayerState createState() => _BetterVideoPlayerState();
}

class _BetterVideoPlayerState extends State<BetterVideoPlayer> with WidgetsBindingObserver {
  BetterPlayerController? _betterPlayerController;
  final WatchHistoryService _historyService = WatchHistoryService();
  int _startPosition = 0;
  bool _initialized = false;
  bool _isLoading = true;
  Timer? _historyTimer;
  Timer? _controlVisibilityTimer;
  final FocusNode _playerFocusNode = FocusNode();
  
  // Track if controls are visible
  bool _controlsVisible = true;
  
  // We'll determine this later in didChangeDependencies
  late bool _isDarkMode;
  
  // Is this device likely a TV
  bool get _isTV {
    // Basic check for TV-like screen
    final size = MediaQuery.of(context).size;
    return size.width > 1200 || widget.fullScreen;
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _fetchWatchHistory();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _isDarkMode = Theme.of(context).brightness == Brightness.dark;
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _historyTimer?.cancel();
    _controlVisibilityTimer?.cancel();
    _playerFocusNode.dispose();
    _betterPlayerController?.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    // Handle app lifecycle changes if needed
  }

  Future<void> _fetchWatchHistory() async {
    try {
      if (widget.auth != null &&
          widget.mediaId != null &&
          widget.mediaType != null &&
          !widget.isTrailer) {
        final transformedMediaType =
            _getTransformedMediaType(widget.mediaType ?? 'movies');
        final lastTime = await _historyService.getWatchHistory(
          mediaId: widget.mediaId!,
          mediaType: transformedMediaType,
          token: widget.auth!,
        );
        _startPosition = lastTime ?? 0;
      }
    } catch (e) {
    } finally {
      // Initialize player after fetching history
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _initializePlayer();
          setState(() {
            _isLoading = false;
          });
          
          // Force focus for TV
          if (_isTV && widget.fullScreen) {
            FocusScope.of(context).requestFocus(_playerFocusNode);
          }
        }
      });
    }
  }
  void _initializePlayer() {
    // Headers setup
    Map<String, String> headers = widget.auth != null && widget.auth!.isNotEmpty
        ? {
            "Authorization": "Bearer ${widget.auth}",
            "User-Agent": Platform.isIOS ? "BetterPlayerPlus/iOS" : "BetterPlayer",
          }
        : {
            "User-Agent": Platform.isIOS ? "BetterPlayerPlus/iOS" : "BetterPlayer",
          };
    
    // Data source configuration
    final dataSource = BetterPlayerDataSource(
      BetterPlayerDataSourceType.network,
      widget.videoUrl,
      videoFormat: Platform.isIOS ? null : BetterPlayerVideoFormat.hls,
      cacheConfiguration: BetterPlayerCacheConfiguration(
        useCache: !Platform.isIOS,
        maxCacheSize: 500 * 1024 * 1024,
        maxCacheFileSize: 100 * 1024 * 1024,
      ),
      headers: headers,
    );

    // Choose configuration based on whether this is a trailer
    final controlsConfig = widget.isTrailer 
        ? _getTrailerControlsConfiguration() 
        : _getVideoControlsConfiguration();

    // Player configuration
    final BetterPlayerConfiguration playerConfig = BetterPlayerConfiguration(
      handleLifecycle: true,
      autoPlay: widget.autoPlay,
      looping: false,
      fullScreenByDefault: widget.fullScreen,
      expandToFill: true,
      fit: BoxFit.contain,
      aspectRatio: 16 / 9,
      fullScreenAspectRatio: 16 / 9,
      controlsConfiguration: controlsConfig,
      placeholder: widget.posterUrl != null
          ? Image.network(
              widget.posterUrl!,
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) => Image.asset(
                "assets/images/placeholder.png",
                fit: BoxFit.contain,
              ),
            )
          : Image.asset("assets/images/placeholder.png", fit: BoxFit.contain),
      showPlaceholderUntilPlay: true,
    );

    // Initialize controller
    _betterPlayerController = BetterPlayerController(
      playerConfig,
      betterPlayerDataSource: dataSource,
    );

    // Setup event listeners
    _betterPlayerController?.addEventsListener(_handlePlayerEvent);
  }
  
  // Special configuration for trailers (more minimal)
  BetterPlayerControlsConfiguration _getTrailerControlsConfiguration() {
    return BetterPlayerControlsConfiguration(
      enableOverflowMenu: false, // No menu for trailers
      enableSkips: true, // Allow skipping
      enablePlaybackSpeed: false, // No speed control for trailers
      enableQualities: false, // No quality selection for trailers
      enableProgressBar: true, // Show progress
      enableFullscreen: true, // Allow fullscreen
      enableAudioTracks: false, // No audio track selection
      enableSubtitles: false, // No subtitles
      enableMute: true, // Allow mute
      enablePlayPause: true, // Allow play/pause
      
      // Semi-transparent background to see video content through controls
      controlBarColor: Colors.black.withOpacity(0.7),
      iconsColor: Colors.white,
      textColor: Colors.white,
      progressBarPlayedColor: Colors.amber,
      progressBarHandleColor: Colors.amber,
      progressBarBufferedColor: Colors.white70,
      progressBarBackgroundColor: Colors.white30,
      liveTextColor: Colors.amber,
      
      // Controls settings
      controlsHideTime: const Duration(seconds: 0), // Very short hide time
      showControlsOnInitialize: true,
      showControls: true,
    );
  }
  
  // Full featured configuration for regular videos
  BetterPlayerControlsConfiguration _getVideoControlsConfiguration() {
    return BetterPlayerControlsConfiguration(
      enableOverflowMenu: true,
      enableSkips: true,
      enablePlaybackSpeed: true,
      enableQualities: true,
      enableProgressBar: true,
      enableFullscreen: true,
      enableAudioTracks: true,
      enableSubtitles: true,
      enableMute: true,
      enablePlayPause: true,
      
      // Semi-transparent background to see video content
      controlBarColor: Colors.black.withOpacity(0.7),
      iconsColor: Colors.white,
      textColor: Colors.white,
      progressBarPlayedColor: Colors.amber,
      progressBarHandleColor: Colors.amber,
      progressBarBufferedColor: Colors.white70,
      progressBarBackgroundColor: Colors.white30,
      liveTextColor: Colors.amber,
      
      // Menu styling with transparency
      overflowMenuIconsColor: Colors.amber,
      overflowModalColor: Colors.black.withOpacity(0.8),
      overflowModalTextColor: Colors.white,
      
      // Skip times
      forwardSkipTimeInMilliseconds: 10000,
      backwardSkipTimeInMilliseconds: 10000,

      // Controls settings - very short hide time to appear instant
      controlsHideTime: const Duration(milliseconds: 0),
      showControlsOnInitialize: true,
      showControls: true,
      
      // Use material theme for better TV support
      playerTheme: BetterPlayerTheme.material,
    );
  }

  void _handlePlayerEvent(BetterPlayerEvent event) {
    if (event.betterPlayerEventType == BetterPlayerEventType.initialized && 
        !_initialized) {
      _initialized = true;

      // Seek to the starting position for non-trailers
      if (_startPosition > 0 && !widget.isTrailer) {
        _betterPlayerController?.seekTo(Duration(seconds: _startPosition));
      }
      
      // Start updating watch history (non-trailers only)
      if (!widget.isTrailer) {
        _startUpdatingHistory();
      }
      
      // Initial controls visibility
      _controlsVisible = true;
      
      // For non-trailers, set a timer to hide controls after playback begins
      if (!widget.isTrailer && widget.autoPlay) {
        _controlVisibilityTimer?.cancel();
        _controlVisibilityTimer = Timer(const Duration(seconds: 3), () {
          if (mounted && _betterPlayerController != null) {
            // Hide controls after initial delay
            _setControlsVisibility(false);
          }
        });
      }
    } else if (event.betterPlayerEventType == BetterPlayerEventType.play) {
      // When video starts playing, set a timer to hide controls
      if (!widget.isTrailer) {
        _controlVisibilityTimer?.cancel();
        _controlVisibilityTimer = Timer(const Duration(seconds: 2), () {
          if (mounted && _betterPlayerController != null) {
            _setControlsVisibility(false);
          }
        });
      }
    } else if (event.betterPlayerEventType == BetterPlayerEventType.pause) {
      // When video is paused, ensure controls are visible
      if (mounted && _betterPlayerController != null) {
        _setControlsVisibility(true);
      }
    }
  }

  void _startUpdatingHistory() {
    _historyTimer = Timer.periodic(const Duration(seconds: 3), (timer) async {
      if (!mounted) {
        timer.cancel();
        return;
      }
      
      if (widget.auth != null &&
          widget.mediaId != null &&
          widget.mediaType != null &&
          _betterPlayerController?.videoPlayerController?.value.initialized == true) {
        final position = await _betterPlayerController!.videoPlayerController!.position;
        final duration = _betterPlayerController!.videoPlayerController!.value.duration;
        
        if (position != null && duration != null) {
          final transformedMediaType = _getTransformedMediaType(widget.mediaType ?? 'movies');
          
          _historyService.updateWatchHistory(
            mediaId: widget.mediaId!,
            mediaType: transformedMediaType,
            watchTime: position.inSeconds.toDouble(),
            duration: duration.inSeconds.toDouble(),
            tvSeriesId: widget.tvSeriesId,
            token: widget.auth!,
          );
        }
      }
    });
  }

  // Show/hide controls with explicit setting
  void _setControlsVisibility(bool visible) {
    if (_betterPlayerController != null) {
      _controlsVisible = visible;
      _betterPlayerController!.setControlsVisibility(visible);
    }
  }

  // Show controls when user interaction occurs
  void _showControls() {
    _controlVisibilityTimer?.cancel();
    
    // Show controls immediately
    _setControlsVisibility(true);
    
    // For non-trailers, auto-hide after delay
    if (!widget.isTrailer) {
      _controlVisibilityTimer = Timer(const Duration(seconds: 4), () {
        if (mounted && _betterPlayerController != null) {
          _setControlsVisibility(false);
        }
      });
    }
  }

  // Toggle play/pause manually
  void _togglePlayPause() {
    if (_betterPlayerController != null &&
        _betterPlayerController!.videoPlayerController != null) {
      final controller = _betterPlayerController!.videoPlayerController!;
      if (controller.value.isPlaying) {
        controller.pause();
      } else {
        controller.play();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    _isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return _isLoading
        ? const Center(child: CircularProgressIndicator(color: Colors.amber))
        : GestureDetector(
            onTap: _showControls,
            child: Stack(
              alignment: Alignment.center,
              children: [
                AspectRatio(
                  aspectRatio: 16 / 9,
                  child: Container(
                    color: Colors.black,
                    child: _betterPlayerController != null
                        ? Focus(
                            focusNode: _playerFocusNode,
                            autofocus: widget.fullScreen,
                            onKeyEvent: (FocusNode node, KeyEvent event) {
                              if (event is KeyDownEvent) {
                                // All key events show controls
                                _showControls();
                                
                                // Navigation keys are passed through
                                if (event.logicalKey == LogicalKeyboardKey.arrowLeft ||
                                    event.logicalKey == LogicalKeyboardKey.arrowRight ||
                                    event.logicalKey == LogicalKeyboardKey.arrowUp ||
                                    event.logicalKey == LogicalKeyboardKey.arrowDown) {
                                  return KeyEventResult.ignored;
                                } 
                                // OK/Enter button
                                else if (event.logicalKey == LogicalKeyboardKey.select ||
                                         event.logicalKey == LogicalKeyboardKey.enter) {
                                  // Toggle play/pause if controls aren't visible
                                  if (!_controlsVisible) {
                                    _togglePlayPause();
                                    return KeyEventResult.handled;
                                  }
                                }
                              }
                              
                              return KeyEventResult.ignored;
                            },
                            child: BetterPlayer(controller: _betterPlayerController!),
                          )
                        : const Center(
                            child: Text(
                              "Loading player...",
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                  ),
                ),
              ],
            ),
          );
  }

  String _getTransformedMediaType(String mediaType) {
    final mediaTypeMap = {
      'videosong': 'videosong',
      'shortfilm': 'shortfilm',
      'documentary': 'documentary',
      'episodes': 'episode',
      'movie': 'movie',
      'tvseries': 'tvseries',
      'VideoSong': 'videosong',
      'ShortFilm': 'shortfilm',
      'Documentary': 'documentary',
      'Movie': 'movie',
      'TVSeries': 'tvseries',
    };

    return mediaTypeMap[mediaType] ?? mediaType;
  }
}