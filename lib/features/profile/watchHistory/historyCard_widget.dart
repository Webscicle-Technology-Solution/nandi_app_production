// import 'package:flutter/material.dart';
// import 'package:nandiott_flutter/app/widgets/SkeltonLoader/filmSkelton.dart';
// import 'package:nandiott_flutter/features/home/provider/getContiuneMedia.dart';
// import 'package:nandiott_flutter/features/profile/watchHistory/watchHistory_provider.dart';
// import 'package:nandiott_flutter/pages/detail_page.dart';
// import 'package:nandiott_flutter/providers/checkauth_provider.dart';
// import 'package:nandiott_flutter/providers/detail_provider.dart';
// import 'package:nandiott_flutter/providers/series_watchhistory_provider.dart';
// import 'package:nandiott_flutter/services/getBannerPoster_service.dart';
// import 'package:nandiott_flutter/utils/Device_size.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';

// class HistorycardWidget extends ConsumerStatefulWidget {
//   final WatchHistoryItem historyItem;
//   final FocusNode? focusNode;
//   final VoidCallback? onFocused;

//   const HistorycardWidget({
//     Key? key,
//     required this.historyItem,
//     this.focusNode,
//     this.onFocused,
//   }) : super(key: key);

//   @override
//   _HistorycardWidgetState createState() => _HistorycardWidgetState();
// }

// class _HistorycardWidgetState extends ConsumerState<HistorycardWidget> {
//   final _getBannerPosterService = getBannerPosterService();
//   late FocusNode _focusNode;
//   String imgUrl = "";
//   double progress = 0.0;
//   double duration = 0.0;

//   Future<void> getPosterImage() async {
//     final Map<String, String> mediaTypeMapbanner = {
//       'videosong': 'videosong',
//       'shortfilm': 'shortfilm',
//       'documentary': 'documentary',
//       'episodes': 'episode',
//       'movie': 'movie',
//       'tvseries': 'tvseries',
//       'VideoSong': 'videosong',
//       'ShortFilm': 'shortfilm',
//       'Documentary': 'documentary',
//       'Movie': 'movie',
//       'TVSeries': 'tvseries',
//     };

//     final transformedMediaTypebanner =
//         mediaTypeMapbanner[widget.historyItem.contentType] ?? "movie";

//     final response = await _getBannerPosterService.getPoster(
//       mediaType: transformedMediaTypebanner,
//       mediaId: widget.historyItem.tvSeriesId ?? widget.historyItem.contentId,
//     );

//     if (response != null && response['success']) {
//       if (mounted) {
//         setState(() {
//           imgUrl = response['contentUrl'];
//         });
//       }
//     } else {
//       if (mounted) {
//         setState(() {
//           imgUrl = "";
//         });
//       }
//     }
//   }

//   @override
//   void initState() {
//     super.initState();
//     _focusNode = widget.focusNode ?? FocusNode();
//     getPosterImage();
//   }

//   @override
//   void dispose() {
//     // Only dispose the focus node if we created it internally
//     if (widget.focusNode == null) {
//       _focusNode.dispose();
//     }
//     super.dispose();
//   }

//   @override
//   void didUpdateWidget(covariant HistorycardWidget oldWidget) {
//     super.didUpdateWidget(oldWidget);

//     if (oldWidget.historyItem.contentType != widget.historyItem.contentType ||
//         oldWidget.historyItem.contentId != widget.historyItem.contentId) {
//       setState(() {
//         imgUrl = "";
//         progress = 0.0;
//       });
//       getPosterImage();
//     }

//     // Update focus node if it changed
//     if (widget.focusNode != null && widget.focusNode != _focusNode) {
//       _focusNode = widget.focusNode!;
//     }
//   }

//   @override
//   void didChangeDependencies() {
//     super.didChangeDependencies();
//     Future.microtask(() => ref.invalidate(continueWatchingProvider));
//     Future.microtask(() => ref.invalidate(watchHistoryProvider));
//     Future.microtask(() => ref.invalidate(movieDetailProvider));
//     Future.microtask(() => ref.invalidate(tvSeriesWatchProgressProvider));
//   }

//   bool isTVSeriesContent() {
//     final contentType = widget.historyItem.contentType.toLowerCase();
//     return contentType == 'tvseries' || contentType == 'episodes';
//   }

//   @override
//   Widget build(BuildContext context) {
//     final isTV = AppSizes.getDeviceType(context) == DeviceType.tv;
//     final userAsync = ref.watch(authUserProvider);

//     // Standard movie detail provider
//     final movieDetailAsync = ref.watch(movieDetailProvider(MovieDetailParameter(
//       movieId: widget.historyItem.tvSeriesId ?? widget.historyItem.contentId,
//       mediaType: widget.historyItem.contentType,
//     )));

//     // TV series watch progress provider - only use when we have both IDs
//     final tvWatchProgressAsync =
//         isTVSeriesContent() && widget.historyItem.tvSeriesId != null
//             ? ref.watch(tvSeriesWatchProgressProvider((
//                 seriesId: widget.historyItem.tvSeriesId!,
//                 episodeId: widget.historyItem.contentId,
//               )))
//             : null;

//     return userAsync.when(
//       data: (user) {
//         final userId = user?.id ?? '';

//         return Focus(
//           focusNode: _focusNode,
//           onFocusChange: (hasFocus) {
//             if (mounted) {
//               setState(() {});
//               if (hasFocus && widget.onFocused != null) {
//                 widget.onFocused!();
//               }
//             }
//           },
//           child: GestureDetector(
//             onTap: () {
//               Navigator.push(
//                 context,
//                 MaterialPageRoute(
//                   builder: (context) => MovieDetailPage(
//                     movieId: widget.historyItem.tvSeriesId ??
//                         widget.historyItem.contentId,
//                     mediaType: widget.historyItem.contentType,
//                     userId: userId,
//                   ),
//                 ),
//               );
//             },
//             child: Container(
//               margin: EdgeInsets.only(right: AppSizes.getCardMargin(context)),
//               width: AppSizes.getFilmCardWidth(context),
//               height: AppSizes.getFilmCardHeight(context),
//               decoration: BoxDecoration(
//                 image: DecorationImage(
//                   image: imgUrl.isEmpty
//                       ? const AssetImage('assets/images/placeholder.png')
//                       : NetworkImage(imgUrl) as ImageProvider,
//                   fit: BoxFit.cover,
//                 ),
//                 borderRadius: BorderRadius.circular(10),
//                 border: isTV && _focusNode.hasFocus
//                     ? Border.all(color: Colors.amber, width: 3.0)
//                     : null,
//               ),
//               child: Container(
//                 decoration: BoxDecoration(
//                   gradient: LinearGradient(
//                     begin: Alignment.bottomCenter,
//                     end: Alignment.topCenter,
//                     colors: [
//                       Colors.black.withOpacity(0.7),
//                       Colors.transparent,
//                     ],
//                   ),
//                   borderRadius: BorderRadius.circular(10),
//                 ),
//                 child: Column(
//                   mainAxisAlignment: MainAxisAlignment.end,
//                   crossAxisAlignment: CrossAxisAlignment.stretch,
//                   children: [
//                     // Title section - Handle different display for TV series
//                     if (isTVSeriesContent() && tvWatchProgressAsync != null)
//                       tvWatchProgressAsync.when(
//                         data: (tvProgress) {
//                           return movieDetailAsync.when(
//                             data: (movieDetail) {
//                               final baseTitle = movieDetail?.title ??
//                                   widget.historyItem.contentId;

//                               // Format title with season and episode info when available
//                               final displayTitle = tvProgress != null
//                                   ? "$baseTitle - S${tvProgress.seasonNumber} E${tvProgress.episodeNumber}"
//                                   : baseTitle;

//                               return Padding(
//                                 padding:
//                                     const EdgeInsets.symmetric(horizontal: 5.0),
//                                 child: Text(
//                                   displayTitle,
//                                   style: TextStyle(
//                                     fontSize:
//                                         AppSizes.getFilmCardFontSize(context),
//                                     fontWeight: FontWeight.w500,
//                                     color: Colors.white,
//                                   ),
//                                   overflow: TextOverflow.ellipsis,
//                                   maxLines: 2,
//                                 ),
//                               );
//                             },
//                             loading: () => const SkeletonLoader(),
//                             error: (error, stackTrace) => const Center(
//                                 child: Text("Failed to load title")),
//                           );
//                         },
//                         loading: () => const SkeletonLoader(),
//                         error: (error, stackTrace) =>
//                             const Center(child: Text("Failed to load TV data")),
//                       )
//                     else
//                       movieDetailAsync.when(
//                         data: (movieDetail) {
//                           final title = movieDetail?.title ??
//                               widget.historyItem.contentId;

//                           return Padding(
//                             padding:
//                                 const EdgeInsets.symmetric(horizontal: 5.0),
//                             child: Text(
//                               title,
//                               style: TextStyle(
//                                 fontSize: AppSizes.getFilmCardFontSize(context),
//                                 fontWeight: FontWeight.w500,
//                                 color: Colors.white,
//                               ),
//                               overflow: TextOverflow.ellipsis,
//                               maxLines: 1,
//                             ),
//                           );
//                         },
//                         loading: () => const SkeletonLoader(),
//                         error: (error, stackTrace) => const Center(
//                             child: Text("Failed to load movie details")),
//                       ),
//                     SizedBox(height: 8),

//                     // Progress section
//                     widget.historyItem.isCompleted
//                         ? Padding(
//                             padding: const EdgeInsets.all(8.0),
//                             child: LinearProgressIndicator(
//                               value: 1.0,
//                               backgroundColor: Colors.grey[300],
//                               valueColor:
//                                   AlwaysStoppedAnimation<Color>(Colors.amber),
//                             ),
//                           )
//                         : isTVSeriesContent() && tvWatchProgressAsync != null
//                             ? tvWatchProgressAsync.when(
//                                 data: (tvProgress) {
//                                   if (tvProgress != null &&
//                                       tvProgress.duration > 0) {
//                                     // Use TV episode duration for TV content
//                                     progress = widget.historyItem.watchTime /
//                                         tvProgress.duration;

//                                     return Padding(
//                                       padding: const EdgeInsets.all(8.0),
//                                       child: LinearProgressIndicator(
//                                         value: progress.clamp(0.0, 1.0),
//                                         backgroundColor: Colors.grey[300],
//                                         valueColor:
//                                             AlwaysStoppedAnimation<Color>(
//                                                 Colors.amber),
//                                       ),
//                                     );
//                                   } else {
//                                     return Padding(
//                                       padding: const EdgeInsets.all(8.0),
//                                       child: LinearProgressIndicator(
//                                         value: 0.0,
//                                         backgroundColor: Colors.grey[300],
//                                         valueColor:
//                                             AlwaysStoppedAnimation<Color>(
//                                                 Colors.amber),
//                                       ),
//                                     );
//                                   }
//                                 },
//                                 loading: () => const SizedBox(),
//                                 error: (error, stackTrace) => Padding(
//                                   padding: const EdgeInsets.all(8.0),
//                                   child: LinearProgressIndicator(
//                                     value: 0.0,
//                                     backgroundColor: Colors.grey[300],
//                                     valueColor: AlwaysStoppedAnimation<Color>(
//                                         Colors.amber),
//                                   ),
//                                 ),
//                               )
//                             : movieDetailAsync.when(
//                                 data: (movieDetail) {
//                                   // Ensure we have movie details and duration
//                                   if (movieDetail != null &&
//                                       movieDetail.duration != null) {
//                                     duration = movieDetail.duration!;
//                                     // Calculate progress
//                                     progress =
//                                         widget.historyItem.watchTime / duration;

//                                     return Padding(
//                                       padding: const EdgeInsets.all(8.0),
//                                       child: LinearProgressIndicator(
//                                         value: progress.clamp(0.0, 1.0),
//                                         backgroundColor: Colors.grey[300],
//                                         valueColor:
//                                             AlwaysStoppedAnimation<Color>(
//                                                 Colors.amber),
//                                       ),
//                                     );
//                                   } else {
//                                     return Padding(
//                                       padding: const EdgeInsets.all(8.0),
//                                       child: LinearProgressIndicator(
//                                         value: 0.0,
//                                         backgroundColor: Colors.grey[300],
//                                         valueColor:
//                                             AlwaysStoppedAnimation<Color>(
//                                                 Colors.amber),
//                                       ),
//                                     );
//                                   }
//                                 },
//                                 loading: () => const SizedBox(),
//                                 error: (error, stackTrace) => const Center(
//                                     child: Text("Failed to load progress")),
//                               ),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//         );
//       },
//       loading: () => const Center(child: SkeletonLoader()),
//       error: (error, stackTrace) =>
//           const Center(child: Text("Failed to load user")),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nandiott_flutter/app/widgets/SkeltonLoader/filmSkelton.dart';
import 'package:nandiott_flutter/features/home/provider/getContiuneMedia.dart';
import 'package:nandiott_flutter/features/profile/watchHistory/watchHistory_provider.dart';
import 'package:nandiott_flutter/pages/detail_page.dart';
import 'package:nandiott_flutter/providers/checkauth_provider.dart';
import 'package:nandiott_flutter/providers/detail_provider.dart';
import 'package:nandiott_flutter/providers/series_watchhistory_provider.dart';
import 'package:nandiott_flutter/services/getBannerPoster_service.dart';
import 'package:nandiott_flutter/utils/Device_size.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HistorycardWidget extends ConsumerStatefulWidget {
  final WatchHistoryItem historyItem;
  final FocusNode? focusNode;
  final VoidCallback? onFocused;
  final bool hasFocus;
  final int index;

  const HistorycardWidget({
    Key? key,
    required this.historyItem,
    this.focusNode,
    this.onFocused,
    this.hasFocus = false,
    this.index = 0,
  }) : super(key: key);

  @override
  _HistorycardWidgetState createState() => _HistorycardWidgetState();
}

class _HistorycardWidgetState extends ConsumerState<HistorycardWidget> {
  final _getBannerPosterService = getBannerPosterService();
  late FocusNode _focusNode;
  bool _isFocused = false;
  String imgUrl = "";
  double progress = 0.0;
  double duration = 0.0;

  Future<void> getPosterImage() async {
    final Map<String, String> mediaTypeMapbanner = {
      'videosong': 'videosong',
      'shortfilm': 'shortfilm',
      'documentary': 'documentary',
      'episodes': 'episode',
      'movie': 'movie',
      'tvseries': 'tvseries',
      'VideoSong': 'videosong',
      'ShortFilm': 'shortfilm',
      'Documentary': 'documentary',
      'Movie': 'movie',
      'TVSeries': 'tvseries',
    };

    final transformedMediaTypebanner =
        mediaTypeMapbanner[widget.historyItem.contentType] ?? "movie";

    final response = await _getBannerPosterService.getPoster(
      mediaType: transformedMediaTypebanner,
      mediaId: widget.historyItem.tvSeriesId ?? widget.historyItem.contentId,
    );

    if (response != null && response['success']) {
      if (mounted) {
        setState(() {
          imgUrl = response['contentUrl'];
        });
      }
    } else {
      if (mounted) {
        setState(() {
          imgUrl = "";
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();
    // Create a unique debug label for this history card
    _focusNode = widget.focusNode ?? 
                 FocusNode(debugLabel: 'history_card_${widget.historyItem.contentType}_${widget.index}');
    
    // Set up focus listener
    _focusNode.addListener(() {
      if (mounted) {
        setState(() {
          _isFocused = _focusNode.hasFocus;
        });
        
        if (_isFocused && widget.onFocused != null) {
          widget.onFocused!();
        }
      }
    });
    
    getPosterImage();
    
    // Request focus if this card should have initial focus
    if (widget.index == 0 && (widget.hasFocus || widget.focusNode != null)) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!_focusNode.hasFocus) {
          print("Auto-focusing history card: ${_focusNode.debugLabel}");
          _focusNode.requestFocus();
        }
      });
    }
  }

  @override
  void dispose() {
    // Only dispose the focus node if we created it internally
    if (widget.focusNode == null) {
      _focusNode.dispose();
    }
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant HistorycardWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.historyItem.contentType != widget.historyItem.contentType ||
        oldWidget.historyItem.contentId != widget.historyItem.contentId) {
      setState(() {
        imgUrl = "";
        progress = 0.0;
      });
      getPosterImage();
    }

    // Update focus state if it changed
    if (oldWidget.hasFocus != widget.hasFocus) {
      setState(() {
        _isFocused = widget.hasFocus;
      });
      
      if (widget.hasFocus && !_focusNode.hasFocus) {
        _focusNode.requestFocus();
      }
    }

    // Update focus node if it changed
    if (widget.focusNode != null && widget.focusNode != _focusNode) {
      _focusNode = widget.focusNode!;
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    Future.microtask(() => ref.invalidate(continueWatchingProvider));
    Future.microtask(() => ref.invalidate(watchHistoryProvider));
    Future.microtask(() => ref.invalidate(movieDetailProvider));
    Future.microtask(() => ref.invalidate(tvSeriesWatchProgressProvider));
  }

  bool isTVSeriesContent() {
    final contentType = widget.historyItem.contentType.toLowerCase();
    return contentType == 'tvseries' || contentType == 'episodes';
  }

  @override
  Widget build(BuildContext context) {
    final isTV = AppSizes.getDeviceType(context) == DeviceType.tv;
    final userAsync = ref.watch(authUserProvider);

    // Standard movie detail provider
    final movieDetailAsync = ref.watch(movieDetailProvider(MovieDetailParameter(
      movieId: widget.historyItem.tvSeriesId ?? widget.historyItem.contentId,
      mediaType: widget.historyItem.contentType,
    )));

    // TV series watch progress provider - only use when we have both IDs
    final tvWatchProgressAsync =
        isTVSeriesContent() && widget.historyItem.tvSeriesId != null
            ? ref.watch(tvSeriesWatchProgressProvider((
                seriesId: widget.historyItem.tvSeriesId!,
                episodeId: widget.historyItem.contentId,
              )))
            : null;

    return userAsync.when(
      data: (user) {
        final userId = user?.id ?? '';

        return Focus(
          focusNode: _focusNode,
          autofocus: widget.index == 0 && widget.hasFocus,
          debugLabel: 'history_card_${widget.historyItem.contentType}_${widget.index}',
          onFocusChange: (hasFocus) {
            if (mounted) {
              setState(() {
                _isFocused = hasFocus;
              });
              if (hasFocus && widget.onFocused != null) {
                widget.onFocused!();
              }
            }
          },
          onKey: isTV ? (FocusNode node, RawKeyEvent event) {
            if (event is RawKeyDownEvent) {
              if (event.logicalKey == LogicalKeyboardKey.select ||
                  event.logicalKey == LogicalKeyboardKey.enter) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MovieDetailPage(
                      movieId: widget.historyItem.tvSeriesId ??
                          widget.historyItem.contentId,
                      mediaType: widget.historyItem.contentType,
                      userId: userId,
                    ),
                  ),
                );
                return KeyEventResult.handled;
              }
            }
            return KeyEventResult.ignored;
          } : null,
          child: GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => MovieDetailPage(
                    movieId: widget.historyItem.tvSeriesId ??
                        widget.historyItem.contentId,
                    mediaType: widget.historyItem.contentType,
                    userId: userId,
                  ),
                ),
              );
            },
            child: Container(
              margin: EdgeInsets.only(right: AppSizes.getCardMargin(context)),
              width: AppSizes.getFilmCardWidth(context),
              height: AppSizes.getFilmCardHeight(context),
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: imgUrl.isEmpty
                      ? const AssetImage('assets/images/placeholder.png')
                      : NetworkImage(imgUrl) as ImageProvider,
                  fit: BoxFit.cover,
                ),
                borderRadius: BorderRadius.circular(10),
                border: isTV && (_isFocused || _focusNode.hasFocus)
                    ? Border.all(color: Colors.amber, width: 3.0)
                    : null,
                boxShadow: isTV && (_isFocused || _focusNode.hasFocus)
                    ? [
                        BoxShadow(
                          color: Colors.amber.withOpacity(0.5),
                          blurRadius: 8,
                          spreadRadius: 2,
                        )
                      ]
                    : null,
              ),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      Colors.black.withOpacity(0.7),
                      Colors.transparent,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Title section - Handle different display for TV series
                    if (isTVSeriesContent() && tvWatchProgressAsync != null)
                      tvWatchProgressAsync.when(
                        data: (tvProgress) {
                          return movieDetailAsync.when(
                            data: (movieDetail) {
                              final baseTitle = movieDetail?.title ??
                                  widget.historyItem.contentId;

                              // Format title with season and episode info when available
                              final displayTitle = tvProgress != null
                                  ? "$baseTitle - S${tvProgress.seasonNumber} E${tvProgress.episodeNumber}"
                                  : baseTitle;

                              return Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 5.0),
                                child: Text(
                                  displayTitle,
                                  style: TextStyle(
                                    fontSize:
                                        AppSizes.getFilmCardFontSize(context),
                                    fontWeight: (_isFocused || _focusNode.hasFocus) ? FontWeight.bold : FontWeight.w500,
                                    color: (_isFocused || _focusNode.hasFocus) ? Colors.amber : Colors.white,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 2,
                                ),
                              );
                            },
                            loading: () => const SkeletonLoader(),
                            error: (error, stackTrace) => const Center(
                                child: Text("Failed to load title")),
                          );
                        },
                        loading: () => const SkeletonLoader(),
                        error: (error, stackTrace) =>
                            const Center(child: Text("Failed to load TV data")),
                      )
                    else
                      movieDetailAsync.when(
                        data: (movieDetail) {
                          final title = movieDetail?.title ??
                              widget.historyItem.contentId;

                          return Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 5.0),
                            child: Text(
                              title,
                              style: TextStyle(
                                fontSize: AppSizes.getFilmCardFontSize(context),
                                fontWeight: (_isFocused || _focusNode.hasFocus) ? FontWeight.bold : FontWeight.w500,
                                color: (_isFocused || _focusNode.hasFocus) ? Colors.amber : Colors.white,
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          );
                        },
                        loading: () => const SkeletonLoader(),
                        error: (error, stackTrace) => const Center(
                            child: Text("Failed to load movie details")),
                      ),
                    SizedBox(height: 8),

                    // Progress section
                    widget.historyItem.isCompleted
                        ? Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: LinearProgressIndicator(
                              value: 1.0,
                              backgroundColor: Colors.grey[300],
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.amber),
                            ),
                          )
                        : isTVSeriesContent() && tvWatchProgressAsync != null
                            ? tvWatchProgressAsync.when(
                                data: (tvProgress) {
                                  if (tvProgress != null &&
                                      tvProgress.duration > 0) {
                                    // Use TV episode duration for TV content
                                    progress = widget.historyItem.watchTime /
                                        tvProgress.duration;

                                    return Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: LinearProgressIndicator(
                                        value: progress.clamp(0.0, 1.0),
                                        backgroundColor: Colors.grey[300],
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                                Colors.amber),
                                      ),
                                    );
                                  } else {
                                    return Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: LinearProgressIndicator(
                                        value: 0.0,
                                        backgroundColor: Colors.grey[300],
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                                Colors.amber),
                                      ),
                                    );
                                  }
                                },
                                loading: () => const SizedBox(),
                                error: (error, stackTrace) => Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: LinearProgressIndicator(
                                    value: 0.0,
                                    backgroundColor: Colors.grey[300],
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.amber),
                                  ),
                                ),
                              )
                            : movieDetailAsync.when(
                                data: (movieDetail) {
                                  // Ensure we have movie details and duration
                                  if (movieDetail != null &&
                                      movieDetail.duration != null) {
                                    duration = movieDetail.duration!;
                                    // Calculate progress
                                    progress =
                                        widget.historyItem.watchTime / duration;

                                    return Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: LinearProgressIndicator(
                                        value: progress.clamp(0.0, 1.0),
                                        backgroundColor: Colors.grey[300],
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                                Colors.amber),
                                      ),
                                    );
                                  } else {
                                    return Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: LinearProgressIndicator(
                                        value: 0.0,
                                        backgroundColor: Colors.grey[300],
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                                Colors.amber),
                                      ),
                                    );
                                  }
                                },
                                loading: () => const SizedBox(),
                                error: (error, stackTrace) => const Center(
                                    child: Text("Failed to load progress")),
                              ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
      loading: () => const Center(child: SkeletonLoader()),
      error: (error, stackTrace) =>
          const Center(child: Text("Failed to load user")),
    );
  }
}