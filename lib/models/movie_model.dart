import 'package:nandiott_flutter/models/moviedetail_model.dart';

class Movie {
  final String id;
  final String title;
  final String? description; // Nullable String
  final String? imageUrl; // Nullable String
  final DateTime? releaseDate;
  final DateTime? publishDate;
  final String status;
  final bool isReady;
  final String? genre; // Nullable String
  final String? certificate; // Nullable String
  final CastDetails? castDetails;

  Movie({
    required this.id,
    required this.title,
    this.description,
    this.imageUrl,
    this.releaseDate,
    this.publishDate,
    required this.status,
    required this.isReady,
    this.genre,
    this.certificate,
    this.castDetails,
  });

  factory Movie.fromJson(Map<String, dynamic> json) {
    // Handle possible null values for description, posterId, etc.
    return Movie(
      id: json['_id'] ?? "", // Non-nullable
      title: json['title'] ?? "", // Non-nullable
    //  description: json['description'] as String?, // Nullable String
            description: json['description']??"", // Nullable String

      imageUrl: json['posterId'] as String?, // Nullable String
      releaseDate: json['releaseDate'] != null 
          ? DateTime.parse(json['releaseDate']) 
          : null,
      publishDate: json['publishDate'] != null 
          ? DateTime.parse(json['publishDate']) 
          : null,
      status: json['status'] ?? "", // Non-nullable
      isReady: json['isReady'] ?? false, // Non-nullable boolean
      genre: json['genre'] as String?, // Nullable String
      certificate: json['certificate'] as String?, // Nullable String
      castDetails: json['castDetails'] != null 
          ? CastDetails.fromJson(json['castDetails']) 
          : null, // Nullable castDetails
    );
  }
}
