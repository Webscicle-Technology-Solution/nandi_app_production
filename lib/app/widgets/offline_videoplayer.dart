// import 'dart:convert';

// import 'package:flutter/material.dart';
// import 'package:better_player_plus/better_player_plus.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_secure_storage/flutter_secure_storage.dart';
// import 'dart:io';
// import 'package:path_provider/path_provider.dart';

// class OfflineVideoPlayer extends StatefulWidget {
//   final String movieId;
//   final List<String> segmentPaths;
//   final String encryptionKeyPath;
//   final String? auth;


//   const OfflineVideoPlayer({
//     Key? key,
//     required this.movieId,
//     required this.segmentPaths,
//     required this.encryptionKeyPath,
//     this.auth,

//   }) : super(key: key);

//   @override
//   _OfflineVideoPlayerState createState() => _OfflineVideoPlayerState();
// }

// class _OfflineVideoPlayerState extends State<OfflineVideoPlayer> {
//   late BetterPlayerController _betterPlayerController;
//   String? _localPlaylistPath;
//   bool _isInitialized = false;
//   String? _errorMessage;

//   @override
//   void initState() {
//     super.initState();
//     print("access token in download player: ${widget.auth}");
//     _initializeOfflinePlayer();
//   }
  

//   Future<void> _initializeOfflinePlayer() async {
//     try {
//       // Validate segments exist
//       await _validateSegments();

//       // Create a local HLS playlist from downloaded segments
//       final playlistContent = await _generateLocalM3U8Playlist();
//       _localPlaylistPath = await _saveLocalPlaylist(playlistContent);

//       // Verify playlist file exists
//       if (_localPlaylistPath == null || !await File(_localPlaylistPath!).exists()) {
//         throw Exception('Failed to create local playlist');
//       }
// print("📂 Local playlist path: $_localPlaylistPath");

// _betterPlayerController = BetterPlayerController(
//   BetterPlayerConfiguration(
//     autoPlay: true,
//     looping: false,
//     fit: BoxFit.cover,
//     aspectRatio: 16 / 9,
//   ),
//   betterPlayerDataSource: BetterPlayerDataSource(
//     BetterPlayerDataSourceType.network, // Change to network
//     Uri.file(_localPlaylistPath!).toString(),  
//     videoFormat: BetterPlayerVideoFormat.hls,
//     headers: widget.auth != null && widget.auth!.isNotEmpty? {
//         "User-Agent": "BetterPlayer",
//         "Authorization": "Bearer ${widget.auth}",
//       }:{
//         "User-Agent": "BetterPlayer",
//       },
//   ),
// );


//       setState(() {
//         _isInitialized = true;
//       });
//     } catch (e) {
//       setState(() {
//         _errorMessage = e.toString();
//       });
//       print('Offline player initialization error: $e');
//     }
//   }

// Future<void> _validateSegments() async {
//   final secureStorage = FlutterSecureStorage();

//   if (widget.encryptionKeyPath.isNotEmpty) {
//     final storedKey = await secureStorage.read(key: widget.encryptionKeyPath);

//     if (storedKey == null || storedKey.isEmpty) {
//       throw Exception('Encryption key not found for ${widget.encryptionKeyPath}');
//     }

//     try {
//       // 🛠 Fix: Decode Base64 properly
//       final keyBytes = base64.decode(storedKey);
//       print('Decoded key length: ${keyBytes.length}');
      
//       if (keyBytes.length != 16) {
//         throw Exception('Invalid AES-128 key length');
//       }

//       print('✅ Decryption key loaded successfully!');
//     } catch (e) {
//       throw Exception('❌ Failed to decode encryption key: $e');
//     }
//   }
// }

// Future<String> _generateLocalM3U8Playlist() async {
//   final playlistBuilder = StringBuffer();
//   playlistBuilder.writeln('#EXTM3U');
//   playlistBuilder.writeln('#EXT-X-PLAYLIST-TYPE:VOD');
//   playlistBuilder.writeln('#EXT-X-TARGETDURATION:10');

//   // 🛠 Ensure the local key is used
//   final appDir = await getApplicationDocumentsDirectory();
//   final localKeyPath = '${appDir.path}/downloads/${widget.movieId}/decryption.key';

//   // 🔥 Write key bytes to a file
//   final keyBytes = base64.decode(await FlutterSecureStorage().read(key: widget.encryptionKeyPath) ?? '');
//   final keyFile = File(localKeyPath);
//   await keyFile.writeAsBytes(keyBytes);

// print('Local key path: $localKeyPath');
// print('Key file exists: ${await File(localKeyPath).exists()}');

//   // ✅ Ensure M3U8 references the local key
//   playlistBuilder.writeln('#EXT-X-KEY:METHOD=AES-128,URI="file://$localKeyPath"');

//   // Add video segments
//   for (int i = 0; i < widget.segmentPaths.length; i++) {
//     playlistBuilder.writeln('#EXTINF:10.0,');
//     playlistBuilder.writeln(widget.segmentPaths[i]);  // Keep absolute paths
//   }
//   for (var segment in widget.segmentPaths) {
//   print('Checking segment: $segment');
//   bool exists = await File(segment).exists();
//   print('Exists: $exists');
// }

// //   if (_localPlaylistPath == null) {
// //   print("❌ Playlist path is null!");
// //   throw Exception("Failed to create local playlist");
// // }
//     print('Generated M3U8 Playlist:');
//     // print(await File(_localPlaylistPath!).readAsString());

//   playlistBuilder.writeln('#EXT-X-ENDLIST');
//   return playlistBuilder.toString();
// }


  
// Future<String?> _saveLocalPlaylist(String playlistContent) async {
//   final playlistContent = await _generateLocalM3U8Playlist();
// print("📄 Generated M3U8 Playlist:\n$playlistContent");

//   try {
//     final appDir = await getApplicationDocumentsDirectory();
//     print("📂 App Directory: ${appDir.path}");

//     final downloadsDir = Directory('${appDir.path}/downloads/${widget.movieId}');
//     if (!downloadsDir.existsSync()) {
//       downloadsDir.createSync(recursive: true);
//       print("📂 Created downloads directory: ${downloadsDir.path}");
//     }

//     final playlistFile = File('${downloadsDir.path}/offline_playlist.m3u8');
//     print("📄 Playlist file path: ${playlistFile.path}");

//     await playlistFile.writeAsString(playlistContent);
//     print("✅ Playlist file written successfully");

//     if (await playlistFile.exists()) {
//       return playlistFile.path;
//     } else {
//       throw Exception("Playlist file creation failed");
//     }
//   } catch (e) {
//     print("❌ Error saving playlist: $e");
//     return null;
//   }
// }


//   @override
//   void dispose() {
//     _betterPlayerController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     if (_errorMessage != null) {
//       return Scaffold(
//         appBar: AppBar(title: const Text('Playback Error')),
//         body: Center(
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               const Icon(Icons.error_outline, color: Colors.red, size: 80),
//               const SizedBox(height: 20),
//               Text(
//                 'Unable to play video',
//                 style: Theme.of(context).textTheme.headlineSmall,
//               ),
//               const SizedBox(height: 10),
//               Text(
//                 _errorMessage!,
//                 style: Theme.of(context).textTheme.bodyMedium,
//                 textAlign: TextAlign.center,
//               ),
//               const SizedBox(height: 20),
//               ElevatedButton(
//                 onPressed: () => Navigator.of(context).pop(),
//                 child: const Text('Go Back'),
//               )
//             ],
//           ),
//         ),
//       );
//     }

//     if (!_isInitialized) {
//       return const Scaffold(
//         body: Center(
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               CircularProgressIndicator(),
//               SizedBox(height: 20),
//               Text('Preparing video...'),
//             ],
//           ),
//         ),
//       );
//     }

//     return Scaffold(
//       appBar: AppBar(title: const Text('Offline Video')),
//       body: AspectRatio(
//         aspectRatio: 16 / 9,
//         child: Container(
//           color: Colors.black,
//           child: BetterPlayer(controller: _betterPlayerController),
//         ),
//       ),
//     );
//   }
// }


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
    print("Access token in download player: ${widget.auth}");
    _initializeOfflinePlayer();
  }

  Future<void> _initializeOfflinePlayer() async {
    try {
      // Check if content is encrypted
      _isEncrypted = widget.encryptionKeyPath.isNotEmpty && widget.encryptionKeyPath != "none";
      print("Content is ${_isEncrypted ? 'encrypted' : 'not encrypted'}");
      
      // Validate segments exist
      if (!await _validateSegments()) {
        throw Exception('One or more segments are missing');
      }

      // For encrypted content, try to prepare the key
      if (_isEncrypted) {
        final keyPath = await _prepareEncryptionKey();
        if (keyPath == null) {
          print("⚠️ Warning: Could not prepare encryption key, content might not play correctly if it is encrypted");
        }
      }

      // Use a direct approach with the first segment for testing
      if (widget.segmentPaths.isNotEmpty) {
        print("📂 Using direct segment playback with first segment: ${widget.segmentPaths[0]}");
        
        // Try directly with the first segment - this is a fallback test
        _betterPlayerController = BetterPlayerController(
          BetterPlayerConfiguration(
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
      print('Offline player initialization error: $e');
    }
  }

  Future<String?> _prepareEncryptionKey() async {
    try {
      // Skip if not encrypted
      if (!_isEncrypted) return null;
      
      // Get the key from secure storage
      final storedKey = await secureStorage.read(key: widget.encryptionKeyPath);
      
      if (storedKey == null || storedKey.isEmpty) {
        print('❌ Encryption key not found in secure storage for ${widget.encryptionKeyPath}');
        return null;
      }

      // Decode the key
      List<int> keyBytes;
      try {
        keyBytes = base64.decode(storedKey);
        print('Decoded key length: ${keyBytes.length} bytes');
        
        if (keyBytes.isEmpty || keyBytes.length != 16) {
          print('❌ Invalid AES-128 key length: ${keyBytes.length} bytes (expected 16)');
          return null;
        }
      } catch (e) {
        print('❌ Failed to decode key: $e');
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
        print('❌ Key file creation failed');
        return null;
      }
      
      final keySize = await keyFile.length();
      if (keySize == 0) {
        print('❌ Key file is empty');
        return null;
      }
      
      print('✅ Key written to ${keyFile.path} (size: $keySize bytes)');
      return keyFile.path;
    } catch (e) {
      print('❌ Error preparing key: $e');
      return null;
    }
  }

  Future<bool> _validateSegments() async {
    for (var segmentPath in widget.segmentPaths) {
      final segmentFile = File(segmentPath);
      print('Checking segment: $segmentPath');
      
      if (!await segmentFile.exists()) {
        print('❌ Segment not found: $segmentPath');
        return false;
      }
      
      final size = await segmentFile.length();
      if (size == 0) {
        print('❌ Segment is empty: $segmentPath');
        return false;
      }
      
      print('✅ Segment exists with size: $size bytes');
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