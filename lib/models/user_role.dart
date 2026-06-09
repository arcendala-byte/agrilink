import 'package:flutter/material.dart';

enum UserRole {
  farmer,
  consumer,
  transporter,
}

extension UserRoleExtension on UserRole {
  String get displayName {
    switch (this) {
      case UserRole.farmer:
        return 'Farmer';
      case UserRole.consumer:
        return 'Consumer';
      case UserRole.transporter:
        return 'Transporter';
    }
  }

  IconData get icon {
    switch (this) {
      case UserRole.farmer:
        return Icons.agriculture;
      case UserRole.consumer:
        return Icons.shopping_cart;
      case UserRole.transporter:
        return Icons.local_shipping;
    }
  }
  
  Color get color {
    switch (this) {
      case UserRole.farmer:
        return const Color(0xFF2E7D32);
      case UserRole.consumer:
        return Colors.blue;
      case UserRole.transporter:
        return Colors.orange;
    }
  }
}
