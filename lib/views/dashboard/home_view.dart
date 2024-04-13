import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:shinda_app/responsive/desktop_scaffold.dart'
    show DesktopScaffold;
import 'package:shinda_app/responsive/mobile_scaffold.dart' show MobileScaffold;
import 'package:shinda_app/responsive/responsive_layout.dart'
    show ResponsiveLayout;
import 'package:shinda_app/responsive/tablet_scaffold.dart' show TabletScaffold;
import 'package:shinda_app/services/auth/auth_service.dart' show AuthService;

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  final user = AuthService.supabase().currentUser;

  @override
  Widget build(BuildContext context) {
    return const ResponsiveLayout(
      mobileScaffold: MobileScaffold(),
      tabletScaffold: TabletScaffold(),
      desktopScaffold: DesktopScaffold(),
    );
  }
}