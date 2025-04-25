class CastDetails {
  final String id;
  final String tvSeriesId;
  final List<String> actors;
  final List<String> producers;
  final List<String> directors;
  final List<String> singers;
  final List<String> writers;
  final List<String> composers;
  final DateTime createdAt;

  CastDetails({
    required this.id,
    required this.tvSeriesId,
    required this.actors,
    required this.producers,
    required this.directors,
    required this.singers,
    required this.writers,
    required this.composers,
    required this.createdAt,
  });

  factory CastDetails.fromJson(Map<String, dynamic> json) {
    return CastDetails(
      id: json['_id'],
      tvSeriesId: json['tvSeriesId'],
      actors: List<String>.from(json['actors'] ?? []),
      producers: List<String>.from(json['producers'] ?? []),
      directors: List<String>.from(json['directors'] ?? []),
      singers: List<String>.from(json['singers'] ?? []),
      writers: List<String>.from(json['writers'] ?? []),
      composers: List<String>.from(json['composers'] ?? []),
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}
