import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final FirebaseFirestore firestore = FirebaseFirestore.instance;

    return StreamBuilder<QuerySnapshot>(
      stream: firestore.collection('history').orderBy('timestamp', descending: true).snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('No history yet!'));
        }

        final docs = snapshot.data!.docs;

        return ListView.builder(
          itemCount: docs.length,
          itemBuilder: (context, index) {
            final data = docs[index].data() as Map<String, dynamic>;
            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              color: const Color(0xFF29293D),
              child: ListTile(
                title: Text(
                  data['expression'] ?? '',
                  style: const TextStyle(fontSize: 20, color: Colors.white),
                ),
                subtitle: Text(
                  '= ${data['result'] ?? ''}',
                  style: const TextStyle(color: Colors.greenAccent, fontSize: 18),
                ),
                trailing: Text(
                  data['timestamp'] != null
                      ? (data['timestamp'] as Timestamp).toDate().toString().split('.')[0]
                      : '',
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
