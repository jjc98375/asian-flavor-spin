class YelpReview {
  final String text;
  final double rating;
  final String userName;
  final String? userImageUrl;
  final DateTime timeCreated;

  const YelpReview({
    required this.text,
    required this.rating,
    required this.userName,
    this.userImageUrl,
    required this.timeCreated,
  });

  factory YelpReview.fromJson(Map<String, dynamic> json) {
    final user = json['user'] as Map<String, dynamic>? ?? {};
    return YelpReview(
      text: json['text'] as String? ?? '',
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      userName: user['name'] as String? ?? 'Anonymous',
      userImageUrl: user['image_url'] as String?,
      timeCreated: DateTime.tryParse(json['time_created'] as String? ?? '') ??
          DateTime.now(),
    );
  }
}
