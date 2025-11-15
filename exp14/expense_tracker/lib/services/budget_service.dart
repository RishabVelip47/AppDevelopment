import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:expense_tracker/models/budget.dart';

class BudgetService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? get currentUserId => _auth.currentUser?.uid;

  // Add or update budget
  Future<void> setBudget(Budget budget) async {
    if (currentUserId == null) return;

    // Check if budget exists for category and month
    final existing = await _firestore
        .collection('budgets')
        .where('userId', isEqualTo: currentUserId)
        .where('category', isEqualTo: budget.category)
        .where('month', isEqualTo: budget.month)
        .get();

    if (existing.docs.isNotEmpty) {
      // Update existing
      await _firestore
          .collection('budgets')
          .doc(existing.docs.first.id)
          .update(budget.toFirestore());
    } else {
      // Add new
      await _firestore.collection('budgets').add(budget.toFirestore());
    }
  }

  // Get budgets for current month
  Stream<List<Budget>> getCurrentMonthBudgets() {
    if (currentUserId == null) return Stream.value([]);

    final now = DateTime.now();
    final currentMonth = '${now.year}-${now.month.toString().padLeft(2, '0')}';

    return _firestore
        .collection('budgets')
        .where('userId', isEqualTo: currentUserId)
        .where('month', isEqualTo: currentMonth)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Budget.fromFirestore(doc)).toList());
  }

  // Get budget for specific category and month
  Future<Budget?> getBudget(String category, String month) async {
    if (currentUserId == null) return null;

    final snapshot = await _firestore
        .collection('budgets')
        .where('userId', isEqualTo: currentUserId)
        .where('category', isEqualTo: category)
        .where('month', isEqualTo: month)
        .get();

    if (snapshot.docs.isEmpty) return null;
    return Budget.fromFirestore(snapshot.docs.first);
  }

  // Delete budget
  Future<void> deleteBudget(String budgetId) async {
    await _firestore.collection('budgets').doc(budgetId).delete();
  }
}