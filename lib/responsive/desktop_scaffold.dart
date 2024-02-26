import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:shinda_app/constants/drawer_views.dart';
import 'package:shinda_app/constants/navigation_rail_items.dart';

class DesktopScaffold extends StatefulWidget {
  const DesktopScaffold({super.key});

  @override
  State<DesktopScaffold> createState() => _DesktopScaffoldState();
}

class _DesktopScaffoldState extends State<DesktopScaffold> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: Row(
          children: [
            NavigationRail(
              selectedIndex: _selectedIndex,
              groupAlignment: 0.0,
              onDestinationSelected: (int index) {
                if (index != (navigationRailItems.length - 1)) {
                  setState(() {
                    _selectedIndex = index;
                  });
                } else {
                  log("Logout");
                }
              },
              labelType: NavigationRailLabelType.all,
              destinations: navigationRailItems,
            ),
            Expanded(child: drawerViews[_selectedIndex]),
          ],
        ),
      ),
    );
  }
  }
