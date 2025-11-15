import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:expense_tracker/screens/expenses/expense_list.dart';
import 'package:expense_tracker/screens/expenses/add_expense.dart';
import 'package:expense_tracker/screens/analytics/analytics_screen.dart';
import 'package:expense_tracker/widgets/vip_upgrade_dialog.dart';
import 'package:expense_tracker/services/expense_service.dart';
import 'package:expense_tracker/models/expense.dart';
import 'package:intl/intl.dart';

class UserHome extends StatefulWidget {
  const UserHome({super.key});

  @override
  State<UserHome> createState() => _UserHomeState();
}

class _UserHomeState extends State<UserHome> {
  int _selectedIndex = 0;
  bool _hasShownVipDialog = false;

  @override
  Widget build(BuildContext context) {
    final List<Widget> screens = [
      UserDashboard(onShowVipDialog: () {
        if (!_hasShownVipDialog) {
          _hasShownVipDialog = true;
          showVipUpgradeDialog(context);
        }
      }),
      const ExpenseListScreen(),
      const AnalyticsScreen(isVip: false),
      const UserFeatures(), // NEW FEATURES TAB
      const UserProfile(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Expense Tracker'),
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 8),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.green.shade600,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Row(
              children: [
                Icon(Icons.verified_user, size: 16),
                SizedBox(width: 4),
                Text(
                  'USER',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        selectedItemColor: Colors.blue.shade700,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt_long),
            label: 'Expenses',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart),
            label: 'Analytics',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.star),
            label: 'Features',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
      floatingActionButton: _selectedIndex == 1
          ? FloatingActionButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AddExpenseScreen(),
                  ),
                );
              },
              backgroundColor: Colors.blue.shade700,
              child: const Icon(Icons.add),
            )
          : null,
    );
  }
}

class UserDashboard extends StatelessWidget {
  final VoidCallback onShowVipDialog;

  const UserDashboard({super.key, required this.onShowVipDialog});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final expenseService = ExpenseService();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Welcome back!',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.blue.shade900,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            user?.email ?? 'User',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 24),
          // Stats Cards
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
                                  color: Colors.blue,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildStatCard(
                                  icon: Icons.trending_up,
                                  title: 'Today',
                                  amount: '₹${(todaySnapshot.data ?? 0).toStringAsFixed(2)}',
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
                                  icon: Icons.calendar_today,
                                  title: 'This Week',
                                  amount: '₹${(weekSnapshot.data ?? 0).toStringAsFixed(2)}',
                                  color: Colors.orange,
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
          // Recent Expenses
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Recent Expenses',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton(
                onPressed: () {},
                child: const Text('View All'),
              ),
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

              // Show VIP dialog after 5 expenses
              if (expenses.length >= 5) {
                Future.delayed(Duration.zero, onShowVipDialog);
              }

              if (expenses.isEmpty) {
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Center(
                      child: Column(
                        children: [
                          Icon(Icons.receipt_long_outlined, size: 48, color: Colors.grey.shade400),
                          const SizedBox(height: 12),
                          Text('No expenses yet', style: TextStyle(color: Colors.grey.shade600)),
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
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                    ),
                  );
                }).toList(),
              );
            },
          ),
          const SizedBox(height: 24),
          // VIP Upgrade Card
          InkWell(
            onTap: () {
              showVipUpgradeDialog(context);
            },
            child: Card(
              elevation: 4,
              color: Colors.amber.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(Icons.workspace_premium, size: 40, color: Colors.amber.shade700),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Upgrade to VIP',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.amber.shade900,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Get AI insights, budget planning & more!',
                            style: TextStyle(fontSize: 12, color: Colors.amber.shade800),
                          ),
                        ],
                      ),
                    ),
                    Icon(Icons.arrow_forward_ios, color: Colors.amber.shade700),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String title,
    required String amount,
    required Color color,
  }) {
    return Card(
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 28),
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

// NEW FEATURES TAB
class UserFeatures extends StatelessWidget {
  const UserFeatures({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Your Features',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'See what you can do with your account',
            style: TextStyle(color: Colors.grey.shade600),
          ),
          const SizedBox(height: 24),
          _buildFeatureCard(
            icon: Icons.add_circle,
            title: 'Add Expenses',
            description: 'Track unlimited expenses',
            available: true,
          ),
          _buildFeatureCard(
            icon: Icons.cloud_done,
            title: 'Cloud Sync',
            description: 'Data saved securely',
            available: true,
          ),
          _buildFeatureCard(
            icon: Icons.history,
            title: 'Expense History',
            description: 'View all past expenses',
            available: true,
          ),
          _buildFeatureCard(
            icon: Icons.bar_chart,
            title: 'Basic Analytics',
            description: 'Monthly and weekly reports',
            available: true,
          ),
          _buildFeatureCard(
            icon: Icons.category,
            title: 'Categories',
            description: 'Organize by categories',
            available: true,
          ),
          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 16),
          Text(
            'VIP Features',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.amber.shade900,
            ),
          ),
          const SizedBox(height: 16),
          _buildFeatureCard(
            icon: Icons.auto_awesome,
            title: 'AI Insights',
            description: 'AI-powered spending analysis',
            available: false,
            lockMessage: 'VIP Only',
          ),
          _buildFeatureCard(
            icon: Icons.insights,
            title: 'Advanced Analytics',
            description: 'Predictions & trends',
            available: false,
            lockMessage: 'VIP Only',
          ),
          _buildFeatureCard(
            icon: Icons.account_balance_wallet,
            title: 'Budget Planning',
            description: 'Smart budgeting tools',
            available: false,
            lockMessage: 'VIP Only',
          ),
          _buildFeatureCard(
            icon: Icons.file_download,
            title: 'Export Reports',
            description: 'PDF & Excel reports',
            available: false,
            lockMessage: 'VIP Only',
          ),
          _buildFeatureCard(
            icon: Icons.support_agent,
            title: 'Priority Support',
            description: '24/7 customer support',
            available: false,
            lockMessage: 'VIP Only',
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              showVipUpgradeDialog(context);
            },
            icon: const Icon(Icons.upgrade),
            label: const Text('Upgrade to VIP'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.amber.shade700,
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureCard({
    required IconData icon,
    required String title,
    required String description,
    required bool available,
    String? lockMessage,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Icon(
          icon,
          color: available ? Colors.green : Colors.grey,
          size: 32,
        ),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: available ? Colors.black : Colors.grey,
          ),
        ),
        subtitle: Text(
          description,
          style: TextStyle(
            color: available ? Colors.black87 : Colors.grey,
          ),
        ),
        trailing: available
            ? const Icon(Icons.check_circle, color: Colors.green)
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.lock, color: Colors.grey),
                  if (lockMessage != null)
                    Text(
                      lockMessage,
                      style: const TextStyle(fontSize: 10, color: Colors.grey),
                    ),
                ],
              ),
      ),
    );
  }
}

class UserProfile extends StatelessWidget {
  const UserProfile({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const SizedBox(height: 20),
          CircleAvatar(
            radius: 50,
            backgroundColor: Colors.blue.shade100,
            child: Text(
              user?.email?.substring(0, 1).toUpperCase() ?? 'U',
              style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: Colors.blue.shade700),
            ),
          ),
          const SizedBox(height: 16),
          Text(user?.email ?? 'User', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.green.shade100,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'REGISTERED USER',
              style: TextStyle(color: Colors.green.shade900, fontWeight: FontWeight.bold, fontSize: 12),
            ),
          ),
          const SizedBox(height: 32),
          Card(
            elevation: 4,
            color: Colors.amber.shade50,
            child: InkWell(
              onTap: () {
                showVipUpgradeDialog(context);
              },
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Icon(Icons.workspace_premium, size: 48, color: Colors.amber.shade700),
                    const SizedBox(height: 16),
                    Text(
                      'Upgrade to VIP',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.amber.shade900),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      '• AI-Powered Insights\n• Advanced Analytics\n• Budget Planning\n• Export Reports\n• Priority Support',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 14),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          showVipUpgradeDialog(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.amber.shade700,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text(
                          'Upgrade Now - ₹299/month',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Settings'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.help_outline),
            title: const Text('Help & Support'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.privacy_tip_outlined),
            title: const Text('Privacy Policy'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {},
          ),
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