import 'package:flutter/material.dart';
import 'package:shinda_app/components/dashboard_drawer_desktop.dart';
import 'package:shinda_app/components/dashboard_drawer_mobile_tablet.dart';

class TabletScaffold extends StatefulWidget {
  const TabletScaffold({super.key});

  @override
  State<TabletScaffold> createState() => _TabletScaffoldState();
}

class _TabletScaffoldState extends State<TabletScaffold> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: dashboardAppbar,
      drawer: const DashboardDrawerMobileTablet(),
    );
  }
}
