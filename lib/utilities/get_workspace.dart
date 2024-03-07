import 'package:shared_preferences/shared_preferences.dart';

Future<String?> getCurrentWorkspaceId() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();

  final String? currentWorkspaceId = prefs.getString('workspaceId');

  return currentWorkspaceId;
}

Future<String?> getCurrentWorkspaceName() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();

  final String? currentWorkspaceName = prefs.getString('workspaceName');

  return currentWorkspaceName;
}

Future<String?> getWorkspaceMember() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();

  final String? workspaceMember = prefs.getString('workspaceMember');

  return workspaceMember;
}
