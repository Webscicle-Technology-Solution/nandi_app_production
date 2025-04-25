// import 'package:flutter/material.dart';
// import 'package:nandiott_flutter/features/rental_download/download_filmcard_widget.dart';
// import 'package:nandiott_flutter/utils/Device_size.dart';

// class DownloadsList extends StatelessWidget {
//   final List<Map<String, dynamic>> downloadItems;
  
//   const DownloadsList({Key? key, required this.downloadItems}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     final isTV = AppSizes.getDeviceType(context) == DeviceType.tv;
    
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Padding(
//           padding: EdgeInsets.only(
//             left: isTV ? 24.0 : 16.0,
//             top: isTV ? 24.0 : 16.0,
//             bottom: isTV ? 16.0 : 8.0,
//           ),
//           child: Text(
//             'Downloads',
//             style: TextStyle(
//               fontSize: isTV ? 28.0 : 20.0,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//         ),
//         Expanded(
//           child: ListView.builder(
//             padding: EdgeInsets.symmetric(
//               horizontal: isTV ? 16.0 : 8.0,
//             ),
//             itemCount: downloadItems.length,
//             itemBuilder: (context, index) {
//               final item = downloadItems[index];
//               return DownloadFilmcardWidget(
//                 title: item['title'],
//                 imageUrl: item['imageUrl'],
//                 isDownloaded: item['isDownloaded'],
//               );
//             },
//           ),
//         ),
//       ],
//     );
//   }
// }

// // Example usage:
// // final downloadItems = [
// //   {'title': 'The Avengers', 'imageUrl': 'https://example.com/avengers.jpg', 'isDownloaded': true},
// //   {'title': 'Black Panther', 'imageUrl': 'https://example.com/blackpanther.jpg', 'isDownloaded': false},
// // ];
// // DownloadsList(downloadItems: downloadItems)