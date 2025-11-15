import 'package:cloud_firestore/cloud_firestore.dart';

class Budget {
  final String id;
  final String userId;
  final String category;
  final double amount;
  final String month; // Format: YYYY-MM
  final DateTime createdAt;

  Budget({
    required this.id,
    required this.userId,
    required this.category,
    required this.amount,
    required this.month,
    required this.createdAt,
  });

  factory Budget.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Budget(
      id: doc.id,
      userId: data['userId'] ?? '',
      category: data['category'] ?? '',
      amount: (data['amount'] ?? 0).toDouble(),
      month: data['month'] ?? '',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'category': category,
      'amount': amount,
      'month': month,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}