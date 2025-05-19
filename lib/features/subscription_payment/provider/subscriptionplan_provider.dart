// Provider for the RentalService
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nandiott_flutter/models/subscriptionplan_models.dart';
import 'package:nandiott_flutter/services/subscriptionplan_service.dart';

final subscriptionplanServiceProvider = Provider((ref) => SubscriptionplanService());

// Provider to fetch rentals data
final subscriptionPlanProvider = FutureProvider<List<SubscriptionPlan>>((ref) async {
  final subscriptionPlanService = ref.watch(subscriptionplanServiceProvider);

  try {
    final response = await subscriptionPlanService.getSubscriptionPlan();

    // Ensure response is valid and contains data
    if (response == null || response['success'] == false || response['data'] == null) {
      final errorMessage = response?['message'] ?? "Failed to fetch plans";
      throw Exception(errorMessage);
    }

    // Convert the data list into Rental model objects
    final planList = (response['data'] as List)
        .map((plan) => SubscriptionPlan.fromJson(plan))
        .toList();

    return planList;
  } catch (e) {
    throw e;
  }
});