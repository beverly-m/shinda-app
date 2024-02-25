import 'package:flutter/material.dart';
import 'package:shinda_app/components/dashboard_drawer_desktop.dart';
import 'package:shinda_app/components/dashboard_drawer_mobile_tablet.dart';

class MobileScaffold extends StatefulWidget {
  const MobileScaffold({super.key});

  @override
  State<MobileScaffold> createState() => _MobileScaffoldState();
}

class _MobileScaffoldState extends State<MobileScaffold> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: dashboardAppbar,
      drawer: const DashboardDrawerMobileTablet(),
    );
  }
}
