class AdminStats {
  final int totalUsers;
  final int totalFarmers;
  final int totalConsumers;
  final int totalTransporters;
  final int totalProducts;
  final int totalOrders;
  final double totalRevenue;
  final int pendingOrders;
  final int completedOrders;
  final int cancelledOrders;
  
  AdminStats({
    required this.totalUsers,
    required this.totalFarmers,
    required this.totalConsumers,
    required this.totalTransporters,
    required this.totalProducts,
    required this.totalOrders,
    required this.totalRevenue,
    required this.pendingOrders,
    required this.completedOrders,
    required this.cancelledOrders,
  });
}

class UserManagement {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String role;
  final DateTime createdAt;
  final bool isVerified;
  final double rating;
  final int totalOrders;
  
  UserManagement({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.role,
    required this.createdAt,
    required this.isVerified,
    required this.rating,
    required this.totalOrders,
  });
}
