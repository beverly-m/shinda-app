import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:shinda_app/services/auth/auth_exceptions.dart';
import 'package:shinda_app/services/auth/auth_service.dart';
import 'package:shinda_app/services/workspace/workspace_service.dart';
import 'package:shinda_app/utilities/show_error_dialog.dart';

class DashboardView extends StatefulWidget {
  const DashboardView({super.key});

  @override
  State<DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends State<DashboardView> {
  final GlobalKey<FormState> _formKey = GlobalKey();

  late final TextEditingController _workspaceName;

  @override
  void initState() {
    super.initState();
    _workspaceName = TextEditingController();
  }

  void _createWorkspace() async {
    final isValid = _formKey.currentState?.validate();
    final workspaceName = _workspaceName.text.trim();

    if (isValid != null && isValid) {
      log("Creating workspace...");
      log(_workspaceName.text.trim());
      _workspaceName.clear();
      Navigator.of(context).pop();
      log(AuthService.supabase().currentUser?.id ?? "no id");
      try {
        await WorkspaceService().getWorkspaceDetails(
          workspaceName: workspaceName,
          creatorId: AuthService.supabase().currentUser!.id,
        );
        log("Workspace created!");
        // log(workspaceData.toString());
      } on GenericAuthException {
        if (context.mounted) {
          showErrorDialog(context, "Some error occurred");
        }
      } catch (e) {
        if (context.mounted) {
          showErrorDialog(context, e.toString());
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Center(
        child: Column(
          children: [
            const Text(
              "Dashboard",
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
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
                Navigator.pop(context);
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
