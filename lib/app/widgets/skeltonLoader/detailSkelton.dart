import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class MovieDetailSkeleton extends StatelessWidget {
  const MovieDetailSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 30.0,right: 10,left: 10),
      child: Shimmer.fromColors(
        baseColor: Colors.grey.shade300,
        highlightColor: Colors.grey.shade100,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(height: 200, width: double.infinity, color: Colors.white), // Poster
              const SizedBox(height: 16),
              Container(height: 20, width: 150, color: Colors.white), // Title
              const SizedBox(height: 12),
              Container(height: 14, width: double.infinity, color: Colors.white), // Description 1
              const SizedBox(height: 8),
              Container(height: 14, width: double.infinity, color: Colors.white), // Description 2
              const SizedBox(height: 32),
              Row(
                children: [
                  Container(height: 40, width: 120, color: Colors.white), // Watch Now
                  const SizedBox(width: 16),
                  Container(height: 40, width: 120, color: Colors.white), // Favorite
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
