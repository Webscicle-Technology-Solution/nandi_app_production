import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nandiott_flutter/providers/filter_provider.dart';

class PrimeFilterBar extends ConsumerStatefulWidget {
  final Function(String) onFilterSelected;
  final bool hasFocus;
  final VoidCallback? onLeftEdgeFocus; // Add this line

  const PrimeFilterBar({
    Key? key,
    required this.onFilterSelected,
    this.hasFocus = false,
    this.onLeftEdgeFocus,
  }) : super(key: key);

  @override
  _PrimeFilterBarState createState() => _PrimeFilterBarState();
}

class _PrimeFilterBarState extends ConsumerState<PrimeFilterBar>
    with SingleTickerProviderStateMixin {
  int _selectedIndex = 0;
  final List<FocusNode> _filterFocusNodes = [];
  late FocusNode _mainFocusNode;
  bool _hasFocus = false;

  late AnimationController _animationController;
  late Animation<double> _heightAnimation;

  @override
  void initState() {
    super.initState();
    _mainFocusNode = FocusNode(debugLabel: 'filter_bar_main');
    _hasFocus = widget.hasFocus;

    // Initialize animation controller
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _heightAnimation = Tween<double>(begin: 50.0, end: 70.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    // Setup focus listener
    _mainFocusNode.addListener(_handleFocusChange);

    // Set initial animation state
    if (widget.hasFocus) {
      _animationController.value = 1.0;
    }

    // Request focus if needed
    if (widget.hasFocus) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _mainFocusNode.requestFocus();
      });
    }
  }

  void _handleFocusChange() {
    if (mounted && _mainFocusNode.hasFocus != _hasFocus) {
      setState(() {
        _hasFocus = _mainFocusNode.hasFocus;
      });

      if (_mainFocusNode.hasFocus) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    }
  }

  @override
  void didUpdateWidget(PrimeFilterBar oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Update focus state
    if (oldWidget.hasFocus != widget.hasFocus) {
      setState(() {
        _hasFocus = widget.hasFocus;
      });

      if (widget.hasFocus && !_mainFocusNode.hasFocus) {
        _mainFocusNode.requestFocus();
      }

      // Update animation
      if (widget.hasFocus) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    }
  }

  @override
  void dispose() {
    _mainFocusNode.removeListener(_handleFocusChange);
    _mainFocusNode.dispose();
    for (var node in _filterFocusNodes) {
      node.dispose();
    }
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final visibleContentTypesAsync = ref.watch(visibleContentTypesProvider);
    final selectedFilter = ref.watch(selectedFilterProvider);

    return visibleContentTypesAsync.when(
      data: (contentTypes) {
        final displayNames = contentTypes.map((typeData) {
          return getDisplayName(typeData['contentType'] as String);
        }).toList();

        // Update selected index based on the current filter
        _selectedIndex = displayNames.indexOf(selectedFilter);
        if (_selectedIndex < 0) _selectedIndex = 0;

        // Ensure we have enough focus nodes
        while (_filterFocusNodes.length < displayNames.length) {
          _filterFocusNodes
              .add(FocusNode(debugLabel: 'filter_${_filterFocusNodes.length}'));
        }

        return Focus(
          focusNode: _mainFocusNode,
          onKey: (node, event) {
            if (event is RawKeyDownEvent) {
              if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
                if (_selectedIndex < displayNames.length - 1) {
                  setState(() {
                    _selectedIndex++;
                  });
                  widget.onFilterSelected(displayNames[_selectedIndex]);
                  return KeyEventResult.handled;
                }
              } else if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
                if (_selectedIndex > 0) {
                  // Not at first item - stay within filter bar
                  setState(() {
                    _selectedIndex--;
                  });
                  widget.onFilterSelected(displayNames[_selectedIndex]);
                  return KeyEventResult.handled;
                } else {
                  // Only at the FIRST item should we move to menu
                  print("FILTER: At leftmost item, moving focus to menu");
                  if (widget.onLeftEdgeFocus != null) {
                    widget.onLeftEdgeFocus!();
                  }
                  return KeyEventResult
                      .ignored; // Match your content row behavior
                }
              }
            }
            return KeyEventResult.ignored;
          },
          child: AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              return Container(
                height: _heightAnimation.value,
                padding: EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColorLight,
                  boxShadow: [
                    BoxShadow(
                      color:
                          Theme.of(context).primaryColorLight.withOpacity(0.3),
                      blurRadius: 5,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    SizedBox(width: 20),
                    // App logo
                    Image.asset(
                      'assets/logo/logo.PNG', // Replace with your actual logo
                      height: 30,
                    ),
                    SizedBox(width: 40),
                    // Filter options
                    Expanded(
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: displayNames.length,
                        itemBuilder: (context, index) {
                          final isSelected = index == _selectedIndex;

                          return AnimatedContainer(
                            duration: Duration(milliseconds: 200),
                            margin: EdgeInsets.symmetric(horizontal: 8),
                            padding: EdgeInsets.symmetric(
                                horizontal: 15, vertical: 8),
                            decoration: BoxDecoration(
                              color: isSelected && _hasFocus
                                  ? Colors.amber
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isSelected
                                    ? Colors.amber
                                    : Colors.transparent,
                                width: 2,
                              ),
                            ),
                            child: Center(
                              child: Text(
                                displayNames[index],
                                style: TextStyle(
                                  color: isSelected && _hasFocus
                                      ? Theme.of(context).primaryColorLight
                                      : isSelected
                                          ? Colors.amber
                                          : Colors.white,
                                  fontSize: isSelected ? 16 : 14,
                                  fontWeight: isSelected
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),

                    // Account icon
                    IconButton(
                      icon: Icon(
                        Icons.account_circle,
                        color: Colors.white,
                        size: 30,
                      ),
                      onPressed: () {
                        // Navigate to account page
                      },
                    ),
                    SizedBox(width: 20),
                  ],
                ),
              );
            },
          ),
        );
      },
      loading: () => Container(
        height: 50,
        color: Theme.of(context).primaryColorLight,
        child: Center(
          child: CircularProgressIndicator(color: Colors.amber),
        ),
      ),
      error: (_, __) => Container(
        height: 50,
        color: Theme.of(context).primaryColorLight,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: ['Movies', 'Series', 'Short Film', 'Documentary', 'Music']
              .map((filter) {
            final isSelected = selectedFilter == filter;
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Text(
                filter,
                style: TextStyle(
                  color: isSelected ? Colors.amber : Colors.white,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}

// Helper function to get display name from content type
String getDisplayName(String contentType) {
  switch (contentType) {
    case 'movie':
      return 'Movies';
    case 'tvseries':
      return 'Series';
    case 'shortfilm':
      return 'Short Film';
    case 'documentary':
      return 'Documentary';
    case 'videosong':
      return 'Music';
    default:
      return contentType;
  }
}
