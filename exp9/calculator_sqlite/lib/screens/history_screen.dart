import 'package:flutter/material.dart';
import '../db/db_helper.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<Map<String, dynamic>> _history = [];

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    final data = await DBHelper.instance.getHistory();
    setState(() {
      _history = data;
    });
  }

  Future<void> _clearHistory() async {
    await DBHelper.instance.clearHistory();
    _loadHistory();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.black,
          title: const Text(
            'Calculation History',
            style: TextStyle(color: Colors.deepPurpleAccent),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.redAccent),
              onPressed: _clearHistory,
            ),
          ],
        ),
        body: _history.isEmpty
            ? const Center(
                child: Text(
                  'No history yet!',
                  style: TextStyle(color: Colors.white70, fontSize: 18),
                ),
              )
            : ListView.builder(
                itemCount: _history.length,
                itemBuilder: (context, index) {
                  final item = _history[index];
                  return ListTile(
                    title: Text(
                      item['expression'] ?? '',
                      style: const TextStyle(color: Colors.white),
                    ),
                    subtitle: Text(
                      '= ${item['result']}',
                      style: const TextStyle(color: Colors.deepPurpleAccent),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
