import 'package:flutter/material.dart';
import 'package:shinda_app/constants/text_syles.dart';

class OutlinedAppButton extends StatelessWidget {
  final void Function() onPressed;
  final String labelText;

  const OutlinedAppButton(
      {super.key, required this.onPressed, required this.labelText});

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      style: OutlinedButton.styleFrom(
          foregroundColor: primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
          padding: const EdgeInsets.symmetric(
            vertical: 6.0,
            horizontal: 24.0,
          )),
      onPressed: onPressed,
      child: Text(
        labelText,
        style: secondaryButtonStyle,
      ),
    );
  }
}
