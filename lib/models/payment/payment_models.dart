import 'package:flutter/material.dart';

enum TransactionType {
  deposit,
  payment,
  withdrawal,
  refund,
}

enum TransactionStatus {
  pending,
  completed,
  failed,
  cancelled,
}

class Transaction {
  final String id;
  final String userId;
  final double amount;
  final TransactionType type;
  final TransactionStatus status;
  final DateTime createdAt;
  final String? reference;
  final String? description;
  
  Transaction({
    required this.id,
    required this.userId,
    required this.amount,
    required this.type,
    required this.status,
    required this.createdAt,
    this.reference,
    this.description,
  });
  
  String get formattedAmount => 'KSh ${amount.toStringAsFixed(0)}';
  
  IconData get icon {
    switch (type) {
      case TransactionType.deposit:
        return Icons.arrow_downward;
      case TransactionType.payment:
        return Icons.shopping_cart;
      case TransactionType.withdrawal:
        return Icons.arrow_upward;
      case TransactionType.refund:
        return Icons.refresh;
    }
  }
  
  Color get color {
    switch (type) {
      case TransactionType.deposit:
        return Colors.green;
      case TransactionType.payment:
        return Colors.orange;
      case TransactionType.withdrawal:
        return Colors.red;
      case TransactionType.refund:
        return Colors.blue;
    }
  }
}

class WalletBalance {
  final double balance;
  final double totalSpent;
  final double totalEarned;
  final int totalTransactions;
  
  WalletBalance({
    required this.balance,
    required this.totalSpent,
    required this.totalEarned,
    required this.totalTransactions,
  });
  
  String get formattedBalance => 'KSh ${balance.toStringAsFixed(0)}';
  
  static WalletBalance getSample() {
    return WalletBalance(
      balance: 2450,
      totalSpent: 3850,
      totalEarned: 6300,
      totalTransactions: 24,
    );
  }
}
