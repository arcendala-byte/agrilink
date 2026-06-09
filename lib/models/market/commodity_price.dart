import 'package:flutter/material.dart';

class CommodityPrice {
  final String id;
  final String name;
  final String category;
  final double currentPrice;
  final double previousPrice;
  final String unit;
  final String location;
  final DateTime lastUpdated;
  final List<PriceHistory> priceHistory;

  CommodityPrice({
    required this.id,
    required this.name,
    required this.category,
    required this.currentPrice,
    required this.previousPrice,
    required this.unit,
    required this.location,
    required this.lastUpdated,
    required this.priceHistory,
  });

  double get priceChange => currentPrice - previousPrice;
  double get priceChangePercentage => (priceChange / previousPrice) * 100;
  bool get isPriceUp => priceChange > 0;

  static List<CommodityPrice> getSamplePrices() {
    return [
      CommodityPrice(
        id: '1',
        name: 'Tomatoes',
        category: 'Vegetables',
        currentPrice: 65,
        previousPrice: 50,
        unit: 'kg',
        location: 'Nairobi Market',
        lastUpdated: DateTime.now(),
        priceHistory: [
          PriceHistory(price: 50, date: DateTime.now().subtract(const Duration(days: 6))),
          PriceHistory(price: 52, date: DateTime.now().subtract(const Duration(days: 5))),
          PriceHistory(price: 55, date: DateTime.now().subtract(const Duration(days: 4))),
          PriceHistory(price: 58, date: DateTime.now().subtract(const Duration(days: 3))),
          PriceHistory(price: 60, date: DateTime.now().subtract(const Duration(days: 2))),
          PriceHistory(price: 65, date: DateTime.now().subtract(const Duration(days: 1))),
          PriceHistory(price: 65, date: DateTime.now()),
        ],
      ),
      CommodityPrice(
        id: '2',
        name: 'Maize',
        category: 'Cereals',
        currentPrice: 90,
        previousPrice: 85,
        unit: 'kg',
        location: 'Nairobi Market',
        lastUpdated: DateTime.now(),
        priceHistory: [
          PriceHistory(price: 85, date: DateTime.now().subtract(const Duration(days: 6))),
          PriceHistory(price: 86, date: DateTime.now().subtract(const Duration(days: 5))),
          PriceHistory(price: 87, date: DateTime.now().subtract(const Duration(days: 4))),
          PriceHistory(price: 88, date: DateTime.now().subtract(const Duration(days: 3))),
          PriceHistory(price: 89, date: DateTime.now().subtract(const Duration(days: 2))),
          PriceHistory(price: 90, date: DateTime.now().subtract(const Duration(days: 1))),
          PriceHistory(price: 90, date: DateTime.now()),
        ],
      ),
      CommodityPrice(
        id: '3',
        name: 'Onions',
        category: 'Vegetables',
        currentPrice: 70,
        previousPrice: 75,
        unit: 'kg',
        location: 'Nairobi Market',
        lastUpdated: DateTime.now(),
        priceHistory: [
          PriceHistory(price: 75, date: DateTime.now().subtract(const Duration(days: 6))),
          PriceHistory(price: 74, date: DateTime.now().subtract(const Duration(days: 5))),
          PriceHistory(price: 73, date: DateTime.now().subtract(const Duration(days: 4))),
          PriceHistory(price: 72, date: DateTime.now().subtract(const Duration(days: 3))),
          PriceHistory(price: 71, date: DateTime.now().subtract(const Duration(days: 2))),
          PriceHistory(price: 70, date: DateTime.now().subtract(const Duration(days: 1))),
          PriceHistory(price: 70, date: DateTime.now()),
        ],
      ),
    ];
  }
}

class PriceHistory {
  final double price;
  final DateTime date;

  PriceHistory({required this.price, required this.date});
}

class MarketInsight {
  final String title;
  final String description;
  final String impact;
  final IconData icon;
  final Color color;

  MarketInsight({
    required this.title,
    required this.description,
    required this.impact,
    required this.icon,
    required this.color,
  });

  static List<MarketInsight> getInsights() {
    return [
      MarketInsight(
        title: 'Tomato Prices Rising',
        description: 'Tomato prices have increased by 30% this week due to reduced supply.',
        impact: 'High demand expected',
        icon: Icons.trending_up,
        color: Colors.green,
      ),
      MarketInsight(
        title: 'Maize Harvest Season',
        description: 'New harvest arriving next week. Prices expected to stabilize.',
        impact: 'Good time to buy',
        icon: Icons.agriculture,
        color: Colors.orange,
      ),
      MarketInsight(
        title: 'Export Opportunity',
        description: 'Increased demand for organic produce from European markets.',
        impact: 'Export potential',
        icon: Icons.local_shipping,
        color: Colors.blue,
      ),
    ];
  }
}
