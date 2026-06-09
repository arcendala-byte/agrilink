import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/bulk_order/bulk_order_models.dart';

class BulkOrderService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? get currentUserId => _auth.currentUser?.uid;
  String? get currentUserName => _auth.currentUser?.displayName;

  // Create bulk order
  Future<String?> createBulkOrder({
    required List<BulkOrderItem> items,
    required double subtotal,
    required double discount,
    required double deliveryFee,
    required double total,
    required String deliveryAddress,
    required String phoneNumber,
    required String farmerId,
    required String farmerName,
    bool isRecurring = false,
    String? recurringFrequency,
    int? recurringWeeks,
    String? notes,
  }) async {
    try {
      final orderData = {
        'retailerId': currentUserId,
        'retailerName': currentUserName,
        'farmerId': farmerId,
        'farmerName': farmerName,
        'items': items.map((item) => item.toJson()).toList(),
        'subtotal': subtotal,
        'discount': discount,
        'deliveryFee': deliveryFee,
        'total': total,
        'status': 'pending',
        'deliveryAddress': deliveryAddress,
        'phoneNumber': phoneNumber,
        'orderDate': FieldValue.serverTimestamp(),
        'isRecurring': isRecurring,
        'recurringFrequency': recurringFrequency,
        'recurringWeeks': recurringWeeks,
        'notes': notes,
      };
      
      final docRef = await _firestore.collection('bulkOrders').add(orderData);
      return docRef.id;
    } catch (e) {
      print('Error creating bulk order: $e');
      return null;
    }
  }

  // Get retailer's bulk orders
  Stream<List<BulkOrder>> getRetailerBulkOrders() {
    return _firestore
        .collection('bulkOrders')
        .where('retailerId', isEqualTo: currentUserId)
        .orderBy('orderDate', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            final data = doc.data();
            final items = (data['items'] as List)
                .map((item) => BulkOrderItem(
                      productId: item['productId'],
                      productName: item['productName'],
                      unitPrice: item['unitPrice'],
                      quantity: item['quantity'],
                      unit: item['unit'],
                      bulkPrice: item['bulkPrice'],
                      bulkQuantity: item['bulkQuantity'],
                    ))
                .toList();
            
            return BulkOrder(
              id: doc.id,
              retailerId: data['retailerId'],
              retailerName: data['retailerName'],
              farmerId: data['farmerId'],
              farmerName: data['farmerName'],
              items: items,
              subtotal: data['subtotal'],
              discount: data['discount'],
              deliveryFee: data['deliveryFee'],
              total: data['total'],
              status: _getStatusFromString(data['status']),
              deliveryAddress: data['deliveryAddress'],
              phoneNumber: data['phoneNumber'],
              orderDate: (data['orderDate'] as Timestamp).toDate(),
              deliveryDate: data['deliveryDate']?.toDate(),
              notes: data['notes'],
              isRecurring: data['isRecurring'] ?? false,
              recurringFrequency: data['recurringFrequency'],
              recurringWeeks: data['recurringWeeks'],
            );
          }).toList();
        });
  }

  // Get farmer's bulk orders (for farmers to see requests)
  Stream<List<BulkOrder>> getFarmerBulkOrders() {
    return _firestore
        .collection('bulkOrders')
        .where('farmerId', isEqualTo: currentUserId)
        .orderBy('orderDate', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            final data = doc.data();
            final items = (data['items'] as List)
                .map((item) => BulkOrderItem(
                      productId: item['productId'],
                      productName: item['productName'],
                      unitPrice: item['unitPrice'],
                      quantity: item['quantity'],
                      unit: item['unit'],
                      bulkPrice: item['bulkPrice'],
                      bulkQuantity: item['bulkQuantity'],
                    ))
                .toList();
            
            return BulkOrder(
              id: doc.id,
              retailerId: data['retailerId'],
              retailerName: data['retailerName'],
              farmerId: data['farmerId'],
              farmerName: data['farmerName'],
              items: items,
              subtotal: data['subtotal'],
              discount: data['discount'],
              deliveryFee: data['deliveryFee'],
              total: data['total'],
              status: _getStatusFromString(data['status']),
              deliveryAddress: data['deliveryAddress'],
              phoneNumber: data['phoneNumber'],
              orderDate: (data['orderDate'] as Timestamp).toDate(),
              deliveryDate: data['deliveryDate']?.toDate(),
              notes: data['notes'],
              isRecurring: data['isRecurring'] ?? false,
              recurringFrequency: data['recurringFrequency'],
              recurringWeeks: data['recurringWeeks'],
            );
          }).toList();
        });
  }

  // Update order status (for farmers)
  Future<void> updateOrderStatus(String orderId, BulkOrderStatus newStatus) async {
    await _firestore.collection('bulkOrders').doc(orderId).update({
      'status': _getStatusString(newStatus),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  BulkOrderStatus _getStatusFromString(String status) {
    switch (status) {
      case 'pending': return BulkOrderStatus.pending;
      case 'confirmed': return BulkOrderStatus.confirmed;
      case 'processing': return BulkOrderStatus.processing;
      case 'ready': return BulkOrderStatus.ready;
      case 'delivered': return BulkOrderStatus.delivered;
      case 'cancelled': return BulkOrderStatus.cancelled;
      default: return BulkOrderStatus.pending;
    }
  }

  String _getStatusString(BulkOrderStatus status) {
    switch (status) {
      case BulkOrderStatus.pending: return 'pending';
      case BulkOrderStatus.confirmed: return 'confirmed';
      case BulkOrderStatus.processing: return 'processing';
      case BulkOrderStatus.ready: return 'ready';
      case BulkOrderStatus.delivered: return 'delivered';
      case BulkOrderStatus.cancelled: return 'cancelled';
    }
  }
}
