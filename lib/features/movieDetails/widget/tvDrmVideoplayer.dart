import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:better_player/better_player.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nandiott_flutter/services/watchhistory_service.dart';

/// A custom DRM video player widget with quality switching, remote control support, and watch history
class DrmVideoPlayer extends StatefulWidget {
  /// The HLS master playlist URL
  final String videoUrl;
  
  /// Default quality to start with (e.g., "480p", "720p")
  final String? defaultQuality;
  
  /// Whether to auto-play the video
  final bool autoPlay;
  
  /// Whether to loop the video
  final bool looping;
  
  /// Whether to start in fullscreen mode
  final bool fullScreenByDefault;
  
  /// Aspect ratio of the video player
  final double aspectRatio;
  
  /// Box fit for the video
  final BoxFit fit;
  
  /// Duration after which controls hide automatically (in seconds)
  final int controlsHideTimeout;

  // Watch history parameters
  final String? auth;
  final String? mediaId;
  final String? mediaType;
  final String? tvSeriesId;
  final bool isTrailer;

  const DrmVideoPlayer({
    Key? key,
    required this.videoUrl,
    this.defaultQuality,
    this.autoPlay = true,
    this.looping = false,
    this.fullScreenByDefault = false,
    this.aspectRatio = 16 / 9,
    this.fit = BoxFit.contain,
    this.controlsHideTimeout = 10,
    this.auth,
    this.mediaId,
    this.mediaType,
    this.tvSeriesId,
    this.isTrailer = false,
  }) : super(key: key);

  @override
  State<DrmVideoPlayer> createState() => _DrmVideoPlayerState();
}

class _DrmVideoPlayerState extends State<DrmVideoPlayer> {
  BetterPlayerController? _videoController;
  late String _currentQualityLabel;
  Map<String, String> _qualityUrls = {};
  bool _isLoading = true;
  String? _errorMessage;
  
  // Watch history related variables
  final WatchHistoryService _historyService = WatchHistoryService();
  int _startPosition = 0;
  bool _initialized = false;
  Timer? _historyTimer;

  @override
  void initState() {
    super.initState();
    _currentQualityLabel = widget.defaultQuality ?? "480p";
    _fetchWatchHistoryAndSetupPlayer();
  }

  @override
  void didUpdateWidget(DrmVideoPlayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.videoUrl != widget.videoUrl) {
      _fetchWatchHistoryAndSetupPlayer();
    }
  }

  @override
  void dispose() {
    _historyTimer?.cancel();
    _videoController?.dispose();
    super.dispose();
  }

  /// Fetch watch history first, then setup player
  Future<void> _fetchWatchHistoryAndSetupPlayer() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Fetch watch history if not a trailer
      if (widget.auth != null &&
          widget.mediaId != null &&
          widget.mediaType != null &&
          !widget.isTrailer) {
        final transformedMediaType = _getTransformedMediaType(widget.mediaType ?? 'movies');
        final lastTime = await _historyService.getWatchHistory(
          mediaId: widget.mediaId!,
          mediaType: transformedMediaType,
          token: widget.auth!,
        );
        _startPosition = lastTime ?? 0;
        print("Fetched watch history: $_startPosition seconds");
      }

      // Now load and setup player
      await _loadAndSetupPlayer();
    } catch (e) {
      print("Error fetching watch history: $e");
      // Continue with player setup even if history fetch fails
      await _loadAndSetupPlayer();
    }
  }

  /// Parse HLS master playlist to extract quality variants
  Future<Map<String, String>> _parseHlsVariants(String masterUrl) async {
    try {
      final response = await http.get(Uri.parse(masterUrl));
      if (response.statusCode != 200) {
        throw Exception("Failed to load HLS master playlist");
      }

      final lines = response.body.split('\n');
      final Map<String, String> qualityMap = {};
      String? currentResolution;
      Uri masterUri = Uri.parse(masterUrl);

      for (int i = 0; i < lines.length; i++) {
        final line = lines[i];

        if (line.startsWith('#EXT-X-STREAM-INF')) {
          final resolutionMatch = RegExp(r'RESOLUTION=(\d+x\d+)').firstMatch(line);
          if (resolutionMatch != null) {
            currentResolution = resolutionMatch.group(1)!;
          }
        } else if (!line.startsWith('#') && currentResolution != null) {
          // Normalize relative paths
          final streamUrl = Uri.parse(line);
          final resolvedUrl = streamUrl.isAbsolute
              ? streamUrl.toString()
              : masterUri.resolveUri(streamUrl).toString();

          final qualityLabel = currentResolution.split('x').last + 'p';
          qualityMap[qualityLabel] = resolvedUrl;
          currentResolution = null;
        }
      }

      return qualityMap;
    } catch (e) {
      throw Exception("Error parsing HLS variants: $e");
    }
  }

  /// Switch video quality
  Future<void> _switchQuality(String qualityLabel) async {
    final newUrl = _qualityUrls[qualityLabel];
    if (newUrl == null) return;

    // Save current position before disposing
    Duration currentPosition = Duration.zero;
    try {
      currentPosition = await _videoController?.videoPlayerController?.position ?? Duration.zero;
    } catch (e) {
      // If error happens, keep zero position
    }

    // Dispose current controller
    await _videoController?.dispose();

    // Create new controller
    _videoController = _createBetterPlayerController(newUrl, qualityLabel);
    
    // Wait for the controller to initialize and restore position
    void listener(BetterPlayerEvent event) async {
      if (event.betterPlayerEventType == BetterPlayerEventType.initialized) {
        await _videoController?.seekTo(currentPosition);
        if (widget.autoPlay) {
          await _videoController?.play();
        }
        _videoController?.removeEventsListener(listener);
      }
    }

    _videoController?.addEventsListener(listener);

    setState(() {
      _currentQualityLabel = qualityLabel;
    });

    _videoController?.setControlsVisibility(true);
  }

  /// Create BetterPlayerController with configuration
  BetterPlayerController _createBetterPlayerController(String url, String qualityLabel) {
    final controller = BetterPlayerController(
      BetterPlayerConfiguration(
        fit: widget.fit,
        fullScreenByDefault: widget.fullScreenByDefault,
        autoDispose: true,
        autoPlay: widget.autoPlay,
        looping: widget.looping,
        aspectRatio: widget.aspectRatio,
        controlsConfiguration: BetterPlayerControlsConfiguration(
          playerTheme: BetterPlayerTheme.custom,
          customControlsBuilder: (controller, onVisibilityChanged) => _CustomPlayerControl(
            controller: controller,
            defaultQuality: qualityLabel,
            qualityUrls: _qualityUrls,
            onQualitySelected: _switchQuality,
            controlsHideTimeout: widget.controlsHideTimeout,
          ),
        ),
      ),
      betterPlayerDataSource: BetterPlayerDataSource(
        BetterPlayerDataSourceType.network,
        url,
        videoFormat: BetterPlayerVideoFormat.hls,
        useAsmsTracks: true,
      ),
    );

    // Add event listener for watch history
    controller.addEventsListener(_handlePlayerEvent);
    
    return controller;
  }

  /// Handle player events for watch history
  void _handlePlayerEvent(BetterPlayerEvent event) {
    if (event.betterPlayerEventType == BetterPlayerEventType.initialized && !_initialized) {
      _initialized = true;

      // Seek to the starting position for non-trailers
      if (_startPosition > 0 && !widget.isTrailer) {
        print("Seeking to saved position: $_startPosition seconds");
        _videoController?.seekTo(Duration(seconds: _startPosition));
      }
      
      // Start updating watch history (non-trailers only)
      if (!widget.isTrailer) {
        _startUpdatingHistory();
      }
    }
  }

  /// Start periodic watch history updates
  void _startUpdatingHistory() {
    _historyTimer = Timer.periodic(const Duration(seconds: 3), (timer) async {
      if (!mounted) {
        timer.cancel();
        return;
      }
      
      if (widget.auth != null &&
          widget.mediaId != null &&
          widget.mediaType != null &&
          _videoController?.videoPlayerController?.value.initialized == true) {
        
        final position = await _videoController!.videoPlayerController!.position;
        final duration = _videoController!.videoPlayerController!.value.duration;
        
        if (position != null && duration != null) {
          final transformedMediaType = _getTransformedMediaType(widget.mediaType ?? 'movies');
          
          try {
            await _historyService.updateWatchHistory(
              mediaId: widget.mediaId!,
              mediaType: transformedMediaType,
              watchTime: position.inSeconds.toDouble(),
              duration: duration.inSeconds.toDouble(),
              tvSeriesId: widget.tvSeriesId,
              token: widget.auth!,
            );
            print("Updated watch history: ${position.inSeconds}s / ${duration.inSeconds}s");
          } catch (e) {
            print("Error updating watch history: $e");
          }
        }
      }
    });
  }

  /// Transform media type to match API expectations
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

  /// Load and setup the video player
  Future<void> _loadAndSetupPlayer() async {
    try {
      _qualityUrls = await _parseHlsVariants(widget.videoUrl);
      
      if (_qualityUrls.isEmpty) {
        throw Exception("No quality variants found in HLS playlist");
      }

      // Set default quality if not available
      if (!_qualityUrls.containsKey(_currentQualityLabel)) {
        _currentQualityLabel = _qualityUrls.keys.first;
      }

      final defaultUrl = _qualityUrls[_currentQualityLabel]!;
      _videoController = _createBetterPlayerController(defaultUrl, _currentQualityLabel);

      // Show controls after initialization
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _videoController?.setControlsVisibility(true);
        setState(() {
          _isLoading = false;
        });
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            Text(
              'Error loading video',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage!,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _fetchWatchHistoryAndSetupPlayer,
              child: Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_videoController == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return BetterPlayer(controller: _videoController!);
  }
}

/// Custom player controls with remote control support
class _CustomPlayerControl extends StatefulWidget {
  final BetterPlayerController controller;
  final String defaultQuality;
  final Map<String, String> qualityUrls;
  final void Function(String quality)? onQualitySelected;
  final int controlsHideTimeout;

  const _CustomPlayerControl({
    required this.controller,
    required this.defaultQuality,
    required this.qualityUrls,
    required this.onQualitySelected,
    required this.controlsHideTimeout,
  });

  @override
  State<_CustomPlayerControl> createState() => _CustomPlayerControlState();
}

class _CustomPlayerControlState extends State<_CustomPlayerControl> {
  Timer? _hideTimer;
  bool _controlsVisible = true;
  late String _currentQuality;
  
  // Focus nodes for each control button
  final List<FocusNode> _buttonFocusNodes = [];
  int _currentFocusedButton = 0;

  @override
  void initState() {
    super.initState();
    _currentQuality = widget.defaultQuality;
    
    // Initialize focus nodes for 4 buttons (rewind, play/pause, forward, quality)
    for (int i = 0; i < 4; i++) {
      _buttonFocusNodes.add(FocusNode());
    }
    
    _startHideTimer();
    
    // Focus the first button after a short delay
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_buttonFocusNodes.isNotEmpty) {
        _buttonFocusNodes[0].requestFocus();
      }
    });
  }

  @override
  void dispose() {
    _hideTimer?.cancel();
    for (final node in _buttonFocusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  void _showControls() {
    setState(() {
      _controlsVisible = true;
    });
    _startHideTimer();
    
    // Ensure a button is focused when controls are shown
    if (_currentFocusedButton < _buttonFocusNodes.length) {
      _buttonFocusNodes[_currentFocusedButton].requestFocus();
    }
  }

  void _hideControls() {
    setState(() {
      _controlsVisible = false;
    });
    _hideTimer?.cancel();
  }

  void _startHideTimer() {
    _hideTimer?.cancel();
    _hideTimer = Timer(Duration(seconds: widget.controlsHideTimeout), _hideControls);
  }

  void _handlePlayPause() {
    try {
      if (widget.controller.isPlaying() == true) {
        widget.controller.pause();
      } else {
        widget.controller.play();
      }
    } catch (e) {
      debugPrint('Play/Pause error: $e');
    }
  }

  void _handleRewind() {
    try {
      final videoController = widget.controller.videoPlayerController;
      if (videoController != null && videoController.value.initialized) {
        final currentPosition = videoController.value.position;
        final newPosition = currentPosition - const Duration(seconds: 10);
        final finalPosition = newPosition.isNegative ? Duration.zero : newPosition;
        widget.controller.seekTo(finalPosition);
      }
    } catch (e) {
      debugPrint('Rewind error: $e');
    }
  }

  void _handleForward() {
    try {
      final videoController = widget.controller.videoPlayerController;
      if (videoController != null && videoController.value.initialized) {
        final currentPosition = videoController.value.position;
        final duration = videoController.value.duration ?? Duration.zero;
        final newPosition = currentPosition + const Duration(seconds: 10);
        final finalPosition = newPosition > duration ? duration : newPosition;
        widget.controller.seekTo(finalPosition);
      }
    } catch (e) {
      debugPrint('Forward error: $e');
    }
  }

  void _showQualityPopup(BuildContext context) {
    final keys = widget.qualityUrls.keys.toList();
    int selectedQualityIndex = keys.indexOf(_currentQuality);
    if (selectedQualityIndex == -1) selectedQualityIndex = 0;

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text("Select Quality"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: keys.asMap().entries.map((entry) {
                  final index = entry.key;
                  final key = entry.value;
                  final isSelected = index == selectedQualityIndex;
                  
                  return Focus(
                    autofocus: isSelected,
                    onKeyEvent: (node, event) {
                      if (event is KeyDownEvent) {
                        if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
                          setState(() {
                            selectedQualityIndex = (selectedQualityIndex + 1) % keys.length;
                          });
                          return KeyEventResult.handled;
                        } else if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
                          setState(() {
                            selectedQualityIndex = (selectedQualityIndex - 1 + keys.length) % keys.length;
                          });
                          return KeyEventResult.handled;
                        } else if (event.logicalKey == LogicalKeyboardKey.select || 
                                   event.logicalKey == LogicalKeyboardKey.enter) {
                          final selectedKey = keys[selectedQualityIndex];
                          this.setState(() {
                            _currentQuality = selectedKey;
                          });
                          widget.onQualitySelected?.call(selectedKey);
                          Navigator.pop(dialogContext);
                          _buttonFocusNodes[3].requestFocus();
                          return KeyEventResult.handled;
                        } else if (event.logicalKey == LogicalKeyboardKey.escape) {
                          Navigator.pop(dialogContext);
                          _buttonFocusNodes[3].requestFocus();
                          return KeyEventResult.handled;
                        }
                      }
                      return KeyEventResult.ignored;
                    },
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 4.0),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isSelected ? Colors.red : Colors.grey.shade900,
                        borderRadius: BorderRadius.circular(8),
                        border: isSelected
                            ? Border.all(color: Colors.white, width: 2)
                            : null,
                      ),
                      child: Text(
                        key,
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  );
                }).toList(),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildFocusableButton({
    required IconData icon,
    required VoidCallback onPressed,
    required int index,
    required FocusNode focusNode,
  }) {
    return Focus(
      focusNode: focusNode,
      onKeyEvent: (node, event) {
        if (event is KeyDownEvent) {
          if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
            _currentFocusedButton = (_currentFocusedButton - 1 + _buttonFocusNodes.length) % _buttonFocusNodes.length;
            _buttonFocusNodes[_currentFocusedButton].requestFocus();
            _showControls();
            return KeyEventResult.handled;
          } else if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
            _currentFocusedButton = (_currentFocusedButton + 1) % _buttonFocusNodes.length;
            _buttonFocusNodes[_currentFocusedButton].requestFocus();
            _showControls();
            return KeyEventResult.handled;
          } else if (event.logicalKey == LogicalKeyboardKey.select ||
                     event.logicalKey == LogicalKeyboardKey.enter) {
            onPressed();
            _showControls();
            return KeyEventResult.handled;
          }
        }
        return KeyEventResult.ignored;
      },
      onFocusChange: (hasFocus) {
        if (hasFocus) {
          _currentFocusedButton = index;
          _showControls();
        }
        setState(() {});
      },
      child: GestureDetector(
        onTap: () {
          _currentFocusedButton = index;
          focusNode.requestFocus();
          onPressed();
          _showControls();
        },
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: CircleAvatar(
            radius: 25,
            backgroundColor: focusNode.hasFocus ? Colors.white : Colors.black54,
            child: Icon(
              icon,
              color: focusNode.hasFocus ? Colors.black : Colors.white,
              size: 24,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildControls() {
    final buttonConfigs = [
      {"icon": Icons.replay_10, "onPressed": _handleRewind},
      {
        "icon": (widget.controller.isPlaying() == true) ? Icons.pause : Icons.play_arrow,
        "onPressed": _handlePlayPause
      },
      {"icon": Icons.forward_10, "onPressed": _handleForward},
      {"icon": Icons.hd, "onPressed": () => _showQualityPopup(context)},
    ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: buttonConfigs.asMap().entries.map((entry) {
        final index = entry.key;
        final config = entry.value;
        return _buildFocusableButton(
          icon: config["icon"] as IconData,
          onPressed: config["onPressed"] as VoidCallback,
          index: index,
          focusNode: _buttonFocusNodes[index],
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (_controlsVisible) {
          _hideControls();
        } else {
          _showControls();
        }
      },
      child: Container(
        width: double.infinity,
        height: double.infinity,
        color: Colors.transparent,
        child: Stack(
          children: [
            // Main controls
            if (_controlsVisible)
              Center(child: _buildControls()),
            
            // Hidden state focus handler
            if (!_controlsVisible)
              Focus(
                autofocus: true,
                onKeyEvent: (node, event) {
                  if (event is KeyDownEvent) {
                    _showControls();
                    return KeyEventResult.handled;
                  }
                  return KeyEventResult.ignored;
                },
                child: Container(
                  width: double.infinity,
                  height: double.infinity,
                  color: Colors.transparent,
                ),
              ),

            // Progress bar
            if (_controlsVisible)
              Positioned(
                left: 10,
                right: 10,
                bottom: 8,
                child: Focus(
                  canRequestFocus: false,
                  descendantsAreFocusable: false,
                  child: ValueListenableBuilder(
                    valueListenable: widget.controller.videoPlayerController!,
                    builder: (context, value, child) {
                      return _VideoScrubber(
                        controller: widget.controller,
                        playerValue: value,
                      );
                    },
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Video scrubber/progress bar widget
class _VideoScrubber extends StatefulWidget {
  const _VideoScrubber({
    required this.playerValue,
    required this.controller,
  });

  final VideoPlayerValue playerValue;
  final BetterPlayerController controller;

  @override
  _VideoScrubberState createState() => _VideoScrubberState();
}

class _VideoScrubberState extends State<_VideoScrubber> {
  double _value = 0.0;

  @override
  void didUpdateWidget(covariant _VideoScrubber oldWidget) {
    super.didUpdateWidget(oldWidget);
    final duration = widget.playerValue.duration?.inSeconds ?? 0;
    final position = widget.playerValue.position.inSeconds;
    setState(() {
      _value = duration == 0 ? 0.0 : position / duration;
    });
  }

  String _formatDuration(Duration? duration) {
    if (duration == null) return "--:--";
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return "${duration.inHours > 0 ? '${duration.inHours}:' : ''}$minutes:$seconds";
  }

  @override
  Widget build(BuildContext context) {
    final total = widget.playerValue.duration ?? Duration.zero;
    final current = widget.playerValue.position;
    final remaining = total - current;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _formatDuration(current),
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
              Text(
                "${_formatDuration(remaining)} / ${_formatDuration(total)}",
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
            ],
          ),
        ),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            thumbShape: _CustomThumbShape(),
            overlayShape: SliderComponentShape.noOverlay,
          ),
          child: Slider(
            value: _value.clamp(0.0, 1.0),
            inactiveColor: Colors.grey,
            min: 0.0,
            max: 1.0,
            onChanged: (newValue) {
              setState(() {
                _value = newValue;
              });
              final duration = widget.controller.videoPlayerController!.value.duration;
              final newProgress = Duration(
                milliseconds: (_value * duration!.inMilliseconds).toInt(),
              );
              widget.controller.seekTo(newProgress);
            },
          ),
        ),
      ],
    );
  }
}

/// Custom slider thumb shape
class _CustomThumbShape extends SliderComponentShape {
  final double thumbRadius = 6.0;

  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) =>
      Size.fromRadius(thumbRadius);

  @override
  void paint(
    PaintingContext context,
    Offset center, {
    required Animation<double> activationAnimation,
    required Animation<double> enableAnimation,
    required bool isDiscrete,
    required TextPainter labelPainter,
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required TextDirection textDirection,
    required double value,
    required double textScaleFactor,
    required Size sizeWithOverflow,
  }) {
    final canvas = context.canvas;
    final fillPaint = Paint()
      ..color = sliderTheme.thumbColor ?? Colors.white
      ..style = PaintingStyle.fill;

    canvas.drawCircle(center, thumbRadius, fillPaint);
  }
}