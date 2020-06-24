import 'package:flutter/material.dart';
import 'app.dart';
import 'dart:async';
import 'package:camera/camera.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final cameras = await availableCameras();

  final firstCamera = cameras.first;
  runApp(App(firstCamera));
}
