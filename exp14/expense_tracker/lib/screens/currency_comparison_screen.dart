import 'package:flutter/material.dart';
import 'package:expense_tracker/models/currency.dart';
import 'package:expense_tracker/services/currency_service.dart';
import 'package:expense_tracker/widgets/currency_selector.dart';

class CurrencyComparisonScreen extends StatefulWidget {
  const CurrencyComparisonScreen({super.key});

  @override
  State<CurrencyComparisonScreen> createState() => _CurrencyComparisonScreenState();
}

class _CurrencyComparisonScreenState extends State<CurrencyComparisonScreen> {
  final CurrencyService _currencyService = CurrencyServiceInstance.instance;
  
  Currency _baseCurrency = CurrencyData.popularCurrencies[0]; // USD
  final List<Currency> _selectedCurrencies = [
    CurrencyData.popularCurrencies[1], // EUR
    CurrencyData.popularCurrencies[2], // GBP
    CurrencyData.popularCurrencies[3], // INR
    CurrencyData.popularCurrencies[4], // JPY
  ];

  Map<String, double> _exchangeRates = {};
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadRates();
  }

  Future<void> _loadRates() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final currencyCodes = _selectedCurrencies.map((c) => c.code).toList();
      final rates = await _currencyService.getMultipleRates(
        _baseCurrency.code,
        currencyCodes,
      );

      setState(() {
        _exchangeRates = rates;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceAll('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  void _selectBaseCurrency() async {
    final selected = await showModalBottomSheet<Currency>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => CurrencySelector(
        selectedCurrency: _baseCurrency,
      ),
    );

    if (selected != null) {
      setState(() {
        _baseCurrency = selected;
      });
      _loadRates();
    }
  }

  void _addCurrency() async {
    final selected = await showModalBottomSheet<Currency>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => CurrencySelector(
        selectedCurrency: _selectedCurrencies.first,
      ),
    );

    if (selected != null && !_selectedCurrencies.contains(selected)) {
      setState(() {
        _selectedCurrencies.add(selected);
      });
      _loadRates();
    }
  }

  void _removeCurrency(Currency currency) {
    if (_selectedCurrencies.length > 1) {
      setState(() {
        _selectedCurrencies.remove(currency);
        _exchangeRates.remove(currency.code);
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('At least one currency must be selected'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Compare Currencies'),
        backgroundColor: Colors.purple[700],
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _isLoading ? null : _loadRates,
          ),
        ],
      ),
      body: Column(
        children: [
          // Base Currency Card
          Card(
            margin: const EdgeInsets.all(16),
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: InkWell(
              onTap: _selectBaseCurrency,
              borderRadius: BorderRadius.circular(16),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.purple[400]!, Colors.purple[700]!],
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Center(
                        child: Text(
                          _baseCurrency.flag,
                          style: const TextStyle(fontSize: 32),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Base Currency',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.9),
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _baseCurrency.code,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            _baseCurrency.name,
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.9),
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.edit, color: Colors.white),
                  ],
                ),
              ),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Comparison',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
                TextButton.icon(
                  onPressed: _addCurrency,
                  icon: const Icon(Icons.add),
                  label: const Text('Add Currency'),
                ),
              ],
            ),
          ),

          // Currency List
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _errorMessage != null
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.error_outline,
                                  size: 64, color: Colors.red[300]),
                              const SizedBox(height: 16),
                              Text(
                                _errorMessage!,
                                style: TextStyle(color: Colors.red[700]),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton(
                                onPressed: _loadRates,
                                child: const Text('Retry'),
                              ),
                            ],
                          ),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: _selectedCurrencies.length,
                        itemBuilder: (context, index) {
                          final currency = _selectedCurrencies[index];
                          final rate = _exchangeRates[currency.code];

                          return _buildCurrencyComparisonCard(
                            currency: currency,
                            rate: rate,
                            onRemove: () => _removeCurrency(currency),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrencyComparisonCard({
    required Currency currency,
    required double? rate,
    required VoidCallback onRemove,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Currency Info
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Colors.purple[50],
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
                  Row(
                    children: [
                      Text(
                        currency.code,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        currency.symbol,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
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
            // Rate
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (rate != null) ...[
                  Text(
                    rate.toStringAsFixed(4),
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.purple,
                    ),
                  ),
                  Text(
                    'per ${_baseCurrency.code}',
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.grey[600],
                    ),
                  ),
                ] else
                  const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
              ],
            ),
            const SizedBox(width: 8),
            // Remove button
            IconButton(
              icon: const Icon(Icons.close, size: 20),
              color: Colors.grey[600],
              onPressed: onRemove,
            ),
          ],
        ),
      ),
    );
  }
}