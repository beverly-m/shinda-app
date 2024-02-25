import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shinda_app/components/drawer_item.dart';
import 'package:shinda_app/constants/drawer_items.dart';
import 'package:shinda_app/utilities/navigation_provider.dart';

class DashboardDrawerDesktop extends StatelessWidget {
  const DashboardDrawerDesktop({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<NavigationProvider>(context);
    final isCollapsed = provider.isCollapsed;
    final safeArea =
        EdgeInsets.only(top: MediaQuery.of(context).viewPadding.top);

    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Drawer(
        width: isCollapsed ? MediaQuery.of(context).size.width * 0.065 : null,
        child: Padding(
          padding: const EdgeInsets.only(left: 8.0),
          child: ListView(
            children: [
              const SizedBox(height: 16.0),
              Row(
                children: [
                  isCollapsed ? const SizedBox(width: 8.0) : const Spacer(),
                  buildCollapseIcon(
                    context: context,
                    isCollapsed: isCollapsed,
                  ),
                  isCollapsed ? const SizedBox() : const SizedBox(width: 8.0),
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
    );
  }
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
          onClicked: () {},
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

Drawer dashboardDrawer = Drawer(
  shape: const RoundedRectangleBorder(
    borderRadius: BorderRadius.all(Radius.zero),
  ),
  child: ListView(
    children: const [
      DrawerHeader(
        padding: EdgeInsets.all(0),
        child: Icon(Icons.calculate),
      ),
      ListTile(
        leading: Icon(Icons.home),
        title: Text(
          "DASHBOARD",
          style: TextStyle(letterSpacing: 1.2),
        ),
      ),
      ListTile(
        leading: Icon(Icons.sell),
        title: Text(
          "SALES",
          style: TextStyle(letterSpacing: 1.2),
        ),
      ),
      ListTile(
        leading: Icon(Icons.inventory),
        title: Text(
          "INVENTORY",
          style: TextStyle(letterSpacing: 1.2),
        ),
      ),
      ListTile(
        leading: Icon(Icons.shopping_cart),
        title: Text(
          "PRODUCTS",
          style: TextStyle(letterSpacing: 1.2),
        ),
      ),
      ListTile(
        leading: Icon(Icons.monetization_on),
        title: Text(
          "DEBTORS",
          style: TextStyle(letterSpacing: 1.2),
        ),
      ),
      ListTile(
        leading: Icon(Icons.auto_graph),
        title: Text(
          "REPORTS",
          style: TextStyle(letterSpacing: 1.2),
        ),
      ),
      ListTile(
        leading: Icon(Icons.person),
        title: Text(
          "USERS",
          style: TextStyle(letterSpacing: 1.2),
        ),
      ),
      ListTile(
        leading: Icon(Icons.settings),
        title: Text(
          "SETTINGS",
          style: TextStyle(letterSpacing: 1.2),
        ),
      ),
      ListTile(
        leading: Icon(Icons.logout),
        title: Text(
          "LOGOUT",
          style: TextStyle(letterSpacing: 1.2),
        ),
      ),
    ],
  ),
);

AppBar dashboardAppbar = AppBar();
