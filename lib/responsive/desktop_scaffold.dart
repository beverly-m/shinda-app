import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:shinda_app/constants/drawer_views.dart';
import 'package:shinda_app/constants/navigation_rail_items.dart';
import 'package:shinda_app/constants/routes.dart';
import 'package:shinda_app/services/auth/auth_exceptions.dart';
import 'package:shinda_app/services/auth/auth_service.dart';
import 'package:shinda_app/utilities/show_error_dialog.dart';
import 'package:shinda_app/views/dashboard/home_view.dart';

class DesktopScaffold extends StatefulWidget {
  const DesktopScaffold({super.key});

  @override
  State<DesktopScaffold> createState() => _DesktopScaffoldState();
}

class _DesktopScaffoldState extends State<DesktopScaffold> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   elevation: 0.0,
      //   automaticallyImplyLeading: false,
      //   backgroundColor: Colors.white,
      // ),
      body: SafeArea(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            NavigationRail(
              backgroundColor: const Color.fromRGBO(241, 249, 249, 1),
              indicatorColor: const Color.fromRGBO(29, 233, 182, 1),
              selectedIndex: _selectedIndex,
              groupAlignment: 0.0,
              onDestinationSelected: (int index) async {
                if (index != (navigationRailItems.length - 1)) {
                  setState(() {
                    _selectedIndex = index;
                  });
                } else {
                  log("Logout");
                  final isLogout = await showLogOutDialog(context);
                  if (isLogout) {
                    try {
                      await AuthService.supabase().logOut();
                      if (context.mounted) {
                        Navigator.of(context).pushNamedAndRemoveUntil(
                          loginRoute,
                          (_) => false,
                        );
                      }
                    } on UserNotLoggedInAuthException {
                      if (context.mounted) {
                        Navigator.of(context).pushNamedAndRemoveUntil(
                          loginRoute,
                          (_) => false,
                        );
                      }
                    } on GenericAuthException {
                      if (context.mounted) {
                        await showErrorDialog(
                          context,
                          "An error occurred. Try again.",
                        );
                      }
                    } catch (_) {
                      if (context.mounted) {
                        await showErrorDialog(
                          context,
                          "An error occurred. Try again.",
                        );
                      }
                    }
                  }
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
