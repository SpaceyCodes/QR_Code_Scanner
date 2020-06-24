import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'dart:async';
import 'dart:io';
import 'url_list.dart';
import 'package:path/path.dart' show join;
import 'package:path_provider/path_provider.dart';
import 'package:firebase_ml_vision/firebase_ml_vision.dart';
import 'package:url_launcher/url_launcher.dart';

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

  _callurllist(rawValue) {
    return Padding(
      padding: EdgeInsets.fromLTRB(0, 10, 0, 0),
      child: Container(
          width: MediaQuery.of(context).size.width * 0.95,
          color: Colors.deepPurpleAccent,
          child: FlatButton(
            child: Text(
              rawValue,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.normal),
            ),
            onPressed: () {
              print(rawValue);
              launchURL(rawValue);
            },
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
        child: Icon(Icons.photo_camera),
        onPressed: () async {
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
            print(path);
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
              print(rawValue.indexOf('errorCode'));
              BarcodeValueType valueType = barcode.valueType;
              print(rawValue);
            }
            barcodeDetector.close();
            final dir = Directory(path);
            dir.deleteSync(recursive: true);
            if (urlList.isEmpty) {
              showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (_) => AlertDialog(
                        title: Text("No QR Code detected."),
                        actions: <Widget>[
                          FlatButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: Text('retry'))
                        ],
                      ));
            } else {
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
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
