class MovieDetail {
  final String id;
  final String title;
  final String? description;
  final DateTime? releaseDate;
  final DateTime? publishDate;
  final String? certificate;
  final String? genre;
  final String? status;
  final bool isReady;
  final String? posterId;
  final String? bannerId;
  final String? trailerId;
  final String? previewId;
  final String? videoId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final CastDetails? castDetails;
  final AccessParams? accessParams;
  final Rating? rating;
  
  final double?duration;

  MovieDetail({
    required this.id,
    required this.title,
    this.description,
    this.releaseDate,
    this.publishDate,
    this.certificate,
    this.genre,
    this.status,
    required this.isReady,
    this.posterId,
    this.bannerId,
    this.trailerId,
    this.previewId,
    this.videoId,
    required this.createdAt,
    required this.updatedAt,
    this.castDetails,
    this.accessParams,
    this.rating,
    this.duration,
  });

factory MovieDetail.fromJson(Map<String, dynamic> json) {
  return MovieDetail(
    id: json["_id"] ?? "",
    title: json["title"] ?? "Unknown Title",
    description: json["description"],
    releaseDate: json["releaseDate"] != null ? DateTime.tryParse(json["releaseDate"]) : null,
    publishDate: json["publishDate"] != null ? DateTime.tryParse(json["publishDate"]) : null,
    certificate: json["certificate"],
    genre: json["genre"],
    status: json["status"]??'unkown',
    isReady: json["isReady"] ?? false,
    posterId: json["posterId"],
    bannerId: json["bannerId"],
    trailerId: json["trailerId"],
    previewId: json["previewId"],
    videoId: json["videoId"],
    createdAt: json["createdAt"] != null ? DateTime.tryParse(json["createdAt"]) ?? DateTime.now() : DateTime.now(),
    updatedAt: json["updatedAt"] != null ? DateTime.tryParse(json["updatedAt"]) ?? DateTime.now() : DateTime.now(),
    castDetails: json["castDetails"] is Map<String, dynamic> ? CastDetails.fromJson(json["castDetails"]) : null,
    accessParams: json["accessParams"] is Map<String, dynamic> ? AccessParams.fromJson(json["accessParams"]) : null,
    rating: json["rating"] is Map<String, dynamic> ? Rating.fromJson(json["rating"]) :null,
    duration: json["duration"]
  );
}

  Map<String, dynamic> toJson() {
    return {
      "_id": id,
      "title": title,
      "description": description,
      "releaseDate": releaseDate?.toIso8601String(),
      "publishDate": publishDate?.toIso8601String(),
      "certificate": certificate,
      "genre": genre,
      "status": status,
      "isReady": isReady,
      "posterId": posterId,
      "bannerId": bannerId,
      "trailerId": trailerId,
      "previewId": previewId,
      "videoId": videoId,
      "createdAt": createdAt.toIso8601String(),
      "updatedAt": updatedAt.toIso8601String(),
      "castDetails": castDetails?.toJson(),
      "accessParams": accessParams?.toJson(),
      "rating":rating?.toJson(),
      "duration": duration 
    };
  }
}

class CastDetails {
  final String id;
  //final String movieId;
  final List<String> actors;
  final List<String> producers;
  final List<String> directors;
  final List<String> singers;
  final List<String> writers;
  final List<String> composers;
  final DateTime createdAt;

  CastDetails({
    required this.id,
  //  required this.movieId,
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
      id: json["_id"],
      //movieId: json["movieId"],
      actors: List<String>.from(json["actors"] ?? []),
      producers: List<String>.from(json["producers"] ?? []),
      directors: List<String>.from(json["directors"] ?? []),
      singers: List<String>.from(json["singers"] ?? []),
      writers: List<String>.from(json["writers"] ?? []),
      composers: List<String>.from(json["composers"] ?? []),
      createdAt: DateTime.parse(json["createdAt"]),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "_id": id,
    //  "movieId": movieId,
      "actors": actors,
      "producers": producers,
      "directors": directors,
      "singers": singers,
      "writers": writers,
      "composers": composers,
      "createdAt": createdAt.toIso8601String(),
    };
  }
}

class AccessParams {
  final String accessType;
  final bool isRentable;
  final bool isFree;
  final int rentalPrice;

  AccessParams({
    required this.accessType,
    required this.isRentable,
    required this.isFree,
    required this.rentalPrice,
  });

  factory AccessParams.fromJson(Map<String, dynamic> json) {
    return AccessParams(
      accessType: json["accessType"] ?? "unknown",
      isRentable: json["isRentable"] ?? false,
      isFree: json["isFree"] ?? false,
      rentalPrice: json["rentalPrice"] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "accessType": accessType,
      "isRentable": isRentable,
      "isFree": isFree,
      "rentalPrice": rentalPrice,
    };
  }
}


class Rating {

final num averageRating;
final int ratingCount;

  Rating({
    required this.averageRating,
    required this.ratingCount
  //  required this.movieId,
 
  });

  factory Rating.fromJson(Map<String, dynamic> json) {
    return Rating(
      averageRating: json['averageRating'],
      ratingCount: json["ratingCount"],
 
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "averageRating":averageRating,
      "ratingCount":ratingCount

  };
}
}