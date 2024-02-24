import 'package:flutter/material.dart';
import 'package:shinda_app/components/dashboard.dart';

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
      drawer: dashboardDrawer,
    );
  }
}
