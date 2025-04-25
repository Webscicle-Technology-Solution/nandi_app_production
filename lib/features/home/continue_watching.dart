// // Example of how to implement the Continue Watching Section
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:nandiott_flutter/features/profile/watchHistory/historyCard_widget.dart';
// import 'package:nandiott_flutter/features/profile/watchHistory/watchHistory_provider.dart';
// import 'package:nandiott_flutter/utils/Device_size.dart';

// class ContinueWatchingSection extends StatefulWidget {
//   final List<WatchHistoryItem> continueWatchingList;
//   final FocusNode focusNode;
//   final VoidCallback onUpKeyEvent;
//   final VoidCallback onDownKeyEvent;

//   const ContinueWatchingSection({
//     Key? key,
//     required this.continueWatchingList,
//     required this.focusNode,
//     required this.onUpKeyEvent,
//     required this.onDownKeyEvent,
//   }) : super(key: key);

//   @override
//   State<ContinueWatchingSection> createState() =>
//       _ContinueWatchingSectionState();
// }

// class _ContinueWatchingSectionState extends State<ContinueWatchingSection> {
//   int _focusedIndex = 0;
//   final List<FocusNode> _itemFocusNodes = [];

//   @override
//   void initState() {
//     super.initState();
//     _initializeFocusNodes();
//   }

//   void _initializeFocusNodes() {
//     // Clear existing nodes first
//     for (var node in _itemFocusNodes) {
//       node.dispose();
//     }
//     _itemFocusNodes.clear();

//     // Create new nodes for each item
//     for (int i = 0; i < widget.continueWatchingList.length; i++) {
//       _itemFocusNodes.add(FocusNode());
//     }
//   }

//   @override
//   void didUpdateWidget(ContinueWatchingSection oldWidget) {
//     super.didUpdateWidget(oldWidget);
//     if (widget.continueWatchingList.length !=
//         oldWidget.continueWatchingList.length) {
//       _initializeFocusNodes();
//     }
//   }

//   @override
//   void dispose() {
//     for (var node in _itemFocusNodes) {
//       node.dispose();
//     }
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final isTV = AppSizes.getDeviceType(context) == DeviceType.tv;

//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Padding(
//           padding: const EdgeInsets.all(16.0),
//           child: Text(
//             'Continue Watching',
//             style: TextStyle(
//               fontSize: 20,
//               fontWeight: FontWeight.bold,
//               color: Colors.white,
//             ),
//           ),
//         ),
//         SizedBox(
//           height: AppSizes.getFilmCardHeight(context) + 20,
//           child: Focus(
//             focusNode: widget.focusNode,
//             onKey: (FocusNode node, RawKeyEvent event) {
//               if (event is RawKeyDownEvent) {
//                 if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
//                   widget.onUpKeyEvent();
//                   return KeyEventResult.handled;
//                 } else if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
//                   widget.onDownKeyEvent();
//                   return KeyEventResult.handled;
//                 } else if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
//                   if (_focusedIndex > 0) {
//                     setState(() {
//                       _focusedIndex--;
//                       _itemFocusNodes[_focusedIndex].requestFocus();
//                     });
//                     return KeyEventResult.handled;
//                   }
//                 } else if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
//                   if (_focusedIndex < widget.continueWatchingList.length - 1) {
//                     setState(() {
//                       _focusedIndex++;
//                       _itemFocusNodes[_focusedIndex].requestFocus();
//                     });
//                     return KeyEventResult.handled;
//                   }
//                 }
//               }
//               return KeyEventResult.ignored;
//             },
//             child: ListView.builder(
//               scrollDirection: Axis.horizontal,
//               padding: const EdgeInsets.symmetric(horizontal: 16.0),
//               itemCount: widget.continueWatchingList.length,
//               itemBuilder: (context, index) {
//                 return HistorycardWidget(
//                   key: ValueKey(widget.continueWatchingList[index].contentId),
//                   historyItem: widget.continueWatchingList[index],
//                   focusNode: _itemFocusNodes[index],
//                   onFocused: isTV
//                       ? () {
//                           setState(() {
//                             _focusedIndex = index;
//                           });
//                         }
//                       : null,
//                 );
//               },
//             ),
//           ),
//         ),
//       ],
//     );
//   }
// }
