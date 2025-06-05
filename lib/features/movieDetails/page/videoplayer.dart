import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:nandiott_flutter/app/widgets/customappbar.dart';
import 'package:nandiott_flutter/features/movieDetails/widget/drmVideoplayer_widget.dart';
import 'package:nandiott_flutter/features/auth/page/loginpage_tv.dart';
import 'package:nandiott_flutter/features/movieDetails/widget/tvDrmVideoplayer.dart';
import 'package:nandiott_flutter/features/profile/provider/watchHistory_provider.dart';
import 'package:nandiott_flutter/features/movieDetails/provider/checkMovieUrl.dart';
import 'package:nandiott_flutter/features/auth/providers/checkauth_provider.dart';
import 'package:nandiott_flutter/features/movieDetails/provider/detail_provider.dart';
import 'package:nandiott_flutter/features/profile/provider/series_watchhistory_provider.dart';
import 'package:nandiott_flutter/utils/Device_size.dart';

class VideoPlayerScreen extends ConsumerStatefulWidget {
  final String movieId;
  final String mediaType;
  final String? tvSeriesId;

  const VideoPlayerScreen({
    super.key,
    required this.movieId,
    required this.mediaType,
    this.tvSeriesId,
  });

  @override
  _VideoPlayerScreenState createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends ConsumerState<VideoPlayerScreen> {
  String accesstoken = '';

  Future<void> getAccessToken() async {
    const storage = FlutterSecureStorage();
    String accessToken = await storage.read(key: 'accessToken') ?? "";
    if (accessToken.isNotEmpty) {
      setState(() {
        accesstoken = accessToken;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    ref.read(authUserProvider); // Trigger authentication check
    getAccessToken();
    // SystemChrome.setPreferredOrientations([
    //   DeviceOrientation.portraitUp,
    //   DeviceOrientation.landscapeLeft,
    //   DeviceOrientation.landscapeRight,
    // ]);
  }

  @override
  void dispose() {
    // Lock back to portrait mode after leaving this screen
    ref.invalidate(watchHistoryProvider);
    ref.invalidate(movieDetailProvider);
    ref.invalidate(tvSeriesWatchProgressProvider);

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isTV = AppSizes.getDeviceType(context) == DeviceType.tv;
    final authUser = ref.watch(authUserProvider);
    final baseUrl = dotenv.env['API_BASE_URL'];

    return authUser.when(
      data: (user) {
        if (user == null) {
          return Scaffold(
            appBar: const CustomAppBar(
                title: "Video Player",
                showBackButton: false,
                showActionIcon: false),
            body: Center(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => LoginScreen()));
                },
                child: const Text("Please log in to view this content."),
              ),
            ),
          );
        }

        final transformedMediaType = _getTransformedMediaType(widget.mediaType);
        final videoUrl =
            "$baseUrl/drm/getmasterplaylist/$transformedMediaType/${widget.movieId.trim()}";

        print("videoplayer response :$videoUrl");

        if (accesstoken.isEmpty) {
          return const Scaffold(
            appBar: CustomAppBar(title: "Video Player"),
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // Use trailerUrlValidityProvider to check the URL validity
        final urlValidity = ref.watch(trailerUrlValidityProvider(videoUrl));

        return urlValidity.when(
          data: (url) {
            print("video url : $url");
            if (url.isEmpty) {
              return const Scaffold(
                appBar: CustomAppBar(
                    title: "Video Player",
                    showBackButton: true,
                    showActionIcon: false),
                body: Center(
                    child:
                        Text("The video URL is not valid or is unavailable.")),
              );
            }

            return isTV
                ? Scaffold(
                    body: DrmVideoPlayer(
                      // Your HLS video URL
                      videoUrl: videoUrl,

                      // Optional parameters
                      defaultQuality: "720p",
                      autoPlay: true,
                      looping: false,
                      fullScreenByDefault: false,
                      aspectRatio: 16 / 9,
                      fit: BoxFit.contain,
                      controlsHideTimeout: 5, // Hide controls after 5 seconds

                      // Watch history parameters (NEW)
                      auth: accesstoken,
                      mediaId: widget.movieId,
                      mediaType: widget.mediaType,
                      tvSeriesId: widget.tvSeriesId ?? "",
                      isTrailer: false,
                    ),
                  )
                : Center(
                    child: FocusScope(
                      autofocus: true,
                      child: BetterVideoPlayer(
                        videoUrl: videoUrl,
                        fullScreen: true,
                        auth: accesstoken,
                        autoPlay: true,
                        mediaId: widget.movieId,
                        mediaType: widget.mediaType,
                        tvSeriesId: widget.tvSeriesId ?? "",
                        isTrailer: false,
                      ),
                    ),
                  );
          },
          loading: () {
            return const Center(
                child: CircularProgressIndicator(
              color: Colors.amber,
            ));
          },
          error: (error, stack) {
            return Center(child: Text("Error: $error"));
          },
        );
      },
      loading: () {
        return Center(child: CircularProgressIndicator());
      },
      error: (error, stack) {
        return Center(child: Text("Error: $error"));
      },
    );
  }

  String _getTransformedMediaType(String mediaType) {
    final mediaTypeMap = {
      'videosong': 'videosongs',
      'shortfilm': 'shortfilms',
      'documentary': 'documentaries',
      'episodes': 'episodes',
      // 'Movie':'movies',
      'movie': 'movies',
      'tvseries': 'tvseries',
      'VideoSong': 'videosongs',
      'ShortFilm': 'shortfilms',
      'Documentary': 'documentaries',
      'Movie': 'movies',
      'TVSeries': 'tvseries',
    };

    return mediaTypeMap[mediaType] ?? mediaType;
  }
}
