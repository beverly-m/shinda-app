import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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
      final List<Map<String, dynamic>> workspaces =
          await WorkspaceService().getWorkspaceData(
        userId: AuthService.supabase().currentUser!.id,
      );

      final String? currentWorkspace = await getCurrentWorkspaceId();
      final String? currentWorkspaceName = await getCurrentWorkspaceName();

      setState(() {
        _workspaceData = workspaces;
      });

      if (currentWorkspace != null && currentWorkspaceName != null) {
        setState(() {
          _currentWorkspace = currentWorkspace;
          _currentWorkspaceName = currentWorkspaceName;
          _isLoading = false;
        });
      } else {
        _selectWorkspace(
            workspace: _workspaceData![0]['workspace_id'],
            workspaceName: _workspaceData![0]['workspace']['name']);
        setState(() {
          _currentWorkspace = _workspaceData![0]['workspace_id'];
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

  void _selectWorkspace({
    required String workspace,
    required String workspaceName,
  }) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    await prefs.setString('workspaceId', workspace);
    await prefs.setString('workspaceName', workspaceName);

    setState(() {
      _currentWorkspace = workspace;
      _currentWorkspaceName = workspaceName;
    });
  }

  @override
  Widget build(BuildContext context) {
    return _isLoading
        ? const Center(
            child: Padding(
              padding: EdgeInsets.all(48.0),
              child: CircularProgressIndicator(
                color: Color.fromRGBO(0, 121, 107, 1),
              ),
            ),
          )
        : Padding(
            padding: const EdgeInsets.all(48.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Dashboard",
                  style: GoogleFonts.eczar(
                    textStyle: const TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                      color: Color.fromRGBO(0, 121, 107, 1),
                    ),
                  ),
                ),
                const SizedBox(height: 24.0),
                _currentWorkspaceName != null &&
                        _workspaceData != null &&
                        _workspaceData!.isNotEmpty
                    ? Row(
                        children: [
                          InkWell(
                            onTap: () {
                              _showSelectWorkspaceDialog(context);
                            },
                            child: Chip(
                              label: Text(
                                "$_currentWorkspaceName's Workspace",
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                ),
                              ),
                              avatar: const Icon(
                                Icons.arrow_drop_down_circle_outlined,
                                color: Color.fromRGBO(29, 233, 182, 1),
                              ),
                            ),
                          ),
                          const Expanded(child: SizedBox()),
                          _workspaceData != null && _workspaceData!.isNotEmpty
                              ? FilledButton(
                                  style: const ButtonStyle(
                                    backgroundColor: MaterialStatePropertyAll(
                                      Color.fromRGBO(0, 121, 107, 1),
                                    ),
                                  ),
                                  onPressed: () async {
                                    await _showAddWorkspaceDialog(context);
                                  },
                                  child: const Text(
                                    "New workspace",
                                    style: TextStyle(fontSize: 16.0),
                                  ),
                                )
                              : const SizedBox(),
                        ],
                      )
                    : const SizedBox(),
                _workspaceData != null && _workspaceData!.isNotEmpty
                    ? Padding(
                        padding: const EdgeInsets.all(48.0),
                        child: Center(
                            child: Column(
                          children: [
                            const Icon(
                              Icons.summarize_outlined,
                              size: 200,
                              color: Color.fromRGBO(219, 240, 239, 1),
                            ),
                            const SizedBox(height: 48.0),
                            Text(
                              "$_currentWorkspaceName Workspace Data Summary",
                              style: const TextStyle(fontSize: 16),
                            ),
                          ],
                        )),
                      )
                    // ? Container(
                    //     padding: const EdgeInsets.all(16.0),
                    //     child: ListView.builder(
                    //       itemBuilder: (context, index) {
                    //         return Container(
                    //           margin: const EdgeInsets.only(bottom: 16.0),
                    //           decoration: BoxDecoration(
                    //             border: Border.all(
                    //                 color: const Color.fromARGB(
                    //                     100, 141, 166, 255),
                    //                 width: 2),
                    //             borderRadius: BorderRadius.circular(8),
                    //           ),
                    //           child: SizedBox(
                    //             width: 300.0,
                    //             child: ListTile(
                    //               title: Text(_workspaceData![index]
                    //                   ["workspace"]['name']),
                    //               subtitle: Text(
                    //                   _workspaceData![index]['workspace_id']),
                    //               onTap: () {
                    //                 _selectWorkspace(
                    //                   workspace: _workspaceData![index]
                    //                       ['workspace_id'],
                    //                   workspaceName: _workspaceData![index]
                    //                       ['name'],
                    //                 );
                    //               },
                    //             ),
                    //           ),
                    //         );
                    //       },
                    //       itemCount: _workspaceData!.length,
                    //       scrollDirection: Axis.vertical,
                    //       shrinkWrap: true,
                    //     ),
                    //   )
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
                              FilledButton(
                                style: const ButtonStyle(
                                  backgroundColor: MaterialStatePropertyAll(
                                    Color.fromRGBO(0, 121, 107, 1),
                                  ),
                                ),
                                onPressed: () async {
                                  await _showAddWorkspaceDialog(context);
                                },
                                child: const Text(
                                  "New workspace",
                                  style: TextStyle(fontSize: 16.0),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
              ],
            ),
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
            child: TextFormField(
              cursorColor: const Color.fromRGBO(0, 121, 107, 1),
              decoration: const InputDecoration(
                hoverColor: Color.fromRGBO(0, 121, 107, 1),
                hintText: "Enter the workspace name",
                focusColor: Color.fromRGBO(0, 121, 107, 1),
              ),
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
              child: const Text(
                "Cancel",
                style: TextStyle(
                  color: Color.fromRGBO(0, 121, 107, 1),
                ),
              ),
            ),
            FilledButton(
              onPressed: _createWorkspace,
              style: const ButtonStyle(
                  backgroundColor:
                      MaterialStatePropertyAll(Color.fromRGBO(0, 121, 107, 1))),
              child: const Text("Create Workspace"),
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
