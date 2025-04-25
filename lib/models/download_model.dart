
// Movie Metadata Model
class DownloadedMovie {
  String id;
  String title;
  String posterUrl;
  String playlistPath;
  String resolution;
  DateTime downloadDate;

  DownloadedMovie({
    required this.id,
    required this.title,
    required this.posterUrl,
    required this.playlistPath,
    required this.resolution,
    DateTime? downloadDate,
  }) : downloadDate = downloadDate ?? DateTime.now();

  // Convert to Map for Hive storage
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'posterUrl': posterUrl,
      'playlistPath': playlistPath,
      'resolution': resolution,
      'downloadDate': downloadDate.toIso8601String(),
    };
  }

  // Create from Map for Hive retrieval
  factory DownloadedMovie.fromMap(Map<String, dynamic> map) {
    return DownloadedMovie(
      id: map['id'],
      title: map['title'],
      posterUrl: map['posterUrl'],
      playlistPath: map['playlistPath'],
      resolution: map['resolution'],
      downloadDate: DateTime.parse(map['downloadDate']),
    );
  }
}