import 'dart:async';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:convert';
import 'package:path/path.dart' as path;

class HLSVideoDownloader {
  final Dio dio;
  final FlutterSecureStorage secureStorage;
  final Map<String, bool> _cancelDownloads = {};
  final Set<String> _activeDownloads = {};

  HLSVideoDownloader({
    required this.dio,
    required this.secureStorage,
  });

  void pauseDownload(String movieId) {
    _cancelDownloads[movieId] = true;
    _activeDownloads.remove(movieId); // Remove from active when paused
  }

  bool isDownloading(String movieId) {
    return _activeDownloads.contains(movieId);
  }

  void clearDownload(String movieId) {
    _cancelDownloads.remove(movieId);
    _activeDownloads.remove(movieId);
  }

  Future<DownloadedVideoMetadata> downloadHLSVideo({
    required String masterM3U8Url,
    required String movieId,
    required String title,
    required String posterUrl,
    required String accessToken,
    required ValueNotifier<double> progress,
    int? preferredResolution,
    List<String> downloadedSegmentUrls = const [],
    int totalSegments = 0,
    bool isResume = false,
  }) async {
    // Reset cancel flag in case this is a fresh download
    _cancelDownloads[movieId] = false;
    _activeDownloads.add(movieId);

    print("access token in download page ${accessToken}");

    // Variable to store the local poster path
    String? localPosterPath;

    try {
      // Create and save directory for storing the download
      final localDirectory = await _createDownloadDirectory(movieId);

      // First try to download the poster image
      localPosterPath = await downloadPoster(posterUrl, movieId);
      // If poster download fails, we continue with the video download

      // Save master URL for future resume operations
      final urlFile = File('${localDirectory.path}/master_url.txt');
      await urlFile.writeAsString(masterM3U8Url);

      // Create temp metadata to save in-progress status
      final tempMetadata = DownloadedVideoMetadata(
        movieId: movieId,
        title: title,
        posterUrl: posterUrl,
        localPosterPath: localPosterPath, // Add the local poster path
        resolution: 0, // Will be updated later
        segmentPaths: [],
        downloadDate: DateTime.now(),
        encryptionKeyPath: '',
        progress: progress,
        isInProgress: true,
        downloadedSegmentUrls: downloadedSegmentUrls,
        totalSegments: totalSegments,
      );

      // Save temp metadata immediately to persist the download state
      await _saveMetadata(tempMetadata);

      // 1. Download Master M3U8 File
      final masterResponse = await dio.get(
        masterM3U8Url,
        options: Options(
          headers: {
            'Authorization': 'Bearer $accessToken',
          },
        ),
      );
      final selectedPlaylistUrl = _selectBestResolution(
          masterResponse.data, preferredResolution, masterM3U8Url);

      // Save selected playlist URL for resuming
      final playlistUrlFile = File('${localDirectory.path}/playlist_url.txt');
      await playlistUrlFile.writeAsString(selectedPlaylistUrl);

      // 2. Download Playlist M3U8
      final playlistResponse = await dio.get(
        selectedPlaylistUrl,
        options: Options(
          headers: {
            'Authorization': 'Bearer $accessToken',
          },
        ),
      );
      final playlist = playlistResponse.data;

      // Save playlist for resuming
      final playlistFile = File('${localDirectory.path}/playlist.m3u8');
      await playlistFile.writeAsString(playlist);

      // 3. Extract & Store Encryption Key
      String encryptionKeyPath = '';
      if (isResume &&
          await secureStorage.containsKey(key: "aes_key_$movieId")) {
        encryptionKeyPath = "aes_key_$movieId";
      } else {
        encryptionKeyPath = await _extractAndStoreEncryptionKey(
            playlist, movieId, selectedPlaylistUrl, accessToken);
      }

      // 4. Get Base URL for segments
      final baseUrl = selectedPlaylistUrl.substring(
          0, selectedPlaylistUrl.lastIndexOf('/') + 1);

      // 5. Download Segments
      final segmentUrls = _parseSegments(playlist, baseUrl);

      // Save segment URLs list for resuming
      final segmentUrlsFile = File('${localDirectory.path}/segment_urls.json');
      await segmentUrlsFile.writeAsString(jsonEncode(segmentUrls));

      final segments = <String>[];
      final downloadedUrls =
          List<String>.from(downloadedSegmentUrls); // Track downloaded segments

      int startIndex = downloadedUrls.length; // Start from where we left off

      // If resuming, add existing segments to our list
      if (startIndex > 0) {
        for (int i = 0; i < startIndex; i++) {
          final path = '${localDirectory.path}/segment_$i.ts';
          if (await File(path).exists()) {
            segments.add(path);
          } else {
            // If some segment files are missing, adjust the starting index
            startIndex = i;
            break;
          }
        }
      }

      // Get total segments count
      int totalSegmentCount = segmentUrls.length;

      // Update the total segments in metadata
      tempMetadata.totalSegments = totalSegmentCount;
      await _saveMetadata(tempMetadata);

      // Update progress based on existing segments
      if (totalSegmentCount > 0) {
        progress.value = startIndex / totalSegmentCount;
      }

      // Download segments one by one
      for (int i = startIndex; i < totalSegmentCount; i++) {
        // Check if download should be paused
        if (_cancelDownloads[movieId] == true) {
          _cancelDownloads[movieId] = false; // Reset for next time
          _activeDownloads.remove(movieId);

          // Save current status before pausing
          final pausedMetadata = DownloadedVideoMetadata(
            movieId: movieId,
            title: title,
            posterUrl: posterUrl,
            localPosterPath: localPosterPath, // Add the local poster path
            resolution: _getResolutionFromUrl(selectedPlaylistUrl),
            segmentPaths: segments,
            downloadDate: DateTime.now(),
            encryptionKeyPath: encryptionKeyPath,
            progress: progress,
            isInProgress: true,
            downloadedSegmentUrls: downloadedUrls,
            totalSegments: totalSegmentCount,
          );
          await _saveMetadata(pausedMetadata);

          throw Exception("Download paused by user");
        }

        final segmentPath = '${localDirectory.path}/segment_$i.ts';
        try {
          await dio.download(
            segmentUrls[i],
            segmentPath,
            options: Options(
              headers: {
                'Authorization': 'Bearer $accessToken',
              },
            ),
          );
          segments.add(segmentPath);
          downloadedUrls
              .add(segmentUrls[i]); // Keep track of downloaded segment URLs

          // Update progress consistently based on total segments
          progress.value = (i + 1) / totalSegmentCount;

          // Update metadata periodically to persist download progress
          if (i % 5 == 0 || i == totalSegmentCount - 1) {
            final updatedMetadata = DownloadedVideoMetadata(
              movieId: movieId,
              title: title,
              posterUrl: posterUrl,
              localPosterPath: localPosterPath, // Add the local poster path
              resolution: _getResolutionFromUrl(selectedPlaylistUrl),
              segmentPaths: segments,
              downloadDate: DateTime.now(),
              encryptionKeyPath: encryptionKeyPath,
              progress: progress,
              isInProgress: i <
                  totalSegmentCount - 1, // Still in progress if not at the end
              downloadedSegmentUrls: downloadedUrls,
              totalSegments: totalSegmentCount,
            );
            await _saveMetadata(updatedMetadata);
          }
        } catch (e) {
          print('Error downloading segment $i: $e');

          // Save current progress before failing
          final errorMetadata = DownloadedVideoMetadata(
            movieId: movieId,
            title: title,
            posterUrl: posterUrl,
            localPosterPath: localPosterPath, // Add the local poster path
            resolution: _getResolutionFromUrl(selectedPlaylistUrl),
            segmentPaths: segments,
            downloadDate: DateTime.now(),
            encryptionKeyPath: encryptionKeyPath,
            progress: progress,
            isInProgress: true,
            downloadedSegmentUrls: downloadedUrls,
            totalSegments: totalSegmentCount,
          );
          await _saveMetadata(errorMetadata);

          _activeDownloads.remove(movieId);
          throw Exception('Segment download failed: $e');
        }
      }

      // 6. Save Final Metadata
      progress.value = 1.0; // Set to 100%

      final metadata = DownloadedVideoMetadata(
        movieId: movieId,
        title: title,
        posterUrl: posterUrl,
        localPosterPath: localPosterPath, // Add the local poster path
        resolution: _getResolutionFromUrl(selectedPlaylistUrl),
        segmentPaths: segments,
        downloadDate: DateTime.now(),
        encryptionKeyPath: encryptionKeyPath,
        progress: progress,
        isInProgress: false, // Ensure this is false
        downloadedSegmentUrls: downloadedUrls,
        totalSegments: segmentUrls.length,
      );

      await _saveMetadata(metadata);
      print("Download complete!");
      _activeDownloads.remove(movieId);
      return metadata;
    } catch (e) {
      print('Download error: $e');

      // Don't throw an exception yet - save the current progress first
      final appDir = await getApplicationDocumentsDirectory();
      final metadataFile =
          File('${appDir.path}/downloads/$movieId/metadata.json');

      if (await metadataFile.exists()) {
        try {
          final jsonString = await metadataFile.readAsString();
          final existingMetadata =
              DownloadedVideoMetadata.fromJson(json.decode(jsonString));

          // Update the metadata to mark as in-progress with current segments
          // and preserve the local poster path if available
          final updatedMetadata = DownloadedVideoMetadata(
            movieId: existingMetadata.movieId,
            title: existingMetadata.title,
            posterUrl: existingMetadata.posterUrl,
            localPosterPath:
                localPosterPath ?? existingMetadata.localPosterPath,
            resolution: existingMetadata.resolution,
            segmentPaths: existingMetadata.segmentPaths,
            downloadDate: existingMetadata.downloadDate,
            encryptionKeyPath: existingMetadata.encryptionKeyPath,
            progress: existingMetadata.progress,
            isInProgress: true,
            downloadedSegmentUrls: existingMetadata.downloadedSegmentUrls,
            totalSegments: existingMetadata.totalSegments,
          );

          await _saveMetadata(updatedMetadata);
        } catch (_) {
          // Ignore errors when trying to save partial download state
        }
      }

      _activeDownloads.remove(movieId);

      if (e.toString().contains('401')) {
        throw Exception('Your Token has expired, Please log in again.');
      }
      // Propagate the exception
      throw e;
    } finally {
      _activeDownloads.remove(movieId);
    }
  }


Future<String?> downloadPoster(String posterUrl, String movieId) async {
  try {
    // Create the download directory if it doesn't exist
    final appDir = await getApplicationDocumentsDirectory();
    final movieDir = Directory('${appDir.path}/downloads/$movieId');
    await movieDir.create(recursive: true);
    
    // Define the local file path for the poster
    String fileExtension = '';
    try {
      fileExtension = path.extension(posterUrl);
      if (fileExtension.isEmpty) {
        fileExtension = '.jpg';  // Use default .jpg extension if none found
      }
    } catch (e) {
      fileExtension = '.jpg';
    }

    final posterFileName = 'poster$movieId';
    final localPosterPath = '${movieDir.path}/$posterFileName';
    
    // Download the poster image using the full signed URL
    final response = await dio.get(
      posterUrl,  // Keep the full URL with query parameters
      options: Options(
        responseType: ResponseType.bytes,
        followRedirects: true,
      ),
    );
    
    // Save the poster image to the local file
    final file = File(localPosterPath);
    await file.writeAsBytes(response.data);
    
    print('Poster downloaded successfully: $localPosterPath');
    return localPosterPath;
  } catch (e) {
    print('Error downloading poster: $e');
    return null;
  }
}


// Improved encryption key handling in downloder.dart

Future<String> _extractAndStoreEncryptionKey(String playlist, String movieId,
    String playlistUrl, String accessToken) async {
  final keyMatch =
      RegExp(r'#EXT-X-KEY:METHOD=AES-128,URI="([^"]*)"').firstMatch(playlist);

  if (keyMatch != null) {
    String keyUrl = keyMatch.group(1)!;

    // Convert relative URL to absolute
    if (!keyUrl.startsWith("https")) {
      final baseUrl =
          playlistUrl.substring(0, playlistUrl.lastIndexOf('/') + 1);
      keyUrl = baseUrl + keyUrl;
    }

    try {
      print('🔑 Downloading encryption key from: $keyUrl');
      
      final keyResponse = await dio.get(
        keyUrl,
        options: Options(
          responseType: ResponseType.bytes,
          headers: {
            'Authorization': 'Bearer $accessToken',
          },
        ),
      );
      
      if (keyResponse.statusCode == 200) {
        final keyBytes = keyResponse.data as List<int>;
        
        // Validate key length
        if (keyBytes.isEmpty || keyBytes.length != 16) {
          print('⚠️ Warning: AES-128 key has invalid length: ${keyBytes.length} bytes');
          
          // If API is returning an invalid key, we should handle it
          if (keyBytes.isEmpty) {
            throw Exception('Empty encryption key received from server');
          }
        }
        
        // Encode as base64 and store in secure storage
        String encodedKey = base64Encode(keyBytes);
        
        // Save key to secure storage
        await secureStorage.write(key: "aes_key_$movieId", value: encodedKey);
        print("✅ Encryption key saved (Base64 length: ${encodedKey.length})");
        
        // Write key to a file for immediate use
        await _writeKeyToFile(keyBytes, movieId);
        
        return "aes_key_$movieId";
      } else {
        throw Exception('Failed to download encryption key: HTTP ${keyResponse.statusCode}');
      }
    } catch (e) {
      print('❌ Error downloading encryption key: $e');
      throw Exception('Failed to download encryption key: $e');
    }
  } else {
    print('⚠️ No encryption key found in playlist');
  }
  return '';
}

// New helper method to write the key to a file
Future<void> _writeKeyToFile(List<int> keyBytes, String movieId) async {
  try {
    final appDir = await getApplicationDocumentsDirectory();
    final keyDir = Directory('${appDir.path}/downloads/$movieId');
    
    if (!keyDir.existsSync()) {
      keyDir.createSync(recursive: true);
    }
    
    final keyFile = File('${keyDir.path}/decryption.key');
    await keyFile.writeAsBytes(keyBytes);
    
    final keySize = await keyFile.length();
    print('✅ Key written to file: ${keyFile.path} (size: $keySize bytes)');
  } catch (e) {
    print('❌ Error writing key to file: $e');
  }
}

  String _selectBestResolution(
      String masterPlaylist, int? preferredResolution, String masterUrl) {
    final resolutionMatches =
        RegExp(r'#EXT-X-STREAM-INF:.*?RESOLUTION=(\d+)x(\d+).*?\n(.*)')
            .allMatches(masterPlaylist);
    final resolutions = resolutionMatches.map((match) {
      final width = int.parse(match.group(1)!);
      final height = int.parse(match.group(2)!);
      final url = match.group(3)!;
      final absoluteUrl = url.startsWith("http")
          ? url
          : masterUrl.substring(0, masterUrl.lastIndexOf('/') + 1) + url;
      return {
        'resolution': width * height,
        'url': absoluteUrl,
      };
    }).toList();

    resolutions
        .sort((a, b) => (b['resolution'] as int) - (a['resolution'] as int));

    if (preferredResolution != null) {
      return resolutions.reduce((a, b) =>
          ((a['resolution'] as int) - preferredResolution).abs() <
                  ((b['resolution'] as int) - preferredResolution).abs()
              ? a
              : b)['url'] as String;
    }

    return resolutions.first['url'] as String;
  }

  List<String> _parseSegments(String playlist, String baseUrl) {
    return playlist
        .split('\n')
        .where((line) => line.isNotEmpty && !line.startsWith('#'))
        .map((segment) =>
            segment.startsWith('http') ? segment : '$baseUrl$segment')
        .toList();
  }

  Future<Directory> _createDownloadDirectory(String movieId) async {
    final appDir = await getApplicationDocumentsDirectory();
    final movieDir = Directory('${appDir.path}/downloads/$movieId');
    await movieDir.create(recursive: true);
    return movieDir;
  }

  Future<void> _saveMetadata(DownloadedVideoMetadata metadata) async {
    final appDir = await getApplicationDocumentsDirectory();
    final metadataFile =
        File('${appDir.path}/downloads/${metadata.movieId}/metadata.json');
    await metadataFile.writeAsString(jsonEncode(metadata.toJson()));
  }

  int _getResolutionFromUrl(String url) {
    final resolutionMatch = RegExp(r'(\d+)p').firstMatch(url);
    return resolutionMatch != null ? int.parse(resolutionMatch.group(1)!) : 720;
  }
}

class DownloadedVideoMetadata {
  final String movieId;
  final String title;
  final String posterUrl;
  final String? localPosterPath; // Added field for local poster image path
  final int resolution;
  final List<String> segmentPaths;
  final DateTime downloadDate;
  final String encryptionKeyPath;
  final ValueNotifier<double>? progress;
  final ValueNotifier<bool> isPausedNotifier = ValueNotifier(false);
  final bool isInProgress;
  final List<String> downloadedSegmentUrls;
  int totalSegments; // Made non-final to allow updates during download

  DownloadedVideoMetadata({
    required this.movieId,
    required this.title,
    required this.posterUrl,
    this.localPosterPath,
    required this.resolution,
    required this.segmentPaths,
    required this.downloadDate,
    required this.encryptionKeyPath,
    required this.progress,
    this.isInProgress = false,
    this.downloadedSegmentUrls = const [],
    this.totalSegments = 0,
  });

  Map<String, dynamic> toJson() => {
        'movieId': movieId,
        'title': title,
        'posterUrl': posterUrl,
        'localPosterPath': localPosterPath,
        'resolution': resolution,
        'segmentPaths': segmentPaths,
        'downloadDate': downloadDate.toIso8601String(),
        'encryptionKeyPath': encryptionKeyPath,
        'isInProgress': isInProgress,
        'downloadedSegmentUrls': downloadedSegmentUrls,
        'totalSegments': totalSegments,
      };

  factory DownloadedVideoMetadata.fromJson(Map<String, dynamic> json) =>
      DownloadedVideoMetadata(
        movieId: json['movieId'],
        title: json['title'],
        posterUrl: json['posterUrl'],
        localPosterPath: json['localPosterPath'],
        resolution: json['resolution'],
        segmentPaths: List<String>.from(json['segmentPaths']),
        downloadDate: DateTime.parse(json['downloadDate']),
        encryptionKeyPath: json['encryptionKeyPath'],
        progress: null, // Not deserialized — added during runtime if needed
        isInProgress: json['isInProgress'] ?? false,
        downloadedSegmentUrls: json['downloadedSegmentUrls'] != null
            ? List<String>.from(json['downloadedSegmentUrls'])
            : [],
        totalSegments: json['totalSegments'] ?? 0,
      );
}
