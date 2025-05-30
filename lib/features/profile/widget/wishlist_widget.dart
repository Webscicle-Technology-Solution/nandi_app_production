// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:nandiott_flutter/features/profile/widget/favFilm_card_widget.dart';
// import 'package:nandiott_flutter/app/widgets/skeltonLoader/filmSkelton.dart';
// import 'package:nandiott_flutter/features/auth/page/loginpage_tv.dart';
// import 'package:nandiott_flutter/models/fav_movie.dart';
// import 'package:nandiott_flutter/models/moviedetail_model.dart';
// import 'package:nandiott_flutter/features/auth/providers/checkauth_provider.dart';
// import 'package:nandiott_flutter/features/profile/provider/favourite_provider.dart';

// class WishlistWidget extends ConsumerWidget {
//   final bool isIos;
//   WishlistWidget({this.isIos=false,super.key});

//   final _buttonFocus = FocusNode();
//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     // Listen for auth state changes to trigger a rebuild
//     final authuser = ref.watch(authUserProvider);

//     return authuser.when(
//         data: (user) {
//           if (user == null) {
//             // If the user is not logged in, show the login prompt
//             return Center(
//               child: Padding(
//                 padding: const EdgeInsets.all(16.0),
//                 child: Row(
//                   children: [
//                     const Text(
//                       "To access your wishlist.",
//                       style: TextStyle(color: Colors.grey, fontSize: 15),
//                     ),
//                     Focus(
//                       focusNode: _buttonFocus,
//                       // onFocusChange: (__)=>,
//                       child: GestureDetector(
//                         onTap: () async {
//                           final result = await Navigator.of(context).push(
//                               MaterialPageRoute(
//                                   builder: (context) => LoginScreen()));

//                           // Force refresh of auth state when returning from login page
//                           if (result == true) {
//                             // User successfully logged in
//                             ref.invalidate(authUserProvider);
//                             ref.invalidate(favoritesProvider);
//                             ref.invalidate(favoritesWithDetailsProvider);
//                           }
//                         },
//                         child: TextButton.icon(
//                           icon: const Icon(
//                             Icons.login,
//                             color: Colors.amber,
//                             size: 35,
//                           ),
//                           label: const Text(
//                             'Login',
//                             style: TextStyle(
//                               color: Colors.amber,
//                               fontSize: 15,
//                             ),
//                           ),
//                           onPressed: () async {
//                             // Navigate to login page and wait for it to complete
//                             final result = await Navigator.of(context).push(
//                                 MaterialPageRoute(
//                                     builder: (context) => LoginScreen()));

//                             // Force refresh of auth state when returning from login page
//                             if (result == true) {
//                               // User successfully logged in
//                               ref.invalidate(authUserProvider);
//                               ref.invalidate(favoritesProvider);
//                               ref.invalidate(favoritesWithDetailsProvider);
//                             }
//                           },
//                         ),
//                       ),
//                     )
//                   ],
//                 ),
//               ),
//             );
//           } else {
//             final favoritesWithDetailsAsync =
//                 ref.watch(favoritesWithDetailsProvider);

//             return favoritesWithDetailsAsync.when(
//               data: (moviesWithDetails) {
//                 if (moviesWithDetails.isEmpty) {
//                   return const Center(
//                     child: Padding(
//                       padding: EdgeInsets.all(16.0),
//                       child: Text(
//                         "No favorites yet. Add some movies to your wishlist!",
//                         style: TextStyle(color: Colors.grey),
//                       ),
//                     ),
//                   );
//                 }

//                 return SingleChildScrollView(
//                   scrollDirection: Axis.horizontal,
//                   child: Padding(
//                     padding: const EdgeInsets.only(top: 8.0, left: 15),
//                     child: Row(
//                       children: moviesWithDetails.map((item) {
//                         final favorite = item['favorite'] as FavoriteMovie;
//                         final movieDetail = item['movieDetail'] as MovieDetail;

//                         return FavFilmCard(
//                           film: movieDetail,
//                           mediaType: favorite.contentType,
//                         );
//                       }).toList(),
//                     ),
//                   ),
//                 );
//               },
//               loading: () => SingleChildScrollView(
//                 scrollDirection: Axis.horizontal,
//                 child: Padding(
//                   padding: const EdgeInsets.only(left: 10),
//                   child: Row(
//                     children: List.generate(5, (index) {
//                       return const SkeletonLoader();
//                     }),
//                   ),
//                 ),
//               ),
//               error: (error, stackTrace) => Center(
//                 child: Padding(
//                   padding: const EdgeInsets.all(16.0),
//                   child: Text(
//                     "Error loading favorites: ${error.toString().split('\n')[0]}",
//                     style: TextStyle(color: Colors.red),
//                   ),
//                 ),
//               ),
//             );
//           }
//         },
//         // If the user is logged in, show the favorites

//         loading: () => Padding(
//               padding: const EdgeInsets.all(16.0),
//               child: SingleChildScrollView(
//                 scrollDirection: Axis.horizontal,
//                 child: Padding(
//                   padding: const EdgeInsets.only(top: 8.0, left: 15),
//                   child: Row(
//                     children: List.generate(5, (index) {
//                       return const Padding(
//                         padding: EdgeInsets.only(right: 15.0),
//                         child:
//                             SkeletonLoader(), // Use skeleton loader for each film card
//                       );
//                     }),
//                   ),
//                 ),
//               ),
//             ),
//         error: (error, stackTrace) => Center(
//               child: Padding(
//                 padding: const EdgeInsets.all(16.0),
//                 child: Text(
//                   "Error loading user: ${error.toString().split('\n')[0]}",
//                   style: TextStyle(color: Colors.red),
//                 ),
//               ),
//             ));
//   }
// }


import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nandiott_flutter/features/profile/widget/favFilm_card_widget.dart';
import 'package:nandiott_flutter/app/widgets/skeltonLoader/filmSkelton.dart';
import 'package:nandiott_flutter/features/auth/page/loginpage_tv.dart';
import 'package:nandiott_flutter/models/fav_movie.dart';
import 'package:nandiott_flutter/models/moviedetail_model.dart';
import 'package:nandiott_flutter/features/auth/providers/checkauth_provider.dart';
import 'package:nandiott_flutter/features/profile/provider/favourite_provider.dart';

class WishlistWidget extends ConsumerWidget {
  final bool isIos;
  WishlistWidget({this.isIos = false, super.key});

  void _navigateToLogin(BuildContext context, WidgetRef ref) async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => LoginScreen()),
    );

    if (result == true) {
      ref.invalidate(authUserProvider);
      ref.invalidate(favoritesProvider);
      ref.invalidate(favoritesWithDetailsProvider);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authUserAsync = ref.watch(authUserProvider);

    return authUserAsync.when(
      data: (user) {
        if (user == null) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: isIos
                  ? Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          "Please login to get your wishlist.",
                          style: TextStyle(fontSize: 16, color: Colors.red),
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: () => _navigateToLogin(context, ref),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 30, vertical: 15),
                            backgroundColor: Colors.amber,
                          ),
                          child: const Text(
                            "Login",
                            style: TextStyle(fontSize: 16, color: Colors.black),
                          ),
                        ),
                      ],
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        const Text(
                          "To access your wishlist.",
                          style: TextStyle(color: Colors.grey, fontSize: 15),
                        ),
                        const SizedBox(width: 8),
                        TextButton.icon(
                          onPressed: () => _navigateToLogin(context, ref),
                          icon: const Icon(Icons.login,
                              color: Colors.amber, size: 35),
                          label: const Text(
                            'Login',
                            style: TextStyle(
                                color: Colors.amber, fontSize: 15),
                          ),
                        ),
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

              return isIos
                  ? Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: GridView.count(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisCount: 3,
                        mainAxisSpacing: 16,
                        crossAxisSpacing: 16,
                        childAspectRatio: 0.7,
                        children: moviesWithDetails.map((item) {
                          final favorite =
                              item['favorite'] as FavoriteMovie;
                          final movieDetail =
                              item['movieDetail'] as MovieDetail;

                          return FavFilmCard(
                            film: movieDetail,
                            mediaType: favorite.contentType,
                          );
                        }).toList(),
                      ),
                    )
                  : SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Padding(
                        padding: const EdgeInsets.only(top: 8.0, left: 15),
                        child: Row(
                          children: moviesWithDetails.map((item) {
                            final favorite =
                                item['favorite'] as FavoriteMovie;
                            final movieDetail =
                                item['movieDetail'] as MovieDetail;

                            return FavFilmCard(
                              film: movieDetail,
                              mediaType: favorite.contentType,
                            );
                          }).toList(),
                        ),
                      ),
                    );
            },
            loading: () => isIos
                ? Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 3,
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 16,
                      childAspectRatio: 0.7,
                      children: List.generate(
                          6, (index) => const SkeletonLoader()),
                    ),
                  )
                : SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 8.0, left: 15),
                      child: Row(
                        children: List.generate(
                          5,
                          (index) => const Padding(
                            padding: EdgeInsets.only(right: 15.0),
                            child: SkeletonLoader(),
                          ),
                        ),
                      ),
                    ),
                  ),
            error: (error, _) => Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  "Error loading favorites: ${error.toString().split('\n')[0]}",
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            ),
          );
        }
      },
      loading: () => isIos
          ? Padding(
              padding: const EdgeInsets.all(16.0),
              child: GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 3,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 0.7,
                children:
                    List.generate(6, (index) => const SkeletonLoader()),
              ),
            )
          : SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Padding(
                padding: const EdgeInsets.only(top: 8.0, left: 15),
                child: Row(
                  children: List.generate(
                    5,
                    (index) => const Padding(
                      padding: EdgeInsets.only(right: 15.0),
                      child: SkeletonLoader(),
                    ),
                  ),
                ),
              ),
            ),
      error: (error, _) => Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            "Error loading user: ${error.toString().split('\n')[0]}",
            style: const TextStyle(color: Colors.red),
          ),
        ),
      ),
    );
  }
}