import 'package:dio/dio.dart';
import 'package:expense_tracker/config/api_config.dart';

class GeminiService {
  final Dio _dio = Dio(
    BaseOptions(
      connectTimeout: ApiConfig.requestTimeout,
      receiveTimeout: ApiConfig.requestTimeout,
    ),
  );

  Future<String> generateInsight(String prompt) async {
    try {
      final response = await _dio.post(
        '${ApiConfig.geminiBaseUrl}/models/${ApiConfig.geminiModel}:generateContent',
        data: {
          'contents': [
            {
              'parts': [
                {'text': prompt}
              ]
            }
          ],
          'generationConfig': {
            'temperature': 0.7,
            'maxOutputTokens': 1024,
          }
        },
        queryParameters: {
          'key': ApiConfig.geminiApiKey,
        },
      );

      if (response.data != null &&
          response.data['candidates'] != null && 
          response.data['candidates'].isNotEmpty &&
          response.data['candidates'][0] != null &&
          response.data['candidates'][0]['content'] != null &&
          response.data['candidates'][0]['content']['parts'] != null &&
          response.data['candidates'][0]['content']['parts'].isNotEmpty) {
        final text = response.data['candidates'][0]['content']['parts'][0]['text'];
        return text?.toString() ?? 'No response generated';
      }
      
      return 'No response generated';
    } on DioException catch (e) {
      if (e.response?.statusCode == 429) {
        throw Exception('API rate limit exceeded. Please try again later.');
      } else if (e.response?.statusCode == 401) {
        throw Exception('Invalid API key. Please check your configuration.');
      } else if (e.response?.statusCode == 400) {
        throw Exception('Invalid request. Please check your input data.');
      }
      throw Exception('Failed to generate insight: ${e.message}');
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  Future<Map<String, dynamic>> analyzeSpending(Map<String, dynamic> expenseData) async {
    try {
      // Safely handle categories
      final categories = expenseData['categories'] as Map<String, dynamic>?;
      final categoriesStr = categories?.entries
          .map((e) => '${e.key}: ₹${(e.value as num).toStringAsFixed(2)}')
          .join(', ') ?? 'No categories';

      final total = expenseData['total'] ?? 0;
      final period = expenseData['period'] ?? 'Unknown period';

      final prompt = '''
Analyze the following expense data and provide financial insights:

Total Spending: ₹$total
Categories: $categoriesStr
Period: $period

Please provide:
1. A brief analysis of the spending pattern (2-3 sentences)
2. Top 3 spending categories
3. 3 actionable money-saving recommendations
4. Suggested monthly budget based on this data
5. Financial health score (1-10) with brief explanation

Format your response clearly with sections.
''';

      final response = await generateInsight(prompt);
      return {
        'analysis': response,
        'timestamp': DateTime.now().toIso8601String(),
      };
    } catch (e) {
      return {
        'analysis': 'Unable to analyze spending data at this time.',
        'timestamp': DateTime.now().toIso8601String(),
        'error': e.toString(),
      };
    }
  }

  Future<String> predictNextMonthSpending(List<Map<String, dynamic>> historicalData) async {
    if (historicalData.isEmpty) {
      return 'Not enough data for prediction. Add more expenses to get insights.';
    }

    try {
      final dataStr = historicalData
          .map((d) => '${d['month']}: ₹${(d['amount'] as num).toStringAsFixed(2)}')
          .join(', ');

      final prompt = '''
Based on this historical expense data over the last few months:
$dataStr

Please:
1. Predict the likely spending for next month
2. Explain the reasoning behind the prediction
3. Highlight any concerning trends
4. Suggest if the user should adjust their budget

Keep the response concise and actionable (3-4 sentences).
''';

      return await generateInsight(prompt);
    } catch (e) {
      return 'Unable to generate prediction at this time. Please try again later.';
    }
  }

  Future<List<String>> generateBudgetTips(double income, double expenses) async {
    try {
      final savingsRate = income > 0 ? ((income - expenses) / income * 100) : 0;
      
      final prompt = '''
Monthly Income: ₹${income.toStringAsFixed(2)}
Monthly Expenses: ₹${expenses.toStringAsFixed(2)}
Savings Rate: ${savingsRate.toStringAsFixed(1)}%

Provide exactly 5 personalized, actionable budgeting tips to improve their financial health.
Make them specific and practical.
Format each tip as a separate line starting with a number (1., 2., etc.).
''';

      final response = await generateInsight(prompt);
      
      // Parse numbered list
      final lines = response.split('\n')
          .where((line) => line.trim().isNotEmpty)
          .where((line) => RegExp(r'^\d+\.').hasMatch(line.trim()))
          .map((line) => line.replaceFirst(RegExp(r'^\d+\.\s*'), '').trim())
          .toList();

      if (lines.isEmpty) {
        // Fallback tips
        return [
          'Track all your expenses to understand spending patterns',
          'Set specific budgets for each category',
          'Try to save at least 20% of your income',
          'Review and adjust your budget monthly',
          'Look for subscription services you can cancel',
        ];
      }

      return lines.take(5).toList();
    } catch (e) {
      // Return default tips on error
      return [
        'Track all your expenses regularly',
        'Create a monthly budget and stick to it',
        'Look for ways to reduce unnecessary spending',
        'Build an emergency fund covering 3-6 months of expenses',
        'Review and adjust your financial goals monthly',
      ];
    }
  }

  Future<String> generateCategoryInsight(String category, double amount, double percentage) async {
    try {
      // Ensure percentage is valid and properly formatted - respect the percentage value
      final validPercentage = percentage.isFinite && !percentage.isNaN ? percentage : 0.0;
      
      final prompt = '''
The user spent ₹${amount.toStringAsFixed(2)} on $category, which is ${validPercentage.toStringAsFixed(1)}% of their total expenses.

Provide a brief insight (2-3 sentences) about whether this spending level is typical and if they should adjust it.
''';

      return await generateInsight(prompt);
    } catch (e) {
      return 'Unable to generate insight for this category at this time.';
    }
  }

  Future<String> chatWithAI(String question, Map<String, dynamic> context) async {
    try {
      final totalSpending = context['totalSpending'] ?? 0;
      final categories = context['categories'] ?? 'N/A';
      final budgetStatus = context['budgetStatus'] ?? 'Not set';
      final savings = context['savings'] ?? 0;

      final prompt = '''
User Question: $question

Financial Context:
- Total Monthly Spending: ₹$totalSpending
- Top Categories: $categories
- Budget Status: $budgetStatus
- Savings: ₹$savings

Provide a helpful, accurate, and concise answer (3-4 sentences max) about their financial situation or the question asked.
Be encouraging but honest about their financial habits.
''';

      return await generateInsight(prompt);
    } catch (e) {
      return 'I apologize, but I encountered an error processing your question. Please try again or rephrase your question.';
    }
  }

  Future<String> generateSavingsGoalPlan(double targetAmount, int months) async {
    try {
      if (months <= 0) {
        return 'Please specify a valid time period (at least 1 month).';
      }

      final monthlyTarget = targetAmount / months;
      
      final prompt = '''
User wants to save ₹${targetAmount.toStringAsFixed(2)} in $months months.
That's ₹${monthlyTarget.toStringAsFixed(2)} per month.

Create a practical savings plan with:
1. Realistic monthly savings target
2. 3 specific strategies to reach the goal
3. Motivation tips

Keep it concise and encouraging (4-5 sentences).
''';

      return await generateInsight(prompt);
    } catch (e) {
      return 'Unable to generate savings plan at this time. Please try again later.';
    }
  }
}

// Helper class for structured responses
class AIInsightResponse {
  final String analysis;
  final List<String> recommendations;
  final String prediction;
  final double healthScore;

  AIInsightResponse({
    required this.analysis,
    required this.recommendations,
    required this.prediction,
    required this.healthScore,
  });

  factory AIInsightResponse.fromJson(Map<String, dynamic> json) {
    return AIInsightResponse(
      analysis: json['analysis'] as String? ?? '',
      recommendations: (json['recommendations'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList() ?? [],
      prediction: json['prediction'] as String? ?? '',
      healthScore: (json['healthScore'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'analysis': analysis,
      'recommendations': recommendations,
      'prediction': prediction,
      'healthScore': healthScore,
    };
  }
}