import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:shinda_app/services/auth/auth_service.dart';
import 'package:shinda_app/services/workspace/workspace_exceptions.dart';
import 'package:shinda_app/services/workspace/workspace_service.dart';
import 'package:shinda_app/utilities/get_workspace.dart';
import 'package:shinda_app/utilities/show_error_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

  String? _currentWorkspace;

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
      final List<Map<String, dynamic>> workspaces =
          await WorkspaceService().getWorkspaceData(
        userId: AuthService.supabase().currentUser!.id,
      );

      final String? currentWorkspace = await getCurrentWorkspace();

      setState(() {
        _workspaceData = workspaces;
      });

      if (currentWorkspace != null) {
        setState(() {
          _currentWorkspace = currentWorkspace;
          _isLoading = false;
        });
      } else {
        _selectWorkspace(workspace: _workspaceData![0]['workspace_id']);
        setState(() {
          _currentWorkspace = _workspaceData![0]['workspace_id'];
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

  void _createWorkspace() async {
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
        if (context.mounted) {
          showErrorDialog(context, "Some error occurred");
        }
      } catch (e) {
        setState(() {
          _isLoading = false;
        });
        if (context.mounted) {
          showErrorDialog(context, e.toString());
        }
      }
    }
  }

  void _selectWorkspace({required String workspace}) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    await prefs.setString('workspace', workspace);

    setState(() {
      _currentWorkspace = workspace;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Center(
        child: _isLoading
            ? const Padding(
                padding: EdgeInsets.all(24.0),
                child: CircularProgressIndicator(),
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "Dashboard",
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 24.0),
                  _currentWorkspace != null
                      ? Chip(
                          label: Text("Current workspace: $_currentWorkspace"))
                      : const SizedBox(),
                  _workspaceData != null
                      ? Container(
                          padding: const EdgeInsets.all(16.0),
                          child: ListView.builder(
                            itemBuilder: (context, index) {
                              return Container(
                                margin: const EdgeInsets.only(bottom: 16.0),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                      color: const Color.fromARGB(
                                          100, 141, 166, 255),
                                      width: 2),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: SizedBox(
                                  width: 300.0,
                                  child: ListTile(
                                    title: Text(_workspaceData![index]
                                        ["workspace"]['name']),
                                    subtitle: Text(
                                        _workspaceData![index]['workspace_id']),
                                    onTap: () {
                                      _selectWorkspace(
                                          workspace: _workspaceData![index]
                                              ['workspace_id']);
                                    },
                                  ),
                                ),
                              );
                            },
                            itemCount: _workspaceData!.length,
                            scrollDirection: Axis.vertical,
                            shrinkWrap: true,
                          ),
                        )
                      : const SizedBox(),
                  const SizedBox(height: 48.0),
                  FilledButton(
                    onPressed: () async {
                      await _showAddWorkspaceDialog(context);
                    },
                    child: const Text("New workspace"),
                  ),
                ],
              ),
      ),
    );
  }

  Future<void> _showAddWorkspaceDialog(BuildContext context) {
    final validCharacters = RegExp(r'^[a-zA-Z0-9]+$');
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("New workspace"),
          content: Form(
            key: _formKey,
            child: TextFormField(
              decoration:
                  const InputDecoration(hintText: "Enter the workspace name"),
              controller: _workspaceName,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Workspace name required';
                } else if (value.length < 3) {
                  return "At least 3 characters";
                } else if (!validCharacters.hasMatch(value)) {
                  return "Letters & numbers allowed. No spaces.";
                }
                return null;
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                _workspaceName.clear();
                Navigator.of(context).pop();
              },
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: _createWorkspace,
              child: const Text("Create Workspace"),
            ),
          ],
        );
      },
    );
  }
}
