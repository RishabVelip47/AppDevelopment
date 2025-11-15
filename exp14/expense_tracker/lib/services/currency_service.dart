import 'package:dio/dio.dart';
import 'package:expense_tracker/models/currency.dart';

class CurrencyService {
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: 'https://api.frankfurter.app',
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
    ),
  );

  // Cache for exchange rates (valid for 1 hour)
  final Map<String, ExchangeRate> _rateCache = {};
  final Map<String, DateTime> _cacheTimestamps = {};
  final Duration _cacheDuration = const Duration(hours: 1);

  Future<ExchangeRate> getExchangeRate(String from, String to) async {
    try {
      // Check cache first
      final cacheKey = '$from-$to';
      if (_rateCache.containsKey(cacheKey) && _cacheTimestamps.containsKey(cacheKey)) {
        final cacheTime = _cacheTimestamps[cacheKey]!;
        if (DateTime.now().difference(cacheTime) < _cacheDuration) {
          print('✅ Using cached rate for $from → $to');
          return _rateCache[cacheKey]!;
        }
      }

      print('🌐 Fetching exchange rate: $from → $to');

      final response = await _dio.get(
        '/latest',
        queryParameters: {
          'from': from,
          'to': to,
        },
      );

      if (response.data == null) {
        throw Exception('No data received from currency API');
      }

      final exchangeRate = ExchangeRate.fromJson(response.data, from, to);
      
      // Update cache
      _rateCache[cacheKey] = exchangeRate;
      _cacheTimestamps[cacheKey] = DateTime.now();

      print('✅ Rate fetched: 1 $from = ${exchangeRate.rate} $to');
      return exchangeRate;
      
    } on DioException catch (e) {
      print('❌ Currency API Error: ${e.type}');
      
      if (e.response?.statusCode == 404) {
        throw Exception('Currency not supported. Please select a different currency.');
      } else if (e.type == DioExceptionType.connectionTimeout ||
                 e.type == DioExceptionType.receiveTimeout) {
        throw Exception('Request timeout. Please check your internet connection.');
      } else if (e.type == DioExceptionType.connectionError) {
        throw Exception('Connection error. Please check your internet connection.');
      }
      
      throw Exception('Failed to fetch exchange rate: ${e.message}');
    } catch (e) {
      print('❌ Unexpected error: $e');
      throw Exception('An unexpected error occurred: $e');
    }
  }

  Future<double> convert(String from, String to, double amount) async {
    try {
      final rate = await getExchangeRate(from, to);
      return amount * rate.rate;
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, double>> getMultipleRates(String baseCurrency, List<String> targetCurrencies) async {
    try {
      print('🌐 Fetching multiple rates from $baseCurrency');

      final response = await _dio.get(
        '/latest',
        queryParameters: {
          'from': baseCurrency,
          'to': targetCurrencies.join(','),
        },
      );

      if (response.data == null || response.data['rates'] == null) {
        throw Exception('No data received from currency API');
      }

      final rates = <String, double>{};
      final ratesData = response.data['rates'] as Map<String, dynamic>;
      
      ratesData.forEach((key, value) {
        rates[key] = (value as num).toDouble();
      });

      print('✅ Fetched ${rates.length} exchange rates');
      return rates;
      
    } on DioException catch (e) {
      print('❌ Currency API Error: ${e.type}');
      
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw Exception('Request timeout. Please check your internet connection.');
      } else if (e.type == DioExceptionType.connectionError) {
        throw Exception('Connection error. Please check your internet connection.');
      }
      
      throw Exception('Failed to fetch exchange rates: ${e.message}');
    } catch (e) {
      print('❌ Unexpected error: $e');
      throw Exception('An unexpected error occurred: $e');
    }
  }

  Future<Map<String, dynamic>> getHistoricalRates(
    String from,
    String to,
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      print('🌐 Fetching historical rates: $from → $to');

      final formattedStart = _formatDate(startDate);
      final formattedEnd = _formatDate(endDate);

      final response = await _dio.get(
        '/$formattedStart..$formattedEnd',
        queryParameters: {
          'from': from,
          'to': to,
        },
      );

      if (response.data == null) {
        throw Exception('No historical data available');
      }

      print('✅ Historical data fetched');
      return response.data;
      
    } on DioException catch (e) {
      print('❌ Currency API Error: ${e.type}');
      throw Exception('Failed to fetch historical data: ${e.message}');
    } catch (e) {
      print('❌ Unexpected error: $e');
      throw Exception('An unexpected error occurred: $e');
    }
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  void clearCache() {
    _rateCache.clear();
    _cacheTimestamps.clear();
    print('🗑️ Cache cleared');
  }

  // Get supported currencies from API
  Future<List<String>> getSupportedCurrencies() async {
    try {
      final response = await _dio.get('/currencies');
      
      if (response.data == null) {
        throw Exception('No currency data received');
      }

      return (response.data as Map<String, dynamic>).keys.toList();
      
    } catch (e) {
      print('❌ Failed to fetch currencies: $e');
      // Return default list if API fails
      return CurrencyData.allCurrencies.map((c) => c.code).toList();
    }
  }
}

// Singleton pattern
class CurrencyServiceInstance {
  static final CurrencyService instance = CurrencyService();
}