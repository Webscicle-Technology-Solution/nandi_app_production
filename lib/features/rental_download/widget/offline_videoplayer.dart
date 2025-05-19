import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:better_player_plus/better_player_plus.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:path_provider/path_provider.dart';

class OfflineVideoPlayer extends StatefulWidget {
  final String movieId;
  final List<String> segmentPaths;
  final String encryptionKeyPath;
  final String? auth;

  const OfflineVideoPlayer({
    Key? key,
    required this.movieId,
    required this.segmentPaths,
    required this.encryptionKeyPath,
    this.auth,
  }) : super(key: key);

  @override
  _OfflineVideoPlayerState createState() => _OfflineVideoPlayerState();
}

class _OfflineVideoPlayerState extends State<OfflineVideoPlayer> {
  BetterPlayerController? _betterPlayerController;
  String? _localPlaylistPath;
  bool _isInitialized = false;
  String? _errorMessage;
  final secureStorage = const FlutterSecureStorage();
  bool _isEncrypted = false;

  @override
  void initState() {
    super.initState();
    _initializeOfflinePlayer();
  }

  Future<void> _initializeOfflinePlayer() async {
    try {
      // Check if content is encrypted
      _isEncrypted = widget.encryptionKeyPath.isNotEmpty && widget.encryptionKeyPath != "none";
      
      // Validate segments exist
      if (!await _validateSegments()) {
        throw Exception('One or more segments are missing');
      }

      // For encrypted content, try to prepare the key
      if (_isEncrypted) {
        final keyPath = await _prepareEncryptionKey();
        if (keyPath == null) {
        }
      }

      // Use a direct approach with the first segment for testing
      if (widget.segmentPaths.isNotEmpty) {        
        // Try directly with the first segment - this is a fallback test
        _betterPlayerController = BetterPlayerController(
         const BetterPlayerConfiguration(
            autoPlay: true,
            looping: false,
            fit: BoxFit.contain,
            aspectRatio: 16 / 9,
            handleLifecycle: true,
            allowedScreenSleep: false,
            autoDetectFullscreenDeviceOrientation: true,
            controlsConfiguration: BetterPlayerControlsConfiguration(
              showControls: true,
              enableFullscreen: true,
              enableMute: true,
              enableProgressBar: true,
              enablePlayPause: true,
              enableSkips: true,
            ),
          ),
          betterPlayerDataSource: BetterPlayerDataSource(
            BetterPlayerDataSourceType.file,
            widget.segmentPaths[0],
            cacheConfiguration: BetterPlayerCacheConfiguration(
              useCache: true,
              maxCacheSize: 100 * 1024 * 1024, // 100MB cache
              maxCacheFileSize: 20 * 1024 * 1024, // 20MB per file
            ),
          ),
        );

        setState(() {
          _isInitialized = true;
        });
      } else {
        throw Exception('No video segments available for playback');
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
    }
  }

  Future<String?> _prepareEncryptionKey() async {
    try {
      // Skip if not encrypted
      if (!_isEncrypted) return null;
      
      // Get the key from secure storage
      final storedKey = await secureStorage.read(key: widget.encryptionKeyPath);
      
      if (storedKey == null || storedKey.isEmpty) {
        return null;
      }

      // Decode the key
      List<int> keyBytes;
      try {
        keyBytes = base64.decode(storedKey);
        
        if (keyBytes.isEmpty || keyBytes.length != 16) {
          return null;
        }
      } catch (e) {
        return null;
      }

      // Create directory for the key file
      final appDir = await getApplicationDocumentsDirectory();
      final keyDir = Directory('${appDir.path}/downloads/movie_${widget.movieId}');
      if (!keyDir.existsSync()) {
        keyDir.createSync(recursive: true);
      }

      // Write key to file
      final keyFile = File('${keyDir.path}/decryption.key');
      await keyFile.writeAsBytes(keyBytes);
      
      // Verify key file was written successfully
      if (!await keyFile.exists()) {
        return null;
      }
      
      final keySize = await keyFile.length();
      if (keySize == 0) {
        return null;
      }
      
      return keyFile.path;
    } catch (e) {
      return null;
    }
  }

  Future<bool> _validateSegments() async {
    for (var segmentPath in widget.segmentPaths) {
      final segmentFile = File(segmentPath);
      
      if (!await segmentFile.exists()) {
        return false;
      }
      
      final size = await segmentFile.length();
      if (size == 0) {
        return false;
      }
          }
    return true;
  }

  @override
  void dispose() {
    _betterPlayerController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_errorMessage != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Playback Error')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 80),
              const SizedBox(height: 20),
              Text(
                'Unable to play video',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  _errorMessage!,
                  style: Theme.of(context).textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Go Back'),
              )
            ],
          ),
        ),
      );
    }

    if (!_isInitialized || _betterPlayerController == null) {
      return const Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 20),
              Text('Preparing video...'),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Offline Video')),
      body: AspectRatio(
        aspectRatio: 16 / 9,
        child: BetterPlayer(controller: _betterPlayerController!),
      ),
    );
  }
}