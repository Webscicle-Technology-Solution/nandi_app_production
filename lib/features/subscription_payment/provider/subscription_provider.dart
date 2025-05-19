import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nandiott_flutter/models/subscription_model.dart';
import 'package:nandiott_flutter/services/subscription_service.dart';


//Provider for Subscrption detail servce


final subscriptionServiceProvider=Provider((ref)=>SubscriptionService());

//Provider for fetch subscription data
final subscriptionProvider=FutureProvider.family<Subscription?,SubscriptionDetailParameter>((ref,params)async{
  final subscriptionService=ref.watch(subscriptionServiceProvider);
  final response=await subscriptionService.getSubscriptionDetail(params.userId);

  if(response != null && response['success'] == true){
    return Subscription.fromJson(response['data']);
  }else {
    throw Exception(response?['message'] ?? 'Failed to load movie details');
  }

});

class SubscriptionDetailParameter extends Equatable {
  final String userId;


  const SubscriptionDetailParameter({required this.userId});

  @override
  List<Object?> get props => [userId];
}