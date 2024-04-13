import 'package:flutter/material.dart' show GlobalKey, ScaffoldMessengerState, SnackBar, Text;

class SnackBarService {
  static final scaffoldKey = GlobalKey<ScaffoldMessengerState>();
  static void showSnackBar({required String content}) {
    scaffoldKey.currentState?.showSnackBar(SnackBar(content: Text(content)));
  }
}
