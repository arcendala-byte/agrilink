import 'package:flutter/material.dart';

class SalesData {
  final DateTime date;
  final double revenue;
  final int orders;
  final int productsSold;
  
  SalesData({
    required this.date,
    required this.revenue,
    required this.orders,
    required this.productsSold,
  });
}

class CustomerInsight {
  final int totalCustomers;
  final int newCustomers;
  final double repeatPurchaseRate;
  final double averageOrderValue;
  final Map<String, int> topLocations;
  
  CustomerInsight({
    required this.totalCustomers,
    required this.newCustomers,
    required this.repeatPurchaseRate,
    required this.averageOrderValue,
    required this.topLocations,
  });
}

class ProductPerformance {
  final String productName;
  final int quantitySold;
  final double revenue;
  final double growth;
  final double rating;
  
  ProductPerformance({
    required this.productName,
    required this.quantitySold,
    required this.revenue,
    required this.growth,
    required this.rating,
  });
}

class SalesForecast {
  final DateTime period;
  final double predictedRevenue;
  final double lowerBound;
  final double upperBound;
  final String confidence;
  
  SalesForecast({
    required this.period,
    required this.predictedRevenue,
    required this.lowerBound,
    required this.upperBound,
    required this.confidence,
  });
}

class FarmerAnalytics {
  final double totalRevenue;
  final int totalOrders;
  final double averageOrderValue;
  final int totalCustomers;
  final double customerSatisfaction;
  final double revenueGrowth;
  final List<SalesData> weeklySales;
  final List<SalesData> monthlySales;
  final List<SalesData> yearlySales;
  final List<ProductPerformance> topProducts;
  final List<SalesForecast> forecasts;
  final CustomerInsight customerInsights;
  
  FarmerAnalytics({
    required this.totalRevenue,
    required this.totalOrders,
    required this.averageOrderValue,
    required this.totalCustomers,
    required this.customerSatisfaction,
    required this.revenueGrowth,
    required this.weeklySales,
    required this.monthlySales,
    required this.yearlySales,
    required this.topProducts,
    required this.forecasts,
    required this.customerInsights,
  });
  
  static FarmerAnalytics getSampleData() {
    return FarmerAnalytics(
      totalRevenue: 125000,
      totalOrders: 156,
      averageOrderValue: 801,
      totalCustomers: 89,
      customerSatisfaction: 4.8,
      revenueGrowth: 23.5,
      weeklySales: [
        SalesData(date: DateTime.now().subtract(const Duration(days: 6)), revenue: 15000, orders: 18, productsSold: 320),
        SalesData(date: DateTime.now().subtract(const Duration(days: 5)), revenue: 18000, orders: 22, productsSold: 410),
        SalesData(date: DateTime.now().subtract(const Duration(days: 4)), revenue: 16500, orders: 20, productsSold: 380),
        SalesData(date: DateTime.now().subtract(const Duration(days: 3)), revenue: 20000, orders: 25, productsSold: 450),
        SalesData(date: DateTime.now().subtract(const Duration(days: 2)), revenue: 22000, orders: 27, productsSold: 490),
        SalesData(date: DateTime.now().subtract(const Duration(days: 1)), revenue: 19500, orders: 24, productsSold: 430),
        SalesData(date: DateTime.now(), revenue: 21000, orders: 26, productsSold: 470),
      ],
      monthlySales: [
        SalesData(date: DateTime.now().subtract(const Duration(days: 30)), revenue: 85000, orders: 98, productsSold: 1800),
        SalesData(date: DateTime.now().subtract(const Duration(days: 60)), revenue: 72000, orders: 85, productsSold: 1600),
        SalesData(date: DateTime.now().subtract(const Duration(days: 90)), revenue: 68000, orders: 79, productsSold: 1500),
      ],
      yearlySales: [
        SalesData(date: DateTime.now().subtract(const Duration(days: 365)), revenue: 520000, orders: 620, productsSold: 12000),
        SalesData(date: DateTime.now().subtract(const Duration(days: 730)), revenue: 480000, orders: 580, productsSold: 11000),
        SalesData(date: DateTime.now().subtract(const Duration(days: 1095)), revenue: 450000, orders: 540, productsSold: 10000),
      ],
      topProducts: [
        ProductPerformance(productName: 'Fresh Tomatoes', quantitySold: 850, revenue: 42500, growth: 15.5, rating: 4.9),
        ProductPerformance(productName: 'Sweet Bananas', quantitySold: 420, revenue: 12600, growth: 8.2, rating: 4.8),
        ProductPerformance(productName: 'Organic Maize', quantitySold: 310, revenue: 24800, growth: 22.0, rating: 4.7),
        ProductPerformance(productName: 'Free-range Eggs', quantitySold: 1200, revenue: 18000, growth: 12.3, rating: 4.9),
      ],
      forecasts: [
        SalesForecast(period: DateTime.now().add(const Duration(days: 7)), predictedRevenue: 23000, lowerBound: 21000, upperBound: 25000, confidence: 'High'),
        SalesForecast(period: DateTime.now().add(const Duration(days: 14)), predictedRevenue: 24500, lowerBound: 22000, upperBound: 27000, confidence: 'Medium'),
        SalesForecast(period: DateTime.now().add(const Duration(days: 21)), predictedRevenue: 26000, lowerBound: 23000, upperBound: 29000, confidence: 'Medium'),
        SalesForecast(period: DateTime.now().add(const Duration(days: 30)), predictedRevenue: 28000, lowerBound: 25000, upperBound: 31000, confidence: 'Low'),
      ],
      customerInsights: CustomerInsight(
        totalCustomers: 89,
        newCustomers: 23,
        repeatPurchaseRate: 68.5,
        averageOrderValue: 801,
        topLocations: {'Nairobi': 45, 'Kiambu': 23, 'Thika': 12, 'Limuru': 9},
      ),
    );
  }
}
