import 'package:nandiott_flutter/models/cast_model.dart';

class Movie {
  final String id;
  final String title;
  final String description;
  final String? imageUrl; // Nullable field for image URL
  final DateTime? releaseDate; // Nullable DateTime
  final DateTime? publishDate; // Nullable publish date
  final String status;
  final bool isReady;
  final String? genre; // Optional genre for detailed view
  final String? certificate; // Optional certificate for detailed view
  final CastDetails? castDetails; // New cast details field

  Movie({
    required this.id,
    required this.title,
    required this.description,
    this.imageUrl,
    this.releaseDate,
    this.publishDate,
    required this.status,
    required this.isReady,
    this.genre,
    this.certificate,
    this.castDetails, // Add cast details here
  });

  // From JSON factory constructor to map API response to model
  factory Movie.fromJson(Map<String, dynamic> json) {
    // Handle the case where 'castDetails' might be missing or null
    var castDetailsJson = json['castDetails'];
    CastDetails? castDetails = castDetailsJson != null && castDetailsJson is Map<String, dynamic>
        ? CastDetails.fromJson(castDetailsJson)
        : null;

    return Movie(
      id: json['_id'] ?? "",
      title: json['title'] ?? "",
      description: json['description'] ?? "",
      imageUrl: json['posterId'], // Nullable
      releaseDate: json['releaseDate'] != null 
        ? DateTime.parse(json['releaseDate']) 
        : null,
      publishDate: json['publishDate'] != null 
        ? DateTime.parse(json['publishDate']) 
        : null,
      status: json['status'] ?? "",
      isReady: json['isReady'] ?? false,
      genre: json['genre'], // Nullable
      certificate: json['certificate'], // Nullable
      castDetails: castDetails, // Parse cast details only if available
    );
  }
}


