import 'package:flutter/material.dart';
import 'package:qrcodescannerapp/db/database_provider.dart';
import 'package:qrcodescannerapp/model/urls.dart';
import 'package:url_launcher/url_launcher.dart';

class Url_List extends StatefulWidget {
  List<Widget> _urlLister;
  Url_List(this._urlLister);
  @override
  Url_ListState createState() => Url_ListState(_urlLister);
}

class Url_ListState extends State<Url_List> {
  List<Widget> _urlLister;
  Url_ListState(this._urlLister);
  List<Widget> _urlDBList = [];
  void initState() {
    super.initState();
    _appendList();
  }

  _appendList() async {
    await DatabaseProvider.db.getUrls().then((urlList) {
      for (var i = 0; i < urlList.length; i++) {
        _urlDBList.add(_buildDBWidget(urlList[i]));
      }
      print(urlList);
    });
    setState(() {});
  }

  String _text;
  checkURL(url) async {
    if (await canLaunch(url)) {
      _text = 'Browse URL';
    } else {
      _text = 'Invalid URL';
    }
  }

  launchURL(url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  _buildDBWidget(url) {
    String _name = url.name;
    checkURL(_name);
    return Padding(
      padding: EdgeInsets.fromLTRB(0, 10, 0, 0),
      child: Container(
          width: MediaQuery.of(context).size.width * 0.95,
          height: 45,
          color: Colors.blueGrey,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Container(
                width: MediaQuery.of(context).size.width * 0.80,
                child: Text(_name,
                    overflow: TextOverflow.ellipsis,
                    style:
                        TextStyle(fontSize: 20, fontWeight: FontWeight.normal),
                    maxLines: 1,
                    softWrap: true),
              ),
              PopupMenuButton<int>(
                onSelected: (value) {
                  if (value == 1 && _text == 'Browse URL') {
                    launchURL(url);
                  } else if (value == 2) {
                    print('hello');
                    DatabaseProvider.db.delete(url.id);
                    this._urlDBList.removeWhere(
                        (contact) => contact.key == Key("index_$_name"));
                    setState(() {});
                  }
                },
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 1,
                    child: Text(_text,
                        style:
                            TextStyle(decoration: TextDecoration.lineThrough)),
                  ),
                  PopupMenuItem(
                    value: 2,
                    child: Text("Delete"),
                  ),
                ],
              ),
            ],
          )),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(''),
          backgroundColor: Color(0xFFd6edfc),
        ),
        body: Column(children: [
          Expanded(
            child: ListView(
              children: <Widget>[
                Column(
                  children: _urlLister,
                ),
              ],
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text('Favorite'),
              Icon(
                Icons.favorite,
                color: Colors.redAccent,
              ),
            ],
          ),
          Expanded(
            child: ListView(
              children: <Widget>[
                Column(
                  children: _urlDBList,
                ),
              ],
            ),
          ),
        ]));
  }
}
