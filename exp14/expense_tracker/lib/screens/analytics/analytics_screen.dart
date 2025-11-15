import 'package:flutter/material.dart';
import 'package:expense_tracker/services/expense_service.dart';
import 'package:expense_tracker/widgets/chart_widget.dart';

class AnalyticsScreen extends StatefulWidget {
  final bool isVip;

  const AnalyticsScreen({super.key, this.isVip = false});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  final ExpenseService _expenseService = ExpenseService();
  String _selectedPeriod = 'Month';
  final List<String> _periods = ['Week', 'Month', 'Year'];

  DateTime _getStartDate() {
    final now = DateTime.now();
    switch (_selectedPeriod) {
      case 'Week':
        return now.subtract(const Duration(days: 7));
      case 'Month':
        return DateTime(now.year, now.month, 1);
      case 'Year':
        return DateTime(now.year, 1, 1);
      default:
        return DateTime(now.year, now.month, 1);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isVip ? 'Advanced Analytics' : 'Analytics'),
        backgroundColor: widget.isVip ? Colors.amber.shade700 : Colors.blue.shade700,
        foregroundColor: Colors.white,
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.calendar_today),
            onSelected: (value) {
              setState(() {
                _selectedPeriod = value;
              });
            },
            itemBuilder: (context) => _periods
                .map((period) => PopupMenuItem(
                      value: period,
                      child: Text(period),
                    ))
                .toList(),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Period Selector
            Card(
              color: widget.isVip ? Colors.amber.shade50 : Colors.blue.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(
                      Icons.calendar_month,
                      color: widget.isVip ? Colors.amber.shade700 : Colors.blue.shade700,
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Viewing',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          _selectedPeriod,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: widget.isVip ? Colors.amber.shade900 : Colors.blue.shade900,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            // Total Spending Card
            FutureBuilder<double>(
              future: _expenseService.getTotalExpenses(
                _getStartDate(),
                DateTime.now(),
              ),
              builder: (context, snapshot) {
                final total = snapshot.data ?? 0;
                return Card(
                  elevation: 4,
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: widget.isVip
                            ? [Colors.amber.shade400, Colors.amber.shade700]
                            : [Colors.blue.shade400, Colors.blue.shade700],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        const Text(
                          'Total Spending',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '₹${total.toStringAsFixed(2)}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'This $_selectedPeriod',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 24),
            // Category Breakdown
            const Text(
              'Spending by Category',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: FutureBuilder<Map<String, double>>(
                  future: _expenseService.getCategoryExpenses(
                    _getStartDate(),
                    DateTime.now(),
                  ),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.all(32),
                          child: CircularProgressIndicator(),
                        ),
                      );
                    }

                    final categoryData = snapshot.data ?? {};
                    if (categoryData.isEmpty) {
                      return const Padding(
                        padding: EdgeInsets.all(32),
                        child: Center(
                          child: Text('No data available'),
                        ),
                      );
                    }

                    return CategoryPieChart(categoryData: categoryData);
                  },
                ),
              ),
            ),
            const SizedBox(height: 24),
            // Daily Trend
            const Text(
              'Daily Spending Trend',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: FutureBuilder<Map<DateTime, double>>(
                  future: _expenseService.getDailyExpenses(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.all(32),
                          child: CircularProgressIndicator(),
                        ),
                      );
                    }

                    final dailyData = snapshot.data ?? {};
                    if (dailyData.isEmpty) {
                      return const Padding(
                        padding: EdgeInsets.all(32),
                        child: Center(
                          child: Text('No data available'),
                        ),
                      );
                    }

                    return DailyExpenseBarChart(dailyData: dailyData);
                  },
                ),
              ),
            ),
            // VIP Features
            if (widget.isVip) ...[
              const SizedBox(height: 24),
              const Text(
                'Predictions & Insights',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              FutureBuilder<double>(
                future: _expenseService.getTotalExpenses(
                  DateTime.now().subtract(const Duration(days: 30)),
                  DateTime.now(),
                ),
                builder: (context, snapshot) {
                  final lastMonthTotal = snapshot.data ?? 0;
                  final predictedNextMonth = lastMonthTotal * 1.05; // Simple 5% increase prediction

                  return Card(
                    color: Colors.amber.shade50,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.auto_graph, color: Colors.amber.shade700),
                              const SizedBox(width: 8),
                              const Text(
                                'AI Prediction',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Based on your spending pattern, you are likely to spend',
                            style: TextStyle(color: Colors.grey.shade700),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '₹${predictedNextMonth.toStringAsFixed(2)}',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.amber.shade900,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'next month',
                            style: TextStyle(color: Colors.grey.shade600),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 12),
              Card(
                color: Colors.green.shade50,
                child: ListTile(
                  leading: Icon(Icons.trending_down, color: Colors.green.shade700),
                  title: const Text('Spending Tip'),
                  subtitle: const Text(
                    'Try to reduce dining expenses by 10% to save ₹500 this month',
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}