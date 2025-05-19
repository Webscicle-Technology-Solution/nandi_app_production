import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nandiott_flutter/services/homecontents_service.dart';

final homecontentsServiceProvider=Provider((ref) =>HomecontentsService() );

final homecontentsProvider=FutureProvider.family<Map<String, dynamic>?, HomecontentsParameter>((ref, params) async{
  final homecontentService=ref.watch(homecontentsServiceProvider);

    final response= await homecontentService.getHomeContents(params.mediaType);
      if (response != null && response['success'] == true) {
    return response["data"];
  } else {
    throw Exception(response?['message'] ?? 'Failed to rate ');
  }


});


class HomecontentsParameter extends Equatable {
  final String mediaType;

  const HomecontentsParameter({required this.mediaType});

  @override
  List<Object?> get props => [mediaType];
}