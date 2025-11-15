import 'package:flutter/material.dart';
import 'package:expense_tracker/models/currency.dart';

class CurrencySelector extends StatefulWidget {
  final Currency selectedCurrency;

  const CurrencySelector({
    super.key,
    required this.selectedCurrency,
  });

  @override
  State<CurrencySelector> createState() => _CurrencySelectorState();
}

class _CurrencySelectorState extends State<CurrencySelector> {
  final TextEditingController _searchController = TextEditingController();
  List<Currency> _filteredCurrencies = [];
  bool _showPopularOnly = true;

  @override
  void initState() {
    super.initState();
    _filteredCurrencies = CurrencyData.popularCurrencies;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterCurrencies(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredCurrencies = _showPopularOnly
            ? CurrencyData.popularCurrencies
            : CurrencyData.allCurrencies;
      } else {
        final lowerQuery = query.toLowerCase();
        final sourceList = _showPopularOnly
            ? CurrencyData.popularCurrencies
            : CurrencyData.allCurrencies;
        
        _filteredCurrencies = sourceList.where((currency) {
          return currency.code.toLowerCase().contains(lowerQuery) ||
                 currency.name.toLowerCase().contains(lowerQuery);
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                const Text(
                  'Select Currency',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                
                // Search bar
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search currency...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              _filterCurrencies('');
                            },
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                  onChanged: _filterCurrencies,
                ),
                const SizedBox(height: 12),

                // Toggle button
                Row(
                  children: [
                    Expanded(
                      child: SegmentedButton<bool>(
                        segments: const [
                          ButtonSegment(
                            value: true,
                            label: Text('Popular'),
                            icon: Icon(Icons.star, size: 16),
                          ),
                          ButtonSegment(
                            value: false,
                            label: Text('All'),
                            icon: Icon(Icons.list, size: 16),
                          ),
                        ],
                        selected: {_showPopularOnly},
                        onSelectionChanged: (Set<bool> selection) {
                          setState(() {
                            _showPopularOnly = selection.first;
                            _searchController.clear();
                            _filterCurrencies('');
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const Divider(height: 1),

          // Currency list
          Expanded(
            child: _filteredCurrencies.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.search_off, size: 64, color: Colors.grey[400]),
                        const SizedBox(height: 16),
                        Text(
                          'No currencies found',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: _filteredCurrencies.length,
                    itemBuilder: (context, index) {
                      final currency = _filteredCurrencies[index];
                      final isSelected = currency == widget.selectedCurrency;

                      return ListTile(
                        leading: Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: isSelected ? Colors.blue[50] : Colors.grey[100],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Center(
                            child: Text(
                              currency.flag,
                              style: const TextStyle(fontSize: 24),
                            ),
                          ),
                        ),
                        title: Row(
                          children: [
                            Text(
                              currency.code,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: isSelected ? Colors.blue[700] : null,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              currency.symbol,
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                        subtitle: Text(currency.name),
                        trailing: isSelected
                            ? Icon(Icons.check_circle, color: Colors.blue[700])
                            : null,
                        onTap: () {
                          Navigator.pop(context, currency);
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}