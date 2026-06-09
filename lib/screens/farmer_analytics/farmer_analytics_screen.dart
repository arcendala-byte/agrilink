import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../models/analytics/farmer_analytics.dart';
import '../../services/analytics_service.dart';

class FarmerAnalyticsScreen extends StatefulWidget {
  const FarmerAnalyticsScreen({super.key});

  @override
  State<FarmerAnalyticsScreen> createState() => _FarmerAnalyticsScreenState();
}

class _FarmerAnalyticsScreenState extends State<FarmerAnalyticsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late FarmerAnalytics _analytics;
  bool _isLoading = true;
  String _selectedPeriod = 'Weekly';
  final AnalyticsService _analyticsService = AnalyticsService();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadAnalytics();
  }

  Future<void> _loadAnalytics() async {
    setState(() => _isLoading = true);
    _analytics = await _analyticsService.getFarmerAnalytics();
    setState(() => _isLoading = false);
  }

  Future<void> _exportReport() async {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Export Report',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              ListTile(
                leading: const Icon(Icons.picture_as_pdf, color: Colors.red),
                title: const Text('Export as PDF'),
                onTap: () {
                  Navigator.pop(context);
                  _analyticsService.exportToPDF(_analytics);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('PDF export started')),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.grid_on, color: Colors.green),
                title: const Text('Export as Excel'),
                onTap: () {
                  Navigator.pop(context);
                  _analyticsService.exportToExcel(_analytics);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Excel export started')),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Farmer Analytics'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: _exportReport,
            tooltip: 'Export Report',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadAnalytics,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Overview', icon: Icon(Icons.dashboard)),
            Tab(text: 'Sales', icon: Icon(Icons.trending_up)),
            Tab(text: 'Products', icon: Icon(Icons.inventory)),
            Tab(text: 'Forecast', icon: Icon(Icons.analytics)),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildOverviewTab(),
                _buildSalesTab(),
                _buildProductsTab(),
                _buildForecastTab(),
              ],
            ),
    );
  }

  Widget _buildOverviewTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Key Metrics Grid
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            children: [
              _buildMetricCard(
                'Total Revenue',
                'KSh ${_analytics.totalRevenue.toStringAsFixed(0)}',
                Icons.attach_money,
                Colors.green,
                '+${_analytics.revenueGrowth}%',
              ),
              _buildMetricCard(
                'Total Orders',
                '${_analytics.totalOrders}',
                Icons.shopping_bag,
                Colors.blue,
                '+12%',
              ),
              _buildMetricCard(
                'Avg Order Value',
                'KSh ${_analytics.averageOrderValue.toStringAsFixed(0)}',
                Icons.receipt,
                Colors.purple,
                '+8%',
              ),
              _buildMetricCard(
                'Customer Rating',
                '${_analytics.customerSatisfaction} ★',
                Icons.star,
                Colors.amber,
                'Excellent',
              ),
            ],
          ),
          const SizedBox(height: 20),
          
          // Customer Insights
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Customer Insights',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildInsightCard(
                          'Total Customers',
                          '${_analytics.customerInsights.totalCustomers}',
                          Icons.people,
                          Colors.blue,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildInsightCard(
                          'New Customers',
                          '+${_analytics.customerInsights.newCustomers}',
                          Icons.person_add,
                          Colors.green,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildInsightCard(
                          'Repeat Rate',
                          '${_analytics.customerInsights.repeatPurchaseRate.toStringAsFixed(1)}%',
                          Icons.repeat,
                          Colors.orange,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildInsightCard(
                          'Avg Order',
                          'KSh ${_analytics.customerInsights.averageOrderValue.toStringAsFixed(0)}',
                          Icons.receipt_long,
                          Colors.purple,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Top Locations',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  ..._analytics.customerInsights.topLocations.entries.map((entry) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Row(
                        children: [
                          Text(entry.key),
                          const Spacer(),
                          Text('${entry.value} customers'),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSalesTab() {
    final salesData = _selectedPeriod == 'Weekly' ? _analytics.weeklySales : 
                      (_selectedPeriod == 'Monthly' ? _analytics.monthlySales : _analytics.yearlySales);
    
    return Column(
      children: [
        // Period Selector
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              const Text('Period:', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(width: 12),
              SegmentedButton<String>(
                segments: const [
                  ButtonSegment(value: 'Weekly', label: Text('Weekly')),
                  ButtonSegment(value: 'Monthly', label: Text('Monthly')),
                  ButtonSegment(value: 'Yearly', label: Text('Yearly')),
                ],
                selected: {_selectedPeriod},
                onSelectionChanged: (Set<String> selection) {
                  setState(() => _selectedPeriod = selection.first);
                },
              ),
            ],
          ),
        ),
        
        // Sales Chart
        Expanded(
          flex: 2,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(16),
              ),
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(show: true),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        getTitlesWidget: (value, meta) {
                          return Text('KSh ${value.toInt()}', style: const TextStyle(fontSize: 10));
                        },
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          if (value.toInt() >= 0 && value.toInt() < salesData.length) {
                            final label = _selectedPeriod == 'Weekly' 
                                ? 'Day ${value.toInt() + 1}'
                                : _selectedPeriod == 'Monthly'
                                    ? 'Month ${value.toInt() + 1}'
                                    : 'Year ${value.toInt() + 1}';
                            return Text(label, style: const TextStyle(fontSize: 10));
                          }
                          return const Text('');
                        },
                      ),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    LineChartBarData(
                      spots: List.generate(salesData.length, (index) {
                        return FlSpot(index.toDouble(), salesData[index].revenue);
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
          ),
        ),
        
        // Sales Summary
        Expanded(
          flex: 1,
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: salesData.length,
            itemBuilder: (context, index) {
              final sale = salesData[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  title: Text(_getDateLabel(sale.date, _selectedPeriod)),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'KSh ${sale.revenue.toStringAsFixed(0)}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        '${sale.orders} orders',
                        style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildProductsTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _analytics.topProducts.length,
      itemBuilder: (context, index) {
        final product = _analytics.topProducts[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.green.shade100,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.shopping_bag, color: Colors.green),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            product.productName,
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          Row(
                            children: [
                              const Icon(Icons.star, size: 14, color: Colors.amber),
                              const SizedBox(width: 4),
                              Text('${product.rating} ★'),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildProductStat('Quantity', '${product.quantitySold} units'),
                    _buildProductStat('Revenue', 'KSh ${product.revenue.toStringAsFixed(0)}'),
                    _buildProductStat('Growth', '+${product.growth}%'),
                  ],
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: product.revenue / _analytics.totalRevenue,
                  backgroundColor: Colors.grey.shade200,
                  color: Colors.green,
                  minHeight: 6,
                  borderRadius: BorderRadius.circular(3),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildForecastTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _analytics.forecasts.length,
      itemBuilder: (context, index) {
        final forecast = _analytics.forecasts[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.blue.shade100,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.analytics, color: Colors.blue),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Week ${index + 1} Forecast',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            'Starting ${_formatDate(forecast.period)}',
                            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: _getConfidenceColor(forecast.confidence).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        forecast.confidence,
                        style: TextStyle(
                          fontSize: 11,
                          color: _getConfidenceColor(forecast.confidence),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildForecastItem('Predicted', 'KSh ${forecast.predictedRevenue.toStringAsFixed(0)}'),
                    _buildForecastItem('Lower Bound', 'KSh ${forecast.lowerBound.toStringAsFixed(0)}'),
                    _buildForecastItem('Upper Bound', 'KSh ${forecast.upperBound.toStringAsFixed(0)}'),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildMetricCard(String title, String value, IconData icon, Color color, String trend) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 8),
            Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(title, style: TextStyle(fontSize: 11, color: Colors.grey.shade600), textAlign: TextAlign.center),
            const SizedBox(height: 4),
            Text(trend, style: TextStyle(fontSize: 10, color: Colors.green.shade600)),
          ],
        ),
      ),
    );
  }

  Widget _buildInsightCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 4),
          Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color)),
          Text(title, style: TextStyle(fontSize: 10, color: Colors.grey.shade600), textAlign: TextAlign.center),
        ],
      ),
    );
  }

  Widget _buildProductStat(String label, String value) {
    return Expanded(
      child: Column(
        children: [
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          Text(label, style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
        ],
      ),
    );
  }

  Widget _buildForecastItem(String label, String value) {
    return Expanded(
      child: Column(
        children: [
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          Text(label, style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
        ],
      ),
    );
  }

  Color _getConfidenceColor(String confidence) {
    switch (confidence) {
      case 'High':
        return Colors.green;
      case 'Medium':
        return Colors.orange;
      default:
        return Colors.red;
    }
  }

  String _getDateLabel(DateTime date, String period) {
    if (period == 'Weekly') {
      const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
      return days[date.weekday - 1];
    } else if (period == 'Monthly') {
      const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
      return '${months[date.month - 1]} ${date.year}';
    } else {
      return '${date.year}';
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
