import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../models/tracking/tracking_models.dart';

class TrackingService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Update driver location (for transporters)
  Future<void> updateDriverLocation({
    required String orderId,
    required double latitude,
    required double longitude,
    required String status,
  }) async {
    final location = OrderLocation(
      latitude: latitude,
      longitude: longitude,
      timestamp: DateTime.now(),
      status: status,
    );
    
    await _firestore
        .collection('orders')
        .doc(orderId)
        .collection('tracking')
        .add(location.toJson());
    
    await _firestore.collection('orders').doc(orderId).update({
      'currentLatitude': latitude,
      'currentLongitude': longitude,
      'lastUpdated': FieldValue.serverTimestamp(),
    });
  }

  // Get real-time tracking stream
  Stream<List<OrderLocation>> getTrackingStream(String orderId) {
    return _firestore
        .collection('orders')
        .doc(orderId)
        .collection('tracking')
        .orderBy('timestamp', descending: true)
        .limit(100)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            final data = doc.data();
            return OrderLocation(
              latitude: data['latitude'],
              longitude: data['longitude'],
              timestamp: (data['timestamp'] as Timestamp).toDate(),
              status: data['status'],
              address: data['address'],
            );
          }).toList();
        });
  }

  // Get current location
  Future<Position> getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }
    
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }
    
    return await Geolocator.getCurrentPosition();
  }

  // Calculate distance between two points
  double calculateDistance(LatLng point1, LatLng point2) {
    const double earthRadius = 6371000; // meters
    double dLat = _toRadians(point2.latitude - point1.latitude);
    double dLng = _toRadians(point2.longitude - point1.longitude);
    double a = _sin(dLat / 2) * _sin(dLat / 2) +
        _cos(_toRadians(point1.latitude)) * _cos(_toRadians(point2.latitude)) *
        _sin(dLng / 2) * _sin(dLng / 2);
    double c = 2 * _atan2(_sqrt(a), _sqrt(1 - a));
    return earthRadius * c;
  }
  
  double _toRadians(double degrees) => degrees * 3.141592653589793 / 180;
  double _sin(double x) => x - (x * x * x) / 6;
  double _cos(double x) => 1 - (x * x) / 2;
  double _sqrt(double x) => x > 0 ? x : 0;
  double _atan2(double y, double x) => y >= 0 ? y / (x + y) : y / (x - y);
}
