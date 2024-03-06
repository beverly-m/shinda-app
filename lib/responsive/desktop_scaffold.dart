import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:shinda_app/constants/drawer_views.dart';
import 'package:shinda_app/constants/navigation_rail_items.dart';
import 'package:shinda_app/constants/routes.dart';
import 'package:shinda_app/constants/text_syles.dart';
import 'package:shinda_app/services/auth/auth_exceptions.dart';
import 'package:shinda_app/services/auth/auth_service.dart';
import 'package:shinda_app/services/auth/auth_user.dart';
import 'package:shinda_app/utilities/show_error_dialog.dart';
import 'package:shinda_app/views/dashboard/home_view.dart';

class DesktopScaffold extends StatefulWidget {
  const DesktopScaffold({super.key});

  @override
  State<DesktopScaffold> createState() => _DesktopScaffoldState();
}

class _DesktopScaffoldState extends State<DesktopScaffold> {
  int _selectedIndex = 0;
  bool _isLoading = false;
  AuthUser? _currentUser;

  @override
  void initState() {
    super.initState();

    _getUser();
  }

  void _getUser() {
    setState(() {
      _isLoading = true;
    });

    final AuthUser? currentUser = AuthService.supabase().currentUser;

    setState(() {
      _currentUser = currentUser;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: MediaQuery.of(context).size.height,
            decoration: const BoxDecoration(
              border: Border(
                right: BorderSide(
                  color: surface3,
                ),
              ),
            ),
            child: SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                    minHeight: MediaQuery.of(context).size.height),
                child: IntrinsicHeight(
                  child: NavigationRail(
                    indicatorColor: surface3,
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
                ),
              ),
            ),
          ),
          Expanded(
              child: Column(
            children: [
              Container(
                decoration: const BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: surface3,
                    ),
                  ),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 32.0,
                  vertical: 12.0,
                ),
                child: Row(
                  children: [
                    InkWell(
                      onTap: () {},
                      borderRadius: BorderRadius.circular(8.0),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: 4.0,
                          horizontal: 8.0,
                        ).copyWith(left: 12.0),
                        decoration: BoxDecoration(
                          color: surface1,
                          border: const Border.fromBorderSide(
                            BorderSide(color: surface3),
                          ),
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        child: const Row(
                          children: [
                            Text(
                              "Example's workspace",
                              style: body2,
                            ),
                            SizedBox(width: 8.0),
                            Column(
                              children: [
                                Icon(
                                  Icons.keyboard_arrow_up_outlined,
                                  size: 16.0,
                                ),
                                Icon(
                                  Icons.keyboard_arrow_down_outlined,
                                  size: 16.0,
                                ),
                              ],
                            )
                          ],
                        ),
                      ),
                    ),
                    const Expanded(child: SizedBox()),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: 4.0,
                        horizontal: 8.0,
                      ).copyWith(left: 12.0),
                      decoration: BoxDecoration(
                        border: const Border.fromBorderSide(
                          BorderSide(color: surface3),
                        ),
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: Row(
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _isLoading
                                    ? "Jane Doe"
                                    : _currentUser!.fullName!,
                                style: subtitle2,
                              ),
                              Text(
                                _isLoading
                                    ? "example@gmail.com"
                                    : _currentUser!.email!,
                                style: body2,
                              ),
                            ],
                          ),
                          const SizedBox(width: 8.0),
                          const Icon(
                            Icons.account_circle,
                            size: 32,
                            color: Colors.black54,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: SizedBox(child: drawerViews[_selectedIndex]),
                ),
              ),
            ],
          )),
        ],
      ),
    );
  }
}
