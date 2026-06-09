import 'package:google_maps_flutter/google_maps_flutter.dart';

class OrderLocation {
  final double latitude;
  final double longitude;
  final DateTime timestamp;
  final String status;
  final String? address;
  
  OrderLocation({
    required this.latitude,
    required this.longitude,
    required this.timestamp,
    required this.status,
    this.address,
  });
  
  LatLng get latLng => LatLng(latitude, longitude);
  
  Map<String, dynamic> toJson() => {
    'latitude': latitude,
    'longitude': longitude,
    'timestamp': timestamp.toIso8601String(),
    'status': status,
    'address': address,
  };
  
  factory OrderLocation.fromJson(Map<String, dynamic> json) {
    return OrderLocation(
      latitude: json['latitude'],
      longitude: json['longitude'],
      timestamp: DateTime.parse(json['timestamp']),
      status: json['status'],
      address: json['address'],
    );
  }
}

class DeliveryRoute {
  final String orderId;
  final String driverName;
  final String driverPhone;
  final String vehicleNumber;
  final double currentLatitude;
  final double currentLongitude;
  final double destinationLatitude;
  final double destinationLongitude;
  final DateTime estimatedArrival;
  final List<OrderLocation> routeHistory;
  
  DeliveryRoute({
    required this.orderId,
    required this.driverName,
    required this.driverPhone,
    required this.vehicleNumber,
    required this.currentLatitude,
    required this.currentLongitude,
    required this.destinationLatitude,
    required this.destinationLongitude,
    required this.estimatedArrival,
    this.routeHistory = const [],
  });
  
  LatLng get currentPosition => LatLng(currentLatitude, currentLongitude);
  LatLng get destination => LatLng(destinationLatitude, destinationLongitude);
}
