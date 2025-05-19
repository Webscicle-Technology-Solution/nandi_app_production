import 'dart:io';

import 'package:flutter/material.dart';
import 'package:nandiott_flutter/utils/Device_size.dart';

class NewDownloadCardWidget extends StatelessWidget {
  final String title;
  final String imageUrl;
  final bool isDownloaded;
  final bool isPaused;
  final ValueNotifier<double> progress;
  final VoidCallback onPlay;
  final VoidCallback onPause;
  final VoidCallback onResume;
  final VoidCallback onDelete;
  final String? localPoster;
  final ValueNotifier<bool> isPausedNotifier;

  const NewDownloadCardWidget({
    required this.title,
    required this.imageUrl,
    required this.isDownloaded,
    required this.isPaused,
    required this.progress,
    required this.onPlay,
    required this.onPause,
    required this.onResume,
    required this.onDelete,
    this.localPoster,
    required this.isPausedNotifier,
  });

  @override
  Widget build(BuildContext context) {
    final isTV = AppSizes.getDeviceType(context) == DeviceType.tv;

    return Container(
      padding: EdgeInsets.all(isTV ? 18.0 : 10.0),
      width: double.infinity,
      height: 110,
      margin: EdgeInsets.symmetric(
        vertical: isTV ? 12.0 : 4.0,
        horizontal: isTV ? 16.0 : 0.0,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(isTV ? 15.0 : 10.0),
        border: isTV && Focus.of(context).hasFocus
            ? Border.all(color: Colors.amber, width: 2.0)
            : null,
      ),
      child: GestureDetector(
        onTap: isDownloaded ? onPlay : null,
        child: Row(
          children: [
            // Thumbnail
            Container(
              margin:
                  EdgeInsets.only(right: AppSizes.getContenetPadding(context)),
              width: 130,
              height: 110,
              decoration: BoxDecoration(
                border: Border.all(color: Theme.of(context).primaryColorDark),
                image: DecorationImage(
                  image: _getImageProvider(),
                  fit: BoxFit.cover,
                  opacity: 0.8,
                ),
                color: Colors.black,
                borderRadius: BorderRadius.circular(isTV ? 15.0 : 10.0),
              ),
              child: isDownloaded
                  ? const SizedBox()
                  : Center(
                      child: ValueListenableBuilder<bool>(
                      valueListenable: isPausedNotifier,
                      builder: (context, paused, _) {
                        return IconButton(
                          icon: Icon(
                            paused ? Icons.play_arrow : Icons.pause,
                            color: Colors.white,
                          ),
                          onPressed: paused ? onResume : onPause,
                        );
                      },
                    )),
            ),

            // Title, status and progress
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(
                    vertical: AppSizes.getContenetPadding(context)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontWeight: FontWeight.normal,
                        fontSize: isTV ? 24 : 14,
                        color: Theme.of(context).primaryColorDark,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                    ),
                    SizedBox(height: isTV ? 16 : 8),
                    if (!isDownloaded)
          ValueListenableBuilder<double>(
            valueListenable: progress,
            builder: (context, value, _) {
              // If progress is 100% (1.0), show "Completing..." instead of "Downloading"
              final status = isPaused ? "Paused" : (value >= 0.99 ? "Completing..." : "Downloading");
              return Text(
                '${(value * 100).toStringAsFixed(0)}% - $status',
                style: TextStyle(
                  fontWeight: FontWeight.w300,
                  fontSize: 9,
                  color: Colors.grey[500],
                ),
              );
            },
          )
                    else
                      Text(
                        'Downloaded',
                        style: TextStyle(
                          fontWeight: FontWeight.w300,
                          fontSize: AppSizes.getstatusFontSize(context),
                          color: Colors.greenAccent,
                        ),
                      ),
                  ],
                ),
              ),
            ),

            // Action buttons (pause/resume/delete/check)
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  onPressed: onDelete,
                  icon: Icon(
                    Icons.delete,
                    color: Colors.red,
                    size: isTV ? 34 : 24,
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  ImageProvider _getImageProvider() {
    try {
      if (localPoster != null && localPoster!.isNotEmpty) {
        final file = File(localPoster!);
        if (file.existsSync()) {
          return FileImage(file);
        }
      }

      if (imageUrl.isNotEmpty) {
        return NetworkImage(imageUrl);
      }
    } catch (_) {
      // Continue to fallback
    }

    return const AssetImage('assets/images/placeholder.png');
  }
}
