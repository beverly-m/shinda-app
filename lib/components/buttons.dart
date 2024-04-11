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
            vertical: 12.0,
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

class FilledAppButton extends StatelessWidget {
  final void Function() onPressed;
  final String labelText;

  const FilledAppButton(
      {super.key, required this.onPressed, required this.labelText});

  @override
  Widget build(BuildContext context) {
    return FilledButton(
      onPressed: onPressed,
      style: FilledButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
        backgroundColor: primary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
      ),
      child: Text(
        labelText,
        style: primaryButtonStyle,
      ),
    );
  }
}
