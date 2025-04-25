class Rental {
  final String id;
  final String userId;
  final String movieId;
  final DateTime startDate;
  final DateTime endDate;
  final String status;
  final String paymentId;

  Rental({
    required this.id,
    required this.userId,
    required this.movieId,
    required this.startDate,
    required this.endDate,
    required this.status,
    required this.paymentId,
  });

  // From JSON to Rental model
  factory Rental.fromJson(Map<String, dynamic> json) {
    return Rental(
      id: json['_id'],
      userId: json['user'],
      movieId: json['movie'],
      startDate: DateTime.parse(json['startDate']),
      endDate: DateTime.parse(json['endDate']),
      status: json['status'],
      paymentId: json['paymentId'],
    );
  }

  // To JSON (optional, if needed for posting data)
  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'user': userId,
      'movie': movieId,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'status': status,
      'paymentId': paymentId,
    };
  }
}
