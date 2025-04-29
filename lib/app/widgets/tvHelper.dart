import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// A helper class for managing TV remote control navigation
class TVRemoteController {
  // Callback for handling D-pad key events at the global level
  static KeyEventResult handleGlobalKeyEvent(KeyEvent event) {
    if (event is! RawKeyDownEvent) return KeyEventResult.ignored;
    
    // Handle back button functionality
    if (event.logicalKey == LogicalKeyboardKey.browserBack || 
        event.logicalKey == LogicalKeyboardKey.goBack) {
      // System will handle the back action
      return KeyEventResult.ignored;
    }
    
    // Let other handlers process the event
    return KeyEventResult.ignored;
  }
  
  // Install a global key handler
  static void installGlobalHandler() {
    ServicesBinding.instance.keyboard.addHandler(handleGlobalKeyEvent as KeyEventCallback);
  }
  
  // Remove the global key handler
  static void removeGlobalHandler() {
    ServicesBinding.instance.keyboard.removeHandler(handleGlobalKeyEvent as KeyEventCallback);
  }
}

/// A widget that handles TV remote focus traversal
class TVFocusTraversalWrapper extends StatefulWidget {
  final Widget child;
  
  const TVFocusTraversalWrapper({
    Key? key,
    required this.child,
  }) : super(key: key);
  
  @override
  _TVFocusTraversalWrapperState createState() => _TVFocusTraversalWrapperState();
}

class _TVFocusTraversalWrapperState extends State<TVFocusTraversalWrapper> {
  @override
  void initState() {
    super.initState();
    TVRemoteController.installGlobalHandler();
  }
  
  @override
  void dispose() {
    TVRemoteController.removeGlobalHandler();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return FocusTraversalGroup(
      policy: WidgetOrderTraversalPolicy(),
      child: widget.child,
    );
  }
}

/// A widget for TV-friendly cards that respond to focus changes
class TVFocusableCard extends StatefulWidget {
  final Widget child;
  final VoidCallback? onFocus;
  final VoidCallback? onTap;
  final FocusNode? focusNode;
  final bool autofocus;
  
  const TVFocusableCard({
    Key? key,
    required this.child,
    this.onFocus,
    this.onTap,
    this.focusNode,
    this.autofocus = false,
  }) : super(key: key);
  
  @override
  _TVFocusableCardState createState() => _TVFocusableCardState();
}

class _TVFocusableCardState extends State<TVFocusableCard> {
  late FocusNode _focusNode;
  bool _isFocused = false;
  
  @override
  void initState() {
    super.initState();
    _focusNode = widget.focusNode ?? FocusNode();
    _focusNode.addListener(_handleFocusChange);
    
    if (widget.autofocus) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && _focusNode.canRequestFocus) {
          _focusNode.requestFocus();
        }
      });
    }
  }
  
  @override
  void dispose() {
    if (widget.focusNode == null) {
      // Only dispose if we created the focus node
      _focusNode.removeListener(_handleFocusChange);
      _focusNode.dispose();
    } else {
      _focusNode.removeListener(_handleFocusChange);
    }
    super.dispose();
  }
  
  void _handleFocusChange() {
    if (_focusNode.hasFocus && widget.onFocus != null) {
      widget.onFocus!();
    }
    
    if (_isFocused != _focusNode.hasFocus) {
      setState(() {
        _isFocused = _focusNode.hasFocus;
      });
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Focus(
      focusNode: _focusNode,
      onKey: (node, event) {
        if (event is RawKeyDownEvent) {
          if (event.logicalKey == LogicalKeyboardKey.select || 
              event.logicalKey == LogicalKeyboardKey.enter) {
            if (widget.onTap != null) {
              widget.onTap!();
              return KeyEventResult.handled;
            }
          }
        }
        return KeyEventResult.ignored;
      },
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          // transform: _isFocused 
          //     ? Matrix4.identity.translate(0.0, -10.0).Matrix4.identity(),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            boxShadow: _isFocused
                ? [
                    BoxShadow(
                      color: Colors.amber.withOpacity(0.6),
                      spreadRadius: 2,
                      blurRadius: 8,
                    )
                  ]
                : [],
            border: _isFocused
                ? Border.all(color: Colors.amber, width: 3)
                : null,
          ),
          child: widget.child,
        ),
      ),
    );
  }
}

/// A widget that manages section-based focus in TV interfaces
class TVSectionFocusManager extends StatefulWidget {
  final List<FocusNode> itemFocusNodes;
  final FocusNode? sectionFocusNode;
  final int sectionIndex;
  final VoidCallback? onUpNavigation;
  final VoidCallback? onDownNavigation;
  final Widget child;
  
  const TVSectionFocusManager({
    Key? key,
    required this.itemFocusNodes,
    this.sectionFocusNode,
    required this.sectionIndex,
    this.onUpNavigation,
    this.onDownNavigation,
    required this.child,
  }) : super(key: key);
  
  @override
  _TVSectionFocusManagerState createState() => _TVSectionFocusManagerState();
}

class _TVSectionFocusManagerState extends State<TVSectionFocusManager> {
  late FocusNode _sectionFocusNode;
  
  @override
  void initState() {
    super.initState();
    _sectionFocusNode = widget.sectionFocusNode ?? FocusNode();
  }
  
  @override
  void dispose() {
    if (widget.sectionFocusNode == null) {
      _sectionFocusNode.dispose();
    }
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Focus(
      focusNode: _sectionFocusNode,
      skipTraversal: true,
      onKey: (node, event) {
        if (event is RawKeyDownEvent) {
          if (event.logicalKey == LogicalKeyboardKey.arrowUp && widget.onUpNavigation != null) {
            widget.onUpNavigation!();
            return KeyEventResult.handled;
          } else if (event.logicalKey == LogicalKeyboardKey.arrowDown && widget.onDownNavigation != null) {
            widget.onDownNavigation!();
            return KeyEventResult.handled;
          }
        }
        return KeyEventResult.ignored;
      },
      child: widget.child,
    );
  }
}