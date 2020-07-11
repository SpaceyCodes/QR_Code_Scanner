import 'package:flutter/material.dart';
import 'scanner.dart';
import 'url_list.dart';

class Scanner_detail extends StatelessWidget {
  var _temp;
  Scanner_detail(this._temp);
  List<Widget> _urlLister = [];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Scanner'),
        backgroundColor: Color(0xFFd6edfc),
        actions: <Widget>[
          IconButton(
              icon: Icon(
                Icons.favorite,
                color: Colors.redAccent,
              ),
              onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => Url_List(_urlLister),
                    ),
                  ))
        ],
      ),
      body: Scanner(_temp),
    );
  }
}
