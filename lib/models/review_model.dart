class ReviewModel {
  String id;
  String productId;
  String userId;
  String userName;
  String userAvatar;
  double rating;
  String comment;
  DateTime createdAt;
  List<String> images;
  int likes;

  ReviewModel({
    required this.id,
    required this.productId,
    required this.userId,
    required this.userName,
    required this.userAvatar,
    required this.rating,
    required this.comment,
    required this.createdAt,
    this.images = const [],
    this.likes = 0,
  });

  Map<String, dynamic> toMap() {
    return {
      'productId': productId,
      'userId': userId,
      'userName': userName,
      'userAvatar': userAvatar,
      'rating': rating,
      'comment': comment,
      'createdAt': createdAt,
      'images': images,
      'likes': likes,
    };
  }

  factory ReviewModel.fromMap(String id, Map<String, dynamic> map) {
    return ReviewModel(
      id: id,
      productId: map['productId'],
      userId: map['userId'],
      userName: map['userName'],
      userAvatar: map['userAvatar'] ?? '',
      rating: map['rating']?.toDouble() ?? 0,
      comment: map['comment'],
      createdAt: (map['createdAt'] as dynamic).toDate(),
      images: List<String>.from(map['images'] ?? []),
      likes: map['likes'] ?? 0,
    );
  }
}
