// import 'package:better_player_plus/better_player_plus.dart';
// import 'package:flutter/material.dart';

// class CustomBetterPlayerFullControls extends StatefulWidget {
//   final BetterPlayerController controller;
//   final Function(bool) onControlsVisibilityChanged;

//   const CustomBetterPlayerFullControls({
//     Key? key,
//     required this.controller,
//     required this.onControlsVisibilityChanged,
//   }) : super(key: key);

//   @override
//   State<CustomBetterPlayerFullControls> createState() =>
//       _CustomBetterPlayerFullControlsState();
// }

// class _CustomBetterPlayerFullControlsState
//     extends State<CustomBetterPlayerFullControls> {
//   bool _hideControls = false;

//   @override
//   void initState() {
//     super.initState();
//     widget.controller.addEventsListener((event) {
//       if (event.betterPlayerEventType == BetterPlayerEventType.controlsVisible) {
//         setState(() {
//           _hideControls = false;
//         });
//         widget.onControlsVisibilityChanged(false);  // Controls visible
//       } else if (event.betterPlayerEventType == BetterPlayerEventType.controlsHiddenEnd) {
//         setState(() {
//           _hideControls = true;
//         });
//         widget.onControlsVisibilityChanged(true);  // Controls hidden
//       }
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     if (_hideControls) return const SizedBox();

//     return Stack(
//       children: [
//         // Center Controls
//         Align(
//           alignment: Alignment.center,
//           child: Row(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               _focusButton(icon: Icons.replay_10, onPressed: _skipBackward),
//               const SizedBox(width: 20),
//               _focusButton(
//                 icon: widget.controller.isPlaying()! ? Icons.pause : Icons.play_arrow,
//                 onPressed: _togglePlayPause,
//               ),
//               const SizedBox(width: 20),
//               _focusButton(icon: Icons.forward_10, onPressed: _skipForward),
//             ],
//           ),
//         ),

//         // Bottom Controls
//         Align(
//           alignment: Alignment.bottomCenter,
//           child: Padding(
//             padding: const EdgeInsets.only(bottom: 12),
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//               children: [
//                 _focusButton(icon: Icons.volume_up, onPressed: _toggleMute),
//                 _seekBar(),
//                 _focusButton(icon: Icons.settings, onPressed: _openSettings),
//                 _focusButton(icon: Icons.fullscreen, onPressed: _toggleFullscreen),
//               ],
//             ),
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _focusButton({required IconData icon, required VoidCallback onPressed}) {
//     return FocusableActionDetector(
//       child: Builder(
//         builder: (context) {
//           final isFocused = Focus.of(context).hasFocus;
//           return AnimatedContainer(
//             duration: const Duration(milliseconds: 150),
//             padding: const EdgeInsets.all(6),
//             decoration: BoxDecoration(
//               shape: BoxShape.circle,
//               border: isFocused
//                   ? Border.all(color: Colors.amberAccent, width: 3)
//                   : null,
//               color: Colors.black45,
//             ),
//             child: IconButton(
//               icon: Icon(icon, color: Colors.white),
//               onPressed: onPressed,
//             ),
//           );
//         },
//       ),
//     );
//   }

//   Widget _seekBar() {
//     final controller = widget.controller.videoPlayerController;
//     final duration = controller?.value.duration ?? Duration.zero;
//     final position = controller?.value.position ?? Duration.zero;

//     return Expanded(
//       child: FocusableActionDetector(
//         child: Builder(
//           builder: (context) {
//             final isFocused = Focus.of(context).hasFocus;
//             return SliderTheme(
//               data: SliderTheme.of(context).copyWith(
//                 trackHeight: 4,
//                 thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
//               ),
//               child: Slider(
//                 activeColor: isFocused ? Colors.amberAccent : Colors.redAccent,
//                 inactiveColor: Colors.white24,
//                 value: position.inSeconds.toDouble().clamp(0, duration.inSeconds.toDouble()),
//                 max: duration.inSeconds.toDouble(),
//                 onChanged: (value) => widget.controller.seekTo(Duration(seconds: value.toInt())),
//               ),
//             );
//           },
//         ),
//       ),
//     );
//   }

//   void _togglePlayPause() {
//     if (widget.controller.isPlaying()!) {
//       widget.controller.pause();
//     } else {
//       widget.controller.play();
//     }
//   }

//   void _toggleMute() {
//     widget.controller.setVolume(widget.controller.videoPlayerController!.value.volume > 0 ? 0 : 1);
//   }

//   void _toggleFullscreen() {
//     widget.controller.toggleFullScreen();
//   }

//   void _openSettings() {
//     // You can build a settings overlay with quality/subtitle options
//   }

//   void _skipForward() {
//     final current = widget.controller.videoPlayerController!.value.position;
//     widget.controller.seekTo(current + const Duration(seconds: 10));
//   }

//   void _skipBackward() {
//     final current = widget.controller.videoPlayerController!.value.position;
//     widget.controller.seekTo(current - const Duration(seconds: 10));
//   }
// }
