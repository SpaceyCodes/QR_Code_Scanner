import 'package:flutter/material.dart';
import 'camera_detail.dart';

class Scanner extends StatelessWidget {
  var _temp;
  Scanner(this._temp);
  @override
  Widget build(BuildContext context) {
    return Camera_Detail(
      camera: _temp,
    );
  }
}
