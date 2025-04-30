import 'package:flutter/material.dart';

class TVFilterItem extends StatelessWidget {
  final String label;
  final bool isSelected;
  final bool hasFocus;
  final VoidCallback onTap;

  const TVFilterItem({
    Key? key,
    required this.label,
    required this.isSelected,
    this.hasFocus = false,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final scale = hasFocus ? 1.1 : 1.0;
    
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        margin: EdgeInsets.symmetric(horizontal: 8),
        padding: EdgeInsets.symmetric(horizontal: 25, vertical: 10),
        decoration: BoxDecoration(
          color: hasFocus 
              ? Colors.amber 
              : isSelected 
                  ? Colors.grey[800] 
                  : Colors.transparent,
          borderRadius: BorderRadius.circular(25),
          border: Border.all(
            color: hasFocus 
                ? Colors.amber 
                : isSelected 
                    ? Colors.amber 
                    : Colors.grey,
            width: hasFocus ? 2 : 1,
          ),
        ),
        transform: Matrix4.identity()..scale(scale),
        child: Text(
          label,
          style: TextStyle(
            color: hasFocus 
                ? Colors.black 
                : isSelected 
                    ? Colors.amber 
                    : Colors.white,
            fontSize: 18,
            fontWeight: hasFocus || isSelected 
                ? FontWeight.bold 
                : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}