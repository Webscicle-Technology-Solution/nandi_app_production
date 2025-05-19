
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nandiott_flutter/features/rental_download/widget/banner_poster_image.dart';
import 'package:nandiott_flutter/features/auth/page/loginpage_tv.dart';
import 'package:nandiott_flutter/features/movieDetails/page/detail_page.dart';
import 'package:nandiott_flutter/features/auth/providers/checkauth_provider.dart';
import 'package:nandiott_flutter/features/movieDetails/provider/detail_provider.dart';
import 'package:nandiott_flutter/features/subscription_payment/provider/payment_provider.dart';
import 'package:nandiott_flutter/features/rental_download/provider/rental_provider.dart';

class MyRentalPage extends ConsumerStatefulWidget {
  const MyRentalPage({super.key});

  @override
  ConsumerState<MyRentalPage> createState() => _MyRentalPageState();
}

class _MyRentalPageState extends ConsumerState<MyRentalPage> {
  late FocusNode _loginButtonFocusNode;

  @override
  void initState() {
    super.initState();
    _loginButtonFocusNode = FocusNode(debugLabel: 'login_button');

    // Initial setup
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authUserValue = ref.read(authUserProvider);
      if (authUserValue is AsyncData && authUserValue.value == null) {
        _loginButtonFocusNode.requestFocus();
      }
    });

    ref.read(authUserProvider);
    ref.read(rentalProvider);
  }

  void _navigateToLogin() async {
    final response = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => LoginScreen()),
    );
if(response == true){
          ref.invalidate(authUserProvider);
    ref.invalidate(rentalProvider);
    ref.invalidate(rentPaymentProvider);
    ref.invalidate(subsciptionPaymentProvider);
    ref.invalidate(movieDetailProvider);
}
  }

  @override
  void dispose() {
    _loginButtonFocusNode.dispose();
    // TODO: implement dispose
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    ref.invalidate(authUserProvider);
    ref.invalidate(rentalProvider);
  }

  @override
  Widget build(BuildContext context) {
    final authUser = ref.watch(authUserProvider);
    final rentalAsyncValue = ref.watch(rentalProvider);
    final isTV = MediaQuery.of(context).size.width > 600;

    return Scaffold(
    ///  appBar: AppBar(title: const Text('My Rentals')),
      body: authUser.when(
        data: (user) {
          if (user == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "Please login to get active rentals",
                    style: TextStyle(fontSize: 16, color: Colors.red),
                  ),
                  const SizedBox(height: 20),
                  Focus(
                    focusNode: _loginButtonFocusNode,
                    onKey: (node, event) {
                      if (event is RawKeyDownEvent) {
                        if (event.logicalKey == LogicalKeyboardKey.select ||
                            event.logicalKey == LogicalKeyboardKey.enter) {
                          _navigateToLogin();
                          return KeyEventResult.handled;
                        }

                        // CRITICAL: Allow left arrow to navigate to menu
                        if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
                          // Find navigation focus node and request focus
                          FocusNode? navigationNode;
                          FocusManager.instance.rootScope.descendants
                              .forEach((node) {
                            if (node.debugLabel ==
                                'navigation_collapsed_button') {
                              navigationNode = node;
                            }
                          });

                          if (navigationNode != null) {
                            navigationNode!.requestFocus();
                            return KeyEventResult.handled;
                          }
                          return KeyEventResult.ignored;
                        }

                        // Block other directional keys to prevent unintended focus movement
                        if (event.logicalKey == LogicalKeyboardKey.arrowUp ||
                            event.logicalKey == LogicalKeyboardKey.arrowDown ||
                            event.logicalKey == LogicalKeyboardKey.arrowRight) {
                          return KeyEventResult.handled;
                        }
                      }
                      return KeyEventResult.ignored;
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        border: _loginButtonFocusNode.hasFocus && isTV
                            ? Border.all(color: Colors.amber, width: 3)
                            : null,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: ElevatedButton(
                        onPressed: _navigateToLogin,
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(
                              horizontal: 30, vertical: 15),
                          backgroundColor: _loginButtonFocusNode.hasFocus
                              ? Colors.amber
                              : null,
                        ),
                        child: Text(
                          "Login",
                          style: TextStyle(
                            fontSize: 16,
                            color: _loginButtonFocusNode.hasFocus
                                ? Colors.black
                                : null,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }
          return rentalAsyncValue.when(
            data: (rentalData) {
              if (rentalData.isEmpty) {
                return const Center(child: Text('No rentals found'));
              }

              return ListView.builder(
                itemCount: rentalData.length,
                itemBuilder: (context, index) {
                  final rental = rentalData[index];
                  final movieDetailAsyncValue =
                      ref.watch(rentedmovieDetailProvider(rental.movieId));

                  return movieDetailAsyncValue.when(
                    data: (movieDetail) {
                      DateTime endDate =
                          DateTime.parse(rental.endDate.toIso8601String());
                      DateTime currentTime = DateTime.now();
                      Duration difference = endDate.difference(currentTime);

                      String remainingTime;
                      Color bannerColor;

                      if (difference.inHours >= 24) {
                        int days = difference.inDays;
                        int hours = difference.inHours % 24;
                        remainingTime =
                            '$days day${days > 1 ? 's' : ''} $hours hour${hours > 1 ? 's' : ''}';
                        bannerColor = Colors.green;
                      } else if (difference.inMinutes >= 60) {
                        int hours = difference.inHours;
                        int minutes = difference.inMinutes % 60;
                        remainingTime =
                            '$hours hour${hours > 1 ? 's' : ''} $minutes minute${minutes > 1 ? 's' : ''}';
                        bannerColor = Colors.orange;
                      } else {
                        int minutes = difference.inMinutes;
                        remainingTime =
                            '$minutes minute${minutes > 1 ? 's' : ''}';
                        bannerColor = Colors.red;
                      }

                      bool _isFocused = false;

                      return StatefulBuilder(
                        builder: (context, setLocalState) {
                          return Focus(
                            onFocusChange: (hasFocus) {
                              setLocalState(() {
                                _isFocused = hasFocus;
                              });
                            },
                            onKey: (node, event) {
                              if (event is RawKeyDownEvent &&
                                  event.logicalKey ==
                                      LogicalKeyboardKey.select) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => MovieDetailPage(
                                      movieId: movieDetail.id,
                                      mediaType: "movie",
                                      userId: user.id,
                                    ),
                                  ),
                                );
                                return KeyEventResult.handled;
                              }
                              return KeyEventResult.ignored;
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                border: _isFocused
                                    ? Border.all(color: Colors.amber, width: 3)
                                    : null,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Card(
                                margin: const EdgeInsets.all(10),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Stack(
                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                          height: isTV ? 200 : 180,
                                          width: isTV ? 140 : 120,
                                          child: ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                            child: BannerPosterImageWidget(
                                              mediaType: "movie",
                                              mediaId: movieDetail.id,
                                              imageType: "poster",
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 10.0,
                                                vertical: 8.0),
                                            child: Padding(
                                              padding: const EdgeInsets.only(
                                                  left: 20),
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    movieDetail.title,
                                                    style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: isTV ? 22 : 20,
                                                    ),
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                  const SizedBox(height: 6),
                                                  Text(
                                                    'Expires in: $remainingTime',
                                                    style: TextStyle(
                                                      fontSize: isTV ? 14 : 12,
                                                      color: bannerColor,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    Positioned(
                                      top: 8,
                                      left: 8,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: bannerColor,
                                          borderRadius:
                                              BorderRadius.circular(4),
                                        ),
                                        child: Text(
                                          'Expires in $remainingTime',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    },
                    loading: () => const ListTile(
                      title: Text('Loading Movie Details...'),
                      subtitle: CircularProgressIndicator(),
                    ),
                    error: (error, stack) =>
                        Center(child: Text('Error: $error')),
                  );
                },
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stack) { 
              ref.refresh(authUserProvider);
              ref.refresh(rentalProvider);

            return  Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Error: Failed to fetch rentals...$error',
                    style: const TextStyle(color: Colors.red, fontSize: 16),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      ref.invalidate(rentalProvider);
                    },
                    child: const Text("Refresh"),
                  ),
                ],
              ),
            );}
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Text('Error loading user: $error'),
        ),
      ),
    );
  }
}
