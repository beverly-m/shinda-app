import 'package:flutter/material.dart';
import 'package:shinda_app/components/drawer_item.dart' show DrawerItem;
import 'package:shinda_app/components/show_log_out_dialog.dart'
    show showLogOutDialog;
import 'package:shinda_app/components/snackbar.dart';
import 'package:shinda_app/constants/drawer_items.dart' show drawerItems;
import 'package:shinda_app/constants/drawer_views.dart'
    show drawerViewsMobileTablet;
import 'package:shinda_app/constants/routes.dart' show loginRoute;
import 'package:shinda_app/constants/text_syles.dart' show primary;
import 'package:shinda_app/services/auth/auth_exceptions.dart'
    show GenericAuthException, UserNotLoggedInAuthException;
import 'package:shinda_app/services/auth/auth_service.dart' show AuthService;
import 'package:shinda_app/views/dashboard/new_transaction_view.dart'
    show NewTransactionView;

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
      appBar: AppBar(
        scrolledUnderElevation: 0.0,
        elevation: 0.0,
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
        backgroundColor: Colors.white,
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
      setState(() {
        _selectedIndex = index;
      });
    } else {
      final isLogout = await showLogOutDialog(context);
      if (isLogout) {
        try {
          await AuthService.supabase().logOut();
          if (mounted) {
            Navigator.of(context)
                .pushNamedAndRemoveUntil(loginRoute, (_) => false);
          }
        } on UserNotLoggedInAuthException {
          if (mounted) {
            Navigator.of(context)
                .pushNamedAndRemoveUntil(loginRoute, (_) => false);
          }
        } on GenericAuthException {
          SnackBarService.showSnackBar(
              content: "An error occurred. Try again.");
        } catch (_) {
          SnackBarService.showSnackBar(
              content: "An error occurred. Try again.");
        }
      }
    }
  }
}
