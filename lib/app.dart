import 'package:flutter/material.dart';
import 'screens/scanner/scanner_detail.dart';

class App extends StatelessWidget {
  var _temp;
  App(this._temp);
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scanner_detail(_temp),
    );
  }
}
