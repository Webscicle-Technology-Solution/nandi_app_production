class FavoriteMovie {
  final String contentId;
  final String contentType;
  final String? id;

  FavoriteMovie({
    required this.contentId,
    required this.contentType,
    this.id,
  });

  // Factory method to create a FavoriteMovie from a JSON map
  factory FavoriteMovie.fromJson(Map<String, dynamic> json) {
    return FavoriteMovie(
      contentId: json['contentId'],
      contentType: json['contentType'],
      id: json['_id'],
    );
  }

  // Method to convert a FavoriteMovie object to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'contentId': contentId,
      'contentType': contentType,
      '_id': id,
    };
  }
}

// class FavoriteMoviesResponse {
//   final bool success;
//   final List<FavoriteMovie> content;

//   FavoriteMoviesResponse({
//     required this.success,
//     required this.content,
//   });

//   // Factory method to create a FavoriteMoviesResponse from a JSON map
//   factory FavoriteMoviesResponse.fromJson(Map<String, dynamic> json) {
//     return FavoriteMoviesResponse(
//       success: json['success'],
//       content: (json['data']['content'] as List)
//           .map((e) => FavoriteMovie.fromJson(e))
//           .toList(),
//     );
//   }

//   // Method to convert a FavoriteMoviesResponse object to a JSON map
//   Map<String, dynamic> toJson() {
//     return {
//       'success': success,
//       'data': {
//         'content': content.map((e) => e.toJson()).toList(),
//       },
//     };
//   }
// }

class FavoriteMoviesResponse {
  final bool success;
  final List<FavoriteMovie> content;

  FavoriteMoviesResponse({
    required this.success,
    required this.content,
  });

  factory FavoriteMoviesResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'];

    List<FavoriteMovie> parsedContent = [];

    // ✅ Safe null check
    if (data != null && data is Map<String, dynamic>) {
      final content = data['content'];
      if (content is List) {
        parsedContent = content
            .map((e) => FavoriteMovie.fromJson(e))
            .toList();
      }
    }

    return FavoriteMoviesResponse(
      success: json['success'] ?? false,
      content: parsedContent,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'data': {
        'content': content.map((e) => e.toJson()).toList(),
      },
    };
  }
}
