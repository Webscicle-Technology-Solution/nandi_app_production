
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Add this class to your code - a simple focused ExpansionTile
class FocusableExpansionTile extends StatefulWidget {
  final String title;
  final String content;
  final FocusNode focusNode;

  const FocusableExpansionTile({
    Key? key,
    required this.title,
    required this.content,
    required this.focusNode,
  }) : super(key: key);

  @override
  State<FocusableExpansionTile> createState() => _FocusableExpansionTileState();
}

class _FocusableExpansionTileState extends State<FocusableExpansionTile> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return Focus(
      focusNode: widget.focusNode,
      onKey: (node, event) {
        if (event is RawKeyDownEvent) {
          if (event.logicalKey == LogicalKeyboardKey.select || 
              event.logicalKey == LogicalKeyboardKey.enter) {
            setState(() {
              _isExpanded = !_isExpanded;
            });
            return KeyEventResult.handled;
          }
        }
        return KeyEventResult.ignored;
      },
      child: Builder(
        builder: (context) {
          final hasFocus = Focus.of(context).hasFocus;
          
          return Card(
            margin: EdgeInsets.only(bottom: 12),
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
              side: hasFocus
                ? BorderSide(color: Colors.amber, width: 2)
                : BorderSide.none,
            ),
            color: hasFocus 
                ? (isDarkMode ? Colors.grey[800] : Colors.grey[100])
                : null,
            child: Column(
              children: [
                ListTile(
                  title: Text(
                    widget.title,
                    style: TextStyle(
                      fontWeight: hasFocus ? FontWeight.bold : FontWeight.w600,
                      color: hasFocus ? Colors.amber : null,
                    ),
                  ),
                  trailing: Icon(
                    _isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                    color: hasFocus ? Colors.amber : null,
                  ),
                  onTap: () {
                    setState(() {
                      _isExpanded = !_isExpanded;
                    });
                  },
                ),
                if (_isExpanded)
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      widget.content,
                      style: TextStyle(
                        color: isDarkMode ? Colors.grey[300] : Colors.grey[800],
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}