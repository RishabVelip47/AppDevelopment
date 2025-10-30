import 'package:flutter/material.dart';
import 'package:math_expressions/math_expressions.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({super.key});

  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  String equation = "";
  String result = "";
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  void _onPressed(String value) {
    setState(() {
      if (value == 'C') {
        equation = "";
        result = "";
      } else if (value == '=') {
        _calculate();
      } else {
        equation += value;
      }
    });
  }

  void _calculate() {
    try {
      Parser p = Parser();
      Expression exp = p.parse(equation.replaceAll('×', '*').replaceAll('÷', '/'));
      ContextModel cm = ContextModel();
      double eval = exp.evaluate(EvaluationType.REAL, cm);
      result = eval.toString();

      // Save to Firestore
      _firestore.collection('history').add({
        'expression': equation,
        'result': result,
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      result = "Error";
    }
    setState(() {});
  }

  Widget _buildButton(String text, {Color color = Colors.deepPurple}) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: color,
            padding: const EdgeInsets.symmetric(vertical: 22),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
          onPressed: () => _onPressed(text),
          child: Text(text, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(24),
            alignment: Alignment.bottomRight,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(equation, style: const TextStyle(fontSize: 32, color: Colors.grey)),
                const SizedBox(height: 10),
                Text(result, style: const TextStyle(fontSize: 48, color: Colors.white, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ),
        const Divider(color: Colors.white54),
        Column(
          children: [
            Row(children: [_buildButton('7'), _buildButton('8'), _buildButton('9'), _buildButton('÷', color: Colors.orange)]),
            Row(children: [_buildButton('4'), _buildButton('5'), _buildButton('6'), _buildButton('×', color: Colors.orange)]),
            Row(children: [_buildButton('1'), _buildButton('2'), _buildButton('3'), _buildButton('-', color: Colors.orange)]),
            Row(children: [_buildButton('C', color: Colors.red), _buildButton('0'), _buildButton('=', color: Colors.green), _buildButton('+', color: Colors.orange)]),
          ],
        ),
      ],
    );
  }
}
