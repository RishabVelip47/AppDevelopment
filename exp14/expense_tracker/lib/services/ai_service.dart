import 'package:expense_tracker/services/gemini_service.dart';
import 'package:expense_tracker/services/expense_service.dart';

class AIService {
  final GeminiService _geminiService = GeminiService();
  final ExpenseService _expenseService = ExpenseService();

  Future<Map<String, dynamic>> getMonthlyInsights() async {
    try {
      // Get current month expenses
      final now = DateTime.now();
      final startOfMonth = DateTime(now.year, now.month, 1);
      final total = await _expenseService.getTotalExpenses(startOfMonth, now);
      final categories = await _expenseService.getCategoryExpenses(startOfMonth, now);

      if (total == 0) {
        return {
          'analysis': 'No expenses recorded this month yet. Start tracking your expenses to get AI-powered insights!',
          'hasData': false,
        };
      }

      final expenseData = {
        'total': total,
        'categories': categories,
        'period': 'This Month',
      };

      final result = await _geminiService.analyzeSpending(expenseData);
      return {
        ...result,
        'hasData': true,
        'total': total,
        'categoryCount': categories.length,
      };
    } catch (e) {
      return {
        'analysis': 'Unable to generate insights at this time. Error: ${e.toString()}',
        'hasData': false,
        'error': true,
      };
    }
  }

  Future<String> getSpendingPrediction() async {
    try {
      // Get last 3 months data
      final now = DateTime.now();
      final historicalData = <Map<String, dynamic>>[];

      for (int i = 0; i < 3; i++) {
        // Calculate month and year properly to handle year boundaries
        int targetMonth = now.month - i;
        int targetYear = now.year;
        
        // Handle year rollover
        while (targetMonth <= 0) {
          targetMonth += 12;
          targetYear -= 1;
        }
        
        final monthStart = DateTime(targetYear, targetMonth, 1);
        // Get last day of the month properly
        final monthEnd = DateTime(targetYear, targetMonth + 1, 1).subtract(const Duration(seconds: 1));
        
        final amount = await _expenseService.getTotalExpenses(monthStart, monthEnd);
        
        if (amount > 0) {
          historicalData.add({
            'month': '${monthStart.year}-${monthStart.month.toString().padLeft(2, '0')}',
            'amount': amount,
          });
        }
      }

      if (historicalData.isEmpty) {
        return 'Not enough historical data for predictions. Track expenses for at least 2 months to get spending predictions.';
      }

      if (historicalData.length < 2) {
        return 'Need at least 2 months of expense data for accurate predictions. Keep tracking!';
      }

      return await _geminiService.predictNextMonthSpending(historicalData);
    } catch (e) {
      return 'Unable to generate prediction: ${e.toString()}';
    }
  }

  Future<List<String>> getPersonalizedTips({double? income}) async {
    try {
      final now = DateTime.now();
      final startOfMonth = DateTime(now.year, now.month, 1);
      final expenses = await _expenseService.getTotalExpenses(startOfMonth, now);

      // Use provided income or default to 50000
      final userIncome = income ?? 50000.0;

      if (expenses == 0) {
        return [
          'Start tracking your daily expenses to understand spending patterns',
          'Set monthly budgets for different categories like food, transport, entertainment',
          'Aim to save at least 20% of your income each month',
          'Review your expenses weekly to stay on track',
          'Use the analytics feature to identify areas where you can cut costs',
        ];
      }

      return await _geminiService.generateBudgetTips(userIncome, expenses);
    } catch (e) {
      return [
        'Track all your expenses regularly',
        'Create a monthly budget and stick to it',
        'Look for ways to reduce unnecessary spending',
        'Build an emergency fund covering 3-6 months of expenses',
        'Review and adjust your financial goals monthly',
      ];
    }
  }

  Future<Map<String, dynamic>> getCategoryInsight(String category) async {
    try {
      final now = DateTime.now();
      final startOfMonth = DateTime(now.year, now.month, 1);
      final total = await _expenseService.getTotalExpenses(startOfMonth, now);
      final categories = await _expenseService.getCategoryExpenses(startOfMonth, now);

      final categoryAmount = categories[category] ?? 0;
      
      // Safely calculate percentage with validation to respect percentage errors
      double percentage = 0.0;
      if (total > 0 && categoryAmount >= 0) {
        final calculatedPercentage = (categoryAmount / total * 100);
        // Ensure percentage is a valid finite number (not NaN or Infinity)
        if (calculatedPercentage.isFinite && !calculatedPercentage.isNaN) {
          percentage = calculatedPercentage;
        }
      }

      if (categoryAmount == 0) {
        return {
          'insight': 'No expenses in this category yet this month.',
          'amount': 0.0,
          'percentage': 0.0,
        };
      }

      final insight = await _geminiService.generateCategoryInsight(
        category,
        categoryAmount,
        percentage,
      );

      return {
        'insight': insight,
        'amount': categoryAmount,
        'percentage': percentage,
      };
    } catch (e) {
      return {
        'insight': 'Unable to generate insight for this category.',
        'amount': 0.0,
        'percentage': 0.0,
        'error': true,
      };
    }
  }

  Future<String> chatWithAI(String question) async {
    try {
      final now = DateTime.now();
      final startOfMonth = DateTime(now.year, now.month, 1);
      final total = await _expenseService.getTotalExpenses(startOfMonth, now);
      final categories = await _expenseService.getCategoryExpenses(startOfMonth, now);

      final topCategories = categories.entries
          .toList()
          ..sort((a, b) => b.value.compareTo(a.value));

      final topCategoryNames = topCategories
          .take(3)
          .map((e) => '${e.key} (₹${e.value.toStringAsFixed(0)})')
          .join(', ');

      final context = {
        'totalSpending': total,
        'categories': topCategoryNames.isEmpty ? 'None' : topCategoryNames,
        'budgetStatus': 'Active',
        'savings': 0, // Can be calculated if income is tracked
      };

      return await _geminiService.chatWithAI(question, context);
    } catch (e) {
      return 'I apologize, but I encountered an error processing your question. Please try again or rephrase your question.';
    }
  }

  Future<Map<String, dynamic>> getFinancialHealthScore() async {
    try {
      final now = DateTime.now();
      final startOfMonth = DateTime(now.year, now.month, 1);
      final total = await _expenseService.getTotalExpenses(startOfMonth, now);
      final categories = await _expenseService.getCategoryExpenses(startOfMonth, now);

      if (total == 0) {
        return {
          'score': 0,
          'label': 'No Data',
          'description': 'Start tracking expenses to get your financial health score',
        };
      }

      // Simple scoring algorithm (can be enhanced)
      int score = 70; // Base score

      // Deduct points for high spending in certain categories
      final foodSpending = categories['Food & Dining'] ?? 0;
      final entertainmentSpending = categories['Entertainment'] ?? 0;

      if (foodSpending > total * 0.4) score -= 10;
      if (entertainmentSpending > total * 0.2) score -= 10;

      // Add points for diverse spending (indicates good budgeting)
      if (categories.length >= 4) score += 10;

      score = score.clamp(0, 100);

      String label;
      String description;

      if (score >= 80) {
        label = 'Excellent';
        description = 'Your spending habits are well-balanced!';
      } else if (score >= 60) {
        label = 'Good';
        description = 'You\'re doing well, with some room for improvement.';
      } else if (score >= 40) {
        label = 'Fair';
        description = 'Consider reviewing your budget and cutting unnecessary expenses.';
      } else {
        label = 'Needs Attention';
        description = 'Focus on creating a budget and tracking all expenses.';
      }

      return {
        'score': score,
        'label': label,
        'description': description,
      };
    } catch (e) {
      return {
        'score': 0,
        'label': 'Error',
        'description': 'Unable to calculate health score',
      };
    }
  }

  Future<String> generateSavingsPlan(double targetAmount, int months) async {
    try {
      return await _geminiService.generateSavingsGoalPlan(targetAmount, months);
    } catch (e) {
      return 'Unable to generate savings plan: ${e.toString()}';
    }
  }
}

// Singleton pattern for global access
class AI {
  static final AIService instance = AIService();
}