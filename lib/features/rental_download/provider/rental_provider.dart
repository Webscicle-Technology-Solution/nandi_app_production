import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nandiott_flutter/services/rental_service.dart';
import 'package:nandiott_flutter/models/rental_model.dart';
import 'package:nandiott_flutter/models/moviedetail_model.dart';

// Provider for the RentalService
final rentalServiceProvider = Provider((ref) => RentalService());

// Provider to fetch rentals data
final rentalProvider = FutureProvider<List<Rental>>((ref) async {
  final rentalService = ref.watch(rentalServiceProvider);

  try {
    final response = await rentalService.getRentals();
// print("rental response in provider : $response");
    // Ensure response is valid and contains data
    if (response == null || response['success'] == false || response['data'] == null) {
      final errorMessage = response?['message'] ?? "Failed to fetch rentals";
      throw Exception(errorMessage);
    }

    // Convert the data list into Rental model objects
    final rentalList = (response['data'] as List)
        .map((rental) => Rental.fromJson(rental))
        .toList();

    return rentalList;
  } catch (e) {
    throw e;
  }
});

// Provider to fetch movie details by movieId
final rentedmovieDetailProvider = FutureProvider.family<MovieDetail, String>((ref, movieId) async {
  final rentalService = ref.watch(rentalServiceProvider);
  final response = await rentalService.getMovieDetail(movieId);

  // Returning the parsed MovieDetail object
  return MovieDetail.fromJson(response['movie']);
});
