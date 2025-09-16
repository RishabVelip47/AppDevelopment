import 'package:flutter/material.dart';

void main() {
  runApp(CalculatorApp());
}

class CalculatorApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Simple Calculator',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home: CalculatorScreen(),
    );
  }
}

class CalculatorScreen extends StatefulWidget {
  @override
  _CalculatorScreenState createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  String _input = '';
  String _output = '';

  void _buttonPressed(String value) {
    setState(() {
      if (value == 'C') {
        _input = '';
        _output = '';
      } else if (value == '⌫') {
        if (_input.isNotEmpty) {
          _input = _input.substring(0, _input.length - 1);
        }
      } else if (value == '=') {
        _output = _evaluate(_input);
      } else {
        _input += value;
      }
    });
  }

  String _evaluate(String expr) {
    try {
      // Tokenize numbers and operators
      List<String> tokens = [];
      String number = '';
      for (int i = 0; i < expr.length; i++) {
        String char = expr[i];
        if ('0123456789.'.contains(char)) {
          number += char;
        } else if ('+-*/'.contains(char)) {
          if (number.isNotEmpty) {
            tokens.add(number);
            number = '';
          }
          tokens.add(char);
        }
      }
      if (number.isNotEmpty) tokens.add(number);

      // Perform *, /
      for (int i = 0; i < tokens.length; i++) {
        if (tokens[i] == '*' || tokens[i] == '/') {
          double left = double.parse(tokens[i - 1]);
          double right = double.parse(tokens[i + 1]);
          double result = tokens[i] == '*' ? left * right : (right == 0 ? double.nan : left / right);
          tokens.replaceRange(i - 1, i + 2, [result.toString()]);
          i = 0; // restart
        }
      }

      // Perform +, -
      double total = double.parse(tokens[0]);
      for (int i = 1; i < tokens.length; i += 2) {
        String op = tokens[i];
        double num = double.parse(tokens[i + 1]);
        if (op == '+') total += num;
        if (op == '-') total -= num;
      }

      if (total.isNaN) return 'Error';
      return total.toString();
    } catch (e) {
      return 'Error';
    }
  }

  Widget _buildButton(String text, {Color? color}) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(6.0),
        child: ElevatedButton(
          onPressed: () => _buttonPressed(text),
          style: ElevatedButton.styleFrom(
            backgroundColor: color ?? Colors.grey[800],
            padding: EdgeInsets.all(22),
          ),
          child: Text(
            text,
            style: TextStyle(fontSize: 24),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Simple Calculator')),
      body: Column(
        children: [
          Expanded(
            child: Container(
              alignment: Alignment.bottomRight,
              padding: EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(_input, style: TextStyle(fontSize: 32)),
                  SizedBox(height: 10),
                  Text(_output, style: TextStyle(fontSize: 24, color: Colors.green)),
                ],
              ),
            ),
          ),
          Divider(),
          Column(
            children: [
              Row(children: [_buildButton('C', color: Colors.red), _buildButton('⌫'), _buildButton(''), _buildButton('/')]),
              Row(children: [_buildButton('7'), _buildButton('8'), _buildButton('9'), _buildButton('*')]),
              Row(children: [_buildButton('4'), _buildButton('5'), _buildButton('6'), _buildButton('-')]),
              Row(children: [_buildButton('1'), _buildButton('2'), _buildButton('3'), _buildButton('+')]),
              Row(children: [_buildButton('0'), _buildButton('.'), _buildButton('='),]),
            ],
          ),
        ],
      ),
    );
  }
}