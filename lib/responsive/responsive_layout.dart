import 'dart:developer';

import 'package:flutter/material.dart'
    show BuildContext, LayoutBuilder, MediaQuery, StatelessWidget, Widget;

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
      if (constraints.maxWidth < 850) {
        log('is mobile');
        return mobileScaffold;
      } else if (constraints.maxWidth < 1100) {
        log('is tablet');
        return tabletScaffold;
      } else {
        log('is desktop');
        return desktopScaffold;
      }
    });
  }
}

class Responsive {
  static bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < 850;

  static bool isTablet(BuildContext context) =>
      MediaQuery.of(context).size.width < 1100 &&
      MediaQuery.of(context).size.width >= 850;

  static bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= 1100;
}
