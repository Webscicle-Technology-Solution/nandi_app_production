  import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
  import 'package:nandiott_flutter/app/widgets/skeltonLoader/filmSkelton.dart';

  import 'package:nandiott_flutter/models/moviedetail_model.dart';
  import 'package:nandiott_flutter/features/movieDetails/page/detail_page.dart';
  import 'package:nandiott_flutter/features/auth/providers/checkauth_provider.dart';
  import 'package:nandiott_flutter/services/getBannerPoster_service.dart';
  import 'package:nandiott_flutter/utils/Device_size.dart';
  import 'package:flutter_riverpod/flutter_riverpod.dart'; // Import Riverpod

  class FavFilmCard extends ConsumerStatefulWidget {
    final MovieDetail film;
    final String mediaType;
     final bool hasFocus;
  final int index;
  final FocusNode? focusNode;
  final VoidCallback? onFocused;
  final bool isLastItem;

    
    const FavFilmCard({super.key, required this.film, required this.mediaType,
        this.hasFocus = false,
    this.index = 0,
    this.focusNode,
    this.onFocused,
    this.isLastItem = false,
    });

    @override
    _FavFilmCardState createState() => _FavFilmCardState();
  }

  class _FavFilmCardState extends ConsumerState<FavFilmCard> {
    final _getBannerPosterService = getBannerPosterService();
      late FocusNode _focusNode;
  bool _isFocused = false;
    String imgUrl = "";

    Future<void> getPosterImage() async {
      final response = await _getBannerPosterService.getPoster(
        mediaType: widget.mediaType,
        mediaId: widget.film.id.toString(),
      );

      if (response != null && response['success']) {
        setState(() {
          imgUrl = response['contentUrl'];
        });
      } else {
        setState(() {
          imgUrl = "";
        });
      }
    }

    @override
    void initState() {
      super.initState();
      // _focusNode = FocusNode();
      _focusNode = widget.focusNode ??
        FocusNode(debugLabel: 'film_card_${widget.mediaType}_${widget.index}');

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
    }

    @override
    void didUpdateWidget(covariant FavFilmCard oldWidget) {
      super.didUpdateWidget(oldWidget);

      if (oldWidget.mediaType != widget.mediaType || oldWidget.film != widget.film) {
        setState(() {
          imgUrl = "";  // Reset the old image
        });
        getPosterImage(); // Fetch the new poster image
      }
      if (oldWidget.hasFocus != widget.hasFocus) {
      setState(() {
        _isFocused = widget.hasFocus;
      });

      if (widget.hasFocus && !_focusNode.hasFocus) {
        _focusNode.requestFocus();
      }
    }

    // Update focus node if provided externally
    if (widget.focusNode != null && widget.focusNode != _focusNode) {
      _focusNode = widget.focusNode!;
    }
    }

    @override
    void dispose() {
      // _focusNode.dispose();
      if (widget.focusNode == null) {
      _focusNode.dispose();
    }
      super.dispose();
    }

      void ensureVisible(GlobalKey key, ScrollController controller) {
    final context = key.currentContext;
    if (context != null) {
      Scrollable.ensureVisible(
        context,
        duration: Duration(milliseconds: 250),
        alignment: 0.5,
        curve: Curves.easeInOut,
      );
    }
  }

    @override
    Widget build(BuildContext context) {
      final isTV = AppSizes.getDeviceType(context) == DeviceType.tv;

      // Watch the authUserProvider to retrieve the user data
      final userAsync = ref.watch(authUserProvider);

      return userAsync.when(
        data: (user) {
          // Only proceed if the user is authenticated (user is not null)
          final userId = user?.id ?? '';  // Set userId to empty if user is null

          return Focus(
            focusNode: _focusNode,
          autofocus: widget.index == 0 && widget.hasFocus,
          onKey: isTV
              ? (FocusNode node, RawKeyEvent event) {
                  if (event is RawKeyDownEvent) {
                    if (event.logicalKey == LogicalKeyboardKey.arrowRight &&
                        widget.isLastItem) {
                      return KeyEventResult
                          .handled; // Prevent going further right
                    } else if (event.logicalKey == LogicalKeyboardKey.select ||
                        event.logicalKey == LogicalKeyboardKey.enter) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => MovieDetailPage(
                            movieId: widget.film.id,
                            mediaType: widget.mediaType,
                            userId: userId,
                          ),
                        ),
                      );
                      return KeyEventResult.handled;
                    }
                  }
                  return KeyEventResult.ignored;
                }
              : null,
            // onFocusChange: (hasFocus) {
            //   if (isTV) {
            //     setState(() {});
            //   }
            // },
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MovieDetailPage(
                      movieId: widget.film.id,
                      mediaType: widget.mediaType,
                      userId: userId,  // Pass the userId from the user data
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
                        : NetworkImage(imgUrl),
                    fit: BoxFit.cover,
                  ),
                  borderRadius: BorderRadius.circular(10),
                  border: isTV && _focusNode.hasFocus
                      ? Border.all(color: Colors.amber, width: 3.0)
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
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 5.0),
                        child: Text(
                          widget.film.title,
                          style: TextStyle(
                            fontSize: AppSizes.getFilmCardFontSize(context),
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                      SizedBox(height: 8)
                    ],
                  ),
                ),
              ),
            ),
          );
        },
        loading: () => const Center(child: SkeletonLoader()),  // Show loading indicator while fetching user
        error: (error, stackTrace) => const Center(child: Text("Failed to load user")),  // Show error message if failed
      );
    }
  }
