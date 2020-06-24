import 'package:flutter/material.dart';

class Url_List extends StatelessWidget {
  List<Widget> _urlLister;
  Url_List(this._urlLister);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('')),
      body: Container(
        height: 500,
        child: ListView(
          children: <Widget>[Column(children: _urlLister)],
        ),
      ),
    );
  }
}
