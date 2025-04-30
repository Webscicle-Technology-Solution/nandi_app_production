import 'package:flutter/material.dart';

class TVSectionTitle extends StatelessWidget {
  final String title;
  final bool hasFocus;

  const TVSectionTitle({
    Key? key,
    required this.title,
    this.hasFocus = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15, top: 30),
      padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
      decoration: BoxDecoration(
        border: hasFocus ? Border.all(color: Colors.amber, width: 2) : null,
        borderRadius: BorderRadius.circular(hasFocus ? 5 : 0),
      ),
      child: Text(
        title,
        style: TextStyle(
          color: hasFocus ? Colors.amber : Colors.white,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}