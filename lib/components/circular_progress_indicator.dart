import 'package:flutter/material.dart';
import 'package:shinda_app/constants/text_syles.dart';

class AppCircularProgressIndicator extends StatelessWidget {
  const AppCircularProgressIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
              child: CircularProgressIndicator(
                color: primary,
                strokeWidth: 2.0,
              ),
            );
  }
}