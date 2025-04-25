// import 'package:flutter_riverpod/flutter_riverpod.dart';

// // Enum to define the possible states of a download
// enum DownloadStatus { notStarted, downloading, paused, completed }

// // StateNotifier to manage download state
// class DownloadNotifier extends StateNotifier<DownloadStatus> {
//   DownloadNotifier() : super(DownloadStatus.notStarted);

//   // Toggle between download states
//   void toggleDownload() {
//     if (state == DownloadStatus.notStarted || state == DownloadStatus.paused) {
//       state = DownloadStatus.downloading;
//     } else if (state == DownloadStatus.downloading) {
//       state = DownloadStatus.paused;
//     }
//   }

//   // Reset the state to 'notStarted'
//   void deleteDownload() {
//     state = DownloadStatus.notStarted;
//   }

//   // Mark the download as completed
//   void completeDownload() {
//     state = DownloadStatus.completed;
//   }
// }
