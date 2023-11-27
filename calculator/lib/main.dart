import 'package:flutter/material.dart';
import 'package:math_expressions/math_expressions.dart';
import 'package:flutter/services.dart'; // Импорт для доступа к платформенным сервисам

void main() {
  runApp(CalculatorApp());
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
}

class CalculatorApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.orange),
      home: Calculator(),
    );
  }
}

class Calculator extends StatefulWidget {
  @override
  _CalculatorState createState() => _CalculatorState();
}

class _CalculatorState extends State<Calculator> {
  String _output = '';
  bool isError = false;
  bool pointAllowed = true;

  Widget buildButton(String buttonText, Color buttonColor, Color textColor) {
    return Expanded(
      child: Container(
        margin: EdgeInsets.all(7),
        child: ElevatedButton(
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all<Color>(buttonColor),
            shape: MaterialStateProperty.all<RoundedRectangleBorder>(
              RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(50.0),
              ),
            ),
          ),
          onPressed: () => buttonPressed(buttonText),
          child: Text(
            buttonText,
            style: TextStyle(fontSize: 40, color: textColor),
          ),
        ),
      ),
    );
  }

  List<String> tokenizeExpression(String expression) {
    var result = <String>[];
    var numberBuffer = StringBuffer();
    for (var i = 0; i < expression.length; i++) {
      var char = expression[i];
      if (isDigit(char) || char == '.') {
        numberBuffer.write(char);
        if (i == expression.length - 1) {
          result.add(numberBuffer.toString());
        }
      } else {
        if (numberBuffer.isNotEmpty) {
          result.add(numberBuffer.toString());
          numberBuffer.clear();
        }
        if (char != ' ') {
          result.add(char);
        }
      }
    }
    return result;
  }

  String evaluateExpression(List<String> expression) {
    try {
      String expr = expression.join('');
      Parser p = Parser();
      Expression exp = p.parse(expr);
      ContextModel cm = ContextModel();
      double result = exp.evaluate(EvaluationType.REAL, cm);

      if (result == result.toInt()) {
        return result.toInt().toString();
      } else {
        String formattedResult = result.toStringAsFixed(4);
        while (formattedResult.endsWith('0')) {
          formattedResult =
              formattedResult.substring(0, formattedResult.length - 1);
        }
        if (formattedResult.endsWith('.')) {
          formattedResult =
              formattedResult.substring(0, formattedResult.length - 1);
        }
        return formattedResult;
      }
    } catch (e) {
      return 'Error';
    }
  }

  buttonPressed(String buttonText) {
    if (buttonText == 'C') {
      _output = '';
      isError = false;
      pointAllowed = true;
    } else if (buttonText == '=') {
      var expression = tokenizeExpression(_output);
      try {
        _output = evaluateExpression(expression);
        isError = _output == 'Error';
        pointAllowed =
            !_output.contains('.'); // Проверяем, есть ли точка в результате
      } catch (e) {
        isError = true;
        _output = 'Error';
      }
    } else if (buttonText == '⌫') {
      if (_output == 'Error') {
        _output = '';
        isError = false;
      }
      if (_output.isNotEmpty) {
        // Проверка, была ли удалена точка
        bool pointRemoved = _output.characters.last == '.';
        _output = _output.substring(0, _output.length - 1);
        isError = false;

        // Если точка была удалена, разрешить ее вставку заново
        if (pointRemoved) {
          pointAllowed = true;
        } else {
          pointAllowed = !_output.contains('.');
        }
      }
    } else {
      if (_output.isEmpty || _output == 'Error') {
        if (!isDigit(buttonText) && buttonText != '-') {
          return;
        }
      } else {
        if (isOperator(buttonText)) {
          final lastChar = _output.isNotEmpty ? _output.characters.last : '';
          if (isOperator(lastChar)) {
            _output = _output.substring(0, _output.length - 1);
          }
          pointAllowed = true;
        } else if (buttonText == '.' && !pointAllowed) {
          return;
        }
      }
      if (buttonText == '.') {
        pointAllowed = false;
      }

      if (_output == 'Error' && buttonText != '') {
        _output = '';
        isError = false;
      }

      _output += buttonText;
    }
    setState(() {});
  }

  bool isOperator(String s) {
    return s == '+' || s == '-' || s == '*' || s == '/' || s == '^' || s == '!';
  }

  bool isDigit(String s) => double.tryParse(s) != null;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 0, 0, 0),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(0.0),
        child: AppBar(
          backgroundColor: Colors.black,
          elevation: 0.0,
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Expanded(
            flex: 3,
            child: Container(
              padding: EdgeInsets.only(top: 115, left: 25, right: 10),
              alignment: Alignment.centerRight,
              child: Text(_output,
                  style: TextStyle(
                    fontSize: 58,
                    fontWeight: FontWeight.bold,
                    color: isError ? Colors.red : Colors.white,
                  ),
                  maxLines: 2),
            ),
          ),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                buildButton('C', Colors.red, Colors.white),
                buildButton('!', Colors.grey, Colors.white),
                buildButton('^', Colors.orange, Colors.white),
                buildButton('/', Colors.orange, Colors.white),
              ],
            ),
          ),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                buildButton('7', Colors.grey, Colors.white),
                buildButton('8', Colors.grey, Colors.white),
                buildButton('9', Colors.grey, Colors.white),
                buildButton('*', Colors.orange, Colors.white),
              ],
            ),
          ),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                buildButton('4', Colors.grey, Colors.white),
                buildButton('5', Colors.grey, Colors.white),
                buildButton('6', Colors.grey, Colors.white),
                buildButton('-', Colors.orange, Colors.white),
              ],
            ),
          ),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                buildButton('1', Colors.grey, Colors.white),
                buildButton('2', Colors.grey, Colors.white),
                buildButton('3', Colors.grey, Colors.white),
                buildButton('+', Colors.orange, Colors.white),
              ],
            ),
          ),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                buildButton('0', Colors.grey, Colors.white),
                buildButton('.', Colors.grey, Colors.white),
                buildButton('⌫', Colors.orange, Colors.white),
                buildButton('=', Colors.orange, Colors.white),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
