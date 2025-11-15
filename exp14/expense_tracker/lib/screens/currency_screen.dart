import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:expense_tracker/models/currency.dart';
import 'package:expense_tracker/services/currency_service.dart';
import 'package:expense_tracker/widgets/currency_selector.dart';
import 'package:expense_tracker/widgets/conversion_history.dart';

class CurrencyScreen extends StatefulWidget {
  const CurrencyScreen({super.key});

  @override
  State<CurrencyScreen> createState() => _CurrencyScreenState();
}

class _CurrencyScreenState extends State<CurrencyScreen> {
  final CurrencyService _currencyService = CurrencyServiceInstance.instance;
  final TextEditingController _amountController = TextEditingController();
  
  Currency _fromCurrency = CurrencyData.popularCurrencies[0]; // USD
  Currency _toCurrency = CurrencyData.popularCurrencies[3]; // INR
  
  double? _exchangeRate;
  double? _convertedAmount;
  bool _isLoading = false;
  String? _errorMessage;
  DateTime? _lastUpdated;
  
  List<CurrencyConversion> _conversionHistory = [];

  @override
  void initState() {
    super.initState();
    _amountController.text = '1';
    _convertCurrency();
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _convertCurrency() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final amount = double.tryParse(_amountController.text) ?? 0;
      
      if (amount <= 0) {
        setState(() {
          _errorMessage = 'Please enter a valid amount';
          _isLoading = false;
        });
        return;
      }

      final rate = await _currencyService.getExchangeRate(
        _fromCurrency.code,
        _toCurrency.code,
      );

      final result = amount * rate.rate;

      // Add to history
      final conversion = CurrencyConversion(
        amount: amount,
        fromCurrency: _fromCurrency,
        toCurrency: _toCurrency,
        rate: rate.rate,
        result: result,
        timestamp: DateTime.now(),
      );

      setState(() {
        _exchangeRate = rate.rate;
        _convertedAmount = result;
        _lastUpdated = rate.timestamp;
        _isLoading = false;
        
        // Add to history (max 10 items)
        _conversionHistory.insert(0, conversion);
        if (_conversionHistory.length > 10) {
          _conversionHistory = _conversionHistory.sublist(0, 10);
        }
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceAll('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  void _swapCurrencies() {
    setState(() {
      final temp = _fromCurrency;
      _fromCurrency = _toCurrency;
      _toCurrency = temp;
    });
    _convertCurrency();
  }

  void _showCurrencySelector(bool isFromCurrency) async {
    final selected = await showModalBottomSheet<Currency>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => CurrencySelector(
        selectedCurrency: isFromCurrency ? _fromCurrency : _toCurrency,
      ),
    );

    if (selected != null) {
      setState(() {
        if (isFromCurrency) {
          _fromCurrency = selected;
        } else {
          _toCurrency = selected;
        }
      });
      _convertCurrency();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Currency Exchange'),
        backgroundColor: Colors.blue[700],
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                builder: (context) => ConversionHistory(
                  history: _conversionHistory,
                  onSelect: (conversion) {
                    setState(() {
                      _fromCurrency = conversion.fromCurrency;
                      _toCurrency = conversion.toCurrency;
                      _amountController.text = conversion.amount.toString();
                    });
                    Navigator.pop(context);
                    _convertCurrency();
                  },
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _isLoading ? null : _convertCurrency,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Amount Input Card
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Amount',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _amountController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: '0.00',
                        hintStyle: TextStyle(color: Colors.grey[300]),
                      ),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
                      ],
                      onChanged: (value) {
                        if (value.isNotEmpty) {
                          // Auto-convert after typing
                          Future.delayed(const Duration(milliseconds: 500), () {
                            if (_amountController.text == value) {
                              _convertCurrency();
                            }
                          });
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // From Currency
            _buildCurrencyCard(
              currency: _fromCurrency,
              label: 'From',
              onTap: () => _showCurrencySelector(true),
            ),
            
            const SizedBox(height: 8),

            // Swap Button
            Center(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.blue[700],
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blue.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: IconButton(
                  icon: const Icon(Icons.swap_vert, color: Colors.white),
                  onPressed: _swapCurrencies,
                ),
              ),
            ),

            const SizedBox(height: 8),

            // To Currency
            _buildCurrencyCard(
              currency: _toCurrency,
              label: 'To',
              onTap: () => _showCurrencySelector(false),
            ),

            const SizedBox(height: 24),

            // Result Card
            if (_isLoading)
              const Card(
                elevation: 4,
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
                ),
              )
            else if (_errorMessage != null)
              Card(
                elevation: 4,
                color: Colors.red[50],
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Icon(Icons.error_outline, color: Colors.red[700]),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _errorMessage!,
                          style: TextStyle(color: Colors.red[700]),
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else if (_convertedAmount != null)
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.blue[400]!, Colors.blue[700]!],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      Text(
                        'Converted Amount',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _toCurrency.symbol,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _convertedAmount!.toStringAsFixed(2),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 40,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _toCurrency.name,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Divider(color: Colors.white.withOpacity(0.3)),
                      const SizedBox(height: 8),
                      Text(
                        '1 ${_fromCurrency.code} = ${_exchangeRate?.toStringAsFixed(4)} ${_toCurrency.code}',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 14,
                        ),
                      ),
                      if (_lastUpdated != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          'Updated: ${_formatDateTime(_lastUpdated!)}',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.7),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),

            const SizedBox(height: 24),

            // Convert Button
            ElevatedButton(
              onPressed: _isLoading ? null : _convertCurrency,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue[700],
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Convert',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrencyCard({
    required Currency currency,
    required String label,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    currency.flag,
                    style: const TextStyle(fontSize: 24),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      currency.code,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      currency.name,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey[400]),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes} min ago';
    } else if (difference.inDays < 1) {
      return '${difference.inHours} hr ago';
    } else {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    }
  }
}