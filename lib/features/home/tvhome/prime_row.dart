import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nandiott_flutter/features/home/tvhome/prime_contenetcrad.dart';
import 'package:nandiott_flutter/features/home/tvhome/tv_home_page.dart';
import 'package:nandiott_flutter/pages/detail_page.dart';
import 'package:shimmer/shimmer.dart';

class PrimeContentRow extends ConsumerStatefulWidget {
  final String title;
  final AsyncValue<List<dynamic>> mediaAsync;
  final String rowType; // 'standard', 'history', 'favorites'
  final String mediaType;
  final bool hasFocus;
  final String userId;
  final Function(String) onBackgroundImageChanged;
  final VoidCallback? onLeftEdgeFocus;
  final VoidCallback? onRightEdgeFocus;
  final VoidCallback? onContentFocus;

  const PrimeContentRow({
    Key? key,
    required this.title,
    required this.mediaAsync,
    required this.rowType,
    required this.mediaType,
    this.hasFocus = false,
    required this.userId,
    required this.onBackgroundImageChanged,
    this.onLeftEdgeFocus,
    this.onRightEdgeFocus,
    this.onContentFocus,
  }) : super(key: key);

  @override
  _PrimeContentRowState createState() => _PrimeContentRowState();
}

class _PrimeContentRowState extends ConsumerState<PrimeContentRow> {
  final ScrollController _scrollController = ScrollController();
  final List<FocusNode> _itemFocusNodes = [];
  int _focusedItemIndex = 0;
  bool _hasFocus = false;

  @override
  void initState() {
    super.initState();
    _hasFocus = widget.hasFocus;

    // Request initial focus if needed
    if (widget.hasFocus) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_itemFocusNodes.isNotEmpty) {
          _itemFocusNodes[0].requestFocus();
        }
      });
    }
  }

  @override
  void didUpdateWidget(PrimeContentRow oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Update focus state
    if (oldWidget.hasFocus != widget.hasFocus) {
      setState(() {
        _hasFocus = widget.hasFocus;
      });

      // Request focus on the first item when row gets focus
      if (widget.hasFocus && !oldWidget.hasFocus) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_itemFocusNodes.isNotEmpty) {
            // Reset the focused item index
            setState(() {
              _focusedItemIndex = 0;
            });
            _itemFocusNodes[0].requestFocus();
          }
        });
      }
    }

    // Handle media type or row type changes
    if (oldWidget.mediaType != widget.mediaType ||
        oldWidget.rowType != widget.rowType) {
      // Reset focus nodes when content changes substantially
      for (final node in _itemFocusNodes) {
        node.dispose();
      }
      _itemFocusNodes.clear();
      _focusedItemIndex = 0;
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    for (final node in _itemFocusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  void _handleKeyEvent(RawKeyEvent event) {
    if (event is RawKeyDownEvent) {
      if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
        if (_focusedItemIndex > 0) {
          // Existing code for moving left within row
          final currentCardData = ref.read(expandedCardProvider);
          ref.read(expandedCardProvider.notifier).state = {};

          Future.delayed(Duration(milliseconds: 50), () {
            _itemFocusNodes[_focusedItemIndex - 1].requestFocus();

            Future.delayed(Duration(milliseconds: 100), () {
              if (currentCardData.isNotEmpty) {
                _handleItemFocus(_focusedItemIndex - 1,
                    widget.mediaAsync.value![_focusedItemIndex - 1]);
              }
            });
          });
        } else {
          // At first item, notify we're at left edge
          if (widget.onLeftEdgeFocus != null) {
            widget.onLeftEdgeFocus!();
          }
        }
      } else if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
        final items = widget.mediaAsync.value ?? [];
        if (_focusedItemIndex < items.length - 1) {
          // Move to next item - existing code...
          final currentCardData = ref.read(expandedCardProvider);
          ref.read(expandedCardProvider.notifier).state = {};

          Future.delayed(Duration(milliseconds: 50), () {
            _itemFocusNodes[_focusedItemIndex + 1].requestFocus();

            Future.delayed(Duration(milliseconds: 100), () {
              if (currentCardData.isNotEmpty) {
                _handleItemFocus(
                    _focusedItemIndex + 1, items[_focusedItemIndex + 1]);
              }
            });
          });
        } else if (items.isNotEmpty) {
          // We're at the last item - LOCK FOCUS HERE
          if (widget.onRightEdgeFocus != null) {
            widget.onRightEdgeFocus!();
          }

          // Re-request focus on the current item to ensure it stays focused
          _itemFocusNodes[_focusedItemIndex].requestFocus();
        }
      }
    }
  }

  void _scrollToFocusedItem() {
    if (_focusedItemIndex < 0 || _itemFocusNodes.isEmpty) return;

    // Calculate the target scroll position
    final itemWidth = 250.0; // Approximate width of each item
    final screenWidth = MediaQuery.of(context).size.width;
    final targetPosition =
        _focusedItemIndex * itemWidth - (screenWidth / 2) + (itemWidth / 2);

    // Ensure we don't scroll beyond bounds
    final maxScroll = _scrollController.position.maxScrollExtent;
    final scrollTo = targetPosition.clamp(0.0, maxScroll);

    // Animate to the position
    _scrollController.animateTo(
      scrollTo,
      duration: Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
    );
  }

  void _handleItemFocus(int index, dynamic item) {
    final prevIndex = _focusedItemIndex;
    setState(() {
      _focusedItemIndex = index;
    });

    // Scroll to ensure focused item is visible
    _scrollToFocusedItem();

    // Get and set the banner image for the focused item
    _updateBackground(item);

    // Update the expanded card provider for detailed overlay
    _updateExpandedCard(item);

    // Notify parent about edge focus if needed
    _checkEdgeFocus(index, prevIndex);
  }

  void _checkEdgeFocus(int currentIndex, int previousIndex) {
    final totalItems = widget.mediaAsync.whenOrNull(
          data: (items) => items.length,
        ) ??
        0;

    // print("Total iyems in file row = $totalItems");

    // Detect left edge focus
    if (currentIndex == 0 && widget.onLeftEdgeFocus != null) {
      widget.onLeftEdgeFocus!();
    }
    // Detect right edge focus
    else if (currentIndex == totalItems && widget.onRightEdgeFocus != null) {
      widget.onRightEdgeFocus!();
    }
    // Center content focus
    else if (widget.onContentFocus != null &&
        (previousIndex == 0 || previousIndex == totalItems - 1)) {
      widget.onContentFocus!();
    }
  }

  Future<void> _updateBackground(dynamic item) async {
    String? bannerUrl;

    // Handle different data types based on row type
    if (widget.rowType == 'favorites') {
      final movieDetail = item['movieDetail'];
      if (movieDetail?.bannerUrl != null) {
        bannerUrl = movieDetail.bannerUrl;
      }
    } else {
      if (item.bannerUrl != null) {
        bannerUrl = item.bannerUrl;
      }
    }

    if (bannerUrl != null && bannerUrl.isNotEmpty) {
      widget.onBackgroundImageChanged(bannerUrl);
    }
  }

  void _updateExpandedCard(dynamic item) {
    // For favorites, extract the movie detail
    final contentItem =
        widget.rowType == 'favorites' ? item['movieDetail'] : item;
    final contentType = widget.rowType == 'favorites'
        ? item['favorite'].contentType
        : widget.mediaType;

    // Create expanded card data
    final cardData = {
      'contentId': contentItem.id,
      'title': contentItem.title,
      'description': contentItem.description ?? 'No description available',
      'mediaType': contentType,
      'posterUrl': contentItem.posterUrl,
      'bannerUrl': contentItem.bannerUrl,
      'rating': contentItem.rating,
      'year': contentItem.year,
    };

    // Update the provider
    ref.read(expandedCardProvider.notifier).state = cardData;
  }

  void _clearExpandedCard() {
    ref.read(expandedCardProvider.notifier).state = {};
  }

  void _navigateToDetail(dynamic item) {
    String contentId;
    String contentType;

    // Handle different data types based on row type
    if (widget.rowType == 'favorites') {
      contentId = item['movieDetail'].id;
      contentType = item['favorite'].contentType;
    } else if (widget.rowType == 'history') {
      contentId = item.contentId;
      contentType = item.contentType;
    } else {
      contentId = item.id;
      contentType = widget.mediaType;
    }
     FocusScope.of(context).unfocus();

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => MovieDetailPage(
          movieId: contentId,
          mediaType: contentType,
          userId: widget.userId,
        ),
      ),
    );
  }

@override
Widget build(BuildContext context) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      // Row title
      Padding(
        padding: const EdgeInsets.only(left: 60.0, top: 15.0, bottom: 10.0),
        child: Text(
          widget.title,
          style: TextStyle(
            color: _hasFocus ? Colors.amber : Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      
      // Content row
      SizedBox(
        height: 260, // Fixed height for the row
        child: widget.mediaAsync.when(
          data: (items) {
            if (items.isEmpty) {
              return Center(
                child: Text(
                  'No content available',
                  style: TextStyle(color: Colors.white70),
                ),
              );
            }
            
            // Ensure we have enough focus nodes
            while (_itemFocusNodes.length < items.length) {
              final index = _itemFocusNodes.length;
              final node = FocusNode(debugLabel: 'card_${widget.title}_$index');
              
              // Add listener to track focus changes
              node.addListener(() {
                if (node.hasFocus && mounted) {
                  _handleItemFocus(index, items[index]);
                }
              });
              
              _itemFocusNodes.add(node);
            }
            
            // The key fix for right edge locking is to use Focus widget instead of RawKeyboardListener
            return Focus(
  focusNode: FocusNode(),
  onKey: (node, event) {
    if (event is RawKeyDownEvent) {
      if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
        if (_focusedItemIndex > 0) {
          // Moving left within row - existing logic
          final currentCardData = ref.read(expandedCardProvider);
          ref.read(expandedCardProvider.notifier).state = {};
          
          Future.delayed(Duration(milliseconds: 50), () {
            _itemFocusNodes[_focusedItemIndex - 1].requestFocus();
            
            Future.delayed(Duration(milliseconds: 100), () {
              if (currentCardData.isNotEmpty) {
                _handleItemFocus(_focusedItemIndex - 1, items[_focusedItemIndex - 1]);
              }
            });
          });
          return KeyEventResult.handled;
        } else {
          // At first item, allow focus to move to side menu
          print("CONTENT_ROW: At left edge, moving focus to menu");
          if (widget.onLeftEdgeFocus != null) {
            widget.onLeftEdgeFocus!();
          }
          return KeyEventResult.ignored; // Let focus transfer happen
        }
      } else if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
        if (_focusedItemIndex < items.length - 1) {
          // Moving right within row - existing logic
          final currentCardData = ref.read(expandedCardProvider);
          ref.read(expandedCardProvider.notifier).state = {};
          
          Future.delayed(Duration(milliseconds: 50), () {
            _itemFocusNodes[_focusedItemIndex + 1].requestFocus();
            
            Future.delayed(Duration(milliseconds: 100), () {
              if (currentCardData.isNotEmpty) {
                _handleItemFocus(_focusedItemIndex + 1, items[_focusedItemIndex + 1]);
              }
            });
          });
          return KeyEventResult.handled;
        } else {
          // At last item, prevent focus from leaving the row
          print("RIGHT EDGE LOCK: Preventing focus from leaving row at item ${_focusedItemIndex}");
          if (widget.onRightEdgeFocus != null) {
            widget.onRightEdgeFocus!();
          }
          return KeyEventResult.handled; // PREVENT focus from moving
        }
      } else if (event.logicalKey == LogicalKeyboardKey.arrowUp ||
                event.logicalKey == LogicalKeyboardKey.arrowDown) {
        // Allow vertical navigation to work
        return KeyEventResult.ignored;
      }
    }
    return KeyEventResult.ignored;
  },
              child: ListView.builder(
                controller: _scrollController,
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.only(left: 60, right: 20),
                itemCount: items.length,
                itemBuilder: (context, index) {
                  // Create a dedicated key for this content card
                  final itemKey = ValueKey('${widget.title}_${widget.rowType}_$index');
                  
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 5.0),
                    child: KeyedSubtree(
                      key: itemKey,
                      child: PrimeContentCard(
                        item: items[index],
                        index: index,
                        focusNode: _itemFocusNodes[index],
                        hasFocus: _hasFocus && index == _focusedItemIndex,
                        rowType: widget.rowType,
                        mediaType: widget.mediaType,
                        onTap: () => _navigateToDetail(items[index]),
                      ),
                    ),
                  );
                },
              ),
            );
          },
          loading: () => _buildLoadingRow(),
          error: (error, stackTrace) => Center(
            child: Text(
              'Error loading content: $error',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ),
      ),
    ],
  );
}

  Widget _buildLoadingRow() {
    return ListView.builder(
      scrollDirection: Axis.horizontal,
      padding: EdgeInsets.only(left: 60, right: 20),
      itemCount: 5,
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: Colors.grey[800]!,
          highlightColor: Colors.grey[700]!,
          child: Container(
            width: 160,
            height: 240,
            margin: EdgeInsets.only(right: 15),
            decoration: BoxDecoration(
              color: Colors.grey[800],
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
      },
    );
  }
}
