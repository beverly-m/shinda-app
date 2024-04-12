import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:shinda_app/components/buttons.dart';
import 'package:shinda_app/components/dashboard_widget.dart';
import 'package:shinda_app/components/sales_details_card.dart';
import 'package:shinda_app/components/side_dashboard_widget.dart';
import 'package:shinda_app/components/textfields.dart';
import 'package:shinda_app/constants/text_syles.dart';
import 'package:shinda_app/services/auth/auth_service.dart';
import 'package:shinda_app/services/auth/auth_user.dart';
import 'package:shinda_app/services/workspace/workspace_exceptions.dart';
import 'package:shinda_app/services/workspace/workspace_service.dart';
import 'package:shinda_app/utilities/get_workspace.dart';
import 'package:shinda_app/utilities/show_error_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shinda_app/responsive/responsive_layout.dart';

class DashboardView extends StatefulWidget {
  const DashboardView({super.key});

  @override
  State<DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends State<DashboardView> {
  final GlobalKey<FormState> _formKey = GlobalKey();

  late final TextEditingController _workspaceName;

  List<Map<String, dynamic>>? _workspaceData;

  bool _isLoading = false;
  AuthUser? _currentUser;

  String? _currentWorkspace;
  String? _currentWorkspaceName;

  @override
  void initState() {
    super.initState();

    _workspaceName = TextEditingController();
    _getWorkspaceData();
  }

  @override
  void dispose() {
    _workspaceName.dispose();

    super.dispose();
  }

  void _getWorkspaceData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final currentUser = AuthService.supabase().currentUser;

      final List<Map<String, dynamic>> workspaces =
          await WorkspaceService().getWorkspaceData(
        userId: currentUser!.id,
      );

      final String? currentWorkspace = await getCurrentWorkspaceId();
      final String? currentWorkspaceName = await getCurrentWorkspaceName();
      final String? workspaceMember = await getWorkspaceMember();

      setState(() {
        _workspaceData = workspaces;
        _currentUser = currentUser;
      });

      if (currentWorkspace != null &&
          currentWorkspaceName != null &&
          workspaceMember != null) {
        if (workspaceMember == _currentUser!.id) {
          setState(() {
            _currentWorkspace = currentWorkspace;
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
          _currentWorkspace = _workspaceData![0]['workspace_id'];
          _currentWorkspaceName = _workspaceData![0]['name'];
          _isLoading = false;
        });
      }
    } on GenericWorkspaceException {
      log("Error occurred");
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      log(e.toString());
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _createWorkspace(BuildContext context) async {
    final isValid = _formKey.currentState?.validate();
    final workspaceName = _workspaceName.text.trim();

    if (isValid != null && isValid) {
      _workspaceName.clear();

      Navigator.of(context).pop();

      setState(() {
        _isLoading = true;
      });

      try {
        await WorkspaceService().createWorkspace(
          workspaceName: workspaceName,
          creatorId: AuthService.supabase().currentUser!.id,
        );
        log("Workspace created!");

        _getWorkspaceData();
        setState(() {
          _isLoading = false;
        });
      } on GenericWorkspaceException {
        setState(() {
          _isLoading = false;
        });
        if (mounted) {
          showErrorDialog(context, "Some error occurred");
        }
      } catch (e) {
        setState(() {
          _isLoading = false;
        });
        if (mounted) {
          showErrorDialog(context, e.toString());
        }
      }
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
      _currentWorkspace = workspace;
      _currentWorkspaceName = workspaceName;
    });
  }

  void _showWorkspaceMenu(BuildContext context) async {
    final AuthUser? currentUser = AuthService.supabase().currentUser;
    await showMenu(
      context: context,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        side: const BorderSide(color: surface3),
        borderRadius: BorderRadius.circular(8.0),
      ),
      surfaceTintColor: Colors.white,
      position: const RelativeRect.fromLTRB(300, 150, 45, 225),
      items: List.generate(
        _workspaceData!.length,
        (index) => PopupMenuItem(
          value: index,
          child: Text(
            _workspaceData![index]['workspace']['name'],
            style: body2,
          ),
        ),
      ),
      elevation: 2.0,
    ).then((value) {
      if (value != null) {
        log(value.toString());
        _selectWorkspace(
          workspace: _workspaceData![value]['workspace_id'],
          workspaceName: _workspaceData![value]['workspace']['name'],
          workspaceMember: currentUser!.id,
        );
        _getWorkspaceData();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool isDesktop = Responsive.isDesktop(context);

    return _isLoading
        ? const Center(
            child: Padding(
              padding: EdgeInsets.all(48.0),
              child: CircularProgressIndicator(
                color: Color.fromRGBO(0, 121, 107, 1),
              ),
            ),
          )
        : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Text(
                    "Dashboard",
                    style: dashboardHeadline,
                  ),
                  const Expanded(child: SizedBox()),
                  _currentWorkspaceName != null &&
                          _workspaceData != null &&
                          _workspaceData!.isNotEmpty &&
                          Responsive.isDesktop(context)
                      ? Row(
                          children: [
                            OutlinedAppButton(
                              onPressed: () async {
                                await _showAddWorkspaceDialog(context);
                              },
                              labelText: 'New Workspace',
                            ),
                            const SizedBox(width: 8.0),
                            InkWell(
                              onTap: () {
                                _showWorkspaceMenu(context);
                              },
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
                                child: Row(
                                  children: [
                                    Text(
                                      "$_currentWorkspaceName's Workspace",
                                      style: body1,
                                    ),
                                    const SizedBox(width: 8.0),
                                    Icon(
                                      Icons.edit_outlined,
                                      color: primary.withOpacity(0.7),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        )
                      : const SizedBox(),
                ],
              ),
              if (_currentWorkspaceName != null &&
                  _workspaceData != null &&
                  _workspaceData!.isNotEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8.0),
                  child: Text(
                    'Here is what is happening in your store today.',
                    style: body1,
                  ),
                ),
              const SizedBox(height: 16.0),
              _currentWorkspaceName != null &&
                      _workspaceData != null &&
                      _workspaceData!.isNotEmpty &&
                      !Responsive.isDesktop(context)
                  ? Row(
                      children: [
                        OutlinedAppButton(
                          onPressed: () async {
                            await _showAddWorkspaceDialog(context);
                          },
                          labelText: 'New Workspace',
                        ),
                        const Expanded(child: SizedBox()),
                        InkWell(
                          onTap: () {
                            _showWorkspaceMenu(context);
                          },
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
                            child: Row(
                              children: [
                                Text(
                                  "$_currentWorkspaceName's Workspace",
                                  style: body1,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  softWrap: false,
                                ),
                                const SizedBox(width: 8.0),
                                Icon(
                                  Icons.edit_outlined,
                                  color: primary.withOpacity(0.7),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    )
                  : const SizedBox(),
              if (!Responsive.isDesktop(context)) const SizedBox(height: 16.0),
              if (_workspaceData != null && _workspaceData!.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: SalesDetailsCard(workspaceId: _currentWorkspace!),
                ),
              _workspaceData != null && _workspaceData!.isNotEmpty
                  ? Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 8,
                          child:
                              DashboardWidget(workspaceId: _currentWorkspace!),
                        ),
                        if (isDesktop)
                          const SizedBox(
                            width: 16,
                          ),
                        if (isDesktop)
                          Expanded(
                            flex: 3,
                            child: SideDashboardWidget(
                                workspaceId: _currentWorkspace!),
                          ),
                      ],
                    )
                  : Center(
                      child: Padding(
                        padding: const EdgeInsets.all(48.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.emoji_symbols_outlined,
                              size: 200,
                              color: Color.fromRGBO(219, 240, 239, 1),
                            ),
                            const SizedBox(height: 48.0),
                            const Text(
                              "Create a new workspace to get started!",
                              style: TextStyle(fontSize: 16),
                            ),
                            const SizedBox(height: 48.0),
                            FilledAppButton(
                                onPressed: () async {
                                  await _showAddWorkspaceDialog(context);
                                },
                                labelText: "New workspace"),
                          ],
                        ),
                      ),
                    ),
            ],
          );
  }

  Future<void> _showAddWorkspaceDialog(BuildContext context) {
    final validCharacters = RegExp(r'^[a-zA-Z0-9]+$');
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          surfaceTintColor: const Color.fromRGBO(241, 249, 249, 1),
          shape: OutlineInputBorder(
            borderSide: BorderSide.none,
            borderRadius: BorderRadius.circular(8.0),
          ),
          title: const Text(
            "New workspace",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          content: Form(
            key: _formKey,
            child: NormalTextFormField(
                controller: _workspaceName,
                hintText: 'Enter the workspace name',
                labelText: 'Workspace name',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Workspace name required';
                  } else if (value.length < 3) {
                    return "At least 3 characters";
                  } else if (!validCharacters.hasMatch(value)) {
                    return "Letters & numbers allowed. No spaces.";
                  }
                  return null;
                }),
          ),
          actions: [
            TextAppButton(
                onPressed: () {
                  _workspaceName.clear();
                  Navigator.of(context).pop();
                },
                labelText: "Cancel"),
            FilledAppButton(
              onPressed: () {
                _createWorkspace(context);
              },
              labelText: "Create Workspace",
            ),
          ],
        );
      },
    );
  }

  Future<void> _showSelectWorkspaceDialog(BuildContext context) {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
            backgroundColor: Colors.white,
            surfaceTintColor: const Color.fromRGBO(241, 249, 249, 1),
            shape: OutlineInputBorder(
                borderSide: BorderSide.none,
                borderRadius: BorderRadius.circular(8.0)),
            title: const Column(
              children: [
                Text(
                  "Select Workspace",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(
                  height: 4.0,
                ),
                Divider(
                  height: 0.5,
                  color: Color.fromRGBO(241, 249, 249, 1),
                ),
              ],
            ),
            scrollable: true,
            content: SizedBox(
              width: 200.0,
              height: 150.0,
              child: ListView.builder(
                itemBuilder: (context, index) {
                  return ListTile(
                    hoverColor: const Color.fromRGBO(230, 244, 244, 1),
                    title: Text(_workspaceData![index]["workspace"]['name']),
                    onTap: () {
                      Navigator.of(context).pop();
                      _selectWorkspace(
                        workspace: _workspaceData![index]['workspace_id'],
                        workspaceName: _workspaceData![index]['workspace']
                            ['name'],
                        workspaceMember: _currentUser!.id,
                      );
                    },
                  );
                },
                itemCount: _workspaceData!.length,
                scrollDirection: Axis.vertical,
                shrinkWrap: true,
              ),
            ));
      },
    );
  }
}
