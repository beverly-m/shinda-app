import 'package:flutter/material.dart';
import 'package:shinda_app/components/dashboard.dart';

class DesktopScaffold extends StatefulWidget {
  const DesktopScaffold({super.key});

  @override
  State<DesktopScaffold> createState() => _DesktopScaffoldState();
}

class _DesktopScaffoldState extends State<DesktopScaffold> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: dashboardAppbar,
      // drawer: const DashboardDrawer(),
      body: const Row(
        children: [DashboardDrawer()],
      ),
    );
  }
}
