class Season {
  final String id;
  final int seasonNumber;
  final DateTime? releaseDate;
  final DateTime? publishDate;
  final String status;

  Season({
    required this.id,
    required this.seasonNumber,
    this.releaseDate,
    this.publishDate,
    required this.status,
  });

  factory Season.fromJson(Map<String, dynamic> json) {
    return Season(
      id: json['_id'],
      seasonNumber: json['seasonNumber'],
      releaseDate: json['releaseDate'] != null ? DateTime.tryParse(json['releaseDate']) : null,
      publishDate: json['publishDate'] != null ? DateTime.tryParse(json['publishDate']) : null,
      status: json['status'] ?? 'N/A',
    );
  }
}

class Episode {
  final String id;
  final int? episodeNumber;
  final String? description;
  final String? status;
  final DateTime? releaseDate;
  final DateTime? publishDate;
  final String? seasonId;
  final String? tvSeriesId;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Episode({
    required this.id,
    this.episodeNumber,
    this.description,
    this.status,
    this.releaseDate,
    this.publishDate,
    this.seasonId,
    this.tvSeriesId,
    this.createdAt,
    this.updatedAt,
  });

  factory Episode.fromJson(Map<String, dynamic> json) => Episode(
        id: json['_id'],
        episodeNumber: json['episodeNumber'],
        description: json['description'],
        status: json['status'],
        releaseDate: json['releaseDate'] != null
            ? DateTime.tryParse(json['releaseDate'])
            : null,
        publishDate: json['publishDate'] != null
            ? DateTime.tryParse(json['publishDate'])
            : null,
        seasonId: json['seasonId'],
        tvSeriesId: json['tvSeriesId'],
        createdAt: json['createdAt'] != null
            ? DateTime.tryParse(json['createdAt'])
            : null,
        updatedAt: json['updatedAt'] != null
            ? DateTime.tryParse(json['updatedAt'])
            : null,
      );
}
