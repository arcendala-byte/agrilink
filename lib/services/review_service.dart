import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/review/review_models.dart';

class ReviewService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? get currentUserId => _auth.currentUser?.uid;
  String? get currentUserName => _auth.currentUser?.displayName;

  // Add a review
  Future<bool> addReview({
    required String productId,
    required double rating,
    required String comment,
    List<String> images = const [],
  }) async {
    try {
      final reviewId = '${productId}_${currentUserId}_${DateTime.now().millisecondsSinceEpoch}';
      
      final review = ProductReview(
        id: reviewId,
        productId: productId,
        userId: currentUserId!,
        userName: currentUserName ?? 'User',
        rating: rating,
        comment: comment,
        images: images,
        createdAt: DateTime.now(),
      );
      
      await _firestore.collection('reviews').doc(reviewId).set(review.toJson());
      
      // Update product average rating
      await _updateProductRating(productId);
      
      return true;
    } catch (e) {
      print('Error adding review: $e');
      return false;
    }
  }

  // Get reviews for a product
  Stream<List<ProductReview>> getProductReviews(String productId) {
    return _firestore
        .collection('reviews')
        .where('productId', isEqualTo: productId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            final data = doc.data();
            return ProductReview(
              id: doc.id,
              productId: data['productId'],
              userId: data['userId'],
              userName: data['userName'],
              rating: data['rating'],
              comment: data['comment'],
              images: List<String>.from(data['images'] ?? []),
              createdAt: DateTime.parse(data['createdAt']),
              updatedAt: data['updatedAt'] != null ? DateTime.parse(data['updatedAt']) : null,
            );
          }).toList();
        });
  }

  // Update product rating
  Future<void> _updateProductRating(String productId) async {
    final reviewsSnapshot = await _firestore
        .collection('reviews')
        .where('productId', isEqualTo: productId)
        .get();
    
    if (reviewsSnapshot.docs.isEmpty) return;
    
    double totalRating = 0;
    for (var doc in reviewsSnapshot.docs) {
      final rating = (doc.data() as Map<String, dynamic>)['rating'] as double;
      totalRating += rating;
    }
    
    final averageRating = totalRating / reviewsSnapshot.docs.length;
    
    await _firestore.collection('products').doc(productId).update({
      'rating': averageRating,
      'reviewCount': reviewsSnapshot.docs.length,
    });
  }

  // Check if user has already reviewed
  Future<bool> hasUserReviewed(String productId) async {
    final snapshot = await _firestore
        .collection('reviews')
        .where('productId', isEqualTo: productId)
        .where('userId', isEqualTo: currentUserId)
        .limit(1)
        .get();
    
    return snapshot.docs.isNotEmpty;
  }

  // Delete a review (for admin or user)
  Future<bool> deleteReview(String reviewId) async {
    try {
      final review = await _firestore.collection('reviews').doc(reviewId).get();
      final productId = (review.data() as Map<String, dynamic>)['productId'];
      
      await _firestore.collection('reviews').doc(reviewId).delete();
      await _updateProductRating(productId);
      
      return true;
    } catch (e) {
      return false;
    }
  }
}
