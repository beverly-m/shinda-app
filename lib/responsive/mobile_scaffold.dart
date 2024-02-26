import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:shinda_app/components/drawer_item.dart';
import 'package:shinda_app/constants/drawer_items.dart';
import 'package:shinda_app/constants/drawer_views.dart';

class MobileScaffold extends StatefulWidget {
  const MobileScaffold({super.key});

  @override
  State<MobileScaffold> createState() => _MobileScaffoldState();
}

class _MobileScaffoldState extends State<MobileScaffold> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final safeArea =
        EdgeInsets.only(top: MediaQuery.of(context).viewPadding.top);
    return Scaffold(
      appBar: AppBar(),
      drawer: Drawer(
        child: ListView(
          children: [
            const SizedBox(height: 16.0),
            Container(
              width: double.infinity,
              padding: safeArea,
              child: buildHeader(),
            ),
            buildDrawerItems(items: drawerItems),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: drawerViews[_selectedIndex],
      ),
    );
  }

  Widget buildDrawerItems({
    required List<DrawerItem> items,
  }) =>
      ListView.separated(
        separatorBuilder: (context, index) => const SizedBox(height: 4.0),
        itemBuilder: (context, index) {
          final item = items[index];

          return buildMenuItem(
            text: item.title,
            icon: item.icon,
            onClicked: () => _selectItem(index: index),
          );
        },
        shrinkWrap: true,
        primary: false,
        itemCount: items.length,
      );

  Widget buildMenuItem({
    required String text,
    required IconData icon,
    VoidCallback? onClicked,
  }) {
    return Material(
      color: Colors.transparent,
      child: ListTile(
        leading: Icon(icon),
        title: Text(
          text,
          style: const TextStyle(letterSpacing: 1.5),
        ),
        onTap: onClicked,
      ),
    );
  }

  Widget buildHeader() => const Padding(
        padding: EdgeInsets.symmetric(
          horizontal: 20.0,
          vertical: 8.0,
        ),
        child: Column(
          children: [
            Row(
              children: [
                Icon(
                  Icons.calculate_outlined,
                  size: 24.0,
                  color: Colors.black54,
                ),
                SizedBox(width: 16.0),
                Padding(
                  padding: EdgeInsets.only(top: 1.0),
                  child: Text(
                    "SHINDA",
                    style: TextStyle(
                      color: Colors.black54,
                      fontSize: 16,
                      letterSpacing: 1.5,
                    ),
                  ),
                )
              ],
            ),
            SizedBox(height: 16.0),
            Divider(thickness: 0.5),
          ],
        ),
      );

  void _selectItem({required int index}) {
    Navigator.pop(context);
    if (index != (drawerViews.length)) {
      setState(() {
        _selectedIndex = index;
      });
    } else {
      log("Logout");
    }
  }
}
