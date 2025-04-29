// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:nandiott_flutter/models/moviedetail_model.dart';
// import 'package:nandiott_flutter/providers/checkauth_provider.dart';
// import 'package:nandiott_flutter/providers/rental_provider.dart';
// import 'package:nandiott_flutter/providers/subscription_provider.dart';

// final watchButtonStateProvider = FutureProvider.autoDispose.family<
//     WatchButtonState, MovieDetail>((ref, movie) async {
//   final user = await ref.watch(authUserProvider.future);
//   if (user == null) return WatchButtonState.notLoggedIn;

//   final rentalList = await ref.watch(rentalProvider.future);
//   final subscription = await ref.watch(
//     subscriptionProvider(SubscriptionDetailParameter(userId: user.id)).future,
//   );

//   final hasRented = rentalList.any((rental) =>
//       rental.userId == user.id && rental.movieId == movie.id);
//   final isSubscribed = subscription?.subscriptionType.name != "Free";
//   final isRentable = movie.accessParams?.isRentable == true;
//   final isFree = movie.accessParams?.isFree == true;

//   if (widget.mediaType == "tvseries" && isSubscribed) {
//     return WatchButtonState.tvSeriesSubscribed;
//   } else if (hasRented || isSubscribed || isFree) {
//     return WatchButtonState.watchNow;
//   } else if (isRentable) {
//     return WatchButtonState.rent;
//   } else {
//     return WatchButtonState.subscribe;
//   }
// });

// enum WatchButtonState {
//   notLoggedIn,
//   watchNow,
//   rent,
//   subscribe,
//   tvSeriesSubscribed,
// }
