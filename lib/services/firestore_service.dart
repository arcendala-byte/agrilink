import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Collections
  CollectionReference get users => _firestore.collection('users');
  CollectionReference get products => _firestore.collection('products');
  CollectionReference get orders => _firestore.collection('orders');
  CollectionReference get transactions => _firestore.collection('transactions');
  CollectionReference get reviews => _firestore.collection('reviews');
  CollectionReference get carts => _firestore.collection('carts');

  // Get current user ID
  String? get currentUserId => _auth.currentUser?.uid;

  // User methods
  Future<void> updateUserProfile(Map<String, dynamic> data) async {
    if (currentUserId == null) throw Exception('User not logged in');
    await users.doc(currentUserId).update({
      ...data,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<DocumentSnapshot> getUserProfile(String userId) async {
    return await users.doc(userId).get();
  }

  // Product methods
  Stream<QuerySnapshot> getProducts({String? category, String? farmerId}) {
    var query = products.where('isActive', isEqualTo: true);
    
    if (category != null && category.isNotEmpty) {
      query = query.where('category', isEqualTo: category);
    }
    
    if (farmerId != null && farmerId.isNotEmpty) {
      query = query.where('farmerId', isEqualTo: farmerId);
    }
    
    return query.orderBy('createdAt', descending: true).snapshots();
  }

  Future<void> addProduct(Map<String, dynamic> productData) async {
    await products.add({
      ...productData,
      'farmerId': currentUserId,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
      'isActive': true,
      'reviews': [],
      'rating': 0.0,
    });
  }

  Future<void> updateProduct(String productId, Map<String, dynamic> data) async {
    await products.doc(productId).update({
      ...data,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> deleteProduct(String productId) async {
    await products.doc(productId).update({'isActive': false});
  }

  // Order methods
  Future<void> createOrder(Map<String, dynamic> orderData) async {
    await orders.add({
      ...orderData,
      'userId': currentUserId,
      'status': 'pending',
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Stream<QuerySnapshot> getUserOrders() {
    return orders
        .where('userId', isEqualTo: currentUserId)
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  Stream<QuerySnapshot> getFarmerOrders() {
    return orders
        .where('farmerId', isEqualTo: currentUserId)
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  Future<void> updateOrderStatus(String orderId, String status) async {
    await orders.doc(orderId).update({
      'status': status,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // Cart methods
  Stream<QuerySnapshot> getCart() {
    return carts
        .where('userId', isEqualTo: currentUserId)
        .where('isActive', isEqualTo: true)
        .snapshots();
  }

  Future<void> addToCart(Map<String, dynamic> item) async {
    await carts.add({
      ...item,
      'userId': currentUserId,
      'isActive': true,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> removeFromCart(String cartItemId) async {
    await carts.doc(cartItemId).update({'isActive': false});
  }

  Future<void> clearCart() async {
    final cartItems = await carts
        .where('userId', isEqualTo: currentUserId)
        .where('isActive', isEqualTo: true)
        .get();
    
    for (var item in cartItems.docs) {
      await item.reference.update({'isActive': false});
    }
  }

  // Review methods
  Future<void> addReview(String productId, double rating, String comment) async {
    await reviews.add({
      'productId': productId,
      'userId': currentUserId,
      'rating': rating,
      'comment': comment,
      'createdAt': FieldValue.serverTimestamp(),
    });
    
    // Update product rating
    final productRef = products.doc(productId);
    final product = await productRef.get();
    final productData = product.data() as Map<String, dynamic>?;
    final currentRating = (productData?['rating'] as num?)?.toDouble() ?? 0.0;
    final reviewCount = (productData?['reviewCount'] as num?)?.toInt() ?? 0;
    final newRating = ((currentRating * reviewCount) + rating) / (reviewCount + 1);
    
    await productRef.update({
      'rating': newRating,
      'reviewCount': reviewCount + 1,
    });
  }

  // Search products
  Future<QuerySnapshot> searchProducts(String query) async {
    return await products
        .where('name', isGreaterThanOrEqualTo: query)
        .where('name', isLessThanOrEqualTo: '$query\uf8ff')
        .where('isActive', isEqualTo: true)
        .limit(20)
        .get();
  }
}
