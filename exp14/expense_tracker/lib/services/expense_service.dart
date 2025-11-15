import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:expense_tracker/models/expense.dart';

class ExpenseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? get currentUserId => _auth.currentUser?.uid;

  // Add expense
  Future<void> addExpense(Expense expense) async {
    await _firestore.collection('expenses').add(expense.toFirestore());
  }

  // Get user expenses stream
  Stream<List<Expense>> getUserExpenses() {
    if (currentUserId == null) return Stream.value([]);
    
    return _firestore
        .collection('expenses')
        .where('userId', isEqualTo: currentUserId)
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Expense.fromFirestore(doc)).toList());
  }

  // Get expenses for date range
  Stream<List<Expense>> getExpensesByDateRange(DateTime start, DateTime end) {
    if (currentUserId == null) return Stream.value([]);

    return _firestore
        .collection('expenses')
        .where('userId', isEqualTo: currentUserId)
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
        .where('date', isLessThanOrEqualTo: Timestamp.fromDate(end))
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Expense.fromFirestore(doc)).toList());
  }

  // Update expense
  Future<void> updateExpense(String expenseId, Expense expense) async {
    await _firestore
        .collection('expenses')
        .doc(expenseId)
        .update(expense.toFirestore());
  }

  // Delete expense
  Future<void> deleteExpense(String expenseId) async {
    await _firestore.collection('expenses').doc(expenseId).delete();
  }

  // Get total expenses for period
  Future<double> getTotalExpenses(DateTime start, DateTime end) async {
    if (currentUserId == null) return 0.0;

    final snapshot = await _firestore
        .collection('expenses')
        .where('userId', isEqualTo: currentUserId)
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
        .where('date', isLessThanOrEqualTo: Timestamp.fromDate(end))
        .get();

    double total = 0;
    for (var doc in snapshot.docs) {
      final data = doc.data();
      total += (data['amount'] ?? 0).toDouble();
    }
    return total;
  }

  // Get category-wise expenses
  Future<Map<String, double>> getCategoryExpenses(
      DateTime start, DateTime end) async {
    if (currentUserId == null) return {};

    final snapshot = await _firestore
        .collection('expenses')
        .where('userId', isEqualTo: currentUserId)
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
        .where('date', isLessThanOrEqualTo: Timestamp.fromDate(end))
        .get();

    Map<String, double> categoryTotals = {};
    for (var doc in snapshot.docs) {
      final expense = Expense.fromFirestore(doc);
      categoryTotals[expense.category] =
          (categoryTotals[expense.category] ?? 0) + expense.amount;
    }
    return categoryTotals;
  }

  // Get daily expenses for the last 7 days
  Future<Map<DateTime, double>> getDailyExpenses() async {
    if (currentUserId == null) return {};

    final now = DateTime.now();
    final sevenDaysAgo = now.subtract(const Duration(days: 7));

    final snapshot = await _firestore
        .collection('expenses')
        .where('userId', isEqualTo: currentUserId)
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(sevenDaysAgo))
        .get();

    Map<DateTime, double> dailyTotals = {};
    for (var doc in snapshot.docs) {
      final expense = Expense.fromFirestore(doc);
      final dateKey = DateTime(expense.date.year, expense.date.month, expense.date.day);
      dailyTotals[dateKey] = (dailyTotals[dateKey] ?? 0) + expense.amount;
    }
    return dailyTotals;
  }
}