import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nandiott_flutter/app/widgets/favFilm_card_widget.dart';
import 'package:nandiott_flutter/app/widgets/skeltonLoader/filmSkelton.dart';
import 'package:nandiott_flutter/features/auth/login_page.dart';
import 'package:nandiott_flutter/features/auth/loginpage_tv.dart';
import 'package:nandiott_flutter/models/fav_movie.dart';
import 'package:nandiott_flutter/models/moviedetail_model.dart';
import 'package:nandiott_flutter/providers/checkauth_provider.dart';
import 'package:nandiott_flutter/providers/favourite_provider.dart';

class WishlistWidget extends ConsumerWidget {
  WishlistWidget({super.key});

  final _buttonFocus = FocusNode();
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Force refresh auth state when this widget builds
    // ref.invalidate(authUserProvider);

    // Listen for auth state changes to trigger a rebuild
    final authuser = ref.watch(authUserProvider);

    return authuser.when(
        data: (user) {
          if (user == null) {
            // If the user is not logged in, show the login prompt
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    const Text(
                      "To access your wishlist.",
                      style: TextStyle(color: Colors.grey, fontSize: 15),
                    ),
                    Focus(
                      focusNode: _buttonFocus,
                      // onFocusChange: (__)=>,
                      child: GestureDetector(
                        onTap: () async {
                          final result = await Navigator.of(context).push(
                              MaterialPageRoute(
                                  builder: (context) => LoginScreen()));

                          // Force refresh of auth state when returning from login page
                          if (result == true) {
                            // User successfully logged in
                            ref.invalidate(authUserProvider);
                            ref.invalidate(favoritesProvider);
                            ref.invalidate(favoritesWithDetailsProvider);
                          }
                        },
                        child: TextButton.icon(
                          icon: const Icon(
                            Icons.login,
                            color: Colors.amber,
                            size: 35,
                          ),
                          label: const Text(
                            'Login',
                            style: TextStyle(
                              color: Colors.amber,
                              fontSize: 15,
                            ),
                          ),
                          onPressed: () async {
                            // Navigate to login page and wait for it to complete
                            final result = await Navigator.of(context).push(
                                MaterialPageRoute(
                                    builder: (context) => LoginScreen()));

                            // Force refresh of auth state when returning from login page
                            if (result == true) {
                              // User successfully logged in
                              ref.invalidate(authUserProvider);
                              ref.invalidate(favoritesProvider);
                              ref.invalidate(favoritesWithDetailsProvider);
                            }
                          },
                        ),
                      ),
                    )
                  ],
                ),
              ),
            );
          } else {
            final favoritesWithDetailsAsync =
                ref.watch(favoritesWithDetailsProvider);

            return favoritesWithDetailsAsync.when(
              data: (moviesWithDetails) {
                if (moviesWithDetails.isEmpty) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Text(
                        "No favorites yet. Add some movies to your wishlist!",
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                  );
                }

                return SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 8.0, left: 15),
                    child: Row(
                      children: moviesWithDetails.map((item) {
                        final favorite = item['favorite'] as FavoriteMovie;
                        final movieDetail = item['movieDetail'] as MovieDetail;

                        return FavFilmCard(
                          film: movieDetail,
                          mediaType: favorite.contentType,
                        );
                      }).toList(),
                    ),
                  ),
                );
              },
              loading: () => SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Padding(
                  padding: const EdgeInsets.only(left: 10),
                  child: Row(
                    children: List.generate(5, (index) {
                      return const SkeletonLoader();
                    }),
                  ),
                ),
              ),
              error: (error, stackTrace) => Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    "Error loading favorites: ${error.toString().split('\n')[0]}",
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              ),
            );
          }
        },
        // If the user is logged in, show the favorites

        loading: () => Padding(
              padding: const EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Padding(
                  padding: const EdgeInsets.only(top: 8.0, left: 15),
                  child: Row(
                    children: List.generate(5, (index) {
                      return const Padding(
                        padding: EdgeInsets.only(right: 15.0),
                        child:
                            SkeletonLoader(), // Use skeleton loader for each film card
                      );
                    }),
                  ),
                ),
              ),
            ),
        error: (error, stackTrace) => Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  "Error loading user: ${error.toString().split('\n')[0]}",
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ));
  }
}
