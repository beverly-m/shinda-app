import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shinda_app/components/drawer_item.dart';
import 'package:shinda_app/constants/drawer_items.dart';
import 'package:shinda_app/constants/drawer_views.dart';
import 'package:shinda_app/utilities/navigation_provider.dart';

class DesktopScaffold extends StatefulWidget {
  const DesktopScaffold({super.key});

  @override
  State<DesktopScaffold> createState() => _DesktopScaffoldState();
}

class _DesktopScaffoldState extends State<DesktopScaffold> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<NavigationProvider>(context);
    final isCollapsed = provider.isCollapsed;
    final safeArea =
        EdgeInsets.only(top: MediaQuery.of(context).viewPadding.top);
    return Scaffold(
      appBar: AppBar(),
      body: Row(
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: Drawer(
              width: isCollapsed
                  ? MediaQuery.of(context).size.width * 0.065
                  : null,
              child: Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: ListView(
                  children: [
                    const SizedBox(height: 16.0),
                    Row(
                      children: [
                        isCollapsed
                            ? const SizedBox(width: 8.0)
                            : const Spacer(),
                        buildCollapseIcon(
                          context: context,
                          isCollapsed: isCollapsed,
                        ),
                        isCollapsed
                            ? const SizedBox()
                            : const SizedBox(width: 8.0),
                      ],
                    ),
                    const SizedBox(height: 8.0),
                    Container(
                      width: double.infinity,
                      padding: safeArea,
                      child: buildHeader(isCollapsed: isCollapsed),
                    ),
                    buildDrawerItems(
                      items: drawerItems,
                      isCollapsed: isCollapsed,
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(child: drawerViews[_selectedIndex]),
        ],
      ),
    );
  }

  Widget buildDrawerItems({
    required List<DrawerItem> items,
    required bool isCollapsed,
  }) =>
      ListView.separated(
        separatorBuilder: (context, index) => const SizedBox(height: 4.0),
        itemBuilder: (context, index) {
          final item = items[index];

          return buildMenuItem(
            isCollapsed: isCollapsed,
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
    required bool isCollapsed,
    required String text,
    required IconData icon,
    VoidCallback? onClicked,
  }) {
    return Material(
      color: Colors.transparent,
      child: isCollapsed
          ? Padding(
              padding: const EdgeInsets.only(left: 4.0),
              child: ListTile(
                leading: Icon(icon),
                onTap: onClicked,
              ),
            )
          : ListTile(
              leading: Icon(icon),
              title: Text(
                text,
                style: const TextStyle(
                  letterSpacing: 1.5,
                  fontSize: 15.0,
                ),
              ),
              onTap: onClicked,
            ),
    );
  }

  Widget buildCollapseIcon({
    required BuildContext context,
    required bool isCollapsed,
  }) {
    final icon = isCollapsed ? Icons.menu : Icons.arrow_back_ios;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(24.0),
        onTap: () {
          final provider =
              Provider.of<NavigationProvider>(context, listen: false);

          provider.toggleIsCollapsed();
        },
        child: Container(
          padding: const EdgeInsets.all(12.0),
          child: Icon(
            icon,
            size: 22.0,
          ),
        ),
      ),
    );
  }

  Widget buildHeader({required bool isCollapsed}) => isCollapsed
      ? Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 20.0,
            vertical: 8.0,
          ).copyWith(left: 6.0),
          child: const Column(
            children: [
              Icon(
                Icons.calculate_outlined,
                size: 24.0,
                color: Colors.black54,
              ),
              SizedBox(height: 16.0),
              Divider(thickness: 0.5),
            ],
          ),
        )
      : const Padding(
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
