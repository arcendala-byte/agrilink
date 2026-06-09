import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../services/tracking_service.dart';
import '../../models/tracking/tracking_models.dart';

class OrderTrackingScreen extends StatefulWidget {
  final String orderId;
  final String deliveryAddress;
  
  const OrderTrackingScreen({
    super.key,
    required this.orderId,
    required this.deliveryAddress,
  });

  @override
  State<OrderTrackingScreen> createState() => _OrderTrackingScreenState();
}

class _OrderTrackingScreenState extends State<OrderTrackingScreen> {
  final TrackingService _trackingService = TrackingService();
  late GoogleMapController _mapController;
  
  static const LatLng _center = LatLng(-1.286389, 36.817223); // Nairobi
  
  final Set<Marker> _markers = {};
  final Set<Polyline> _polylines = {};
  
  List<OrderLocation> _locations = [];
  bool _isLoading = true;
  String _orderStatus = 'pending';
  String _driverName = '';
  String _driverPhone = '';
  double _progress = 0.0;

  @override
  void initState() {
    super.initState();
    _loadTrackingData();
  }

  Future<void> _loadTrackingData() async {
    // Simulate loading tracking data
    await Future.delayed(const Duration(seconds: 2));
    
    setState(() {
      _orderStatus = 'in_transit';
      _driverName = 'John Kamau';
      _driverPhone = '+254712345678';
      _progress = 0.45;
      _isLoading = false;
      _addMarkers();
    });
  }

  void _addMarkers() {
    // Driver marker (current location)
    _markers.add(
      Marker(
        markerId: const MarkerId('driver'),
        position: const LatLng(-1.276389, 36.827223),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
        infoWindow: const InfoWindow(title: 'Driver', snippet: 'On the way'),
      ),
    );
    
    // Destination marker
    _markers.add(
      Marker(
        markerId: const MarkerId('destination'),
        position: const LatLng(-1.296389, 36.807223),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
        infoWindow: InfoWindow(title: 'Delivery Address', snippet: widget.deliveryAddress),
      ),
    );
    
    // Add polyline (route)
    _polylines.add(
      Polyline(
        polylineId: const PolylineId('route'),
        points: const [
          LatLng(-1.276389, 36.827223),
          LatLng(-1.281389, 36.820223),
          LatLng(-1.286389, 36.815223),
          LatLng(-1.291389, 36.810223),
          LatLng(-1.296389, 36.807223),
        ],
        color: const Color(0xFF2E7D32),
        width: 4,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Track Order'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadTrackingData,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Map
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.5,
                  child: GoogleMap(
                    onMapCreated: (controller) => _mapController = controller,
                    initialCameraPosition: const CameraPosition(
                      target: _center,
                      zoom: 12,
                    ),
                    markers: _markers,
                    polylines: _polylines,
                    myLocationEnabled: true,
                    myLocationButtonEnabled: true,
                  ),
                ),
                
                // Tracking Info
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, -5),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Order Status
                        Row(
                          children: [
                            _buildStatusIcon(),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _getStatusText(),
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    _getStatusSubtitle(),
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        
                        // Progress Bar
                        LinearProgressIndicator(
                          value: _progress,
                          backgroundColor: Colors.grey.shade200,
                          color: const Color(0xFF2E7D32),
                          minHeight: 8,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        const SizedBox(height: 16),
                        
                        // ETA
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.orange.shade50,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.access_time, color: Colors.orange),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Estimated Arrival',
                                      style: TextStyle(fontWeight: FontWeight.bold),
                                    ),
                                    Text(
                                      '30-45 minutes',
                                      style: TextStyle(color: Colors.orange.shade700),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        
                        // Driver Info
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.green.shade50,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              const CircleAvatar(
                                backgroundColor: Color(0xFF2E7D32),
                                child: Icon(Icons.person, color: Colors.white),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      _driverName,
                                      style: const TextStyle(fontWeight: FontWeight.bold),
                                    ),
                                    Text(
                                      'Driver',
                                      style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                                    ),
                                  ],
                                ),
                              ),
                              OutlinedButton.icon(
                                onPressed: () {},
                                icon: const Icon(Icons.phone),
                                label: const Text('Call'),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildStatusIcon() {
    IconData icon;
    Color color;
    
    switch (_orderStatus) {
      case 'pending':
        icon = Icons.pending;
        color = Colors.orange;
        break;
      case 'confirmed':
        icon = Icons.check_circle;
        color = Colors.blue;
        break;
      case 'in_transit':
        icon = Icons.local_shipping;
        color = Colors.orange;
        break;
      case 'delivered':
        icon = Icons.delivery_dining;
        color = Colors.green;
        break;
      default:
        icon = Icons.pending;
        color = Colors.grey;
    }
    
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: color, size: 28),
    );
  }

  String _getStatusText() {
    switch (_orderStatus) {
      case 'pending':
        return 'Order Confirmed';
      case 'confirmed':
        return 'Preparing your order';
      case 'in_transit':
        return 'Out for Delivery';
      case 'delivered':
        return 'Delivered';
      default:
        return 'Processing';
    }
  }

  String _getStatusSubtitle() {
    switch (_orderStatus) {
      case 'pending':
        return 'Your order has been confirmed';
      case 'confirmed':
        return 'Farmer is preparing your fresh produce';
      case 'in_transit':
        return 'Your order is on the way';
      case 'delivered':
        return 'Your order has been delivered';
      default:
        return 'Processing your order';
    }
  }
}
