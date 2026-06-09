import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class MarketIntelligenceScreen extends StatefulWidget {
  const MarketIntelligenceScreen({super.key});

  @override
  State<MarketIntelligenceScreen> createState() => _MarketIntelligenceScreenState();
}

class _MarketIntelligenceScreenState extends State<MarketIntelligenceScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _selectedCommodity = 'Tomatoes';
  
  final List<CommodityData> _commodities = [
    CommodityData(
      name: 'Tomatoes',
      currentPrice: 65,
      previousPrice: 50,
      unit: 'kg',
      priceHistory: [50, 52, 55, 58, 60, 65, 65],
    ),
    CommodityData(
      name: 'Maize',
      currentPrice: 90,
      previousPrice: 85,
      unit: 'kg',
      priceHistory: [85, 86, 87, 88, 89, 90, 90],
    ),
    CommodityData(
      name: 'Onions',
      currentPrice: 70,
      previousPrice: 75,
      unit: 'kg',
      priceHistory: [75, 74, 73, 72, 71, 70, 70],
    ),
    CommodityData(
      name: 'Potatoes',
      currentPrice: 85,
      previousPrice: 80,
      unit: 'kg',
      priceHistory: [80, 81, 82, 83, 84, 85, 85],
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Market Intelligence'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Price Trends'),
            Tab(text: 'Insights'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildPriceTrendsTab(),
          _buildInsightsTab(),
        ],
      ),
    );
  }

  Widget _buildPriceTrendsTab() {
    final selectedCommodity = _commodities.firstWhere((c) => c.name == _selectedCommodity);
    final priceChange = selectedCommodity.currentPrice - selectedCommodity.previousPrice;
    final priceChangePercent = (priceChange / selectedCommodity.previousPrice) * 100;
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Commodity Selector
          const Text('Select Commodity', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(12),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedCommodity,
                isExpanded: true,
                icon: const Icon(Icons.arrow_drop_down),
                items: _commodities.map((commodity) {
                  return DropdownMenuItem(
                    value: commodity.name,
                    child: Text(commodity.name),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedCommodity = value!;
                  });
                },
              ),
            ),
          ),
          const SizedBox(height: 24),
          
          // Price Card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.green.shade700, Colors.green.shade400],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: [
                Text(
                  'Current Price',
                  style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 14),
                ),
                const SizedBox(height: 8),
                Text(
                  'KSh ${selectedCommodity.currentPrice.toStringAsFixed(0)}/${selectedCommodity.unit}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      priceChange >= 0 ? Icons.trending_up : Icons.trending_down,
                      color: priceChange >= 0 ? Colors.green.shade300 : Colors.red.shade300,
                      size: 20,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${priceChangePercent.abs().toStringAsFixed(1)}% vs last week',
                      style: TextStyle(
                        color: priceChange >= 0 ? Colors.green.shade300 : Colors.red.shade300,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          
          // Price Chart
          const Text('Price Trend (Last 7 Days)', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Container(
            height: 250,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  blurRadius: 10,
                ),
              ],
            ),
            child: LineChart(
              LineChartData(
                gridData: FlGridData(show: true),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: true, reservedSize: 40),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
                        if (value.toInt() >= 0 && value.toInt() < days.length) {
                          return Text(days[value.toInt()], style: const TextStyle(fontSize: 10));
                        }
                        return const Text('');
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: List.generate(selectedCommodity.priceHistory.length, (index) {
                      return FlSpot(index.toDouble(), selectedCommodity.priceHistory[index]);
                    }),
                    isCurved: true,
                    color: const Color(0xFF2E7D32),
                    barWidth: 3,
                    dotData: FlDotData(show: true),
                    belowBarData: BarAreaData(
                      show: true,
                      color: const Color(0xFF2E7D32).withOpacity(0.1),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          
          // Market Summary
          const Text('Market Summary', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            children: [
              _buildSummaryCard(
                'Average Price',
                'KSh ${_getAveragePrice().toStringAsFixed(0)}',
                Icons.attach_money,
                Colors.blue,
              ),
              _buildSummaryCard(
                'Price Range',
                'KSh ${_getMinPrice().toStringAsFixed(0)} - ${_getMaxPrice().toStringAsFixed(0)}',
                Icons.compare_arrows,
                Colors.purple,
              ),
              _buildSummaryCard(
                'Trading Volume',
                '↑ 15%',
                Icons.trending_up,
                Colors.green,
              ),
              _buildSummaryCard(
                'Demand',
                'High',
                Icons.people,
                Colors.orange,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInsightsTab() {
    final insights = [
      {
        'title': 'Tomato Prices Rising',
        'description': 'Tomato prices have increased by 30% this week due to reduced supply from major farming regions.',
        'impact': 'High demand expected',
        'icon': Icons.trending_up,
        'color': Colors.green,
      },
      {
        'title': 'Maize Harvest Season',
        'description': 'New harvest arriving next week. Prices expected to stabilize after recent increases.',
        'impact': 'Good time to buy',
        'icon': Icons.agriculture,
        'color': Colors.orange,
      },
      {
        'title': 'Export Opportunity',
        'description': 'Increased demand for organic produce from European markets. Farmers can get premium prices.',
        'impact': 'Export potential',
        'icon': Icons.local_shipping,
        'color': Colors.blue,
      },
      {
        'title': 'Weather Alert',
        'description': 'Heavy rains expected in Central region next week. May affect vegetable supplies.',
        'impact': 'Plan accordingly',
        'icon': Icons.warning,
        'color': Colors.red,
      },
    ];
    
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: insights.length,
      itemBuilder: (context, index) {
        final insight = insights[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: (insight['color'] as Color).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(insight['icon'] as IconData, color: insight['color'] as Color, size: 24),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        insight['title'] as String,
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  insight['description'] as String,
                  style: TextStyle(color: Colors.grey.shade600, height: 1.5),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: (insight['color'] as Color).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    insight['impact'] as String,
                    style: TextStyle(color: insight['color'] as Color, fontSize: 12, fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSummaryCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 8),
            Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(title, style: TextStyle(fontSize: 11, color: Colors.grey.shade600), textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }

  double _getAveragePrice() {
    if (_commodities.isEmpty) return 0;
    return _commodities.map((c) => c.currentPrice).reduce((a, b) => a + b) / _commodities.length;
  }

  double _getMinPrice() {
    if (_commodities.isEmpty) return 0;
    return _commodities.map((c) => c.currentPrice).reduce((a, b) => a < b ? a : b);
  }

  double _getMaxPrice() {
    if (_commodities.isEmpty) return 0;
    return _commodities.map((c) => c.currentPrice).reduce((a, b) => a > b ? a : b);
  }
}

class CommodityData {
  final String name;
  final double currentPrice;
  final double previousPrice;
  final String unit;
  final List<double> priceHistory;
  
  CommodityData({
    required this.name,
    required this.currentPrice,
    required this.previousPrice,
    required this.unit,
    required this.priceHistory,
  });
}
