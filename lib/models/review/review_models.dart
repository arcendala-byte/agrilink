import 'package:flutter/material.dart';

class ProductReview {
  final String id;
  final String productId;
  final String userId;
  final String userName;
  final double rating;
  final String comment;
  final List<String> images;
  final DateTime createdAt;
  final DateTime? updatedAt;
  
  ProductReview({
    required this.id,
    required this.productId,
    required this.userId,
    required this.userName,
    required this.rating,
    required this.comment,
    this.images = const [],
    required this.createdAt,
    this.updatedAt,
  });
  
  Map<String, dynamic> toJson() => {
    'id': id,
    'productId': productId,
    'userId': userId,
    'userName': userName,
    'rating': rating,
    'comment': comment,
    'images': images,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt?.toIso8601String(),
  };
  
  factory ProductReview.fromJson(Map<String, dynamic> json) {
    return ProductReview(
      id: json['id'],
      productId: json['productId'],
      userId: json['userId'],
      userName: json['userName'],
      rating: json['rating'],
      comment: json['comment'],
      images: List<String>.from(json['images'] ?? []),
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
    );
  }
}

class RatingDistribution {
  final int fiveStar;
  final int fourStar;
  final int threeStar;
  final int twoStar;
  final int oneStar;
  
  RatingDistribution({
    this.fiveStar = 0,
    this.fourStar = 0,
    this.threeStar = 0,
    this.twoStar = 0,
    this.oneStar = 0,
  });
  
  int get total => fiveStar + fourStar + threeStar + twoStar + oneStar;
  
  double get averageRating {
    if (total == 0) return 0;
    return (5 * fiveStar + 4 * fourStar + 3 * threeStar + 2 * twoStar + 1 * oneStar) / total;
  }
}
