import 'package:cloud_firestore/cloud_firestore.dart';

class Expense {
  final String id;
  final String userId;
  final String title;
  final double amount;
  final String category;
  final String? description;
  final DateTime date;
  final DateTime createdAt;

  Expense({
    required this.id,
    required this.userId,
    required this.title,
    required this.amount,
    required this.category,
    this.description,
    required this.date,
    required this.createdAt,
  });

  factory Expense.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Expense(
      id: doc.id,
      userId: data['userId'] ?? '',
      title: data['title'] ?? '',
      amount: (data['amount'] ?? 0).toDouble(),
      category: data['category'] ?? '',
      description: data['description'],
      date: (data['date'] as Timestamp).toDate(),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'title': title,
      'amount': amount,
      'category': category,
      'description': description,
      'date': Timestamp.fromDate(date),
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}

class ExpenseCategory {
  static const String food = 'Food & Dining';
  static const String transportation = 'Transportation';
  static const String shopping = 'Shopping';
  static const String entertainment = 'Entertainment';
  static const String bills = 'Bills & Utilities';
  static const String health = 'Health & Fitness';
  static const String education = 'Education';
  static const String travel = 'Travel';
  static const String others = 'Others';

  static List<String> get all => [
        food,
        transportation,
        shopping,
        entertainment,
        bills,
        health,
        education,
        travel,
        others,
      ];

  static Map<String, dynamic> getCategoryDetails(String category) {
    switch (category) {
      case food:
        return {'icon': '🍔', 'color': 0xFFFF6B6B};
      case transportation:
        return {'icon': '🚗', 'color': 0xFF4ECDC4};
      case shopping:
        return {'icon': '🛍️', 'color': 0xFF95E1D3};
      case entertainment:
        return {'icon': '🎬', 'color': 0xFFF38181};
      case bills:
        return {'icon': '💡', 'color': 0xFFAA96DA};
      case health:
        return {'icon': '💊', 'color': 0xFFFCBAD3};
      case education:
        return {'icon': '📚', 'color': 0xFFA8E6CF};
      case travel:
        return {'icon': '✈️', 'color': 0xFFFFD3B6};
      case others:
        return {'icon': '📦', 'color': 0xFFFFAAA5};
      default:
        return {'icon': '📦', 'color': 0xFF999999};
    }
  }
}