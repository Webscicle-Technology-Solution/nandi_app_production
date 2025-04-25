import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nandiott_flutter/app/widgets/SkeltonLoader/filmSkelton.dart';
import 'package:nandiott_flutter/models/movie_model.dart';
import 'package:nandiott_flutter/pages/detail_page.dart';
import 'package:nandiott_flutter/providers/checkauth_provider.dart';
import 'package:nandiott_flutter/services/getBannerPoster_service.dart';
import 'package:nandiott_flutter/utils/Device_size.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

  class FilmCard extends ConsumerStatefulWidget {
    final Movie film;
    final String mediaType;
    final bool hasFocus;
    final int index;
    final FocusNode? focusNode;
    final VoidCallback? onFocused;

  const FilmCard({
    super.key,
    required this.film,
    required this.mediaType,
    this.hasFocus = false,
    this.index = 0,
    this.focusNode,
    this.onFocused,
  });

  @override
  _FilmCardState createState() => _FilmCardState();
}

class _FilmCardState extends ConsumerState<FilmCard> {
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
    // Create a unique debug label for this film card
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
    
    // Request focus if this card is the first in its section
    if (widget.index == 0 && (widget.hasFocus || widget.focusNode != null)) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!_focusNode.hasFocus) {
          print("Auto-focusing film card: ${_focusNode.debugLabel}");
          _focusNode.requestFocus();
        }
      });
    }
  }

  @override
  void didUpdateWidget(covariant FilmCard oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.mediaType != widget.mediaType ||
        oldWidget.film != widget.film) {
      setState(() {
        imgUrl = ""; // Reset the old image
      });
      getPosterImage(); // Fetch the new poster image
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
    
    // Update focus node if provided externally
    if (widget.focusNode != null && widget.focusNode != _focusNode) {
      _focusNode = widget.focusNode!;
    }
  }

  @override
  void dispose() {
    // Only dispose if we created it internally
    if (widget.focusNode == null) {
      _focusNode.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isTV = AppSizes.getDeviceType(context) == DeviceType.tv;

    // Watch the authUserProvider to retrieve the user data
    final userAsync = ref.watch(authUserProvider);

    return userAsync.when(
      data: (user) {
        // Only proceed if the user is authenticated (user is not null)
        final userId = user?.id ?? ''; // Set userId to empty if user is null
        
        return Focus(
          focusNode: _focusNode,
          autofocus: widget.index == 0 && widget.hasFocus,
          debugLabel: 'film_card_${widget.mediaType}_${widget.index}',
          onKey: isTV ? (FocusNode node, RawKeyEvent event) {
            if (event is RawKeyDownEvent) {
              if (event.logicalKey == LogicalKeyboardKey.select ||
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
          } : null,
          child: GestureDetector(
            onTap: () {
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
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 5.0),
                      child: Text(
                        widget.film.title,
                        style: TextStyle(
                          fontSize: AppSizes.getFilmCardFontSize(context),
                          fontWeight: (_isFocused || _focusNode.hasFocus) ? FontWeight.bold : FontWeight.w500,
                          color: (_isFocused || _focusNode.hasFocus) ? Colors.amber : Colors.white,
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
      loading: () => const Center(
          child:
              SkeletonLoader()), // Show loading indicator while fetching user
      error: (error, stackTrace) => const Center(
          child: Text("Failed to load user")), // Show error message if failed
    );
  }
}