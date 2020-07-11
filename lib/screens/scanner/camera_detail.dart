import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'dart:async';
import 'dart:io';
import 'url_list.dart';
import 'package:path/path.dart' show join;
import 'package:path_provider/path_provider.dart';
import 'package:firebase_ml_vision/firebase_ml_vision.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:qrcodescannerapp/model/urls.dart';
import 'package:qrcodescannerapp/db/database_provider.dart';

class Camera_Detail extends StatefulWidget {
  final CameraDescription camera;
  const Camera_Detail({
    Key key,
    @required this.camera,
  }) : super(key: key);

  @override
  Camera_DetailState createState() => Camera_DetailState();
}

class Camera_DetailState extends State<Camera_Detail> {
  // Add two variables to the state class to store the CameraController and
  // the Future.

  launchURL(url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  String _text;
  checkURL(url) async {
    if (await canLaunch(url)) {
      _text = 'Browse URL';
    } else {
      _text = 'Invalid URL';
    }
  }

  _insertURL(rawValue) async {
    bool _trueorFalse = true;
    print('lol2');
    await DatabaseProvider.db.getUrls().then((urlList) {
      print(urlList.length);
      try {
        for (var i = 0; i <= urlList.length; i++) {
          print('lol1');
          if (urlList[i].name == rawValue) {
            print('lol');
            _trueorFalse = false;
          }
        }
      } catch (e) {
        print(e);
      }
      if (_trueorFalse) {
        URL url = URL(name: rawValue);
        DatabaseProvider.db.insert(url);
      }
    });
  }

  _callurllist(rawValue) {
    checkURL(rawValue);
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
                child: Text(rawValue,
                    overflow: TextOverflow.ellipsis,
                    style:
                        TextStyle(fontSize: 20, fontWeight: FontWeight.normal),
                    maxLines: 1,
                    softWrap: true),
              ),
              PopupMenuButton<int>(
                onSelected: (value) {
                  if (value == 1 && _text == 'Browse URL') {
                    launchURL(rawValue);
                  } else if (value == 2) {
                    _insertURL(rawValue);
                  }
                },
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 1,
                    child: Text(_text),
                  ),
                  PopupMenuItem(
                    value: 2,
                    child: Text("Save"),
                  ),
                ],
              ),
            ],
          )),
    );
  }

  CameraController _controller;
  Future<void> _initializeControllerFuture;

  @override
  void initState() {
    super.initState();
    // To display the current output from the camera,
    // create a CameraController.
    _controller = CameraController(
      // Get a specific camera from the list of available cameras.
      widget.camera,
      // Define the resolution to use.
      ResolutionPreset.medium,
    );

    // Next, initialize the controller. This returns a Future.
    _initializeControllerFuture = _controller.initialize();
  }

  @override
  void dispose() {
    // Dispose of the controller when the widget is disposed.
    _controller.dispose();
    super.dispose();
  }

  Timer _timer;
  bool _starter;
  Icon iconButton = Icon(
    Icons.photo_camera,
    color: Color(0xFF333333),
  );
  _startTimer() {
    try {
      _starter = _timer.isActive;
    } on NoSuchMethodError {
      _starter = false;
    }
    if (_starter) {
      _timer.cancel();
      setState(() {
        iconButton = Icon(
          Icons.photo_camera,
          color: Color(0xFF333333),
        );
      });
    } else {
      setState(() {
        iconButton = Icon(
          Icons.close,
          color: Color(0xFF333333),
        );
      });

      _timer = Timer.periodic(Duration(milliseconds: 1500), (timer) {
        qrscanner();
      });
    }
  }

  qrscanner() async {
    try {
      // Ensure that the camera is initialized.
      await _initializeControllerFuture;

      // Construct the path where the image should be saved using the path
      // package.
      var path = join(
        // Store the picture in the temp directory.
        // Find the temp directory using the `path_provider` plugin.
        (await getExternalStorageDirectory()).path,
        'lolwenkang${DateTime.now()}.png',
      );
      String rawValue;
      List<Widget> urlList = [];
      // Attempt to take a picture and log where it's been saved.
      final BarcodeDetector barcodeDetector =
          FirebaseVision.instance.barcodeDetector();
      await _controller.takePicture(path);
      FirebaseVisionImage visionImage =
          FirebaseVisionImage.fromFile(File(path));
      final List<Barcode> barcodes =
          await barcodeDetector.detectInImage(visionImage);
      for (Barcode barcode in barcodes) {
        rawValue = barcode.rawValue;
        if (rawValue.indexOf('errorCode') == -1) {
          urlList.add(_callurllist(rawValue));
        }
        print(rawValue);
      }
      barcodeDetector.close();
      final dir = Directory(path);
      dir.deleteSync(recursive: true);
      if (urlList.isNotEmpty) {
        setState(() {
          iconButton = Icon(
            Icons.photo_camera,
            color: Color(0xFF333333),
          );
        });
        _timer.cancel();
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => Url_List(urlList),
          ),
        );
      }
    } catch (e) {
      // If an error occurs, log the error to the console.
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            // If the Future is complete, display the preview.
            return CameraPreview(_controller);
          } else {
            // Otherwise, display a loading indicator.
            return Center(child: CircularProgressIndicator());
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Color(0xFFd6edfc),
        child: iconButton,
        onPressed: () {
          _startTimer();
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
