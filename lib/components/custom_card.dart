import 'package:flutter/material.dart';
import 'package:shinda_app/constants/text_syles.dart' show surface1, surface3;

class CustomCard extends StatelessWidget {
  const CustomCard({
    super.key,
    required this.child,
    this.color,
    this.padding,
  });

  final Widget child;
  final Color? color;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(color: surface3),
        color: color ?? surface1,
      ),
      child: Padding(
        padding: padding ?? const EdgeInsets.all(8.0),
        child: child,
      ),
    );
  }
}
