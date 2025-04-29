import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nandiott_flutter/models/moviedetail_model.dart';
import 'package:nandiott_flutter/services/detail_service.dart';



final detailServiceProvider=Provider((ref)=>DetailService());

// Provider to fetch a single movie by ID
final movieDetailProvider = FutureProvider.family<MovieDetail?, MovieDetailParameter>((ref, params) async {

Map<String, String> resultCategoryMap = {
  'Movies': 'movie',
  'movies':'movie',
  'Movie':'movie',
  'TVSeries':'tvSeries',
 'Series': 'tvSeries',
 'tvseries':'tvSeries',
  'Short Film': 'shortFilm',
  'ShortFilm':'shortFilm',
  'shortfilms':'shortFilm',
  'shortfilm':'shortFilm',
  'Documentary': 'documentary',
  'documentaries':'documentary',
  'Music': 'videoSong',
  'videosongs':'videoSong',
  'videosong':'videoSong',
  'VideoSong':'videoSong',
};
Map<String, String> mediaCategoryApiMap = {
  'Movies': 'movies',
  'movie':'movies',
  'Movie':'movies',
  'TVSeries':'tvseries',
 'Series': 'tvseries',
 'tvseries':'tvseries',
  'Short Film': 'shortfilms',
  'ShortFilm':'shortFilms',
  'shortfilm':'shortfilms',
  'Documentary': 'documentaries',
  'documentary':'documentaries',
  'Music': 'videosongs',
  'videosong':'videosongs',
  'VideoSong':'videosongs',

};

  final service = DetailService();
  final response = await service.getMovieDetail(
    mediaType: mediaCategoryApiMap[params.mediaType]??params.mediaType,
    movieId: params.movieId,
  );
print("mediatype before converting:${params.mediaType}");
String apiMediaType=resultCategoryMap[ params.mediaType]?? params.mediaType;


  print('🎬 Movie id and mediatype: ${params.mediaType},${params.movieId}'); // Debug Print
    print("mediatype for selecting result is ${apiMediaType}");
    
  print('🎬 Media Detail Response: ${response}'); // Debug Print

  print('🎬 Movie Detail Response: ${response?['${apiMediaType}'] }'); // Debug Print

  if (response != null && response['success'] == true) {
    return MovieDetail.fromJson(response['${apiMediaType}']);
  } else {
    throw Exception(response?['message'] ?? 'Failed to load movie details');
  }
});




final movieRateProvider=FutureProvider.family<String?, MovieDetailParameter>((ref, params) async {
  final ratingService = ref.watch(detailServiceProvider);
  
  // Call the API with movieId and redirectUrl
  final response = await ratingService.postMovieRating(mediaType: params.mediaType,movieId: params.movieId,rating: params.rating!);

  if (response != null && response['success'] == true) {
    print(" post rating provider Response: ${response}");
    return response['message'];
  } else {
    throw Exception(response?['message'] ?? 'Failed to rate ');
  }
});



final ratedMovieProvider=FutureProvider.family<Map<String, dynamic>?, MovieDetailParameter>((ref, params) async {
  final ratedService = ref.watch(detailServiceProvider);
  
  // Call the API with movieId and redirectUrl
  final response = await ratedService.getMovieRating(mediaType: params.mediaType,movieId: params.movieId);

  if (response != null && response['success'] == true) {
    print("get rating provider Response: ${response['data']}");
    return response['data'];
  } else {
    throw Exception(response?['message'] ?? 'Failed to rate ');
  }
});



class MovieDetailParameter extends Equatable {
  final String movieId;
  final String mediaType;

  final num? rating;
  const MovieDetailParameter({required this.movieId, required this.mediaType,this.rating});

  @override
  List<Object?> get props => [movieId, mediaType,rating];
}