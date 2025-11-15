import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:expense_tracker/screens/expenses/expense_list.dart';
import 'package:expense_tracker/screens/expenses/add_expense.dart';
import 'package:expense_tracker/screens/analytics/analytics_screen.dart';
import 'package:expense_tracker/screens/budget/budget_screen.dart';
import 'package:expense_tracker/screens/ai/ai_insights_screen.dart';
import 'package:expense_tracker/services/expense_service.dart';
import 'package:expense_tracker/models/expense.dart';
import 'package:intl/intl.dart';

// Currency imports
import 'package:expense_tracker/screens/currency_screen.dart';
import 'package:expense_tracker/screens/currency_comparison_screen.dart';

class VipHome extends StatefulWidget {
  const VipHome({super.key});

  @override
  State<VipHome> createState() => _VipHomeState();
}

class _VipHomeState extends State<VipHome> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final List<Widget> screens = [
      const VipDashboard(),
      const ExpenseListScreen(),
      const AnalyticsScreen(isVip: true),
      const BudgetScreen(),
      const AIInsightsScreen(),
      const VipProfile(), // ✔ Profile kept EXACTLY as it is
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Expense Tracker Pro'),
        backgroundColor: Colors.amber.shade700,
        foregroundColor: Colors.white,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 8),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [Colors.amber.shade300, Colors.amber.shade600]),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.amber.shade700.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Row(
              children: [
                Icon(Icons.workspace_premium, size: 16, color: Colors.white),
                SizedBox(width: 4),
                Text('VIP', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white)),
              ],
            ),
          ),
        ],
      ),

      // ----------------------------------
      //        VIP DRAWER (OPTION A)
      // ----------------------------------
      drawer: const VipDrawer(),

      body: screens[_selectedIndex],

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        selectedItemColor: Colors.amber.shade700,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Dashboard'),
          BottomNavigationBarItem(icon: Icon(Icons.receipt_long), label: 'Expenses'),
          BottomNavigationBarItem(icon: Icon(Icons.insights), label: 'Analytics'),
          BottomNavigationBarItem(icon: Icon(Icons.account_balance_wallet), label: 'Budget'),
          BottomNavigationBarItem(icon: Icon(Icons.auto_awesome), label: 'AI'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),

      floatingActionButton: _selectedIndex == 1
          ? FloatingActionButton.extended(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const AddExpenseScreen()));
              },
              backgroundColor: Colors.amber.shade700,
              icon: const Icon(Icons.add),
              label: const Text('Add Expense'),
            )
          : null,
    );
  }
}

class VipDashboard extends StatelessWidget {
  const VipDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final expenseService = ExpenseService();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // VIP Header
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.amber.shade400, Colors.amber.shade700],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(color: Colors.amber.shade700.withOpacity(0.3), blurRadius: 12, offset: const Offset(0, 4)),
              ],
            ),
            child: Row(
              children: [
                const Icon(Icons.workspace_premium, size: 50, color: Colors.white),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('VIP Member', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
                      const SizedBox(height: 4),
                      Text(user?.email ?? 'VIP User', style: const TextStyle(fontSize: 14, color: Colors.white70)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // ▶ Stats Section (unchanged)
          FutureBuilder<double>(
            future: expenseService.getTotalExpenses(
              DateTime(DateTime.now().year, DateTime.now().month, 1),
              DateTime.now(),
            ),
            builder: (context, monthSnapshot) {
              return FutureBuilder<double>(
                future: expenseService.getTotalExpenses(
                  DateTime.now().subtract(const Duration(days: 7)),
                  DateTime.now(),
                ),
                builder: (context, weekSnapshot) {
                  return FutureBuilder<double>(
                    future: expenseService.getTotalExpenses(
                      DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day),
                      DateTime.now(),
                    ),
                    builder: (context, todaySnapshot) {
                      return Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: _buildStatCard(
                                  icon: Icons.account_balance_wallet,
                                  title: 'This Month',
                                  amount: '₹${(monthSnapshot.data ?? 0).toStringAsFixed(2)}',
                                  change: '+0%',
                                  isPositive: true,
                                  color: Colors.amber,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildStatCard(
                                  icon: Icons.trending_up,
                                  title: 'Today',
                                  amount: '₹${(todaySnapshot.data ?? 0).toStringAsFixed(2)}',
                                  change: '0%',
                                  isPositive: true,
                                  color: Colors.green,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 12),

                          Row(
                            children: [
                              Expanded(
                                child: _buildStatCard(
                                  icon: Icons.savings,
                                  title: 'This Week',
                                  amount: '₹${(weekSnapshot.data ?? 0).toStringAsFixed(2)}',
                                  change: '100%',
                                  isPositive: true,
                                  color: Colors.blue,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: StreamBuilder<List<Expense>>(
                                  stream: expenseService.getUserExpenses(),
                                  builder: (context, expensesSnapshot) {
                                    return _buildStatCard(
                                      icon: Icons.receipt,
                                      title: 'Transactions',
                                      amount: '${expensesSnapshot.data?.length ?? 0}',
                                      change: '+0',
                                      isPositive: true,
                                      color: Colors.purple,
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        ],
                      );
                    },
                  );
                },
              );
            },
          ),

          const SizedBox(height: 24),

          // AI Quick Insight Card
          Card(
            color: Colors.amber.shade50,
            child: ListTile(
              leading: Icon(Icons.auto_awesome, color: Colors.amber.shade700, size: 32),
              title: const Text('AI Insights Available', style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: const Text('Tap to view personalized financial insights'),
              trailing: Icon(Icons.arrow_forward_ios, color: Colors.amber.shade700),
              onTap: () {
                final homeState = context.findAncestorStateOfType<_VipHomeState>();
                homeState?.setState(() {
                  homeState._selectedIndex = 4;
                });
              },
            ),
          ),

          const SizedBox(height: 24),

          // Recent Expenses header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Recent Expenses', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              TextButton(onPressed: () {}, child: const Text('View All')),
            ],
          ),

          const SizedBox(height: 12),

          StreamBuilder<List<Expense>>(
            stream: expenseService.getUserExpenses(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              final expenses = snapshot.data ?? [];

              if (expenses.isEmpty) {
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Center(
                      child: Column(
                        children: [
                          Icon(Icons.receipt_long_outlined, size: 48, color: Colors.amber.shade300),
                          const SizedBox(height: 12),
                          const Text('No expenses yet'),
                        ],
                      ),
                    ),
                  ),
                );
              }

              return Column(
                children: expenses.take(5).map((expense) {
                  final categoryDetails = ExpenseCategory.getCategoryDetails(expense.category);
                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: Text(categoryDetails['icon'], style: const TextStyle(fontSize: 24)),
                      title: Text(expense.title),
                      subtitle: Text(DateFormat('MMM dd, yyyy').format(expense.date)),
                      trailing: Text(
                        '₹${expense.amount.toStringAsFixed(2)}',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.amber.shade900),
                      ),
                    ),
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String title,
    required String amount,
    required String change,
    required bool isPositive,
    required Color color,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(icon, color: color, size: 28),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: isPositive ? Colors.green.shade50 : Colors.red.shade50,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    change,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: isPositive ? Colors.green : Colors.red,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(title, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
            const SizedBox(height: 4),
            Text(amount, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color)),
          ],
        ),
      ),
    );
  }
}

// -------------------------------------------------------------
//            VIP DRAWER (OPTION A — VIP HEADER)
// -------------------------------------------------------------

class VipDrawer extends StatelessWidget {
  const VipDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [

          // ⭐ VIP Themed Header (Option A)
          DrawerHeader(
            decoration: BoxDecoration(color: Colors.amber.shade700),
            child: const Text(
              "VIP Menu",
              style: TextStyle(color: Colors.white, fontSize: 24),
            ),
          ),

          // Currency items
          ListTile(
            leading: const Icon(Icons.currency_exchange),
            title: const Text('Currency Exchange'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const CurrencyScreen()),
              );
            },
          ),

          ListTile(
            leading: const Icon(Icons.compare_arrows),
            title: const Text('Compare Currencies'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const CurrencyComparisonScreen()),
              );
            },
          ),
        ],
      ),
    );
  }
}

// -------------------------------------------------------------
//               ORIGINAL VIP PROFILE (UNCHANGED)
// -------------------------------------------------------------

class VipProfile extends StatelessWidget {
  const VipProfile({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const SizedBox(height: 20),
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(colors: [Colors.amber.shade300, Colors.amber.shade700]),
              boxShadow: [
                BoxShadow(
                    color: Colors.amber.shade700.withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4))
              ],
            ),
            child: CircleAvatar(
              radius: 50,
              backgroundColor: Colors.transparent,
              child: Text(
                user?.email?.substring(0, 1).toUpperCase() ?? 'V',
                style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(user?.email ?? 'VIP User', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [Colors.amber.shade300, Colors.amber.shade600]),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(color: Colors.amber.shade700.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 2))
              ],
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.workspace_premium, color: Colors.white, size: 16),
                SizedBox(width: 6),
                Text('VIP MEMBER', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
              ],
            ),
          ),

          const SizedBox(height: 32),

          Card(
            elevation: 4,
            color: Colors.amber.shade50,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Icon(Icons.verified, size: 48, color: Colors.amber.shade700),
                  const SizedBox(height: 16),
                  Text('VIP Membership Active',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.amber.shade900)),
                  const SizedBox(height: 8),
                  const Text('Enjoying all premium features', textAlign: TextAlign.center, style: TextStyle(fontSize: 14)),
                  const SizedBox(height: 16),
                  Text(
                    'Next billing: ${DateFormat('MMMM dd, yyyy').format(DateTime.now().add(const Duration(days: 30)))}',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          ListTile(
              leading: Icon(Icons.person, color: Colors.amber.shade700),
              title: const Text('Account Settings'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {}),

          ListTile(
              leading: Icon(Icons.notifications, color: Colors.amber.shade700),
              title: const Text('Notification Preferences'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {}),

          ListTile(
              leading: Icon(Icons.download, color: Colors.amber.shade700),
              title: const Text('Export Data'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {}),

          ListTile(
              leading: Icon(Icons.credit_card, color: Colors.amber.shade700),
              title: const Text('Manage Subscription'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {}),

          const ListTile(
              leading: Icon(Icons.help_outline),
              title: Text('VIP Support'),
              subtitle: Text('24/7 Priority Support'),
              trailing: Icon(Icons.arrow_forward_ios, size: 16)),

          const ListTile(
              leading: Icon(Icons.privacy_tip_outlined),
              title: Text('Privacy Policy'),
              trailing: Icon(Icons.arrow_forward_ios, size: 16)),

          const Divider(height: 32),

          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('Logout', style: TextStyle(color: Colors.red)),
            onTap: () async {
              await FirebaseAuth.instance.signOut();
              if (context.mounted) {
                Navigator.of(context).pushReplacementNamed('/login');
              }
            },
          ),
        ],
      ),
    );
  }
}
