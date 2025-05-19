import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nandiott_flutter/models/subscription_model.dart';
import 'package:nandiott_flutter/services/payment_service.dart';
import 'package:nandiott_flutter/services/subscription_service.dart';


//Provider for Subscrption detail servce


final paymentServiceProvider=Provider((ref)=>PaymentService());

//Provider for fetch subscription data
final rentPaymentProvider = FutureProvider.family<String?, PaymentDetailParameter>((ref, params) async {
  final paymentService = ref.watch(paymentServiceProvider);
  
  // Call the API with movieId and redirectUrl
  final response = await paymentService.rentalPaymentService(params.movieId!, params.redirectUrl!);

  if (response != null && response['success'] == true) {
    return response['data']['paymentUrl']; // ✅ Extract the payment URL
  } else {
    throw Exception(response?['message'] ?? 'Failed to initiate payment');
  }
});


//Provider for fetch subscription data
final subsciptionPaymentProvider = FutureProvider.family<String?, PaymentDetailParameter>((ref, params) async {
  final paymentService = ref.watch(paymentServiceProvider);
  
  // Call the API with movieId and redirectUrl
  final response = await paymentService.subscriptionPaymentService(params.planName!,params.redirectUrl!);

  if (response != null && response['success'] == true) {
    return response['data']['paymentUrl']; // ✅ Extract the payment URL
  } else {
    throw Exception(response?['message'] ?? 'Failed to initiate payment');
  }
});


class PaymentDetailParameter extends Equatable {
  final String? movieId;
  final String? redirectUrl;
  final String? planName;


  const PaymentDetailParameter({ this.movieId, this.redirectUrl,this.planName});

  @override
  List<Object?> get props => [movieId,redirectUrl,planName];
}