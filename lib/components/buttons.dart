import 'package:flutter/material.dart';
import 'package:shinda_app/constants/text_syles.dart'
    show
        neutral3,
        neutral4,
        primary,
        primaryButtonStyle,
        secondaryButtonStyle,
        subtitle2;
import 'package:shinda_app/responsive/responsive_layout.dart' show Responsive;

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
  final Color backgroundColor;

  const FilledAppButton(
      {super.key,
      required this.onPressed,
      required this.labelText,
      this.backgroundColor = primary});

  @override
  Widget build(BuildContext context) {
    return FilledButton(
      onPressed: onPressed,
      style: FilledButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
        backgroundColor: backgroundColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
      ),
      child: Text(
        labelText,
        style: primaryButtonStyle,
      ),
    );
  }
}

class PlusMinusButtons extends StatelessWidget {
  final VoidCallback deleteQuantity;
  final VoidCallback addQuantity;
  final String text;
  const PlusMinusButtons(
      {Key? key,
      required this.addQuantity,
      required this.deleteQuantity,
      required this.text})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: neutral3),
        borderRadius: BorderRadius.circular(8.0),
      ),
      padding: Responsive.isMobile(context)
          ? const EdgeInsets.symmetric(vertical: 4.0)
          : const EdgeInsets.all(8.0),
      child: Row(
        children: [
          IconButton(
            visualDensity: VisualDensity.compact,
            onPressed: addQuantity,
            icon: const Icon(Icons.add),
          ),
          SizedBox(width: Responsive.isMobile(context) ? 0.0 : 12.0),
          Container(
            width: Responsive.isMobile(context) ? 32.0 : 56.0,
            height: 40.0,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              border: Responsive.isMobile(context)
                  ? const Border()
                  : Border.all(color: neutral4),
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: Text(
              text,
              style: subtitle2,
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(width: Responsive.isMobile(context) ? 0.0 : 12.0),
          IconButton(
            onPressed: deleteQuantity,
            visualDensity: VisualDensity.compact,
            icon: const Icon(Icons.remove),
          ),
        ],
      ),
    );
  }
}

class TextAppButton extends StatelessWidget {
  const TextAppButton({
    super.key,
    required this.onPressed,
    required this.labelText,
  });
  final void Function() onPressed;
  final String labelText;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
        padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 36.0),
      ),
      child: Text(
        labelText,
        style: secondaryButtonStyle,
      ),
    );
  }
}
