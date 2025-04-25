import 'package:flutter/material.dart';
import 'package:nandiott_flutter/utils/Device_size.dart';
import 'package:shimmer/shimmer.dart';

class SkeletonLoader extends StatelessWidget {
  const SkeletonLoader({super.key});

  @override

  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!, // Light grey base color
      highlightColor: Colors.grey[100]!, // Lighter grey highlight color
      child: Container(
        margin: const EdgeInsets.only(top: 8.0, left: 5),
       width: AppSizes.getFilmCardWidth(context),
          height: AppSizes.getFilmCardHeight(context),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
}