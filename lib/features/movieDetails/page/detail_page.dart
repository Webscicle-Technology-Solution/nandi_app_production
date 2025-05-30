import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:nandiott_flutter/app/widgets/custombottombar.dart';
import 'package:nandiott_flutter/features/movieDetails/widget/downloadbutton.dart';
import 'package:nandiott_flutter/features/movieDetails/widget/drmVideoplayer_widget.dart';
import 'package:nandiott_flutter/features/movieDetails/widget/season_dialog.dart';
import 'package:nandiott_flutter/app/widgets/skeltonLoader/buttonSkelton.dart';
import 'package:nandiott_flutter/app/widgets/skeltonLoader/detailSkelton.dart';
import 'package:nandiott_flutter/features/auth/page/loginpage_tv.dart';
import 'package:nandiott_flutter/features/profile/provider/watchHistory_provider.dart';
import 'package:nandiott_flutter/features/rental_download/page/download_page.dart';
import 'package:nandiott_flutter/features/movieDetails/page/videoplayer.dart';
import 'package:nandiott_flutter/models/moviedetail_model.dart';
import 'package:nandiott_flutter/features/subscription_payment/page/payment_page.dart';
import 'package:nandiott_flutter/features/subscription_payment/page/subscriptionplan_page.dart';
import 'package:nandiott_flutter/features/movieDetails/provider/checkMovieUrl.dart';
import 'package:nandiott_flutter/features/auth/providers/checkauth_provider.dart';
import 'package:nandiott_flutter/features/movieDetails/provider/detail_provider.dart';
import 'package:nandiott_flutter/app/widgets/customappbar.dart';
import 'package:nandiott_flutter/features/profile/provider/favourite_provider.dart';
import 'package:nandiott_flutter/features/movieDetails/provider/getbanner_poster.dart';
import 'package:nandiott_flutter/features/rental_download/provider/rental_provider.dart';
import 'package:nandiott_flutter/features/profile/provider/series_watchhistory_provider.dart';
import 'package:nandiott_flutter/features/subscription_payment/provider/subscription_provider.dart';
import 'package:nandiott_flutter/features/movieDetails/provider/tvseries_season_provider.dart';
import 'package:nandiott_flutter/utils/Device_size.dart';
import 'package:url_launcher/url_launcher.dart';

class MovieDetailPage extends ConsumerStatefulWidget {
  final String movieId;
  final String mediaType;
  final String userId;
  const MovieDetailPage(
      {super.key,
      required this.movieId,
      required this.mediaType,
      required this.userId});

  @override
  _MovieDetailPageState createState() => _MovieDetailPageState();
}

class _MovieDetailPageState extends ConsumerState<MovieDetailPage> {
  final baseUrl = dotenv.env['API_BASE_URL'];

  final bool isIos = Platform.isIOS;

  double currentRating = 0.0;
  // Initialize focus nodes for TV navigation
  late FocusNode watchButtonFocusNode;
  late FocusNode favoriteButtonFocusNode;
  // late FocusNode downloadButtonFocusNode;
  // Function to fetch and set the initial rating

  void _resetRating() {
    setState(() {
      currentRating = 0.0;
    });
  }

  late String movieId;
  late String mediaType;
  late String userId;

  bool _isNavigatingAway = false;

  @override
  void initState() {
    super.initState();

    // Initialize focus nodes
    watchButtonFocusNode = FocusNode(debugLabel: 'watchButton');
    favoriteButtonFocusNode = FocusNode(debugLabel: 'favoriteButton');
    // downloadButtonFocusNode = FocusNode(debugLabel: 'downloadButton');


    ref.read(authUserProvider);
    movieId = widget.movieId;
    userId = widget.userId;
    mediaType = widget.mediaType;

    // Ensure initial focus is set after the first frame is rendered
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (AppSizes.getDeviceType(context) == DeviceType.tv) {
        FocusScope.of(context).requestFocus(watchButtonFocusNode);
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // ✅ Refresh provider on page load
    ref.invalidate(authUserProvider);
    ref.invalidate(bannerProvider);
    ref.invalidate(posterProvider);
    ref.invalidate(movieDetailProvider);
    ref.invalidate(rentalProvider);
    ref.invalidate(movieRateProvider);
    // ref.invalidate(authUserProvider);
    ref.invalidate(rentalProvider);
    ref.invalidate(
        subscriptionProvider(SubscriptionDetailParameter(userId: userId)));
    ref.invalidate(movieDetailProvider);
    ref.invalidate(tvSeriesWatchProgressProvider);
    ref.invalidate(watchHistoryProvider);
    ref.invalidate(ratedMovieProvider(MovieDetailParameter(
        movieId: widget.movieId, mediaType: widget.mediaType)));
  }

  @override
  void dispose() {
    _isNavigatingAway = true;
    FocusScope.of(context).unfocus();
    // Clean up focus nodes
    watchButtonFocusNode.dispose();
    favoriteButtonFocusNode.dispose();
    // downloadButtonFocusNode.dispose();
    // ref.invalidate(movieDetailProvider);
    // ref.invalidate(tvSeriesWatchProgressProvider);

    // TODO: implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(rentalProvider);
    //     ref.watch(ratedMovieProvider(MovieDetailParameter(movieId: widget.movieId, mediaType: widget.mediaType)));

    final Map<String, String> mediaTypeMapbanner = {
      'videosong': 'videosong',
      'shortfilm': 'shortfilm',
      'documentary': 'documentary',
      'episodes': 'episode',
      'movie': 'movie',
      'tvseries': 'tvseries', // Keeping 'tvseries' unchanged
      'VideoSong': 'videosong',
      'ShortFilm': 'shortfilm',
      'Documentary': 'documentary',
      'Movie': 'movie',
      'TVSeries': 'tvseries',
    };

    final transformedMediaTypebanner =
        mediaTypeMapbanner[mediaType] ?? mediaType;

    final movieDetails = ref.watch(movieDetailProvider(MovieDetailParameter(
        movieId: widget.movieId, mediaType: transformedMediaTypebanner)));
    final bannerUrl = ref.watch(bannerProvider(MovieDetailParameter(
        movieId: widget.movieId, mediaType: transformedMediaTypebanner)));

    final Map<String, String> mediaTypeMap = {
      'videosong': 'videosongs',
      'shortfilm': 'shortfilms',
      'documentary': 'documentaries',
      'episodes': 'episode',
      'movie': 'movies',
      'tvseries': 'tvseries', // Keeping 'tvseries' unchanged
      'VideoSong': 'videosongs',
      'ShortFilm': 'shortfilms',
      'Documentary': 'documentaries',
      'Movie': 'movies',
      'TVSeries': 'tvseries', // Keeping 'tvseries' unchanged
    };

    final transformedMediaType = mediaTypeMap[mediaType] ?? mediaType;

    // Construct the trailer URL using the movieId
    final trailerUrl =
        "$baseUrl/drm/getmasterplaylist/$transformedMediaType/$movieId/trailer";

    // Watch the trailer URL validity provider using the full URL
    final isTrailerValid = ref.watch(trailerUrlValidityProvider(trailerUrl));

    final bool isTV = AppSizes.getDeviceType(context) == DeviceType.tv;

    return Scaffold(
      appBar: CustomAppBar(
          showActionIcon: false,
          title:
              "${mediaType[0].toUpperCase()}${mediaType.substring(1)} Details",
          showBackButton: true),
      body: SafeArea(
        child: FocusScope(
          // This traps focus within the detail page
          onFocusChange: (hasFocus) {
            if (!hasFocus &&
                mounted &&
                AppSizes.getDeviceType(context) == DeviceType.tv) {
              FocusScope.of(context).requestFocus(watchButtonFocusNode);
            }
            ;
          },
          child: movieDetails.when(
            data: (movie) => movie != null
                ? bannerUrl.when(
                    data: (url) => isTrailerValid.when(
                      data: (isValid) =>
                          _buildMovieDetails(context, movie, url, isValid),
                      loading: () =>
                          const MovieDetailSkeleton(), // Loading trailer validity check
                      error: (err, _) => _buildErrorView(
                          "Error checking trailer: $err"), // Handle error checking trailer URL
                    ),
                    loading: () => const Center(child: MovieDetailSkeleton()),
                    error: (err, _) =>
                        _buildErrorView("Error loading banner: $err"),
                  )
                : _buildErrorView("Movie details not found"),
            loading: () => const Center(child: Buttonskelton()),
            error: (err, _) =>
                _buildErrorView("Error loading movie details: $err"),
          ),
        ),
      ),
    );
  }

  Widget _buildErrorView(String message) {
    return Center(
        child: Text(message,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500)));
  }

  Widget _buildMovieDetails(
      BuildContext context, MovieDetail movie, String? url, String videoUrl) {
    String formatDuration(double seconds) {
      int totalSeconds = seconds.floor();
      int hours = totalSeconds ~/ 3600;
      int minutes = (totalSeconds % 3600) ~/ 60;
      int secs = totalSeconds % 60;

      String result = '';
      if (hours > 0) result += '${hours}h';
      if (minutes > 0) result += '${minutes}m';
      if (secs > 0 || result.isEmpty) result += '${secs}s';

      return result;
    }

    final finalBannerUrl = url ?? ""; // Fallback image URL

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          videoUrl != "" || videoUrl.isNotEmpty
              ? SizedBox(
                  height: AppSizes.getbannerHeight(context),
                  width: double.infinity,
                  child: BetterVideoPlayer(
                    videoUrl: videoUrl,
                    autoPlay: false,
                    posterUrl: finalBannerUrl, // Pass the banner URL here
                    isTrailer: true,
                  ),
                )
              : SizedBox(
                  height: AppSizes.getbannerHeight(context),
                  width: double.infinity,
                  child: Image.network(
                    finalBannerUrl,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return Image.asset(
                        "assets/images/placeholder.png",
                        fit: BoxFit.cover,
                      );
                    },
                  ),
                ),
          _buildWatchNowButton(movie, context),
          _buildFavoriteDownloadButtons(movie, context),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  movie.title,
                  style: TextStyle(
                      fontSize: AppSizes.getTitleFontSize(context),
                      fontWeight: FontWeight.bold),
                ),

                // duration , release date,
                Row(
                  children: [
                    Text(
                        movie.releaseDate != null
                            ? "${movie.releaseDate!.year} »"
                            : "",
                        style: TextStyle(
                            fontSize: AppSizes.getstatusFontSize(context))),
                    Text(
                      movie.duration != null
                          ? formatDuration(movie.duration!)
                          : "",
                      style: TextStyle(
                          fontSize: AppSizes.getstatusFontSize(context)),
                    )
                  ],
                ),
                const SizedBox(height: 10),
                widget.mediaType == "TVSeries" || widget.mediaType == "tvseries"
                    ? _buildSeasonSelector(context, ref)
                    : const SizedBox(),
                const SizedBox(height: 15),

                if (movie.description != null &&
                    movie.description!.trim().isNotEmpty) ...[
                  const Text(
                    "About",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 5),
                  _buildFocusableBox(
                    child: Text(
                      movie.description!,
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
                ],
                const SizedBox(height: 20),

                // Cast Section (Focusable)
                _buildCastSection(movie.castDetails, context),

                const SizedBox(height: 20),
                // If rating wanted, uncomment this
                // userId != "" ? Center(child: _buildRatingBar(context, widget.mediaType, movie.id)) : const Text(""),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Helper method to add consistent focus styling
  Widget _buildFocusableBox({
    required Widget child,
    FocusNode? focusNode,
    bool autofocus = false,
    VoidCallback? onPressed,
  }) {
    return Focus(
      focusNode: focusNode,
      autofocus: autofocus,
      onKey: onPressed != null
          ? (node, event) {
              if (event is RawKeyDownEvent) {
                if (event.logicalKey == LogicalKeyboardKey.select ||
                    event.logicalKey == LogicalKeyboardKey.enter) {
                  onPressed();
                  return KeyEventResult.handled;
                }
              }
              return KeyEventResult.ignored;
            }
          : null,
      child: Builder(
        builder: (context) {
          final isFocused = Focus.of(context).hasFocus;
          return GestureDetector(
            onTap: onPressed,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isFocused ? Colors.amber : Colors.transparent,
                  width: 3,
                ),
                boxShadow: isFocused
                    ? [
                        BoxShadow(
                          color: Colors.amber.withOpacity(0.5),
                          blurRadius: 8,
                          spreadRadius: 2,
                        )
                      ]
                    : null,
              ),
              child: child,
            ),
          );
        },
      ),
    );
  }

  Widget _buildButton({
    required String text,
    required IconData icon,
    required Color textColor,
    required VoidCallback onPressed,
    FocusNode? focusNode,
    bool autofocus = false,
  }) {
    final isTv = AppSizes.getDeviceType(context) == DeviceType.tv;
    return Focus(
      focusNode: focusNode,
      autofocus: autofocus,
      onKey: (node, event) {
        if (event is RawKeyDownEvent) {
          if (event.logicalKey == LogicalKeyboardKey.select ||
              event.logicalKey == LogicalKeyboardKey.enter) {
            onPressed();
            return KeyEventResult.handled;
          }
        }
        return KeyEventResult.ignored;
      },
      child: Builder(builder: (context) {
        final isFocused = Focus.of(context).hasFocus;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: isFocused && isTv ? Colors.amber : Colors.transparent,
                width: 3,
              ),
              boxShadow: isFocused && isTv
                  ? [
                      BoxShadow(
                        color: Colors.amber.withOpacity(0.5),
                        blurRadius: 10,
                        spreadRadius: 2,
                      )
                    ]
                  : null,
            ),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: onPressed,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  side: const BorderSide(color: Colors.black),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                icon: Icon(icon, size: 20, color: textColor),
                label: Text(text,
                    style: TextStyle(fontSize: 15, color: textColor)),
              ),
            ),
          ),
        );
      }),
    );
  }

  // rent button with focus
  // Modified _buildWatchNowButton implementation
  Widget _buildWatchNowButton(MovieDetail movie, BuildContext context) {
    bool isRentable = movie.accessParams?.isRentable == true;
    bool isFree = movie.accessParams?.isFree == true;

    final authUser = ref.watch(authUserProvider);
    final rentals = ref.watch(rentalProvider);

    // Add a loading state variable
    bool isRefreshing = false;

    return authUser.when(
      data: (user) {
        // When no user is logged in
        if (user == null) {
          return _buildButton(
            text: "Login to watch",
            icon: Icons.login,
            textColor: Color(0xFFF4AE00),
            focusNode: watchButtonFocusNode,
            autofocus: true,
            onPressed: () async {
              FocusScope.of(context).unfocus();
              watchButtonFocusNode.canRequestFocus = false;
              favoriteButtonFocusNode.canRequestFocus = false;
              // downloadButtonFocusNode.canRequestFocus = false;

              // Start with loading state
              setState(() {
                isRefreshing = true;
              });

              // Navigate to login page and wait for result
              final loginResult = await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => LoginScreen()),
              );
              if (mounted) {
                watchButtonFocusNode.canRequestFocus = true;
                favoriteButtonFocusNode.canRequestFocus = true;
                // downloadButtonFocusNode.canRequestFocus = true;

                // Request focus on the watch button
                FocusScope.of(context).requestFocus(watchButtonFocusNode);
              }

              // If login was successful
              if (loginResult == true) {
                // Explicitly refresh providers one by one in order
                await ref.refresh(authUserProvider.future);

                // Wait a small amount of time for auth to propagate
                await Future.delayed(Duration(milliseconds: 300));

                // Now refresh dependent providers
                if (mounted) {
                  final newUser = ref.read(authUserProvider).value;
                  if (newUser != null) {
                    setState(() {
                      userId = newUser.id;
                    });

                    // Refresh remaining providers
                    await ref.refresh(rentalProvider.future);
                    await ref.refresh(subscriptionProvider(
                            SubscriptionDetailParameter(userId: newUser.id))
                        .future);
                    // await ref.refresh(isMovieFavoriteProvider(movie.id).future);
                    await ref.refresh(favoritesProvider.future);
                  }

                  // End loading state
                  setState(() {
                    isRefreshing = false;
                  });
                }
              } else {
                // Login was not successful
                setState(() {
                  isRefreshing = false;
                });
              }
            },
          );
        } else {
          // User is already logged in
          if (isRefreshing) {
            return const Center(child: Buttonskelton());
          }

          setState(() {
            userId = user.id;
          });

          final subscriptions = ref.watch(subscriptionProvider(
              SubscriptionDetailParameter(userId: user.id)));

          // User is logged in, show appropriate button based on rental/subscription status
          return rentals.when(
            data: (rentalList) {
              // Check if the user has rented this movie
              bool hasRented = rentalList.any((rental) =>
                  rental.userId == user.id && rental.movieId == movie.id);

              return subscriptions.when(
                data: (subscription) {
                  // Check if user has active subscription
                  bool isSubscribed =
                      subscription?.subscriptionType.name != "Free";

                  if ((widget.mediaType == "tvseries" ||
                          widget.mediaType == "TVSeries") &&
                      isSubscribed) {
                    return const SizedBox(height: 10);
                  } else {
                    if (hasRented || isSubscribed || isFree) {
                      return _buildButton(
                        text: "Watch Now",
                        icon: Icons.visibility,
                        textColor: Color(0xFFF4AE00),
                        focusNode: watchButtonFocusNode,
                        autofocus: true,
                        onPressed: () async {
                          FocusScope.of(context).unfocus();
                          watchButtonFocusNode.canRequestFocus = false;
                          favoriteButtonFocusNode.canRequestFocus = false;

                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => VideoPlayerScreen(
                                mediaType: widget.mediaType,
                                movieId: movie.id,
                              ),
                            ),
                          );
                          ref.invalidate(watchHistoryProvider);
                          ref.invalidate(movieDetailProvider);
                          ref.invalidate(tvSeriesWatchProgressProvider);

                          if (mounted) {
                            watchButtonFocusNode.canRequestFocus = true;
                            favoriteButtonFocusNode.canRequestFocus = true;

                            // Request focus on the watch button
                            FocusScope.of(context)
                                .requestFocus(watchButtonFocusNode);
                          }
                        },
                      );
                    } else if (isRentable) {
                      return _buildButton(
                        text:
                            "Rent for ₹${movie.accessParams?.rentalPrice ?? "N/A"}",
                        icon: Icons.payments,
                        textColor: Color(0xFFF4AE00),
                        focusNode: watchButtonFocusNode,
                        autofocus: true,
                        onPressed: () async {
                          FocusScope.of(context).unfocus();
                          watchButtonFocusNode.canRequestFocus = false;
                          favoriteButtonFocusNode.canRequestFocus = false;
                          final result = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => RentalPaymentRedirectPage(
                                      movieId: widget.movieId,
                                      redirectUrl:
                                          "https://nandi.webscicle.com/app/paymentreport")));

                          if (mounted) {
                            watchButtonFocusNode.canRequestFocus = true;
                            favoriteButtonFocusNode.canRequestFocus = true;

                            // Request focus on the watch button
                            FocusScope.of(context)
                                .requestFocus(watchButtonFocusNode);
                          }
                          if (result == true) {
                            ref.invalidate(rentalProvider);
                          }
                          // Add rental logic here
                        },
                      );
                    } else {
                      return _buildButton(
                        text: "Subscribe to Watch",
                        icon: Icons.subscriptions,
                        textColor: Color(0xFFF4AE00),
                        focusNode: watchButtonFocusNode,
                        autofocus: true,
                        onPressed: () {
                          FocusScope.of(context).unfocus();
                          watchButtonFocusNode.canRequestFocus = false;
                          favoriteButtonFocusNode.canRequestFocus = false;

                          if (isIos == true) {
                            // Show alert dialog for iOS users
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: Text("Subscription Unavailable"),
                                content: Text(
                                  "Subscriptions are not available.\nPlease visit our website to know more",
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                    child: Text("Cancel"),
                                  ),
                                  TextButton(
                                    onPressed: () async {
                                      const url =
                                          'https://nandipictures.in/app'; // Replace with your real link
                                      if (await canLaunchUrl(Uri.parse(url))) {
                                        await launchUrl(Uri.parse(url),
                                            mode:
                                                LaunchMode.externalApplication);
                                      } else {
                                        // Show error if URL can't be launched
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                              content: Text(
                                                  "Could not launch website")),
                                        );
                                      }
                                      Navigator.of(context).pop();
                                    },
                                    child: Text("Go to Website"),
                                  ),
                                ],
                              ),
                            );
                          } else {
                            // For non-iOS devices, show the subscription modal
                            showModalBottomSheet(
                              context: context,
                              isScrollControlled: true,
                              backgroundColor: Colors.transparent,
                              builder: (_) => SubscriptionPlanModal(
                                userId: user.id,
                                movieId: movieId,
                              ),
                            );
                          }

                          if (mounted) {
                            watchButtonFocusNode.canRequestFocus = true;
                            favoriteButtonFocusNode.canRequestFocus = true;

                            FocusScope.of(context)
                                .requestFocus(watchButtonFocusNode);
                          }
                        },
                      );
                    }
                  }
                },
                loading: () => Center(child: Buttonskelton()),
                error: (_, __) => _buildButton(
                  text:
                      "Loading Subscription...", // Changed error text to be less alarming
                  icon: Icons.refresh,
                  textColor: Color(0xFFF4AE00),
                  focusNode: watchButtonFocusNode,
                  autofocus: true,
                  onPressed: () {
                    ref.refresh(subscriptionProvider(
                            SubscriptionDetailParameter(userId: user.id))
                        .future);
                  },
                ),
              );
            },
            loading: () => Center(child: Buttonskelton()),
            error: (_, __) => _buildButton(
              text:
                  "Loading Content...", // Changed error text to be less alarming
              icon: Icons.refresh,
              textColor: Color(0xFFF4AE00),
              focusNode: watchButtonFocusNode,
              autofocus: true,
              onPressed: () {
                ref.refresh(rentalProvider.future);
              },
            ),
          );
        }
      },
      loading: () => Center(child: Buttonskelton()),
      error: (_, __) => _buildButton(
        text: "Login to Watch",
        icon: Icons.login,
        textColor: Color(0xFFF4AE00),
        focusNode: watchButtonFocusNode,
        autofocus: true,
        onPressed: () async {
          FocusScope.of(context).unfocus();
          watchButtonFocusNode.canRequestFocus = false;
          favoriteButtonFocusNode.canRequestFocus = false;
          setState(() {
            isRefreshing = true;
          });

          final loginResult = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => LoginScreen()),
          );

          if (mounted) {
            watchButtonFocusNode.canRequestFocus = true;
            favoriteButtonFocusNode.canRequestFocus = true;

            // Request focus on the watch button
            FocusScope.of(context).requestFocus(watchButtonFocusNode);
          }

          // If login was successful
          if (loginResult == true) {
            // Explicitly refresh providers one by one
            await ref.refresh(authUserProvider.future);

            // Wait for auth to propagate
            await Future.delayed(Duration(milliseconds: 300));

            // Now refresh dependent providers
            if (mounted) {
              final newUser = ref.read(authUserProvider).value;
              if (newUser != null) {
                setState(() {
                  userId = newUser.id;
                });

                // Refresh remaining providers
                await ref.refresh(rentalProvider.future);
                await ref.refresh(subscriptionProvider(
                        SubscriptionDetailParameter(userId: newUser.id))
                    .future);
                // ref.refresh(isMovieFavoriteProvider(movie.id));
                await ref.refresh(favoritesProvider.future);
              }

              setState(() {
                isRefreshing = false;
              });
            }
          } else {
            setState(() {
              isRefreshing = false;
            });
          }
        },
      ),
    );
  }

  //********************************************* */
  //*old backend working button without sub and rental*//

  // Widget _buildWatchNowButton(MovieDetail movie, BuildContext context) {
  //   final authUser = ref.watch(authUserProvider);

  //   return authUser.when(
  //     data: (user) {
  //       if (user == null) {
  //         return _buildButton(
  //           text: "Login to Watch",
  //           icon: Icons.login,
  //           textColor: Color(0xFFF4AE00),
  //           focusNode: watchButtonFocusNode,
  //           autofocus: true,
  //           onPressed: () async {
  //             FocusScope.of(context).unfocus();
  //             watchButtonFocusNode.canRequestFocus = false;
  //             favoriteButtonFocusNode.canRequestFocus = false;

  //             final loginResult = await Navigator.push(
  //               context,
  //               MaterialPageRoute(builder: (context) => LoginScreen()),
  //             );

  //             if (mounted) {
  //               watchButtonFocusNode.canRequestFocus = true;
  //               favoriteButtonFocusNode.canRequestFocus = true;
  //               FocusScope.of(context).requestFocus(watchButtonFocusNode);
  //             }

  //             if (loginResult == true) {
  //               await ref.refresh(authUserProvider.future);
  //               await ref.refresh(favoritesProvider.future);
  //             }
  //           },
  //         );
  //       } else {
  //         return _buildButton(
  //           text: "Watch Now",
  //           icon: Icons.visibility,
  //           textColor: Color(0xFFF4AE00),
  //           focusNode: watchButtonFocusNode,
  //           autofocus: true,
  //           onPressed: () async {
  //             FocusScope.of(context).unfocus();
  //             watchButtonFocusNode.canRequestFocus = false;
  //             favoriteButtonFocusNode.canRequestFocus = false;

  //             await Navigator.push(
  //               context,
  //               MaterialPageRoute(
  //                 builder: (context) => VideoPlayerScreen(
  //                   mediaType: widget.mediaType,
  //                   movieId: movie.id,
  //                 ),
  //               ),
  //             );

  //             ref.invalidate(watchHistoryProvider);
  //             ref.invalidate(movieDetailProvider);
  //             ref.invalidate(tvSeriesWatchProgressProvider);

  //             if (mounted) {
  //               watchButtonFocusNode.canRequestFocus = true;
  //               favoriteButtonFocusNode.canRequestFocus = true;
  //               FocusScope.of(context).requestFocus(watchButtonFocusNode);
  //             }
  //           },
  //         );
  //       }
  //     },
  //     loading: () => const Center(child: Buttonskelton()),
  //     error: (_, __) => _buildButton(
  //       text: "Login to Watch",
  //       icon: Icons.login,
  //       textColor: Color(0xFFF4AE00),
  //       focusNode: watchButtonFocusNode,
  //       autofocus: true,
  //       onPressed: () async {
  //         FocusScope.of(context).unfocus();
  //         watchButtonFocusNode.canRequestFocus = false;
  //         favoriteButtonFocusNode.canRequestFocus = false;

  //         final loginResult = await Navigator.push(
  //           context,
  //           MaterialPageRoute(builder: (context) => LoginScreen()),
  //         );

  //         if (mounted) {
  //           watchButtonFocusNode.canRequestFocus = true;
  //           favoriteButtonFocusNode.canRequestFocus = true;
  //           FocusScope.of(context).requestFocus(watchButtonFocusNode);
  //         }

  //         if (loginResult == true) {
  //           await ref.refresh(authUserProvider.future);
  //           await ref.refresh(favoritesProvider.future);
  //         }
  //       },
  //     ),
  //   );
  // }

  // Widget _buildFavoriteDownloadButtons(
  //     MovieDetail movie, BuildContext context) {
  //   final isTV = AppSizes.getDeviceType(context) == DeviceType.tv;
  //   final isDarkMode = Theme.of(context).brightness == Brightness.dark;

  //   final Map<String, String> mediaTypeMapbanner = {
  //     'videosong': 'videosong',
  //     'shortfilm': 'shortfilm',
  //     'documentary': 'documentary',
  //     'episodes': 'episode',
  //     'movie': 'movie',
  //     'tvseries': 'tvseries',
  //     'VideoSong': 'videosong',
  //     'ShortFilm': 'shortfilm',
  //     'Documentary': 'documentary',
  //     'Movie': 'movie',
  //     'TVSeries': 'tvseries',
  //   };

  //   final transformedMediaTypebanner =
  //       mediaTypeMapbanner[widget.mediaType] ?? widget.mediaType;

  //   final Map<String, String> mediaTypeMap = {
  //     'videosong': 'videosongs',
  //     'shortfilm': 'shortfilms',
  //     'documentary': 'documentaries',
  //     'episodes': 'episode',
  //     'movie': 'movies',
  //     'tvseries': 'tvseries',
  //     'VideoSong': 'videosongs',
  //     'ShortFilm': 'shortfilms',
  //     'Documentary': 'documentaries',
  //     'Movie': 'movies',
  //     'TVSeries': 'tvseries',
  //   };

  //   final transformedMediaType =
  //       mediaTypeMap[widget.mediaType] ?? widget.mediaType;

  //   final authUser = ref.watch(authUserProvider);
  //   final buttonState = ref.watch(downloadButtonStateProvider(widget.movieId));

  //   return authUser.when(
  //     data: (user) {
  //       // When no user is logged in
  //       if (user == null) {
  //         return const SizedBox();
  //       } else {
  //         // User is logged in, show appropriate buttons
  //         final isFavorite = ref.watch(isMovieFavoriteProvider(movie.id));

  //         // Simplify button logic by using our dedicated state provider
  //         final showGoToDownloads = buttonState.isDownloaded ||
  //             buttonState.isDownloading ||
  //             buttonState.isPaused;

  //         // Check if content is TV Series - we don't allow downloads for these
  //         bool isTVSeries =
  //             widget.mediaType == "TVSeries" || widget.mediaType == "tvseries";

  //         return Padding(
  //           padding: const EdgeInsets.symmetric(horizontal: 16.0),
  //           child: Row(
  //             children: [
  //               // Favorite Button with focus
  //               Expanded(
  //                 child: Focus(
  //                   focusNode: favoriteButtonFocusNode,
  //                   onKey: (node, event) {
  //                     if (event is RawKeyDownEvent) {
  //                       if (event.logicalKey == LogicalKeyboardKey.select ||
  //                           event.logicalKey == LogicalKeyboardKey.enter) {
  //                         ref.read(favoritesProvider.notifier).toggleFavorite(
  //                               movie.id,
  //                               widget.mediaType,
  //                             );
  //                         return KeyEventResult.handled;
  //                       }
  //                     }
  //                     return KeyEventResult.ignored;
  //                   },
  //                   child: Builder(builder: (context) {
  //                     final isFocused = Focus.of(context).hasFocus;
  //                     return Container(
  //                       decoration: BoxDecoration(
  //                         borderRadius: BorderRadius.circular(10),
  //                         border: Border.all(
  //                           color:
  //                               isFocused ? Colors.amber : Colors.transparent,
  //                           width: 3,
  //                         ),
  //                         boxShadow: isFocused && isTV
  //                             ? [
  //                                 BoxShadow(
  //                                   color: Colors.amber.withOpacity(0.5),
  //                                   blurRadius: 8,
  //                                   spreadRadius: 2,
  //                                 )
  //                               ]
  //                             : null,
  //                       ),
  //                       child: OutlinedButton.icon(
  //                         onPressed: () {
  //                           ref.read(favoritesProvider.notifier).toggleFavorite(
  //                                 movie.id,
  //                                 widget.mediaType,
  //                               );
  //                         },
  //                         icon: ShaderMask(
  //                           shaderCallback: (Rect bounds) {
  //                             return const LinearGradient(
  //                               colors: [
  //                                 Color.fromARGB(255, 255, 187, 0),
  //                                 Color.fromARGB(255, 255, 123, 0)
  //                               ],
  //                               begin: Alignment.topLeft,
  //                               end: Alignment.bottomRight,
  //                             ).createShader(bounds);
  //                           },
  //                           child: Icon(
  //                             isFavorite
  //                                 ? Icons.favorite
  //                                 : Icons.favorite_border,
  //                             color: Colors.white,
  //                           ),
  //                         ),
  //                         label: ShaderMask(
  //                           shaderCallback: (Rect bounds) {
  //                             return const LinearGradient(
  //                               colors: [
  //                                 Color.fromARGB(255, 255, 187, 0),
  //                                 Color.fromARGB(255, 255, 123, 0)
  //                               ],
  //                               begin: Alignment.topLeft,
  //                               end: Alignment.bottomRight,
  //                             ).createShader(bounds);
  //                           },
  //                           child: Text(
  //                             isFavorite
  //                                 ? "Remove Favorite"
  //                                 : "Add to Favorites",
  //                             style: const TextStyle(color: Colors.white),
  //                           ),
  //                         ),
  //                         style: OutlinedButton.styleFrom(
  //                           padding: const EdgeInsets.symmetric(vertical: 12),
  //                           side: const BorderSide(
  //                               color: Color.fromARGB(255, 224, 129, 5)),
  //                           foregroundColor: Colors.white,
  //                         ),
  //                       ),
  //                     );
  //                   }),
  //                 ),
  //               ),
  //               const SizedBox(width: 10),

  //               // Download Button with focus - skip for TV Series and TV devices
  //               isTVSeries || isTV || isIos
  //                   ? const SizedBox()
  //                   : Expanded(
  //                       child: Focus(
  //                         // focusNode: downloadButtonFocusNode,
  //                         child: Builder(builder: (context) {
  //                           final isFocused = Focus.of(context).hasFocus;
  //                           return Container(
  //                             decoration: BoxDecoration(
  //                               borderRadius: BorderRadius.circular(10),
  //                               border: Border.all(
  //                                 color: isFocused
  //                                     ? Colors.amber
  //                                     : Colors.transparent,
  //                                 width: 3,
  //                               ),
  //                               boxShadow: isFocused && isTV
  //                                   ? [
  //                                       BoxShadow(
  //                                         color: Colors.amber.withOpacity(0.5),
  //                                         blurRadius: 8,
  //                                         spreadRadius: 2,
  //                                       )
  //                                     ]
  //                                   : null,
  //                             ),
  //                             child: OutlinedButton.icon(
  //                               onPressed: buttonState.isPreparingDownload ||
  //                                       buttonState.isDownloading
  //                                   ? null // Disable during download
  //                                   : () async {
  //                                       if (showGoToDownloads) {
  //                                         ref
  //                                             .read(selectedIndexProvider
  //                                                 .notifier)
  //                                             .state = 1;
  //                                         Navigator.push(
  //                                           context,
  //                                           MaterialPageRoute(
  //                                               builder: (context) =>
  //                                                   ResponsiveNavigation()),
  //                                         );
  //                                       } else {
  //                                         // Show initial feedback
  //                                         ScaffoldMessenger.of(context)
  //                                             .showSnackBar(
  //                                           const SnackBar(
  //                                               content: Text(
  //                                                   'Preparing download...')),
  //                                         );
  //                                         // Start preparing for download
  //                                         ref
  //                                             .read(downloadButtonStateProvider(
  //                                                     widget.movieId)
  //                                                 .notifier)
  //                                             .setPreparingDownload(true);

  //                                         try {
  //                                           // Get and validate the media URL
  //                                           final mediaUrl =
  //                                               "$baseUrl/drm/getmasterplaylist/$transformedMediaType/${movie.id}";
  //                                           final mediaUrlValidity =
  //                                               await ref.read(
  //                                                   trailerUrlValidityProvider(
  //                                                           mediaUrl)
  //                                                       .future);

  //                                           if (mediaUrlValidity.isEmpty) {
  //                                             ref
  //                                                 .read(
  //                                                     downloadButtonStateProvider(
  //                                                             widget.movieId)
  //                                                         .notifier)
  //                                                 .setPreparingDownload(false);

  //                                             if (mounted) {
  //                                               ScaffoldMessenger.of(context)
  //                                                   .showSnackBar(
  //                                                 const SnackBar(
  //                                                     content: Text(
  //                                                         'No media available to download.')),
  //                                               );
  //                                             }
  //                                             return;
  //                                           }

  //                                           // Start the download using our method
  //                                           final success = await ref
  //                                               .read(
  //                                                   downloadButtonStateProvider(
  //                                                           widget.movieId)
  //                                                       .notifier)
  //                                               .startDownload(
  //                                                 mediaUrl: mediaUrlValidity,
  //                                                 movieId: movie.id,
  //                                                 title: movie.title,
  //                                                 context: context,
  //                                                 mediaType: widget.mediaType,
  //                                                 transformedMediaTypebanner:
  //                                                     transformedMediaTypebanner,
  //                                               );

  //                                           if (success && mounted) {
  //                                             ScaffoldMessenger.of(context)
  //                                                 .showSnackBar(
  //                                               SnackBar(
  //                                                 content: const Text(
  //                                                     'Download started. Go to Downloads page to view progress.'),
  //                                                 action: SnackBarAction(
  //                                                   label: 'Go Now',
  //                                                   onPressed: () {
  //                                                     Navigator.push(
  //                                                       context,
  //                                                       MaterialPageRoute(
  //                                                           builder: (context) =>
  //                                                               DownloadsPage()),
  //                                                     );
  //                                                   },
  //                                                 ),
  //                                               ),
  //                                             );
  //                                           }
  //                                         } catch (e) {
  //                                           ref
  //                                               .read(
  //                                                   downloadButtonStateProvider(
  //                                                           widget.movieId)
  //                                                       .notifier)
  //                                               .setPreparingDownload(false);

  //                                           if (mounted) {
  //                                             ScaffoldMessenger.of(context)
  //                                                 .showSnackBar(
  //                                               SnackBar(
  //                                                   content: Text(
  //                                                       'Error: ${e.toString()}')),
  //                                             );
  //                                           }
  //                                         }
  //                                       }
  //                                     },
  //                               icon: buttonState.isPreparingDownload
  //                                   ? const SizedBox(
  //                                       width: 16,
  //                                       height: 16,
  //                                       child: CircularProgressIndicator(
  //                                           strokeWidth: 2))
  //                                   : buttonState.isDownloading
  //                                       ? const SizedBox(
  //                                           width: 16,
  //                                           height: 16,
  //                                           child: CircularProgressIndicator(
  //                                               strokeWidth: 2,
  //                                               valueColor:
  //                                                   AlwaysStoppedAnimation<
  //                                                       Color>(Colors.white)))
  //                                       : showGoToDownloads
  //                                           ? const Icon(Icons.download_done,
  //                                               color: Colors.green)
  //                                           : Icon(Icons.download,
  //                                               color: Theme.of(context)
  //                                                   .primaryColorDark),
  //                               label: buttonState.isPreparingDownload
  //                                   ? const Text("Starting...",
  //                                       style: TextStyle(color: Colors.white))
  //                                   : buttonState.isDownloading
  //                                       ? const Text("Downloading...",
  //                                           style:
  //                                               TextStyle(color: Colors.white))
  //                                       : showGoToDownloads
  //                                           ? const Text("Go to Downloads",
  //                                               style: TextStyle(
  //                                                   color: Colors.white))
  //                                           : Text("Download",
  //                                               style: TextStyle(
  //                                                   color: Theme.of(context)
  //                                                       .primaryColorDark)),
  //                               style: OutlinedButton.styleFrom(
  //                                 backgroundColor: isDarkMode
  //                                     ? Colors.grey[900]
  //                                     : Colors.grey[50],
  //                                 padding:
  //                                     const EdgeInsets.symmetric(vertical: 12),
  //                                 side: BorderSide(
  //                                   color: buttonState.isPreparingDownload ||
  //                                           buttonState.isDownloading
  //                                       ? Colors.blue
  //                                       : showGoToDownloads
  //                                           ? Colors.green
  //                                           : Theme.of(context)
  //                                               .primaryColorDark,
  //                                 ),
  //                                 foregroundColor: Colors.white,
  //                                 disabledForegroundColor:
  //                                     buttonState.isDownloading
  //                                         ? Colors.white.withOpacity(0.7)
  //                                         : Colors.grey.withOpacity(0.5),
  //                                 disabledBackgroundColor:
  //                                     buttonState.isDownloading
  //                                         ? Colors.blue.withOpacity(0.1)
  //                                         : null,
  //                               ),
  //                             ),
  //                           );
  //                         }),
  //                       ),
  //                     ),
  //             ],
  //           ),
  //         );
  //       }
  //     },
  //     loading: () => const Center(child: Buttonskelton()),
  //     error: (_, __) => Padding(
  //       padding: const EdgeInsets.symmetric(horizontal: 16.0),
  //       child: Row(
  //         children: [
  //           // Favorite Button still works even if auth fails
  //           Expanded(
  //             child: Focus(
  //               focusNode: favoriteButtonFocusNode,
  //               child: Builder(builder: (context) {
  //                 final isFocused = Focus.of(context).hasFocus;
  //                 return Container(
  //                   decoration: BoxDecoration(
  //                     borderRadius: BorderRadius.circular(10),
  //                     border: Border.all(
  //                       color: isFocused ? Colors.amber : Colors.transparent,
  //                       width: 3,
  //                     ),
  //                     boxShadow: isFocused && isTV
  //                         ? [
  //                             BoxShadow(
  //                               color: Colors.amber.withOpacity(0.5),
  //                               blurRadius: 8,
  //                               spreadRadius: 2,
  //                             )
  //                           ]
  //                         : null,
  //                   ),
  //                   child: OutlinedButton.icon(
  //                     onPressed: () {
  //                       // Show login dialog if not authenticated
  //                       showDialog(
  //                         context: context,
  //                         builder: (context) => AlertDialog(
  //                           title: const Text("Authentication Required"),
  //                           content: const Text(
  //                               "Please login to add items to favorites."),
  //                           actions: [
  //                             TextButton(
  //                               onPressed: () => Navigator.pop(context),
  //                               child: const Text("Cancel"),
  //                             ),
  //                             TextButton(
  //                               onPressed: () {
  //                                 Navigator.pop(context);
  //                                 Navigator.push(
  //                                   context,
  //                                   MaterialPageRoute(
  //                                       builder: (context) => LoginScreen()),
  //                                 );
  //                               },
  //                               child: const Text("Login"),
  //                             ),
  //                           ],
  //                         ),
  //                       );
  //                     },
  //                     icon: Icon(
  //                       Icons.favorite_border,
  //                       color: const Color.fromARGB(255, 255, 123, 0),
  //                     ),
  //                     label: Text(
  //                       "Add to Favorites",
  //                       style: const TextStyle(
  //                           color: Color.fromARGB(255, 255, 123, 0)),
  //                     ),
  //                     style: OutlinedButton.styleFrom(
  //                       padding: const EdgeInsets.symmetric(vertical: 12),
  //                       side: const BorderSide(
  //                           color: Color.fromARGB(255, 224, 129, 5)),
  //                     ),
  //                   ),
  //                 );
  //               }),
  //             ),
  //           ),
  //           const SizedBox(width: 10),

  //           // Show login required download button
  //           widget.mediaType == "TVSeries" ||
  //                   widget.mediaType == "tvseries" ||
  //                   isTV ||
  //                   isIos
  //               ? const SizedBox()
  //               : Expanded(
  //                   child: Builder(builder: (context) {
  //                     final isFocused = Focus.of(context).hasFocus;
  //                     return Container(
  //                       decoration: BoxDecoration(
  //                         borderRadius: BorderRadius.circular(10),
  //                         border: Border.all(
  //                           color:
  //                               isFocused ? Colors.amber : Colors.transparent,
  //                           width: 3,
  //                         ),
  //                         boxShadow: isFocused && isTV
  //                             ? [
  //                                 BoxShadow(
  //                                   color: Colors.amber.withOpacity(0.5),
  //                                   blurRadius: 8,
  //                                   spreadRadius: 2,
  //                                 )
  //                               ]
  //                             : null,
  //                       ),
  //                       child: OutlinedButton.icon(
  //                         onPressed: () {
  //                           Navigator.push(
  //                             context,
  //                             MaterialPageRoute(
  //                                 builder: (context) => LoginScreen()),
  //                           );
  //                         },
  //                         icon: const Icon(Icons.login, color: Colors.grey),
  //                         label: const Text("Login to Download",
  //                             style: TextStyle(color: Colors.grey)),
  //                         style: OutlinedButton.styleFrom(
  //                           padding: const EdgeInsets.symmetric(vertical: 12),
  //                           side: const BorderSide(color: Colors.grey),
  //                         ),
  //                       ),
  //                     );
  //                   }),
  //                 ),
  //         ],
  //       ),
  //     ),
  //   );
  // }

  //*old backend working button without sub and rental*//
  //********************************************* */

  Widget _buildFavoriteDownloadButtons(
      MovieDetail movie, BuildContext context) {
    final isTV = AppSizes.getDeviceType(context) == DeviceType.tv;

    final Map<String, String> mediaTypeMapbanner = {
      'videosong': 'videosong',
      'shortfilm': 'shortfilm',
      'documentary': 'documentary',
      'episodes': 'episode',
      'movie': 'movie',
      'tvseries': 'tvseries',
      'VideoSong': 'videosong',
      'ShortFilm': 'shortfilm',
      'Documentary': 'documentary',
      'Movie': 'movie',
      'TVSeries': 'tvseries',
    };

    final transformedMediaTypebanner =
        mediaTypeMapbanner[widget.mediaType] ?? widget.mediaType;

    final Map<String, String> mediaTypeMap = {
      'videosong': 'videosongs',
      'shortfilm': 'shortfilms',
      'documentary': 'documentaries',
      'episodes': 'episode',
      'movie': 'movies',
      'tvseries': 'tvseries',
      'VideoSong': 'videosongs',
      'ShortFilm': 'shortfilms',
      'Documentary': 'documentaries',
      'Movie': 'movies',
      'TVSeries': 'tvseries',
    };

    final transformedMediaType =
        mediaTypeMap[widget.mediaType] ?? widget.mediaType;

    bool isRentable = movie.accessParams?.isRentable == true;
    bool isFree = movie.accessParams?.isFree == true;
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    final authUser = ref.watch(authUserProvider);
    final buttonState = ref.watch(downloadButtonStateProvider(widget.movieId));
    return authUser.when(
      data: (user) {
        // When no user is logged in
        if (user == null) {
          return const SizedBox();
        } else {
          // User is logged in, show appropriate buttons based on rental/subscription status
          final isFavorite = ref.watch(isMovieFavoriteProvider(movie.id));
          final rentals = ref.watch(rentalProvider);
          final subscriptions = ref.watch(subscriptionProvider(
              SubscriptionDetailParameter(userId: user.id)));

          // Simplify button logic by using our dedicated state provider
          final showGoToDownloads = buttonState.isDownloaded ||
              buttonState.isDownloading ||
              buttonState.isPaused;

          return rentals.when(
            data: (rentalList) {
              // Check if the user has rented this movie
              bool hasRented = rentalList.any((rental) =>
                  rental.userId == user.id && rental.movieId == movie.id);

              return subscriptions.when(
                data: (subscription) {
                  // Check if user has active subscription
                  bool isSubscribed =
                      subscription?.subscriptionType.name != "Free";

                  // Determine if download is allowed based on rental/subscription/free status
                  bool canDownload = hasRented || isSubscribed || isFree;

                  // Don't allow downloads for TV series
                  bool isTVSeries = widget.mediaType == "TVSeries" ||
                      widget.mediaType == "tvseries";

                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Row(
                      children: [
                        // Favorite Button with focus
                        Expanded(
                          child: Focus(
                            focusNode: favoriteButtonFocusNode,
                            onKey: (node, event) {
                              if (event is RawKeyDownEvent) {
                                if (event.logicalKey ==
                                        LogicalKeyboardKey.select ||
                                    event.logicalKey ==
                                        LogicalKeyboardKey.enter) {
                                  ref
                                      .read(favoritesProvider.notifier)
                                      .toggleFavorite(
                                        movie.id,
                                        widget.mediaType,
                                      );
                                  return KeyEventResult.handled;
                                }
                              }
                              return KeyEventResult.ignored;
                            },
                            child: Builder(builder: (context) {
                              final isFocused = Focus.of(context).hasFocus;
                              return Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: isFocused
                                        ? Colors.amber
                                        : Colors.transparent,
                                    width: 3,
                                  ),
                                  boxShadow: isFocused && isTV
                                      ? [
                                          BoxShadow(
                                            color:
                                                Colors.amber.withOpacity(0.5),
                                            blurRadius: 8,
                                            spreadRadius: 2,
                                          )
                                        ]
                                      : null,
                                ),
                                child: OutlinedButton.icon(
                                  onPressed: () {
                                    ref
                                        .read(favoritesProvider.notifier)
                                        .toggleFavorite(
                                          movie.id,
                                          widget.mediaType,
                                        );
                                  },
                                  icon: ShaderMask(
                                    shaderCallback: (Rect bounds) {
                                      return const LinearGradient(
                                        colors: [
                                          Color.fromARGB(255, 255, 187, 0),
                                          Color.fromARGB(255, 255, 123, 0)
                                        ],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      ).createShader(bounds);
                                    },
                                    child: Icon(
                                      isFavorite
                                          ? Icons.favorite
                                          : Icons.favorite_border,
                                      color: Colors.white,
                                    ),
                                  ),
                                  label: ShaderMask(
                                    shaderCallback: (Rect bounds) {
                                      return const LinearGradient(
                                        colors: [
                                          Color.fromARGB(255, 255, 187, 0),
                                          Color.fromARGB(255, 255, 123, 0)
                                        ],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      ).createShader(bounds);
                                    },
                                    child: Text(
                                      isFavorite
                                          ? "Remove Favorite"
                                          : "Add to Favorites",
                                      style:
                                          const TextStyle(color: Colors.white),
                                    ),
                                  ),
                                  style: OutlinedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 12),
                                    side: const BorderSide(
                                        color:
                                            Color.fromARGB(255, 224, 129, 5)),
                                    foregroundColor: Colors.white,
                                  ),
                                ),
                              );
                            }),
                          ),
                        ),
                        const SizedBox(width: 10),

                        // Download Button with focus
                        isTVSeries || isTV || isIos
                            ? const SizedBox()
                            : Expanded(
                                child: Builder(builder: (context) {
                                  final isFocused =
                                      Focus.of(context).hasFocus;
                                  return Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(
                                        color: isFocused
                                            ? Colors.amber
                                            : Colors.transparent,
                                        width: 3,
                                      ),
                                      boxShadow: isFocused
                                          ? [
                                              BoxShadow(
                                                color: Colors.amber
                                                    .withOpacity(0.5),
                                                blurRadius: 8,
                                                spreadRadius: 2,
                                              )
                                            ]
                                          : null,
                                    ),
                                    child: OutlinedButton.icon(
                                      onPressed: !canDownload ||
                                              buttonState
                                                  .isPreparingDownload ||
                                              buttonState.isDownloading
                                          ? null // Disable button if not allowed or during download
                                          : () async {
                                              if (showGoToDownloads) {
                                                ref
                                                    .read(
                                                        selectedIndexProvider
                                                            .notifier)
                                                    .state = 1;
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: (context) =>
                                                          ResponsiveNavigation()),
                                                );
                                              } else {
                                                // Show initial feedback
                                                ScaffoldMessenger.of(context)
                                                    .showSnackBar(
                                                  const SnackBar(
                                                      content: Text(
                                                          'Preparing download...')),
                                                );
                                                // Start preparing for download
                                                ref
                                                    .read(
                                                        downloadButtonStateProvider(
                                                                widget
                                                                    .movieId)
                                                            .notifier)
                                                    .setPreparingDownload(
                                                        true);

                                                try {
                                                  // Get and validate the media URL
                                                  final mediaUrl =
                                                      "$baseUrl/drm/getmasterplaylist/$transformedMediaType/${movie.id}";
                                                  final mediaUrlValidity =
                                                      await ref.read(
                                                          trailerUrlValidityProvider(
                                                                  mediaUrl)
                                                              .future);

                                                  if (mediaUrlValidity
                                                      .isEmpty) {
                                                    ref
                                                        .read(downloadButtonStateProvider(
                                                                widget
                                                                    .movieId)
                                                            .notifier)
                                                        .setPreparingDownload(
                                                            false);

                                                    if (mounted) {
                                                      ScaffoldMessenger.of(
                                                              context)
                                                          .showSnackBar(
                                                        const SnackBar(
                                                            content: Text(
                                                                'No media available to download.')),
                                                      );
                                                    }
                                                    return;
                                                  }

                                                  // Start the download using our method
                                                  final success = await ref
                                                      .read(
                                                          downloadButtonStateProvider(
                                                                  widget
                                                                      .movieId)
                                                              .notifier)
                                                      .startDownload(
                                                        mediaUrl:
                                                            mediaUrlValidity,
                                                        movieId: movie.id,
                                                        title: movie.title,
                                                        context: context,
                                                        mediaType:
                                                            widget.mediaType,
                                                        transformedMediaTypebanner:
                                                            transformedMediaTypebanner,
                                                      );

                                                  if (success && mounted) {
                                                    ScaffoldMessenger.of(
                                                            context)
                                                        .showSnackBar(
                                                      SnackBar(
                                                        content: const Text(
                                                            'Download started. Go to Downloads page to view progress.'),
                                                        action:
                                                            SnackBarAction(
                                                          label: 'Go Now',
                                                          onPressed: () {
                                                            Navigator.push(
                                                              context,
                                                              MaterialPageRoute(
                                                                  builder:
                                                                      (context) =>
                                                                          DownloadsPage()),
                                                            );
                                                          },
                                                        ),
                                                      ),
                                                    );
                                                  }
                                                } catch (e) {
                                                  ref
                                                      .read(
                                                          downloadButtonStateProvider(
                                                                  widget
                                                                      .movieId)
                                                              .notifier)
                                                      .setPreparingDownload(
                                                          false);

                                                  if (mounted) {
                                                    ScaffoldMessenger.of(
                                                            context)
                                                        .showSnackBar(
                                                      SnackBar(
                                                          content: Text(
                                                              'Error: ${e.toString()}')),
                                                    );
                                                  }
                                                }
                                              }
                                            },
                                      icon: !canDownload
                                          ? const Icon(
                                              Icons.file_download_off,
                                              color: Colors.grey)
                                          : buttonState.isPreparingDownload
                                              ? const SizedBox(
                                                  width: 16,
                                                  height: 16,
                                                  child:
                                                      CircularProgressIndicator(
                                                          strokeWidth: 2))
                                              : buttonState.isDownloading
                                                  ? const SizedBox(
                                                      width: 16,
                                                      height: 16,
                                                      child: CircularProgressIndicator(
                                                          strokeWidth: 2,
                                                          valueColor:
                                                              AlwaysStoppedAnimation<
                                                                      Color>(
                                                                  Colors
                                                                      .white)))
                                                  : showGoToDownloads
                                                      ? const Icon(
                                                          Icons.download_done,
                                                          color: Colors.green)
                                                      : Icon(Icons.download,
                                                          color: Theme.of(
                                                                  context)
                                                              .primaryColorDark),
                                      label: !canDownload
                                          ? _getDownloadButtonText(
                                              isRentable, isSubscribed)
                                          : buttonState.isPreparingDownload
                                              ? const Text("Starting...",
                                                  style: TextStyle(
                                                      color: Colors.white))
                                              : buttonState.isDownloading
                                                  ? const Text(
                                                      "Downloading...",
                                                      style: TextStyle(
                                                          color:
                                                              Colors.white))
                                                  : showGoToDownloads
                                                      ? const Text(
                                                          "Go to Downloads",
                                                          style: TextStyle(
                                                              color: Colors
                                                                  .white))
                                                      : Text("Download",
                                                          style: TextStyle(
                                                              color: Theme.of(
                                                                      context)
                                                                  .primaryColorDark)),
                                      style: OutlinedButton.styleFrom(
                                        backgroundColor: isDarkMode
                                            ? Colors.grey[900]
                                            : Colors.grey[50],
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 12),
                                        side: BorderSide(
                                          color: !canDownload
                                              ? Colors.grey
                                              : buttonState
                                                          .isPreparingDownload ||
                                                      buttonState
                                                          .isDownloading
                                                  ? Colors.blue
                                                  : showGoToDownloads
                                                      ? Colors.green
                                                      : Theme.of(context)
                                                          .primaryColorDark,
                                        ),
                                        foregroundColor: Colors.white,
                                        disabledForegroundColor: buttonState
                                                .isDownloading
                                            ? Colors.white.withOpacity(0.7)
                                            : Colors.grey.withOpacity(0.5),
                                        disabledBackgroundColor:
                                            buttonState.isDownloading
                                                ? Colors.blue.withOpacity(0.1)
                                                : null,
                                      ),
                                    ),
                                  );
                                }),
                              ),
                      ],
                    ),
                  );
                },
                loading: () => const Center(child: Buttonskelton()),
                error: (_, __) => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    children: [
                      // Favorite Button still works even if subscription info fails
                      Expanded(
                        child: Focus(
                          focusNode: favoriteButtonFocusNode,
                          child: Builder(builder: (context) {
                            final isFocused = Focus.of(context).hasFocus;
                            return Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: isFocused
                                      ? Colors.amber
                                      : Colors.transparent,
                                  width: 3,
                                ),
                                boxShadow: isFocused
                                    ? [
                                        BoxShadow(
                                          color: Colors.amber.withOpacity(0.5),
                                          blurRadius: 8,
                                          spreadRadius: 2,
                                        )
                                      ]
                                    : null,
                              ),
                              child: OutlinedButton.icon(
                                onPressed: () {
                                  ref
                                      .read(favoritesProvider.notifier)
                                      .toggleFavorite(
                                        movie.id,
                                        widget.mediaType,
                                      );
                                },
                                icon: Icon(
                                  isFavorite
                                      ? Icons.favorite
                                      : Icons.favorite_border,
                                  color: const Color.fromARGB(255, 255, 123, 0),
                                ),
                                label: Text(
                                  isFavorite
                                      ? "Remove Favorite"
                                      : "Add to Favorites",
                                  style: const TextStyle(
                                      color: Color.fromARGB(255, 255, 123, 0)),
                                ),
                                style: OutlinedButton.styleFrom(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 12),
                                  side: const BorderSide(
                                      color: Color.fromARGB(255, 224, 129, 5)),
                                ),
                              ),
                            );
                          }),
                        ),
                      ),
                      const SizedBox(width: 10),

                      // Show disabled download button with error
                      widget.mediaType == "TVSeries" ||
                              widget.mediaType == "tvseries"
                          ? const SizedBox()
                          : Expanded(
                              child: Builder(builder: (context) {
                                final isFocused = Focus.of(context).hasFocus;
                                return Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                      color: isFocused
                                          ? Colors.amber
                                          : Colors.transparent,
                                      width: 3,
                                    ),
                                    boxShadow: isFocused
                                        ? [
                                            BoxShadow(
                                              color: Colors.amber
                                                  .withOpacity(0.5),
                                              blurRadius: 8,
                                              spreadRadius: 2,
                                            )
                                          ]
                                        : null,
                                  ),
                                  child: OutlinedButton.icon(
                                    onPressed: null,
                                    icon: const Icon(Icons.error,
                                        color: Colors.grey),
                                    label: const Text(
                                        "Unable to verify access",
                                        style: TextStyle(color: Colors.grey)),
                                    style: OutlinedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 12),
                                      side: const BorderSide(
                                          color: Colors.grey),
                                    ),
                                  ),
                                );
                              }),
                            ),
                    ],
                  ),
                ),
              );
            },
            loading: () => const Center(child: Buttonskelton()),
            error: (_, __) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: [
                  // Favorite Button still works even if rental info fails
                  Expanded(
                    child: Focus(
                      focusNode: favoriteButtonFocusNode,
                      child: Builder(builder: (context) {
                        final isFocused = Focus.of(context).hasFocus;
                        return Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color:
                                  isFocused ? Colors.amber : Colors.transparent,
                              width: 3,
                            ),
                            boxShadow: isFocused
                                ? [
                                    BoxShadow(
                                      color: Colors.amber.withOpacity(0.5),
                                      blurRadius: 8,
                                      spreadRadius: 2,
                                    )
                                  ]
                                : null,
                          ),
                          child: OutlinedButton.icon(
                            onPressed: () {
                              ref
                                  .read(favoritesProvider.notifier)
                                  .toggleFavorite(
                                    movie.id,
                                    widget.mediaType,
                                  );
                            },
                            icon: Icon(
                              isFavorite
                                  ? Icons.favorite
                                  : Icons.favorite_border,
                              color: const Color.fromARGB(255, 255, 123, 0),
                            ),
                            label: Text(
                              isFavorite
                                  ? "Remove Favorite"
                                  : "Add to Favorites",
                              style: const TextStyle(
                                  color: Color.fromARGB(255, 255, 123, 0)),
                            ),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              side: const BorderSide(
                                  color: Color.fromARGB(255, 224, 129, 5)),
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
                  const SizedBox(width: 10),

                  // Show disabled download button with error
                  widget.mediaType == "TVSeries" ||
                          widget.mediaType == "tvseries"
                      ? const SizedBox()
                      : Expanded(
                          child: Builder(builder: (context) {
                            final isFocused = Focus.of(context).hasFocus;
                            return Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: isFocused
                                      ? Colors.amber
                                      : Colors.transparent,
                                  width: 3,
                                ),
                                boxShadow: isFocused
                                    ? [
                                        BoxShadow(
                                          color:
                                              Colors.amber.withOpacity(0.5),
                                          blurRadius: 8,
                                          spreadRadius: 2,
                                        )
                                      ]
                                    : null,
                              ),
                              child: OutlinedButton.icon(
                                onPressed: null,
                                icon: const Icon(Icons.error,
                                    color: Colors.grey),
                                label: const Text("Unable to verify access",
                                    style: TextStyle(color: Colors.grey)),
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 12),
                                  side: const BorderSide(color: Colors.grey),
                                ),
                              ),
                            );
                          }),
                        ),
                ],
              ),
            ),
          );
        }
      },
      loading: () => const Center(child: Buttonskelton()),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  // Helper method to get the appropriate button text based on movie status
  Text _getDownloadButtonText(bool isRentable, bool isSubscribed) {
    if (isRentable && !isSubscribed) {
      return const Text("Rent", style: TextStyle(color: Colors.grey));
    } else if (!isRentable && !isSubscribed) {
      return const Text("Subscribe", style: TextStyle(color: Colors.grey));
    } else {
      return const Text("No Download", style: TextStyle(color: Colors.grey));
    }
  }

  // Cast Section with enhanced focus
  Widget _buildCastSection(CastDetails? castDetails, BuildContext context) {
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    if (castDetails == null) return const SizedBox.shrink();

    // Creating a combined list of non-empty cast members with their roles
    List<Map<String, String>> castList = [];

    void addToCastList(List<String> members, String role) {
      for (var member in members) {
        if (member.trim().isNotEmpty) {
          castList.add({"name": member, "role": role});
        }
      }
    }

    addToCastList(castDetails.actors, "Actor");
    addToCastList(castDetails.producers, "Producer");
    addToCastList(castDetails.directors, "Director");
    addToCastList(castDetails.singers, "Singer");
    addToCastList(castDetails.writers, "Writer");
    addToCastList(castDetails.composers, "Composer");

    if (castList.isEmpty) {
      return const SizedBox.shrink(); // Hide if all lists are empty
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Cast",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 100,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: castList.length,
            separatorBuilder: (_, __) => const SizedBox(width: 10),
            itemBuilder: (context, index) {
              return Builder(builder: (context) {
                return Focus(
                  autofocus: index == 0 &&
                      AppSizes.getDeviceType(context) == DeviceType.tv,
                  child: Builder(
                    builder: (context) {
                      final isFocused = Focus.of(context).hasFocus;
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color:
                                isFocused ? Colors.amber : Colors.transparent,
                            width: 3,
                          ),
                          boxShadow: isFocused
                              ? [
                                  BoxShadow(
                                    color: Colors.amber.withOpacity(0.5),
                                    blurRadius: 8,
                                    spreadRadius: 2,
                                  )
                                ]
                              : null,
                          color: isFocused
                              ? Colors.amber.withOpacity(0.1)
                              : Theme.of(context).brightness == Brightness.dark
                                  ? Colors.grey[800]
                                  : Colors.grey[300],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              castList[index]["name"]!,
                              style: const TextStyle(
                                  fontSize: 14, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              castList[index]["role"]!,
                              style: const TextStyle(
                                  fontSize: 12, color: Color(0xFFF4AE00)),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                );
              });
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSeasonSelector(BuildContext context, WidgetRef ref) {
    final seasonsAsync = ref.watch(seasonsProvider(widget.movieId));
    final selectedSeason = ref.watch(selectedSeasonProvider);

    return seasonsAsync.when(
      loading: () => const Center(child: Buttonskelton()),
      error: (err, stack) => Text(err.toString()),
      data: (seasons) {
        if (seasons.isEmpty) return const Text("No seasons available.");

        final defaultSeason = selectedSeason ?? seasons.first;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (selectedSeason == null) {
            ref.read(selectedSeasonProvider.notifier).state = defaultSeason;
          }
        });

        // Make the season selector itself focusable
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Dropdown with focus support
            Focus(
              onKey: (node, event) {
                if (event is RawKeyDownEvent &&
                    (event.logicalKey == LogicalKeyboardKey.select ||
                        event.logicalKey == LogicalKeyboardKey.enter)) {
                  showSeasonSelectorDialog(
                    context: context,
                    seasons: seasons,
                    onSelected: (season) => ref
                        .read(selectedSeasonProvider.notifier)
                        .state = season,
                  );
                  return KeyEventResult.handled;
                }
                return KeyEventResult.ignored;
              },
              child: Builder(builder: (context) {
                final isFocused = Focus.of(context).hasFocus;
                return Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isFocused ? Colors.amber : Colors.grey.shade300,
                      width: isFocused ? 3 : 1,
                    ),
                    boxShadow: isFocused
                        ? [
                            BoxShadow(
                              color: Colors.amber.withOpacity(0.5),
                              blurRadius: 8,
                              spreadRadius: 2,
                            )
                          ]
                        : null,
                  ),
                  child: InkWell(
                    onTap: () => showSeasonSelectorDialog(
                      context: context,
                      seasons: seasons,
                      onSelected: (season) => ref
                          .read(selectedSeasonProvider.notifier)
                          .state = season,
                    ),
                    child: InputDecorator(
                      decoration: InputDecoration(
                        labelText: 'Select Season',
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8)),
                        enabledBorder: InputBorder.none,
                        disabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                              'Season ${defaultSeason.seasonNumber} (${defaultSeason.status ?? "Unknown"})'),
                          const Icon(Icons.arrow_drop_down),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: 16),
            // Now the episode section
            _buildEpisodeSection(ref, widget.movieId),
          ],
        );
      },
    );
  }

  Widget _buildEpisodeSection(WidgetRef ref, String seriesId) {
    final authUser = ref.watch(authUserProvider);
    final episodesState = ref.watch(
      paginatedEpisodesProvider((seriesId: seriesId)),
    );

    if (episodesState.hasError) {
      return const Center(child: Text("Failed to load episodes"));
    }

    if (episodesState.episodes.isEmpty && episodesState.isLoading) {
      return const Center(child: Buttonskelton());
    }

    // Use a direct List<Widget> approach for better control
    List<Widget> episodeWidgets = [];

    // Create individually focusable episode items
    for (int i = 0; i < episodesState.episodes.length; i++) {
      final episode = episodesState.episodes[i];
      final isPublished =
          episode.status == 'published' || episode.status == 'active';

      // Create a standalone focusable widget for each episode
      episodeWidgets.add(
        Padding(
          padding: const EdgeInsets.only(bottom: 12.0),
          child: _buildFocusableEpisode(
            context: context,
            ref: ref,
            episode: episode,
            isPublished: isPublished,
            index: i,
            seriesId: seriesId,
          ),
        ),
      );
    }

    // Add View More button if needed
    if (episodesState.currentPage < episodesState.totalPages) {
      episodeWidgets.add(
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: ElevatedButton(
            onPressed: () {
              ref
                  .read(
                      paginatedEpisodesProvider((seriesId: seriesId)).notifier)
                  .fetchNextPage();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.amber,
              foregroundColor: Colors.black,
            ),
            child: episodesState.isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Text("View More"),
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: episodeWidgets,
    );
  }

// Dedicated method for building focusable episodes
  Widget _buildFocusableEpisode({
    required BuildContext context,
    required WidgetRef ref,
    required dynamic episode,
    required bool isPublished,
    required int index,
    required String seriesId,
  }) {
    final posterAsync = ref.watch(posterProvider(episode.id));
    final authUser = ref.watch(authUserProvider);

    // Create a separate focus node for explicit control
    FocusNode episodeFocusNode = FocusNode(debugLabel: 'episode-$index');

    return Focus(
      focusNode: episodeFocusNode,
      canRequestFocus: true,
      descendantsAreFocusable:
          false, // Important: prevent descendants from receiving focus
      onKey: (node, event) {
        if (event is RawKeyDownEvent &&
            (event.logicalKey == LogicalKeyboardKey.select ||
                event.logicalKey == LogicalKeyboardKey.enter)) {
          // Handle user auth check and episode playback
          _handleEpisodeSelection(
            context,
            ref,
            authUser,
            episode,
            isPublished,
            seriesId,
          );
          return KeyEventResult.handled;
        }
        return KeyEventResult.ignored;
      },
      child: Builder(
        builder: (context) {
          final isFocused = Focus.of(context).hasFocus;
          return GestureDetector(
            onTap: () {
              // Request focus when tapped (important for TV)
              FocusScope.of(context).requestFocus(episodeFocusNode);
              // Handle the episode selection
              _handleEpisodeSelection(
                context,
                ref,
                authUser,
                episode,
                isPublished,
                seriesId,
              );
            },
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(
                  color:
                      isFocused ? Colors.amber : Colors.grey.withOpacity(0.3),
                  width: isFocused ? 3 : 1,
                ),
                borderRadius: BorderRadius.circular(8),
                color: isFocused ? Colors.amber.withOpacity(0.1) : null,
                boxShadow: isFocused
                    ? [
                        BoxShadow(
                          color: Colors.amber.withOpacity(0.6),
                          blurRadius: 8,
                          spreadRadius: 1,
                        )
                      ]
                    : null,
              ),
              padding: const EdgeInsets.all(8),
              child: Row(
                children: [
                  // Episode thumbnail
                  posterAsync.when(
                    data: (posterUrl) => SizedBox(
                      width: 100,
                      height: 60,
                      child: Stack(
                        children: [
                          if (posterUrl != null)
                            ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: Image.network(
                                posterUrl,
                                width: 100,
                                height: 60,
                                fit: BoxFit.cover,
                              ),
                            ),
                          Center(
                            child: Icon(
                              isPublished
                                  ? Icons.play_circle_filled
                                  : Icons.access_time,
                              color: isPublished ? Colors.green : Colors.orange,
                              size: 30,
                            ),
                          ),
                        ],
                      ),
                    ),
                    loading: () => const SizedBox(
                      width: 100,
                      height: 60,
                      child: Center(child: CircularProgressIndicator()),
                    ),
                    error: (_, __) => const SizedBox(
                      width: 100,
                      height: 60,
                      child: Center(child: Icon(Icons.error)),
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Episode details
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Episode ${episode.episodeNumber ?? "-"}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: isFocused ? Colors.amber : null,
                          ),
                        ),
                        if (episode.description != null)
                          Text(
                            episode.description!,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(fontSize: 12),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

// Handle episode selection based on auth state
  void _handleEpisodeSelection(
    BuildContext context,
    WidgetRef ref,
    AsyncValue<dynamic> authUser,
    dynamic episode,
    bool isPublished,
    String seriesId,
  ) {
    authUser.when(
      data: (user) {
        final isLoggedIn = user != null;

        if (!isLoggedIn) {
          // Show login dialog
          showDialog(
            context: context,
            builder: (_) => AlertDialog(
              title: const Text("Login Required"),
              content: const Text("Please log in to watch this episode."),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Cancel"),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => LoginScreen()),
                    );
                  },
                  child: const Text("Login"),
                ),
              ],
            ),
          );
          return;
        }

        // Check subscription
        final subscription = ref.read(
            subscriptionProvider(SubscriptionDetailParameter(userId: user.id)));

        subscription.when(
          data: (sub) {
            final isSubscribed = sub?.subscriptionType.name != "Free";

            if (!isSubscribed) {
              // Show subscription dialog
              showDialog(
                context: context,
                builder: (_) => AlertDialog(
                  title: const Text("Subscription Required"),
                  content:
                      const Text("Please subscribe to watch this episode."),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text("Cancel"),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                        // Navigate to subscription page
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          backgroundColor: Colors.transparent,
                          builder: (_) => SubscriptionPlanModal(
                            userId: user.id,
                            movieId: seriesId,
                          ),
                        );
                      },
                      child: const Text("Subscribe"),
                    ),
                  ],
                ),
              );
            } else if (!isPublished) {
              // Show coming soon dialog
              showDialog(
                context: context,
                builder: (_) => AlertDialog(
                  title: const Text("Coming Soon"),
                  content: Text(
                      "Episode ${episode.episodeNumber} is scheduled for release soon."),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text("OK"),
                    ),
                  ],
                ),
              );
            } else {
              // Play the episode
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => VideoPlayerScreen(
                    movieId: episode.id,
                    mediaType: "episodes",
                    tvSeriesId: seriesId,
                  ),
                ),
              );
            }
          },
          loading: () {
            // Show loading
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Checking subscription...")),
            );
          },
          error: (_, __) {
            // Show error
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Error checking subscription")),
            );
          },
        );
      },
      loading: () {
        // Show loading
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Checking login status...")),
        );
      },
      error: (_, __) {
        // Show error
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Error checking login status")),
        );
      },
    );
  }

// New helper method to build individual episode items with proper focus
  Widget _buildEpisodeItem(
      BuildContext context,
      WidgetRef ref,
      dynamic episode,
      AsyncValue<String?> posterAsync,
      bool isPublished,
      bool autofocus,
      String seriesId) {
    return posterAsync.when(
      loading: () => const ListTile(
        leading: SizedBox(
          width: 80,
          height: 80,
          child: Center(child: Buttonskelton()),
        ),
        title: Text('Loading episode...'),
      ),
      error: (err, stack) => ListTile(
        leading: const Icon(Icons.error),
        title: Text('Episode ${episode.episodeNumber ?? "-"}'),
        subtitle: const Text("Failed to load poster."),
      ),
      data: (posterUrl) {
        final authUser = ref.watch(authUserProvider);

        return authUser.when(
          loading: () => const ListTile(title: Text("Loading user...")),
          error: (err, _) => const ListTile(title: Text("Error loading user")),
          data: (user) {
            final isLoggedIn = user != null;
            final subscriptionAsync = isLoggedIn
                ? ref.watch(subscriptionProvider(
                    SubscriptionDetailParameter(userId: user.id)))
                : const AsyncValue.data(null);

            return subscriptionAsync.when(
              loading: () =>
                  const ListTile(title: Text("Checking subscription...")),
              error: (err, _) =>
                  const ListTile(title: Text("Subscription error")),
              data: (subscription) {
                final isSubscribed =
                    subscription?.subscriptionType.name != "Free";

                // Make each episode individually focusable
                return Focus(
                  autofocus: autofocus &&
                      AppSizes.getDeviceType(context) == DeviceType.tv,
                  onKey: (node, event) {
                    if (event is RawKeyDownEvent &&
                        (event.logicalKey == LogicalKeyboardKey.select ||
                            event.logicalKey == LogicalKeyboardKey.enter)) {
                      _handleEpisodeTap(context, isLoggedIn, isSubscribed,
                          isPublished, episode, seriesId);
                      return KeyEventResult.handled;
                    }
                    return KeyEventResult.ignored;
                  },
                  child: Builder(
                    builder: (context) {
                      final isFocused = Focus.of(context).hasFocus;
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color:
                                isFocused ? Colors.amber : Colors.transparent,
                            width: 3,
                          ),
                          borderRadius: BorderRadius.circular(6),
                          boxShadow: isFocused
                              ? [
                                  BoxShadow(
                                    color: Colors.amber.withOpacity(0.5),
                                    blurRadius: 8,
                                    spreadRadius: 2,
                                  )
                                ]
                              : null,
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(8),
                          leading: posterUrl != null
                              ? Stack(
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(3),
                                      child: Image.network(
                                        posterUrl,
                                        width: 100,
                                        height: 150,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                    Positioned.fill(
                                      child: Container(
                                          color: Colors.black.withOpacity(0.2)),
                                    ),
                                    Positioned.fill(
                                      child: Align(
                                        alignment: Alignment.center,
                                        child: Icon(
                                          isPublished
                                              ? Icons.play_circle_fill
                                              : Icons.timer_outlined,
                                          color: isPublished
                                              ? Colors.green
                                              : Colors.orange,
                                          size: 30,
                                        ),
                                      ),
                                    ),
                                  ],
                                )
                              : Icon(
                                  isPublished
                                      ? Icons.play_circle_fill
                                      : Icons.timer_outlined,
                                  color: isPublished
                                      ? Colors.green
                                      : Colors.orange,
                                  size: 30,
                                ),
                          title:
                              Text('Episode ${episode.episodeNumber ?? "-"}'),
                          subtitle: episode.description != null
                              ? Text(
                                  episode.description!,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                )
                              : null,
                          onTap: () => _handleEpisodeTap(context, isLoggedIn,
                              isSubscribed, isPublished, episode, seriesId),
                        ),
                      );
                    },
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

// Extract episode tap logic to a separate method for reuse
  void _handleEpisodeTap(BuildContext context, bool isLoggedIn,
      bool isSubscribed, bool isPublished, dynamic episode, String seriesId) {
    if (!isLoggedIn) {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text("Login Required"),
          content: const Text("Please log in to watch this episode."),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => LoginScreen()),
                );
              },
              child: const Text("Login"),
            ),
          ],
        ),
      );
    } else if (!isSubscribed) {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text("Subscription Required"),
          content: const Text("Please subscribe to watch this episode."),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Subscribe"),
            ),
          ],
        ),
      );
    } else if (!isPublished) {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text("Coming Soon"),
          content: Text(
              "Episode ${episode.episodeNumber} is scheduled for release soon."),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("OK"),
            ),
          ],
        ),
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => VideoPlayerScreen(
            movieId: episode.id,
            mediaType: "episodes",
            tvSeriesId: seriesId,
          ),
        ),
      );
    }
  }

  Widget _buildRatingBar(
      BuildContext context, String contentType, String contentId) {
    // Fetch the async value (assuming ratedMoviesProvider is a FutureProvider or StreamProvider)
    final ratedMovieAsyncValue = ref.watch(ratedMovieProvider(
        MovieDetailParameter(
            movieId: widget.movieId, mediaType: widget.mediaType)));

    return ratedMovieAsyncValue.when(
      data: (data) {
        // Handle the data state, for example, showing the rating bar
        return _buildFocusableBox(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "Rate the Movie",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              RatingBar.builder(
                initialRating: (data?['userRating'] as num?)?.toDouble() ?? 0.0,
                minRating: (data?['userRating'] as num?)?.toDouble() ?? 0.0,
                direction: Axis.horizontal,
                allowHalfRating: false,
                itemCount: 5,
                itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
                itemBuilder: (context, _) => Icon(
                  Icons.star,
                  color: Colors.amber,
                ),
                onRatingUpdate: (newRating) {
                  // Store the rating temporarily
                  setState(() {
                    currentRating = newRating;
                  });

                  // Show the confirmation dialog
                  _showRatingConfirmationDialog(
                      context, currentRating, widget.mediaType, widget.movieId);
                },
              ),
            ],
          ),
        );
      },
      loading: () {
        // Handle loading state, maybe show a loading indicator
        return Center(child: CircularProgressIndicator());
      },
      error: (error, stackTrace) {
        // Handle error state, show a message
        return Center(child: Text('Error: $error'));
      },
    );
  }

  void _showRatingConfirmationDialog(BuildContext context, double currentRating,
      String contentType, String contentId) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.amber.shade100, Colors.white],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.transparent,
                    child: Image.asset("")),
                const SizedBox(height: 10),
                Text(
                  "How Would You Rate this $contentType ?",
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.black),
                ),
                const SizedBox(height: 16),
                RatingBar.builder(
                  unratedColor: Colors.grey,
                  initialRating: currentRating,
                  minRating: currentRating,
                  direction: Axis.horizontal,
                  allowHalfRating: false,
                  itemCount: 5,
                  itemBuilder: (context, _) => const Icon(
                    Icons.star,
                    color: Colors.amber,
                  ),
                  onRatingUpdate: (newRating) {
                    setState(() {
                      currentRating = newRating;
                    });
                  },
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size(double.infinity, 45),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    backgroundColor: Colors.amber,
                  ),
                  onPressed: () async {
                    final params = MovieDetailParameter(
                      mediaType: contentType,
                      movieId: contentId,
                      rating: currentRating,
                    );

                    try {
                      final result =
                          await ref.refresh(movieRateProvider(params).future);
                      await ref.refresh(ratedMovieProvider(MovieDetailParameter(
                          movieId: widget.movieId,
                          mediaType: widget.mediaType)));
                      Fluttertoast.showToast(
                        msg: result!,
                        toastLength: Toast.LENGTH_SHORT,
                        gravity: ToastGravity.BOTTOM,
                      );
                    } catch (e) {
                      Fluttertoast.showToast(
                        msg: e.toString().replaceAll('Exception:', ''),
                        toastLength: Toast.LENGTH_SHORT,
                        gravity: ToastGravity.BOTTOM,
                      );
                    }

                    Navigator.of(context).pop();
                  },
                  child: const Text("Submit"),
                ),
                TextButton(
                  onPressed: () async {
                    _resetRating();
                    Navigator.of(context).pop();
                  },
                  child: const Text(
                    "No, Thanks!",
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
