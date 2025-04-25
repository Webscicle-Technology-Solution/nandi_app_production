// import 'dart:async';

// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:flutter_secure_storage/flutter_secure_storage.dart';
// import 'package:nandiott_flutter/app/widgets/offline_videoplayer.dart';
// import 'package:nandiott_flutter/features/auth/login_page.dart';
// import 'package:nandiott_flutter/features/videoPlayer/download_service.dart';
// import 'package:nandiott_flutter/features/videoPlayer/test_download%20card.dart';

// class DownloadsPage extends ConsumerStatefulWidget {
//   const DownloadsPage({Key? key}) : super(key: key);

//   @override
//   ConsumerState<DownloadsPage> createState() => _DownloadsPageState();
// }

// class _DownloadsPageState extends ConsumerState<DownloadsPage> {
//   String? accesstoken;
// Timer? _uiRefreshTimer;

//   @override
//   void initState() {
//     super.initState();
//     getAccessToken();

//      _uiRefreshTimer = Timer.periodic(Duration(milliseconds: 500), (_) {
//     if (mounted) {
//       setState(() {
//         // This forces the UI to rebuild
//       });
//     }
//   });
//   }
// //   @override
// // void didChangeDependencies() {
// //     super.didChangeDependencies();
// //     getAccessToken();
// //     ref.invalidate(downloadsProvider);
// //     ref.invalidate(downloadServiceProvider);
// //   }

// @override
// void dispose() {
//   _uiRefreshTimer?.cancel();
//   super.dispose();
// }

//   Future<void> getAccessToken() async {
//     const storage = FlutterSecureStorage();
//     String accessToken = await storage.read(key: 'accessToken') ?? "";

//     if (accessToken.isNotEmpty && mounted) {
//       setState(() {
//         accesstoken = accessToken;
//       });
//       // ref.invalidate(downloadsProvider);
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final downloads = ref.watch(downloadsProvider);
//     final downloadService = ref.watch(downloadServiceProvider);

//     final bool isLoggedIn = accesstoken != null && accesstoken!.isNotEmpty;

//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Downloads'),
//         // actions: [
//         //   IconButton(
//         //     icon: const Icon(Icons.refresh),
//         //     onPressed: () {
//         //       ref.invalidate(downloadsProvider);
//         //     },
//         //     tooltip: 'Refresh downloads',
//         //   ),
//         // ],
//       ),
//       body: !isLoggedIn
//           ? Center(
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   Text(
//                     'Please login to\nsee your downloads',
//                     style: TextStyle(color: Colors.grey[600], fontSize: 18),
//                     textAlign: TextAlign.center,
//                   ),
//                   const SizedBox(height: 20),
//                   ElevatedButton(
//                     onPressed: () async {
//                       final navigator = await Navigator.push(
//                         context,
//                         MaterialPageRoute(builder: (context) => LoginPage()),
//                       );
//                       if (navigator == true) {
//                         getAccessToken(); // Refresh access token locally
//                         ref.invalidate(downloadsProvider);
//                       }
//                     },
//                     child: const Text('Login'),
//                   ),
//                 ],
//               ),
//             )
//           : downloads.isEmpty
//               ? Center(
//                   child: Column(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       Icon(Icons.download_done,
//                           size: 100, color: Colors.grey[400]),
//                       const SizedBox(height: 20),
//                       Text(
//                         'No downloads yet',
//                         style: TextStyle(color: Colors.grey[600], fontSize: 18),
//                       ),
//                     ],
//                   ),
//                 )
//               : ListView.builder(
//                   itemCount: downloads.length,
//                   itemBuilder: (context, index) {
//                     final download = downloads[index];
//                     bool isComplete = download.progress?.value == 1.0 && download.segmentPaths.isNotEmpty;
                    
//                     return NewDownloadCardWidget(
//                       isPausedNotifier: download.isPausedNotifier,
//                       title: download.title,
//                       imageUrl: download.posterUrl,
//                       localPoster: download.localPosterPath,
//                       // isDownloaded: !download.isInProgress &&
//                       //     download.segmentPaths.isNotEmpty,
//                       isDownloaded: isComplete || (!download.isInProgress && download.segmentPaths.isNotEmpty),
//                       progress: download.progress ?? ValueNotifier<double>(0.0),
//                       isPaused: download.isInProgress &&
//                           !downloadService.isDownloading(download.movieId),
//                       onPlay: () async {
//                         if (!download.isInProgress &&
//                             download.segmentPaths.isNotEmpty) {
//                           Navigator.push(
//                             context,
//                             MaterialPageRoute(
//                               builder: (context) => OfflineVideoPlayer(
//                                 movieId: download.movieId,
//                                 segmentPaths: download.segmentPaths,
//                                 encryptionKeyPath: download.encryptionKeyPath,
//                                 auth: accesstoken,
//                               ),
//                             ),
//                           );
//                         } else if (download.isInProgress) {
//                           ScaffoldMessenger.of(context).showSnackBar(
//                           const SnackBar(
//                                 content: Text(
//                                     'Download in progress. Please wait or resume to complete.')),
//                           );
//                         }
//                       },
//                       onDelete: () async {
//                         await downloadService.deleteDownload(
//                             download.movieId, context);
//                         ref.invalidate(downloadsProvider);
//                       },
//                       onPause: () {
//                         download.isPausedNotifier.value = true; // when paused
//                         if (download.isInProgress &&
//                             downloadService.isDownloading(download.movieId)) {
//                           downloadService.pauseDownload(
//                               download.movieId, context);
//                         } else {
//                           ScaffoldMessenger.of(context).showSnackBar(
//                             SnackBar(
//                                 content: Text(
//                                     'Download already paused or completed')),
//                           );
//                         }
//                       },
//                       onResume: () {
//                         download.isPausedNotifier.value = false; // when resumed
//                         if (download.isInProgress &&
//                             !downloadService.isDownloading(download.movieId)) {
//                           downloadService.resumeDownload(download, context);
//                         } else {
//                           ScaffoldMessenger.of(context).showSnackBar(
//                             SnackBar(
//                               content: Text(downloadService
//                                       .isDownloading(download.movieId)
//                                   ? 'Download already in progress'
//                                   : 'Download already complete'),
//                             ),
//                           );
//                         }
//                       },
//                     );
//                   },
//                 ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: () {
//           // Example of how to trigger a download
//           downloadService.startDownload(
//               masterM3U8Url:
//                   'https://demoapinandi.webscicle.com/v1/drm/getmasterplaylist/movies/67b6a54593d713efae61d103/trailer',
//               movieId: '67b6a54593d713efae61d103',
//               title: 'Manjumal boys',
//               posterUrl: 'https://c8.alamy.com/comp/F762XE/film-movie-poster-of-titanic-F762XE.jpg',
//               context: context);
//         },
//         child: const Icon(Icons.download),
//       ),
//     );
//   }
// }

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:nandiott_flutter/app/widgets/offline_videoplayer.dart';
import 'package:nandiott_flutter/features/auth/login_page.dart';
import 'package:nandiott_flutter/features/auth/loginpage_tv.dart';
import 'package:nandiott_flutter/features/videoPlayer/download_service.dart';
import 'package:nandiott_flutter/features/videoPlayer/test_download%20card.dart';

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
                        print("Resulotion = ${download.resolution}");
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
