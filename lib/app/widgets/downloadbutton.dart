// First, create a provider specifically for tracking download button state
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nandiott_flutter/features/videoPlayer/download_service.dart';
import 'package:nandiott_flutter/providers/detail_provider.dart';
import 'package:nandiott_flutter/providers/getbanner_poster.dart';

final downloadButtonStateProvider = StateNotifierProvider.family<DownloadButtonStateNotifier, DownloadButtonState, String>(
  (ref, movieId) => DownloadButtonStateNotifier(ref, movieId),
);

// Define a state class for the button
class DownloadButtonState {
  final bool isPreparingDownload;
  final bool isDownloading;
  final bool isDownloaded;
  final bool isPaused;
  
  DownloadButtonState({
    this.isPreparingDownload = false,
    this.isDownloading = false,
    this.isDownloaded = false,
    this.isPaused = false,
  });
  
  DownloadButtonState copyWith({
    bool? isPreparingDownload,
    bool? isDownloading,
    bool? isDownloaded,
    bool? isPaused,
  }) {
    return DownloadButtonState(
      isPreparingDownload: isPreparingDownload ?? this.isPreparingDownload,
      isDownloading: isDownloading ?? this.isDownloading,
      isDownloaded: isDownloaded ?? this.isDownloaded,
      isPaused: isPaused ?? this.isPaused,
    );
  }
}

// Create a state notifier to manage the button state
class DownloadButtonStateNotifier extends StateNotifier<DownloadButtonState> {
  final Ref _ref;
  final String _movieId;
  
  DownloadButtonStateNotifier(this._ref, this._movieId) : super(DownloadButtonState()) {
    // Initialize with current download status
    _updateFromDownloadStatus();
    
    // Listen to download status changes
    _ref.listen(movieDownloadStatusProvider(_movieId), (previous, next) {
      _updateFromDownloadStatus();
    });
  }
  
  void _updateFromDownloadStatus() {
    final downloadStatus = _ref.read(movieDownloadStatusProvider(_movieId));
    
    state = DownloadButtonState(
      isDownloading: downloadStatus.isDownloading,
      isDownloaded: downloadStatus.isDownloaded,
      isPaused: downloadStatus.isPaused,
      isPreparingDownload: state.isPreparingDownload, // Preserve this state
    );
  }
  
  void setPreparingDownload(bool value) {
    state = state.copyWith(isPreparingDownload: value);
  }
  
Future<bool> startDownload({
  required String mediaUrl,
  required String movieId,
  required String title,
  required BuildContext context,
  required String mediaType,
  required String transformedMediaTypebanner,
}) async {
  // Set preparing state
  setPreparingDownload(true);
  
  try {
    // Better approach to get the poster URL
    String posterUrl = "";
    
    // Use a FutureProvider to get the poster
    final posterFuture = _ref.read(PosterProvider(MovieDetailParameter(
      movieId: movieId,
      mediaType: transformedMediaTypebanner,
    )).future);
    
    try {
      posterUrl = await posterFuture ?? "";
    } catch (e) {
      // If poster fetch fails, continue with empty string
      print("Failed to fetch poster: $e");
    }
    
    // Start the download
    final downloadService = _ref.read(downloadServiceProvider);
    final success = await downloadService.startDownload(
      masterM3U8Url: mediaUrl,
      movieId: movieId,
      title: title,
      posterUrl: posterUrl,
      context: context,
    );
    
    // Update state and force refresh
    setPreparingDownload(false);
    _ref.refresh(movieDownloadStatusProvider(movieId));
    
    return success;
  } catch (e) {
    // Handle any errors
    setPreparingDownload(false);
    
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error starting download: ${e.toString()}')),
      );
    }
    return false;
  }
}
}