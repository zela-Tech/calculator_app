import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Calculator App',
      theme: ThemeData.dark(),
      home: const CalculatorScreen(),
    );
  }
}

// Hold Key Calculator UI elements  
class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({super.key});

  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  //color palete 
  static const Color kBodyColor    = Color(0xFF181826); // backgorund color
  static const Color kDisplayColor = Color(0xFF0D0D1A); // display areaa
  static const Color kNumColor     = Color(0xFF26263A); // numbers
  static const Color kOpColor      = Color(0xFF695CFF); // operators
  static const Color kTopColor     = Color(0xFF7467D9); // (C, ±, %)
  static const Color kTextColor    = Color(0xFF48F58A);


  String _display = '0';// tracks what's shown on the display area

  // sotres parts of the equation
  double _firstOperand = 0;       // number stored before operator is pressed
  String _operator = '';        
  bool _waitingForSecond = false; // will become true when operator is presesd
  bool _hasResult = false;        // true after = is pressed


  // Utilize Dart functions for arithmetic calculations and control flow for user interactions

  // Resets all states
  void _handleClear() {
    _display = '0';
    _firstOperand = 0;
    _operator = '';
    _waitingForSecond = false;
    _hasResult = false;
  }

  // Save the curr # and the chosen operator
  void _handleOperator(String op) {
    _firstOperand = double.tryParse(_display) ?? 0;
    _operator = op;
    _waitingForSecond = true;
    _hasResult = false;
  }

  // evaluates the expression for... then Provide clear feedback to users about what went wrong
    // 1. Handle cases where user presses "=" without complete input
    // 2. Operator chosen but no second number entered
    // 3. Detect division by zero attempts
  void _handleEquals() {

    // case 1: Handle cases where user presses "=" without complete input
    if (_operator.isEmpty) {
      _display = 'Enter operator';
      _hasResult = false;
      return;
    }

    // case 2: operator was chosen but second number not entered
    if (_waitingForSecond) {
      _display = 'Enter 2nd number';
      _hasResult = false;
      return;
    }

    final double secondOperand = double.tryParse(_display) ?? 0;

    // case 3: division by zero
    if (_operator == '÷' && secondOperand == 0) {
      _display = 'Error';
      _operator = '';
      _waitingForSecond = false;
      _hasResult = false;
      return;
    }

    // if all checks are passed perform the calculation
    final double result = _performCalculation(
        _firstOperand, secondOperand, _operator);

    _display = _formatResult(result);
    _operator = '';
    _waitingForSecond = false;
    _hasResult = true;
  }

  void _handleDecimal() {
    if (_waitingForSecond) {
      _display = '0.';
      _waitingForSecond = false;
    } else if (!_display.contains('.')) {
      _display = '$_display.';
    }
  }

  void _handleDigit(String digit) {
    // clear if an error message is currently shown
    final bool isShowingError = !_isValidNumber(_display);

    // decide which mode we are currently in
    if (_hasResult || isShowingError) {  
      // Start a new expression after seeing a result or error
      _display = digit;
      _hasResult = false;
    } else if (_waitingForSecond) { // Start typing the second operand
      _display = digit;
      _waitingForSecond = false;
    } else { 
      // Append the digit; ensure 0 is replaced with 1-9 so we avoid displaying 01, etc.
      _display = _display == '0' ? digit : '$_display$digit';
    }
  }
  //Used to detect when the display is showing an error str
  bool _isValidNumber(String s) {
    return double.tryParse(s) != null;
  }

  // Routes each button pressed to the appropriate function
  void _onButtonPressed(String label) {
    setState(() {
      if (label == 'C') {
        _handleClear();
      } else if (['+', '-', '×', '÷'].contains(label)) {
        _handleOperator(label);
      } else if (label == '=') {
        _handleEquals();
      } else if (label == '.') {
        _handleDecimal();
      } else {
        _handleDigit(label);
      }
    });
  }

  // Calls the correct Dart operator based on the operator string
  double _performCalculation(double a, double b, String op) {
    if (op == '+') return a + b;
    if (op == '-') return a - b;
    if (op == '×') return a * b;
    if (op == '÷') return a / b;
    return a;
  }

  //For formating...removes unnecessary trailing zeros, ex. 4.0 → 4
  String _formatResult(double value) {
    if (value == value.truncateToDouble()) {
      return value.toInt().toString();
    }
    return double.parse(value.toStringAsFixed(10))
        .toString()
        .replaceAll(RegExp(r'0+$'), '');
  }
  
  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      body:Center(
        child: Container(
          width:320,
          padding: const EdgeInsets.all(20),
          decoration:  BoxDecoration(
            color: kBodyColor,
            borderRadius: BorderRadius.circular(32),
            boxShadow: const [
              BoxShadow(
                color: Colors.black45,
                blurRadius:50,
                offset: Offset(0, 10),
              ),
            ],
          ),

          child: Column(
            mainAxisSize: MainAxisSize.min,
            children:[
              _buildDisplay(),
              const SizedBox(height: 20),
              _buildButtonGrid(),
            ],
          ),
        ),
      ),
    );
  }

  //Implement UI for display area 
  Widget _buildDisplay() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 30, vertical:24),
      decoration: BoxDecoration(
        color: kDisplayColor,
        borderRadius:BorderRadius.circular(25),
      ),
      child: Text(
        _display, //remove placeholder 0, now reads from state
        textAlign:TextAlign.right,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style:TextStyle(
          color: kTextColor,
          fontSize: _display.length > 10 ? 18 : 40, // shrink for error messages
          fontWeight: FontWeight.w300,
          letterSpacing: 2,
        ),
      ),
    );
  }

  // Implement a UI with number buttons (0-9), arithmetic operators (+, -, *, /)
  Widget _buildButtonGrid() {
    // Each sub-list is one row of the calculator
    final List<List<String>> rows = [
      ['C', '±', '%', '÷'],  //  row 1
      ['7', '8', '9', '×'],  //  2
      ['4', '5', '6', '-'],  //  3
      ['1', '2', '3', '+'],  //  4
      ['0', '.', '='],       
    ];

    return Column(
      children: rows.map((row) => _buildRow(row)).toList(),
    );
  }

  // Builds a single horizontal row of buttons
  Widget _buildRow(List<String> labels) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: labels.map((label) {
          return _CalcButton(
            label: label,
            color: _colorFor(label),
            isWide: label == '0', // the zero button spans double width
            onPressed: () => _onButtonPressed(label),
          );
        }).toList(),
      ),
    );
  }

  // Returns the correct color for each button type
  Color _colorFor(String label) {
    const topRowLabels  = ['C', '±', '%'];
    const operatorLabels = ['÷', '×', '-', '+', '='];

    if (topRowLabels.contains(label))   return kTopColor;
    if (operatorLabels.contains(label)) return kOpColor;
    return kNumColor;
  }
}

// Renders a single calculator button; isWide doubles the width
class _CalcButton extends StatelessWidget {
  final String label;
  final Color color;
  final bool isWide;
  final VoidCallback onPressed;

  const _CalcButton({
    required this.label,
    required this.color,
    required this.onPressed,
    this.isWide = false,
  });

  @override
  Widget build(BuildContext context) {
    const double buttonSize = 60;
    final double width = isWide ? buttonSize * 2 + 12 : buttonSize;

    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: width,
        height: buttonSize,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.5),
              blurRadius:3,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Center(
          child: Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}