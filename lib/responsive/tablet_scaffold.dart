import 'package:flutter/material.dart';
import 'package:shinda_app/components/dashboard.dart';

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
      drawer: dashboardDrawer,
    );
  }
}
