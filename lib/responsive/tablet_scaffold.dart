import 'package:flutter/material.dart';
import 'package:shinda_app/components/drawer_item.dart';
import 'package:shinda_app/components/show_log_out_dialog.dart';
import 'package:shinda_app/constants/drawer_items.dart';
import 'package:shinda_app/constants/drawer_views.dart';
import 'package:shinda_app/constants/routes.dart';
import 'package:shinda_app/constants/text_syles.dart';
import 'package:shinda_app/services/auth/auth_exceptions.dart';
import 'package:shinda_app/services/auth/auth_service.dart';
import 'package:shinda_app/utilities/show_error_dialog.dart';
import 'package:shinda_app/views/dashboard/new_transaction_view.dart';

class TabletScaffold extends StatefulWidget {
  const TabletScaffold({super.key});

  @override
  State<TabletScaffold> createState() => _TabletScaffoldState();
}

class _TabletScaffoldState extends State<TabletScaffold> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final safeArea =
        EdgeInsets.only(top: MediaQuery.of(context).viewPadding.top);
    return Scaffold(
      appBar: AppBar(
        scrolledUnderElevation: 0.0,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: FilledButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (BuildContext context) =>
                        const NewTransactionView(),
                  ),
                );
              },
              style: FilledButton.styleFrom(
                backgroundColor: primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              child: const Row(
                children: [
                  Icon(Icons.add),
                  SizedBox(width: 4.0),
                  Text(
                    "New Sale",
                    style: TextStyle(fontSize: 16),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
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
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: drawerViewsMobileTablet[_selectedIndex],
        ),
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

  void _selectItem({required int index}) async {
    Navigator.pop(context);
    if (index != (drawerViewsMobileTablet.length)) {
      if (!mounted) return;
      setState(() {
        _selectedIndex = index;
      });
    } else {
      final isLogout = await showLogOutDialog(context);
      if (isLogout) {
        try {
          await AuthService.supabase().logOut();
          if (mounted) {
            Navigator.of(context).pushNamedAndRemoveUntil(
              loginRoute,
              (_) => false,
            );
          }
        } on UserNotLoggedInAuthException {
          if (mounted) {
            Navigator.of(context).pushNamedAndRemoveUntil(
              loginRoute,
              (_) => false,
            );
          }
        } on GenericAuthException {
          if (mounted) {
            await showErrorDialog(
              context,
              "An error occurred. Try again.",
            );
          }
        } catch (_) {
          if (mounted) {
            await showErrorDialog(
              context,
              "An error occurred. Try again.",
            );
          }
        }
      }
    }
  }
}
