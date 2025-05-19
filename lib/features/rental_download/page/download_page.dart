import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:nandiott_flutter/features/rental_download/widget/offline_videoplayer.dart';
import 'package:nandiott_flutter/features/auth/page/loginpage_tv.dart';
import 'package:nandiott_flutter/features/rental_download/provider/download_service.dart';
import 'package:nandiott_flutter/features/rental_download/widget/download_card_widget.dart';

class DownloadsPage extends ConsumerStatefulWidget {
  const DownloadsPage({Key? key}) : super(key: key);

  @override
  ConsumerState<DownloadsPage> createState() => _DownloadsPageState();
}

class _DownloadsPageState extends ConsumerState<DownloadsPage> {
  String? accesstoken;
  Timer? _uiRefreshTimer;

  @override
  void initState() {
    super.initState();
    getAccessToken();

    _uiRefreshTimer = Timer.periodic(Duration(milliseconds: 500), (_) {
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _uiRefreshTimer?.cancel();
    super.dispose();
  }

  Future<void> getAccessToken() async {
    const storage = FlutterSecureStorage();
    String accessToken = await storage.read(key: 'accessToken') ?? "";

    if (accessToken.isNotEmpty && mounted) {
      setState(() {
        accesstoken = accessToken;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final downloads = ref.watch(downloadsProvider);
    final downloadService = ref.watch(downloadServiceProvider);
    final bool isLoggedIn = accesstoken != null && accesstoken!.isNotEmpty;

    final queuedDownloads = downloads.where((d) =>
        d.progress?.value != 1.0 || d.isInProgress).toList();

    final completedDownloads = downloads.where((d) =>
        d.progress?.value == 1.0 && d.segmentPaths.isNotEmpty).toList();

    return Scaffold(
      
      body: !isLoggedIn
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Please login to\nsee your downloads',
                    style: TextStyle(color: Colors.grey[600], fontSize: 18),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () async {
                      final navigator = await Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => LoginScreen()),
                      );
                      if (navigator == true) {
                        getAccessToken();
                        ref.invalidate(downloadsProvider);
                      }
                    },
                    child: const Text('Login'),
                  ),
                ],
              ),
            )
          : downloads.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.download_done,
                          size: 100, color: Colors.grey[400]),
                      const SizedBox(height: 20),
                      Text(
                        'No downloads yet',
                        style: TextStyle(color: Colors.grey[600], fontSize: 18),
                      ),
                    ],
                  ),
                )
              : ListView(
                  padding: const EdgeInsets.all(12),
                  children: [
                    if (queuedDownloads.isNotEmpty) ...[
                      Text("Queue",
                          style: Theme.of(context).textTheme.headlineSmall),
                      const SizedBox(height: 8),
                      ...queuedDownloads.map((download) {
                        return buildDownloadCard(download, downloadService);
                      }
                         ),
                      const SizedBox(height: 20),
                    ],
                    if (completedDownloads.isNotEmpty) ...[
                      Text("Downloaded",
                          style: Theme.of(context).textTheme.headlineSmall),
                      const SizedBox(height: 8),
                      ...completedDownloads.map((download) =>
                          buildDownloadCard(download, downloadService)),
                    ],
                  ],
                ),
      // floatingActionButton: FloatingActionButton(
      //   onPressed: () {
      //     downloadService.startDownload(
      //         masterM3U8Url:
      //             'https://api.nandipictures.in/v1/drm/getmasterplaylist/movies/67ff8d2e7e227a61ed9172b9/trailer',
      //         movieId: '67ff8d2e7e227a61ed9172b9',
      //         title: 'Manjumal boys',
      //         posterUrl:
      //             'https://c8.alamy.com/comp/F762XE/film-movie-poster-of-titanic-F762XE.jpg',
      //         context: context);
      //   },
      //   child: const Icon(Icons.download),
      // ),
    );
  }

  Widget buildDownloadCard(download, downloadService) {
    final isComplete =
        download.progress?.value == 1.0 && download.segmentPaths.isNotEmpty;

    return NewDownloadCardWidget(
      isPausedNotifier: download.isPausedNotifier,
      title: download.title,
      imageUrl: download.posterUrl,
      localPoster: download.localPosterPath,
      isDownloaded: isComplete ||
          (!download.isInProgress && download.segmentPaths.isNotEmpty),
      progress: download.progress ?? ValueNotifier<double>(0.0),
      isPaused: download.isInProgress &&
          !downloadService.isDownloading(download.movieId),
      onPlay: () async {
        if (!download.isInProgress && download.segmentPaths.isNotEmpty) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => OfflineVideoPlayer(
                movieId: download.movieId,
                segmentPaths: download.segmentPaths,
                encryptionKeyPath: download.encryptionKeyPath,
                auth: accesstoken,
              ),
            ),
          );
        } else if (download.isInProgress) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                  'Download in progress. Please wait or resume to complete.'),
            ),
          );
        }
      },
      onDelete: () async {
        await downloadService.deleteDownload(download.movieId, context);
        ref.invalidate(downloadsProvider);
      },
      onPause: () {
        download.isPausedNotifier.value = true;
        if (download.isInProgress &&
            downloadService.isDownloading(download.movieId)) {
          downloadService.pauseDownload(download.movieId, context);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Download already paused or completed')),
          );
        }
      },
      onResume: () {
        download.isPausedNotifier.value = false;
        if (download.isInProgress &&
            !downloadService.isDownloading(download.movieId)) {
          downloadService.resumeDownload(download, context);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(downloadService.isDownloading(download.movieId)
                  ? 'Download already in progress'
                  : 'Download already complete'),
            ),
          );
        }
      },
    );
  }
}
