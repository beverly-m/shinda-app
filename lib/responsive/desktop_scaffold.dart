import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shinda_app/components/circular_progress_indicator.dart';
import 'package:shinda_app/components/show_log_out_dialog.dart';
import 'package:shinda_app/constants/drawer_views.dart';
import 'package:shinda_app/constants/navigation_rail_items.dart';
import 'package:shinda_app/constants/routes.dart';
import 'package:shinda_app/constants/text_syles.dart';
import 'package:shinda_app/services/auth/auth_exceptions.dart';
import 'package:shinda_app/services/auth/auth_service.dart';
import 'package:shinda_app/services/auth/auth_user.dart';
import 'package:shinda_app/services/workspace/workspace_exceptions.dart';
import 'package:shinda_app/utilities/show_error_dialog.dart';
import 'package:shinda_app/views/dashboard/home_view.dart';
import 'package:shinda_app/services/workspace/workspace_service.dart';
import 'package:shinda_app/utilities/get_workspace.dart';

class DesktopScaffold extends StatefulWidget {
  const DesktopScaffold({super.key});

  @override
  State<DesktopScaffold> createState() => _DesktopScaffoldState();
}

class _DesktopScaffoldState extends State<DesktopScaffold> {
  int _selectedIndex = 1;
  bool _isLoading = false;
  AuthUser? _currentUser;
  List<Map<String, dynamic>>? _workspaceData;
  String? _currentWorkspaceName;

  @override
  void initState() {
    super.initState();
    _getUser();
    _getWorkspaceData();
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

  void _getWorkspaceData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final List<Map<String, dynamic>> workspaces =
          await WorkspaceService().getWorkspaceData(
        userId: AuthService.supabase().currentUser!.id,
      );

      final String? currentWorkspace = await getCurrentWorkspaceId();
      final String? currentWorkspaceName = await getCurrentWorkspaceName();
      final String? workspaceMember = await getWorkspaceMember();

      setState(() {
        _workspaceData = workspaces;
      });

      if (currentWorkspace != null &&
          currentWorkspaceName != null &&
          workspaceMember != null) {
        if (workspaceMember == _currentUser!.id) {
          setState(() {
            _currentWorkspaceName = currentWorkspaceName;
            _isLoading = false;
          });
        }
      } else {
        _selectWorkspace(
          workspace: _workspaceData![0]['workspace_id'],
          workspaceName: _workspaceData![0]['workspace']['name'],
          workspaceMember: _currentUser!.id,
        );
        setState(() {
          _currentWorkspaceName = _workspaceData![0]['name'];
          _isLoading = false;
        });
      }
    } on GenericWorkspaceException {
      log("Error occurred");
      _isLoading = false;
    } catch (e) {
      log(e.toString());
      _isLoading = false;
    }
  }

  void _selectWorkspace({
    required String workspace,
    required String workspaceName,
    required String workspaceMember,
  }) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    await prefs.setString('workspaceId', workspace);
    await prefs.setString('workspaceName', workspaceName);
    await prefs.setString('workspaceMember', workspaceMember);

    setState(() {
      _currentWorkspaceName = workspaceName;
    });
  }

  @override
  Widget build(BuildContext context) {
    return _isLoading
        ? const Center(
            child: Padding(
              padding: EdgeInsets.all(48.0),
              child: AppCircularProgressIndicator(),
            ),
          )
        : Scaffold(
            body: SafeArea(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 1,
                    child: Container(
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
                                  final isLogout =
                                      await showLogOutDialog(context);
                                  if (isLogout) {
                                    try {
                                      await AuthService.supabase().logOut();
                                      if (context.mounted) {
                                        Navigator.of(context)
                                            .pushNamedAndRemoveUntil(
                                          loginRoute,
                                          (_) => false,
                                        );
                                      }
                                    } on UserNotLoggedInAuthException {
                                      if (context.mounted) {
                                        Navigator.of(context)
                                            .pushNamedAndRemoveUntil(
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
                  ),
                  Expanded(
                      flex: 11,
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
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
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
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            _isLoading
                                                ? ""
                                                : _currentUser!.fullName!,
                                            style: subtitle2,
                                          ),
                                          Text(
                                            _isLoading
                                                ? ""
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
                            flex: 11,
                            child: SingleChildScrollView(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 32.0,
                                vertical: 24.0,
                              ),
                              child: SizedBox(
                                  child: drawerViewsDesktop[_selectedIndex]),
                            ),
                          ),
                        ],
                      )),
                ],
              ),
            ),
          );
  }
}
