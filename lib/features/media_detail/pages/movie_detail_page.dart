// import 'package:flutter/material.dart';
// import 'package:nandiott_flutter/app/widgets/customappbar.dart';
// import 'package:nandiott_flutter/models/movie_model.dart';
// import 'package:nandiott_flutter/utils/Device_size.dart';

// class MovieDetailPage extends StatefulWidget {
//   final Movie movie;

//   const MovieDetailPage({super.key, required this.movie});

//   @override
//   State<MovieDetailPage> createState() => _MovieDetailPageState();
// }

// class _MovieDetailPageState extends State<MovieDetailPage> {
//   // Focus Nodes
//   late FocusNode _mainFocusNode;
//   late FocusNode _playFocusNode;
//   late FocusNode _bookmarkFocusNode;

//   @override
//   void initState() {
//     super.initState();
//     _mainFocusNode = FocusNode();
//     _playFocusNode = FocusNode();
//     _bookmarkFocusNode = FocusNode();
//   }

//   @override
//   void dispose() {
//     _mainFocusNode.dispose();
//     _playFocusNode.dispose();
//     _bookmarkFocusNode.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final isTV = AppSizes.getDeviceType(context) == DeviceType.tv;

//     return Scaffold(
//       appBar: CustomAppBar(
//         title: widget.movie.title,
//         showBackButton: true,
//       ),
//       body: SingleChildScrollView(
//         child: Padding(
//           padding: EdgeInsets.fromLTRB(
//             AppSizes.getContenetPadding(context) * 2,
//             0,
//             AppSizes.getContenetPadding(context) * 2,
//             AppSizes.getContenetPadding(context),
//           ),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               // Movie Image Container
//               Focus(
//                 focusNode: _mainFocusNode,
//                 onFocusChange: (hasFocus) {
//                   setState(() {});
//                 },
//                 child: Container(
//                   decoration: BoxDecoration(
//                     borderRadius: BorderRadius.circular(isTV ? 20 : 10),
//                     color: Colors.black,
//                     image: DecorationImage(
//                       image: NetworkImage(""),
//                       fit: BoxFit.cover,
//                       opacity: 0.7,
//                     ),
//                   ),
//                   width: isTV ? 1100 : 400,
//                   height: isTV ? 500 : 220,
//                   child: Focus(
//                     focusNode: _playFocusNode,
//                     onFocusChange: (hasFocus) {
//                       setState(() {});
//                     },
//                     child: IconButton(
//                       onPressed: () {},
//                       icon: Icon(
//                         Icons.play_circle_outline,
//                         color: _playFocusNode.hasFocus
//                             ? Colors.amber
//                             : Colors.white,
//                         size: AppSizes.getIconSize(context),
//                       ),
//                     ),
//                   ),
//                 ),
//               ),

//               SizedBox(height: isTV ? 20 : 10),

//               // Continue Watching (Progress bar or indicator)
//               SizedBox(height: isTV ? 20 : 10),

//               // Watch Now and Bookmark Row
//               Row(
//                 children: [
//                   ElevatedButton(
//                     style: ElevatedButton.styleFrom(
//                       padding: EdgeInsets.symmetric(
//                         horizontal: isTV ? 45 : 15,
//                         vertical: isTV ? 20 : 18,
//                       ),
//                     ),
//                     onPressed: () {},
//                     child: Row(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         Icon(Icons.play_circle_outline,
//                             size: AppSizes.getPlayIconSize(context)),
//                         SizedBox(width: isTV ? 15 : 10),
//                         Text(
//                           "Watch Now",
//                           style: TextStyle(
//                               fontSize: AppSizes.getTitleFontSize(context),
//                               fontWeight: FontWeight.bold),
//                         ),
//                       ],
//                     ),
//                   ),
//                   Focus(
//                     focusNode: _bookmarkFocusNode,
//                     onFocusChange: (hasFocus) {
//                       setState(() {});
//                     },
//                     child: IconButton(
//                       icon: Icon(
//                         // widget.movie.isBookmarked
//                         //     ? Icons.bookmark_added
//                         //     : 
//                             Icons.bookmark_add_outlined,
//                         size: AppSizes.getIconSize(context),
//                         color:
//                         //  widget.movie.isBookmarked
//                         //     ? Colors.amber.withOpacity(0.8)
//                         //     : 
//                             Theme.of(context).primaryColorDark,
//                       ),
//                       onPressed: () {
//                         setState(() {
//                           // widget.movie.isBookmarked = !widget.movie.isBookmarked;
//                         });

//                         // Optionally, show a snackbar or other feedback to the user
//                         // final message = widget.movie.isBookmarked
//                         //     ? 'Added to Bookmarks'
//                         //     : 'Removed from Bookmarks';
//                         ScaffoldMessenger.of(context).showSnackBar(
//                           SnackBar(
//                             content: Text(
//                               "message",
//                               style: TextStyle(
//                                   fontSize: AppSizes.getstatusFontSize(context)),
//                             ),
//                           ),
//                         );
//                       },
//                     ),
//                   ),
//                 ],
//               ),

//               SizedBox(height: isTV ? 35 : 20),

//               // Movie Title
//               Text(
//                 widget.movie.title,
//                 style: TextStyle(
//                     fontSize: isTV ? 36 : 24, fontWeight: FontWeight.bold),
//               ),

//               SizedBox(height: isTV ? 20 : 10),

//               // Movie Description
//               Text(
//             widget.movie.description,
//                 style: TextStyle(fontSize: isTV ? 22 : 16),
//               ),

//               SizedBox(height: isTV ? 35 : 20),

//               // Additional metadata section for TV layout
//               if (isTV) _buildTVMetadataSection(context),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   // Additional metadata section specifically for TV layout
//   Widget _buildTVMetadataSection(BuildContext context) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           'Details',
//           style: TextStyle(
//             fontSize: 28,
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//         SizedBox(height: 15),
//         Row(
//           children: [
//             _buildMetadataItem(context, 'Genre', 'Action/Adventure'),
//             SizedBox(width: 30),
//             _buildMetadataItem(context, 'Duration', '2h 15m'),
//             SizedBox(width: 30),
//             _buildMetadataItem(context, 'Year', '2023'),
//           ],
//         ),
//         SizedBox(height: 30),
//         Text(
//           'Synopsis',
//           style: TextStyle(
//             fontSize: 28,
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//         SizedBox(height: 15),
//         Text(
//           'A more detailed description of the movie would go here. This section would include a full synopsis of the plot, information about the cast, director, and other relevant details that might interest viewers.',
//           style: TextStyle(
//             fontSize: 22,
//             height: 1.5,
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildMetadataItem(BuildContext context, String label, String value) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           label,
//           style: TextStyle(
//             fontSize: 20,
//             color: Colors.grey,
//           ),
//         ),
//         SizedBox(height: 5),
//         Text(
//           value,
//           style: TextStyle(
//             fontSize: 22,
//             fontWeight: FontWeight.w500,
//           ),
//         ),
//       ],
//     );
//   }
// }
