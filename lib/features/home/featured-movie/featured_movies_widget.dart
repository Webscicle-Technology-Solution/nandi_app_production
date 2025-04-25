import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nandiott_flutter/pages/detail_page.dart';
import 'package:nandiott_flutter/providers/checkauth_provider.dart';
import 'package:nandiott_flutter/utils/Device_size.dart';
import 'package:nandiott_flutter/utils/appstyle.dart';
import 'package:shimmer/shimmer.dart';

class FeaturedMoviesWidget extends ConsumerStatefulWidget {
  final dynamic movie; // The movie data is passed as raw map
  final String imageUrl;
  final bool isActive; // Add this to track if this card is active in the carousel

  const FeaturedMoviesWidget({
    super.key,
    required this.movie,
    required this.imageUrl,
    this.isActive = false,
  });

  @override
  _FeaturedMoviesWidgetState createState() => _FeaturedMoviesWidgetState();
}

class _FeaturedMoviesWidgetState extends ConsumerState<FeaturedMoviesWidget> {
  late String title;
  late String movieId;
  late String contentType;

  @override
  void initState() {
    super.initState();
    title = widget.movie['contentId']['title'] ?? 'No Title';
    movieId = widget.movie['contentId']['_id'] ?? "";
    contentType = widget.movie['contentType'] ?? "";
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    ref.refresh(authUserProvider);
  }

  void _handleTap(String userId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MovieDetailPage(
          movieId: movieId,
          mediaType: contentType,
          userId: userId,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final userAsync = ref.watch(authUserProvider);
    final isTV = AppSizes.getDeviceType(context) == DeviceType.tv;
    final cardHeight = isTV ? 240.0 : 200.0;
    final titleFontSize = isTV ? 18.0 : 16.0;
    final buttonFontSize = isTV ? 16.0 : 14.0;

    return userAsync.when(
      data: (user) {
        final userId = user?.id ?? '';

        return GestureDetector(
          onTap: () => _handleTap(userId),
          child: AnimatedContainer(
            duration: Duration(milliseconds: 300),
            height: cardHeight,
            margin: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              border: widget.isActive
                  ? Border.all(color: Colors.amber, width: 3)
                  : null,
              image: DecorationImage(
                image: widget.imageUrl.isEmpty
                    ? const AssetImage('assets/images/placeholder.png')
                    : NetworkImage(widget.imageUrl) as ImageProvider,
                fit: BoxFit.cover,
                colorFilter: widget.isActive 
                    ? null 
                    : ColorFilter.mode(
                        Colors.black.withOpacity(0.2),
                        BlendMode.darken,
                      ),
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Stack(
              children: [
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(0.8)
                      ],
                    ),
                  ),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: titleFontSize,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    // Animated watch now button with emphasized appearance when active
                    AnimatedContainer(
                      duration: Duration(milliseconds: 200),
                      padding: EdgeInsets.symmetric(
                        horizontal: widget.isActive ? 16 : 8, 
                        vertical: widget.isActive ? 8 : 4
                      ),
                      decoration: BoxDecoration(
                        color: widget.isActive 
                            ? AppStyles.primaryColor
                            : AppStyles.primaryColor.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.play_circle,
                            color: widget.isActive ? Colors.black : Colors.white,
                            size: widget.isActive ? 28 : 24,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            'Watch Now',
                            style: TextStyle(
                              color: widget.isActive ? Colors.black : Colors.white,
                              fontSize: buttonFontSize,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                  ],
                ),
                // TV remote navigation hints
                if (isTV && widget.isActive)
                  Positioned(
                    right: 16,
                    top: cardHeight / 2 - 24,
                    child: Icon(
                      Icons.arrow_forward_ios,
                      color: Colors.amber,
                      size: 24,
                    ),
                  ),
                if (isTV && widget.isActive)
                  Positioned(
                    left: 16,
                    top: cardHeight / 2 - 24,
                    child: Icon(
                      Icons.arrow_back_ios,
                      color: Colors.amber,
                      size: 24,
                    ),
                  ),
              ],
            ),
          ),
        );
      },
      loading: () => SizedBox(
        height: 200,
        child: Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: Container(
            margin: EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ),
      error: (error, stackTrace) => Center(
        child: Text('Error: $error'),
      ),
    );
  }
}