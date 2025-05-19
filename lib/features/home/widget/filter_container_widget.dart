import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class FilterContainer extends StatefulWidget {
  final String filterOption;
  final bool isSelected;
  final VoidCallback onTap;
  final FocusNode focusNode;

  const FilterContainer({
    super.key,
    required this.filterOption,
    required this.isSelected,
    required this.onTap,
    required this.focusNode,
  });

  @override
  _FilterContainerState createState() => _FilterContainerState();
}

class _FilterContainerState extends State<FilterContainer> {
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Determine if we're on TV or mobile
    final isTV = MediaQuery.of(context).size.width > 800;

    // Get the current theme (either light or dark)
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Focus(
      focusNode: _focusNode,
      onFocusChange: (hasFocus) {
        setState(() {}); // Rebuild the widget on focus change
      },
      onKey: (node, event) {
        if (event is RawKeyDownEvent) {
          if (event.logicalKey == LogicalKeyboardKey.select ||
              event.logicalKey == LogicalKeyboardKey.enter) {
            widget.onTap(); // Trigger the filter change on select
            return KeyEventResult.handled;
          }
          if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
            FocusScope.of(context).nextFocus(); // Move to the next filter
            return KeyEventResult.handled;
          }
          if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
            FocusScope.of(context)
                .previousFocus(); // Move to the previous filter
            return KeyEventResult.handled;
          }
        }
        return KeyEventResult.ignored;
      },
      child: GestureDetector(
        onTap: widget.onTap,
        child: Container(
          padding: isTV
              ? EdgeInsets.symmetric(
                  horizontal: 14, vertical: 12) // Larger padding for TV
              : EdgeInsets.symmetric(
                  horizontal: 12, vertical: 10), // Original padding for mobile
          margin: isTV ? EdgeInsets.all(8) : EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: isDarkMode ? Colors.grey[900] : Colors.grey[50],
            border: _focusNode.hasFocus || widget.isSelected
                ? Border.all(color: Colors.amber, width: 2.0)
                : Border.all(color: Colors.transparent),
            borderRadius: BorderRadius.circular(isTV ? 12 : 10),
            boxShadow: _focusNode.hasFocus || widget.isSelected
                ? [
                    BoxShadow(
                        color: Colors.amber.withOpacity(0.5),
                        blurRadius: 8,
                        spreadRadius: 1)
                  ]
                : null,
          ),
          child: Text(
            widget.filterOption,
            style: TextStyle(
              fontSize: isTV ? 14 : 13, // Larger text on TV
              fontWeight: _focusNode.hasFocus || widget.isSelected
                  ? FontWeight.bold
                  : FontWeight.normal,
              color: _focusNode.hasFocus || widget.isSelected
                  ? Colors.amber
                  : null,
            ),
          ),
        ),
      ),
    );
  }
}
