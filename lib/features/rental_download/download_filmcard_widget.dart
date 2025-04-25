import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nandiott_flutter/features/rental_download/download_provider.dart';
import 'package:nandiott_flutter/utils/Device_size.dart';
import 'package:nandiott_flutter/utils/appstyle.dart';

// class DownloadFilmcardWidget extends ConsumerStatefulWidget {
//   // Accepting parameters via constructor for dynamic data
//   final String title;
//   final String imageUrl;
//   final bool isDownloaded;

//   // Adding a constructor to pass the data (title, image, isDownloaded)
//   DownloadFilmcardWidget({
//     super.key,
//     required this.title,
//     required this.imageUrl,
//     required this.isDownloaded,
//   });

//   @override
//   _DownloadFilmcardWidgetState createState() => _DownloadFilmcardWidgetState();
// }

// class _DownloadFilmcardWidgetState extends ConsumerState<DownloadFilmcardWidget> {
//   final downloadProvider = StateNotifierProvider<DownloadNotifier, DownloadStatus>(
//     (ref) => DownloadNotifier(),
//   );
  
//   late FocusNode _mainFocusNode;
//   late FocusNode _playFocusNode;
//   late FocusNode _deleteFocusNode;

//   @override
//   void initState() {
//     super.initState();
//     _mainFocusNode = FocusNode();
//     _playFocusNode = FocusNode();
//     _deleteFocusNode = FocusNode();
//   }

//   @override
//   void dispose() {
//     _mainFocusNode.dispose();
//     _playFocusNode.dispose();
//     _deleteFocusNode.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     // Determine if we're on TV or mobile
//     final isTV = AppSizes.getDeviceType(context) == DeviceType.tv;
    
//     // Watch the download state using Riverpod
//     final downloadStatus = ref.watch(downloadProvider);

//     // Reference to the notifier so we can modify the state
//     final downloadNotifier = ref.read(downloadProvider.notifier);

//     // Calculate responsive sizes
//     // final iconSize = isTV ? 50.0 : 38.0;
//     // final titleFontSize = isTV ? 18.0 : 13.0;
//     // final statusFontSize = isTV ? 16.0 : 12.0;
//     // final contentPadding = isTV ? 16.0 : 8.0;

//     return Focus(
//       focusNode: _mainFocusNode,
//       onFocusChange: (hasFocus) {
//         if (isTV && hasFocus) {
//           setState(() {});
//         }
//       },
//       child: Container(
//         width: double.infinity,
//         height: AppSizes.getCardHeight(context),
//         margin: EdgeInsets.symmetric(vertical: isTV ? 12.0 : 4.0, horizontal: isTV ? 16.0 : 0.0),
//         decoration: BoxDecoration(
//           borderRadius: BorderRadius.circular(isTV ? 15.0 : 10.0),
//           border: isTV && _mainFocusNode.hasFocus 
//               ? Border.all(color: Colors.amber, width: 2.0)
//               : null,
//         ),
//         child: Row(
//           mainAxisAlignment: MainAxisAlignment.start,
//           crossAxisAlignment: CrossAxisAlignment.center,
//           children: [
//             // Thumbnail with play button
//             Container(
//               margin: EdgeInsets.only(right: AppSizes.getContenetPadding(context)),
//               width: AppSizes.getImageWidth(context),
//               height: AppSizes.getImageHeight(context),
//               decoration: BoxDecoration(
//                 border: Border.all(color: Theme.of(context).primaryColorDark),
//                 image: DecorationImage(
//                   image: NetworkImage(widget.imageUrl),
//                   fit: BoxFit.fill,
//                   opacity: 0.8,
//                 ),
//                 color: Colors.black,
//                 borderRadius: BorderRadius.circular(isTV ? 15.0 : 10.0),
//               ),
//               child: Focus(
//                 focusNode: _playFocusNode,
//                 onFocusChange: (hasFocus) {
//                   if (isTV && hasFocus) {
//                     setState(() {});
//                   }
//                 },
//                 child: widget.isDownloaded 
//                   ? IconButton(
//                       onPressed: (){},
//                       icon: Icon(
//                         Icons.play_circle_outline,
//                         color: _playFocusNode.hasFocus ? Colors.amber : Colors.white,
//                         size: AppSizes.getIconSize(context),
//                       ),
//                     )
//                   : IconButton(
//                       onPressed: () {
//                         downloadNotifier.toggleDownload();
//                       },
//                       icon: Icon(
//                         downloadStatus == DownloadStatus.downloading
//                           ? (downloadStatus == DownloadStatus.paused
//                               ? Icons.play_circle_fill
//                               : Icons.pause_circle_filled)
//                           : Icons.play_circle_fill,
//                         color: _playFocusNode.hasFocus ? Colors.amber : Colors.white,
//                         size: AppSizes.getIconSize(context),
//                       ),
//                     ),
//               ),
//             ),
            
//             // Title and status
//             Expanded(
//               child: Padding(
//                 padding: EdgeInsets.symmetric(vertical: AppSizes.getContenetPadding(context)),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     // Title Text with flexible space and ellipsis
//                     Text(
//                       widget.title,
//                       style: TextStyle(
//                         fontWeight: FontWeight.bold, 
//                         fontSize: AppSizes.getTitleFontSize(context),
//                         color: _mainFocusNode.hasFocus && isTV ? Colors.amber : null,
//                       ),
//                       overflow: TextOverflow.ellipsis,
//                       maxLines: 2,
//                     ),
//                     SizedBox(height: isTV ? 16 : 10),
//                     widget.isDownloaded
//                       ? Text(
//                           'Downloaded',
//                           style: TextStyle(
//                             fontWeight: FontWeight.w300, 
//                             fontSize: AppSizes.getstatusFontSize(context)
//                           ),
//                         )
//                       : Text(
//                           downloadStatus == DownloadStatus.downloading
//                             ? (downloadStatus == DownloadStatus.paused
//                                 ? 'Paused'
//                                 : 'Downloading...')
//                             : (downloadStatus == DownloadStatus.completed
//                                 ? 'Downloaded'
//                                 : 'Not Started'),
//                           style: TextStyle(
//                             fontWeight: FontWeight.w300, 
//                             fontSize: AppSizes.getstatusFontSize(context)
//                           ),
//                         ),
//                   ],
//                 ),
//               ),
//             ),
            
//             // Status icon and delete button
//             Padding(
//               padding: EdgeInsets.only(right: AppSizes.getContenetPadding(context)),
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   widget.isDownloaded 
//                     ? Icon(
//                         Icons.check, 
//                         size: isTV ? 30 : 24,
//                       )
//                     : Icon(
//                         Icons.timelapse,
//                         size: isTV ? 30 : 24,
//                       ),
//                   SizedBox(height: isTV ? 16 : 5),
//                   Focus(
//                     focusNode: _deleteFocusNode,
//                     onFocusChange: (hasFocus) {
//                       if (isTV && hasFocus) {
//                         setState(() {});
//                       }
//                     },
//                     child: IconButton(
//                       onPressed: () {
//                         downloadNotifier.deleteDownload();
//                       },
//                       icon: Icon(
//                         Icons.delete, 
//                         color: _deleteFocusNode.hasFocus ? Colors.red : AppStyles.errorColor,
//                         size: isTV ? 34 : 24,
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             )
//           ],
//         ),
//       ),
//     );
//   }
// }

class DownloadCardWidget extends StatelessWidget {
  final String title;
  final String imageUrl;
  final bool isDownloaded;
  final VoidCallback onPlay;
  final VoidCallback onDelete;

  const DownloadCardWidget({
    required this.title,
    required this.imageUrl,
    required this.isDownloaded,
    required this.onPlay,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final isTV = AppSizes.getDeviceType(context) == DeviceType.tv;
    return Container(
      padding: EdgeInsets.all(isTV ? 18.0 : 10.0),
      width: double.infinity,
      height: AppSizes.getCardHeight(context),
      margin: EdgeInsets.symmetric(vertical: isTV ? 12.0 : 4.0, horizontal: isTV ? 16.0 : 0.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(isTV ? 15.0 : 10.0),
        border: isTV && Focus.of(context).hasFocus 
            ? Border.all(color: Colors.amber, width: 2.0)
            : null,
      ),
      child: GestureDetector(
        onTap: isDownloaded? onPlay: null,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Thumbnail with play button
            Container(
              margin: EdgeInsets.only(right: AppSizes.getContenetPadding(context)),
              width: AppSizes.getImageWidth(context),
              height: AppSizes.getImageHeight(context),
              decoration: BoxDecoration(
                border: Border.all(color: Theme.of(context).primaryColorDark),
                image: DecorationImage(
                  image: NetworkImage(imageUrl),
                  fit: BoxFit.fill,
                  opacity: 0.8,
                ),
                color: Colors.black,
                borderRadius: BorderRadius.circular(isTV ? 15.0 : 10.0),
              ),
              child: 
              // Icon(
              //   Icons.play_arrow,)
             isDownloaded? const SizedBox() : IconButton(
                onPressed:  (){
                  
                },
                icon: Icon(
                  Icons.play_circle_outline,
                  color: Colors.white,
                  size: AppSizes.getIconSize(context),
                ),
             )
            ),
            
            // Title and status
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: AppSizes.getContenetPadding(context)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontWeight: FontWeight.bold, 
                        fontSize: isTV ? 24 : 16,
                        color: Colors.white,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                    ),
                    SizedBox(height: isTV ? 16 : 10),
                    Text(
                      isDownloaded ? 'Downloaded' : 'Downloading...',
                      style: TextStyle(
                        fontWeight: FontWeight.w300, 
                        fontSize: AppSizes.getstatusFontSize(context)
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            // Status icon and delete button
            Padding(
              padding: EdgeInsets.only(right: AppSizes.getContenetPadding(context)),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    isDownloaded ? Icons.check : Icons.timelapse,
                    size: isTV ? 30 : 24,
                  ),
                  SizedBox(height: isTV ? 16 : 5),
                  IconButton(
                    onPressed: onDelete,
                    icon: Icon(
                      Icons.delete, 
                      color: Colors.red,
                      size: isTV ? 34 : 24,
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}