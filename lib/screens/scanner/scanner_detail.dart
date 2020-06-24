import 'package:flutter/material.dart';
import 'scanner.dart';

class Scanner_detail extends StatelessWidget {
  var _temp;
  Scanner_detail(this._temp);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Scanner'),
      ),
      body: Scanner(_temp),
    );
  }
}
