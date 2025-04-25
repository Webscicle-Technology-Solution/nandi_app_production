import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:nandiott_flutter/features/videoPlayer/downloder.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Create a provider for the download service
final downloadServiceProvider = Provider<DownloadService>((ref) {
  return DownloadService(ref);
});

// Provider to expose the list of downloads
final downloadsProvider = StateNotifierProvider<DownloadsNotifier, List<DownloadedVideoMetadata>>((ref) {
  final downloadService = ref.watch(downloadServiceProvider);
  return DownloadsNotifier(downloadService);
});

// State notifier for downloads
class DownloadsNotifier extends StateNotifier<List<DownloadedVideoMetadata>> {
  final DownloadService _downloadService;
  StreamSubscription? _subscription;

  DownloadsNotifier(this._downloadService) : super([]) {
    // Initialize downloads
    _loadDownloads();
    
    // Subscribe to changes
    _subscription = _downloadService.downloadsStream.listen((downloads) {
      state = downloads;
    });
  }

  Future<void> _loadDownloads() async {
    final downloads = await _downloadService.getAllDownloads();
    state = downloads;
  }

  

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}

// Create a provider for tracking download status of specific movie
final movieDownloadStatusProvider = Provider.family<DownloadStatus, String>((ref, movieId) {
  final downloads = ref.watch(downloadsProvider);
  final downloadService = ref.watch(downloadServiceProvider);
  
  final movieDownload = downloads.firstWhere(
    (d) => d.movieId == 'movie_$movieId',
    orElse: () => DownloadedVideoMetadata(
      movieId: '',
      title: '',
      posterUrl: '',
      localPosterPath: '',
      resolution: 0,
      segmentPaths: [],
      downloadDate: DateTime.now(),
      encryptionKeyPath: '',
      progress: null,
      isInProgress: false,
      downloadedSegmentUrls: [],
      totalSegments: 0,
    ),
  );
  
  return DownloadStatus(
    movieId: movieId,
    isDownloaded: movieDownload.movieId.isNotEmpty && 
                !movieDownload.isInProgress && 
                movieDownload.segmentPaths.isNotEmpty,
    isDownloading: movieDownload.movieId.isNotEmpty && 
                  movieDownload.isInProgress && 
                  downloadService.isDownloading('movie_$movieId'),
    isPaused: movieDownload.movieId.isNotEmpty && 
             movieDownload.isInProgress && 
             !downloadService.isDownloading('movie_$movieId'),
    progress: movieDownload.progress,
    download: movieDownload.movieId.isNotEmpty ? movieDownload : null,
  );
});

// Main download service class
class DownloadService {
  final Ref _ref;
  
  DownloadService(this._ref) {
    _initializeDownloader();
  }
  
  late HLSVideoDownloader _downloader;
  final StreamController<List<DownloadedVideoMetadata>> _downloadsController = 
      StreamController<List<DownloadedVideoMetadata>>.broadcast();

  Stream<List<DownloadedVideoMetadata>> get downloadsStream => _downloadsController.stream;
  List<DownloadedVideoMetadata> _downloads = [];
  Timer? _refreshTimer;
  String? _accessToken;

  void _initializeDownloader() {
    _downloader = HLSVideoDownloader(
      dio: Dio(),
      secureStorage: const FlutterSecureStorage(),
    );
    
    _loadAccessToken();
    _loadDownloadedVideos();
    
    // Set up a timer to refresh download progress
    _refreshTimer = Timer.periodic(Duration(seconds: 1), (_) {
      if (_downloads.any((d) => d.isInProgress)) {
        // Update download statuses
        _downloadsController.add(_downloads);
      }
    });
  }
  
  Future<void> _loadAccessToken() async {
    const storage = FlutterSecureStorage();
  
    _accessToken = await storage.read(key: 'accessToken') ?? "";
    
  }
  
  Future<void> _loadDownloadedVideos() async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final downloadsDir = Directory('${appDir.path}/downloads');

      // Check if downloads directory exists
      if (!await downloadsDir.exists()) {
        _downloadsController.add([]);
        return;
      }

      // Find all movie download directories
      final movieDirs = await downloadsDir
          .list()
          .where((entity) => entity is Directory)
          .toList();

      // Load metadata for each movie
      final loadedDownloads = <DownloadedVideoMetadata>[];

      for (var movieDir in movieDirs) {
        final metadataFile = File('${movieDir.path}/metadata.json');

        if (await metadataFile.exists()) {
          try {
            final jsonString = await metadataFile.readAsString();
            final metadata =
                DownloadedVideoMetadata.fromJson(json.decode(jsonString));

            // Create a new progress notifier for resumed downloads
            final progressNotifier = ValueNotifier<double>(metadata.isInProgress
                ? metadata.totalSegments > 0
                    ? metadata.downloadedSegmentUrls.length /
                        metadata.totalSegments
                    : 0.0
                : 1.0);

            final updatedMetadata = DownloadedVideoMetadata(
                movieId: metadata.movieId,
                title: metadata.title,
                posterUrl: metadata.posterUrl,
                resolution: metadata.resolution,
                segmentPaths: metadata.segmentPaths,
                downloadDate: metadata.downloadDate,
                encryptionKeyPath: metadata.encryptionKeyPath,
                progress: progressNotifier,
                isInProgress: metadata.isInProgress,
                downloadedSegmentUrls: metadata.downloadedSegmentUrls,
                totalSegments: metadata.totalSegments,
                localPosterPath: metadata.localPosterPath);

            // For completed downloads, verify all segments still exist
            if (!metadata.isInProgress) {
              final allSegmentsExist =
                  await _validateSegments(metadata.segmentPaths);

              if (allSegmentsExist) {
                loadedDownloads.add(updatedMetadata);
              } else {
                // Clean up incomplete downloads
                await movieDir.delete(recursive: true);
              }
            } else {
              // Add in-progress downloads to the list
              loadedDownloads.add(updatedMetadata);
            }
          } catch (e) {
            print('Error parsing metadata: $e');
            // Skip this download if metadata is corrupted
          }
        }
      }

      // Update downloads list and notify listeners
      _downloads = loadedDownloads;
      _downloadsController.add(_downloads);
    } catch (e) {
      print('Error loading downloads: $e');
    }
  }

  Future<bool> _validateSegments(List<String> segmentPaths) async {
    for (var path in segmentPaths) {
      if (!await File(path).exists()) {
        return false;
      }
    }
    return true;
  }

  Future<void> markDownloadAsComplete(String movieId) async {
  // Format movieId to ensure consistency
  final formattedMovieId = movieId.startsWith('movie_') ? movieId : 'movie_$movieId';
  
  // Find the download in the list
  final index = _downloads.indexWhere((d) => d.movieId == formattedMovieId);
  if (index == -1) return;
  
  // Get the current download
  final download = _downloads[index];
  
  // Create updated metadata with isInProgress set to false
  final updatedMetadata = DownloadedVideoMetadata(
    movieId: download.movieId,
    title: download.title,
    posterUrl: download.posterUrl,
    localPosterPath: download.localPosterPath,
    resolution: download.resolution,
    segmentPaths: download.segmentPaths,
    downloadDate: DateTime.now(),
    encryptionKeyPath: download.encryptionKeyPath,
    progress: ValueNotifier<double>(1.0),
    isInProgress: false, // This is the key change
    downloadedSegmentUrls: download.downloadedSegmentUrls,
    totalSegments: download.totalSegments,
  );
  
  // Update in memory
  _downloads[index] = updatedMetadata;
  
  // Update on disk
  try {
    final appDir = await getApplicationDocumentsDirectory();
    final metadataFile = File('${appDir.path}/downloads/${formattedMovieId}/metadata.json');
    
    if (await metadataFile.exists()) {
      await metadataFile.writeAsString(json.encode(updatedMetadata.toJson()));
    }
  } catch (e) {
    print('Error saving metadata: $e');
  }
  
  // Notify listeners
  _downloadsController.add(List.from(_downloads));
}
  
  /// Start downloading a video
  Future<bool> startDownload({
    required String masterM3U8Url,
    required String movieId,
    required String title,
    required String posterUrl,
    required BuildContext context,
  }) async {
    // Format movieId to ensure consistency
    final formattedMovieId = movieId.startsWith('movie_') ? movieId : 'movie_$movieId';
    
    // Check if download already exists
    final existingDownload = _downloads.firstWhere(
      (d) => d.movieId == formattedMovieId,
      orElse: () => DownloadedVideoMetadata(
        movieId: '',
        title: '',
        posterUrl: '',
        localPosterPath: '',
        resolution: 0,
        segmentPaths: [],
        downloadDate: DateTime.now(),
        encryptionKeyPath: '',
        progress: null,
        isInProgress: false,
        downloadedSegmentUrls: [],
        totalSegments: 0,
      ),
    );

    if (existingDownload.movieId.isNotEmpty) {
      if (existingDownload.isInProgress) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Download already in progress')),
          );
        }
        return false;
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Video already downloaded')),
          );
        }
        return false;
      }
    }

    final progress = ValueNotifier<double>(0.0);

    // Try to download the poster image first
    String? localPosterPath;
    try {
      print("Starting local poster downloaded: $localPosterPath");
      localPosterPath = await _downloader.downloadPoster(posterUrl, formattedMovieId);
      print("local poster downloaded: $localPosterPath");
    } catch (e) {
      print('Poster download failed, continuing with video download: $e');
    }

    final prefs = await SharedPreferences.getInstance();
    final resolution = prefs.getInt('download_quality')??720;

    // Create temporary metadata
    final tempMetadata = DownloadedVideoMetadata(
      movieId: formattedMovieId,
      title: title,
      posterUrl: posterUrl,
      localPosterPath: localPosterPath,
      resolution: resolution, // default resolution
      segmentPaths: [],
      downloadDate: DateTime.now(),
      encryptionKeyPath: '',
      progress: progress,
      isInProgress: true,
      downloadedSegmentUrls: [],
      totalSegments: 0,
    );

    // Add to downloads list and notify
    _downloads.add(tempMetadata);
    _downloadsController.add(_downloads);

    _addProgressListener(tempMetadata);

    // Store the master URL for resumption
    final appDir = await getApplicationDocumentsDirectory();
    final movieDir = Directory('${appDir.path}/downloads/$formattedMovieId');
    await movieDir.create(recursive: true);
    final urlFile = File('${movieDir.path}/master_url.txt');
    await urlFile.writeAsString(masterM3U8Url);

    try {
      // Start actual download
      final metadata = await _downloader.downloadHLSVideo(
        masterM3U8Url: masterM3U8Url,
        movieId: formattedMovieId,
        title: title,
        posterUrl: posterUrl,
        accessToken: _accessToken ?? "",
        progress: progress,
      );

      // Update download in list
      final index = _downloads.indexWhere((d) => d.movieId == formattedMovieId);
      if (index != -1) {
        _downloads[index] = metadata;
        _downloadsController.add(_downloads);
      }
      await markDownloadAsComplete(formattedMovieId);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Download complete: $title')),
        );
      }
      return true;
    } catch (e) {
      if (context.mounted) {
        if (e.toString().contains('paused by user')) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Download started: $title')),
          );
          return true;
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Download failed: $e')),
          );
          return false;
        }
      }
      
      // Refresh downloads list
      await _loadDownloadedVideos();
      return false;
    }
  }

void _setupProgressListener(String movieId, ValueNotifier<double> progress) {
  // Add listener for progress updates
  progress.addListener(() {
    // This will be called whenever the progress changes
    final index = _downloads.indexWhere((d) => d.movieId == movieId);
    if (index != -1) {
      // Force a UI update
      _downloadsController.add(List.from(_downloads));
    }
  });
}

// Add this when starting a download
void _addProgressListener(DownloadedVideoMetadata download) {
  if (download.progress != null) {
    _setupProgressListener(download.movieId, download.progress!);
  }
}

  Future<void> resumeDownload(DownloadedVideoMetadata download, BuildContext context) async {
  final baseUrl = dotenv.env['API_BASE_URL'];

    try {
      // Update download status
      final index = _downloads.indexWhere((d) => d.movieId == download.movieId);
      if (index != -1) {
        final updatedDownload = DownloadedVideoMetadata(
            movieId: download.movieId,
            title: download.title,
            posterUrl: download.posterUrl,
            resolution: download.resolution,
            segmentPaths: download.segmentPaths,
            downloadDate: download.downloadDate,
            encryptionKeyPath: download.encryptionKeyPath,
            progress: download.progress,
            isInProgress: true,
            downloadedSegmentUrls: download.downloadedSegmentUrls,
            totalSegments: download.totalSegments,
            localPosterPath: download.localPosterPath);

        _downloads[index] = updatedDownload;
        _downloadsController.add(_downloads);
_addProgressListener(updatedDownload);

      }
      if (context.mounted) {
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Resuming download: ${download.title}')),
        );
      }

      final appDir = await getApplicationDocumentsDirectory();
      final urlFile = File('${appDir.path}/downloads/${download.movieId}/master_url.txt');

      String masterM3U8Url;
      if (await urlFile.exists()) {
        masterM3U8Url = await urlFile.readAsString();
      } else {
        // Fallback URL formatting 
        masterM3U8Url =
            '$baseUrl/drm/getmasterplaylist/movies/${download.movieId.replaceAll('movie_', '')}';
      }

      final metadata = await _downloader.downloadHLSVideo(
        masterM3U8Url: masterM3U8Url,
        movieId: download.movieId,
        title: download.title,
        posterUrl: download.posterUrl,
        accessToken: _accessToken ?? "",
        progress: download.progress!,
        downloadedSegmentUrls: download.downloadedSegmentUrls,
        totalSegments: download.totalSegments,
        isResume: true,
      );
await markDownloadAsComplete(download.movieId);
      // Update download in list
      final updatedIndex = _downloads.indexWhere((d) => d.movieId == download.movieId);
      if (updatedIndex != -1) {
        _downloads[updatedIndex] = metadata;
        _downloadsController.add(_downloads);
      }
    } catch (e) {
      print('Failed to resume download: $e');

      if (context.mounted) {
        if (e.toString().contains('paused by user')) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Download paused: ${download.title}')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Download failed: $e')),
          );
        }
      }

      // Refresh the list
      await _loadDownloadedVideos();
    }
  }

  void pauseDownload(String movieId, BuildContext context) {
    // Format movieId to ensure consistency
    final formattedMovieId = movieId.startsWith('movie_') ? movieId : 'movie_$movieId';
    
    final download = _downloads.firstWhere(
      (d) => d.movieId == formattedMovieId,
      orElse: () => DownloadedVideoMetadata(
        movieId: '',
        title: '',
        posterUrl: '',
        localPosterPath: '',
        resolution: 0,
        segmentPaths: [],
        downloadDate: DateTime.now(),
        encryptionKeyPath: '',
        progress: null,
        isInProgress: false,
        downloadedSegmentUrls: [],
        totalSegments: 0,
      ),
    );
    
    if (download.movieId.isNotEmpty) {
      _downloader.pauseDownload(formattedMovieId);
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Pausing download: ${download.title}')),
        );
      }
    }
  }

  Future<void> deleteDownload(String movieId, BuildContext context) async {
    // Format movieId to ensure consistency
    final formattedMovieId = movieId.startsWith('movie_') ? movieId : 'movie_$movieId';
    
    final download = _downloads.firstWhere(
      (d) => d.movieId == formattedMovieId,
      orElse: () => DownloadedVideoMetadata(
        movieId: '',
        title: '',
        posterUrl: '',
        localPosterPath: '',
        resolution: 0,
        segmentPaths: [],
        downloadDate: DateTime.now(),
        encryptionKeyPath: '',
        progress: null,
        isInProgress: false,
        downloadedSegmentUrls: [],
        totalSegments: 0,
      ),
    );

    if (download.movieId.isEmpty) return;

    try {
      // Stop the download if it's in progress
      if (download.isInProgress) {
        _downloader.pauseDownload(formattedMovieId);
      }

      // Delete local files
      final appDir = await getApplicationDocumentsDirectory();
      final movieDir = Directory('${appDir.path}/downloads/${formattedMovieId}');

      if (await movieDir.exists()) {
        await movieDir.delete(recursive: true);
      }

      // Clear any in-memory references
      _downloader.clearDownload(formattedMovieId);

      // Remove from downloads list
      _downloads.removeWhere((d) => d.movieId == formattedMovieId);
      _downloadsController.add(_downloads);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${download.title} deleted')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete download: $e')),
        );
      }
    }
  }

  // Helper methods
  bool isDownloading(String movieId) {
    final formattedMovieId = movieId.startsWith('movie_') ? movieId : 'movie_$movieId';
    return _downloader.isDownloading(formattedMovieId);
  }

  bool isDownloaded(String movieId) {
    final formattedMovieId = movieId.startsWith('movie_') ? movieId : 'movie_$movieId';
    final download = _downloads.firstWhere(
      (d) => d.movieId == formattedMovieId,
      orElse: () => DownloadedVideoMetadata(
        movieId: '',
        title: '',
        posterUrl: '',
        localPosterPath: '',
        resolution: 0,
        segmentPaths: [],
        downloadDate: DateTime.now(),
        encryptionKeyPath: '',
        progress: null,
        isInProgress: false,
        downloadedSegmentUrls: [],
        totalSegments: 0,
      ),
    );
    
    return download.movieId.isNotEmpty && 
           !download.isInProgress && 
           download.segmentPaths.isNotEmpty;
  }

  DownloadedVideoMetadata? getDownload(String movieId) {
    final formattedMovieId = movieId.startsWith('movie_') ? movieId : 'movie_$movieId';
    try {
      return _downloads.firstWhere((d) => d.movieId == formattedMovieId);
    } catch (e) {
      return null;
    }
  }

  Future<List<DownloadedVideoMetadata>> getAllDownloads() async {
    await _loadDownloadedVideos();
    return List.from(_downloads);
  }

  void dispose() {
    _refreshTimer?.cancel();
    _downloadsController.close();
  }
}

// Helper class to track download status
class DownloadStatus {
  final String movieId;
  final bool isDownloaded;
  final bool isDownloading;
  final bool isPaused;
  final ValueNotifier<double>? progress;
  final DownloadedVideoMetadata? download;

  DownloadStatus({
    required this.movieId,
    required this.isDownloaded,
    required this.isDownloading,
    required this.isPaused,
    this.progress,
    this.download,
  });
}