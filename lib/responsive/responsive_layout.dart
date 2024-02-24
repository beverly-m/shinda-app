import 'package:flutter/material.dart';

class ResponsiveLayout extends StatelessWidget {
  const ResponsiveLayout({
    super.key,
    required this.mobileScaffold,
    required this.tabletScaffold,
    required this.desktopScaffold,
  });

  final Widget mobileScaffold;
  final Widget tabletScaffold;
  final Widget desktopScaffold;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      if (constraints.maxWidth < 500) {
        return mobileScaffold;
      } else if (constraints.maxWidth < 800) {
        return tabletScaffold;
      } else {
        return desktopScaffold;
      }
    });
  }
}
