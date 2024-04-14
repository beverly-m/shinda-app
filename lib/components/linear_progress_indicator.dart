import 'package:flutter/material.dart';
import 'package:shinda_app/constants/text_syles.dart' show primary;

class AppLinearProgressIndicator extends StatelessWidget {
  const AppLinearProgressIndicator({super.key, this.color = primary});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 2.0,
      child: LinearProgressIndicator(
        color: color,
        borderRadius: BorderRadius.circular(8.0),
      ),
    );
  }
}
