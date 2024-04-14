import 'package:flutter/material.dart'
    show
        BuildContext,
        Center,
        CircularProgressIndicator,
        StatelessWidget,
        Widget;
import 'package:shinda_app/constants/text_syles.dart' show primary;

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
