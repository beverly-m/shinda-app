import 'package:flutter/material.dart';
import 'package:shinda_app/constants/text_syles.dart';

class AppLinearProgressIndicator extends StatelessWidget {
  const AppLinearProgressIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return LinearProgressIndicator(
      color: primary,
      borderRadius: BorderRadius.circular(8.0),
    );
  }
}
