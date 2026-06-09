import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class OrderService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? get currentUserId => _auth.currentUser?.uid;

  Future<String?> createOrder({
    required List<Map<String, dynamic>> items,
    required double totalAmount,
    required String deliveryAddress,
    required String farmerId,
    required String farmerName,
  }) async {
    try {
      final orderData = {
        'userId': currentUserId,
        'farmerId': farmerId,
        'farmerName': farmerName,
        'items': items,
        'totalAmount': totalAmount,
        'deliveryAddress': deliveryAddress,
        'status': 'pending',
        'orderDate': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'trackingNumber': _generateTrackingNumber(),
      };
      
      final docRef = await _firestore.collection('orders').add(orderData);
      return docRef.id;
    } catch (e) {
      print('Error creating order: $e');
      return null;
    }
  }

  // Simplified query - returns Future instead of Stream (no index needed)
  Future<List<QueryDocumentSnapshot>> getUserOrders() async {
    try {
      final snapshot = await _firestore
          .collection('orders')
          .get();
      
      final userOrders = snapshot.docs.where((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return data['userId'] == currentUserId;
      }).toList();
      
      // Sort by orderDate descending
      userOrders.sort((a, b) {
        final aData = a.data() as Map<String, dynamic>;
        final bData = b.data() as Map<String, dynamic>;
        final aDate = aData['orderDate'] as Timestamp?;
        final bDate = bData['orderDate'] as Timestamp?;
        if (aDate == null && bDate == null) return 0;
        if (aDate == null) return 1;
        if (bDate == null) return -1;
        return bDate.compareTo(aDate);
      });
      
      return userOrders;
    } catch (e) {
      print('Error getting orders: $e');
      return [];
    }
  }

  Future<DocumentSnapshot> getOrder(String orderId) async {
    return await _firestore.collection('orders').doc(orderId).get();
  }

  Future<bool> cancelOrder(String orderId) async {
    try {
      await _firestore.collection('orders').doc(orderId).update({
        'status': 'cancelled',
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return true;
    } catch (e) {
      return false;
    }
  }

  String _generateTrackingNumber() {
    return 'AGR-${DateTime.now().millisecondsSinceEpoch}-${currentUserId?.substring(0, 4) ?? '0000'}';
  }
}
