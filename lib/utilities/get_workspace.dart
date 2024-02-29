import 'package:shared_preferences/shared_preferences.dart';

Future<String?> getCurrentWorkspace() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();

  final String? currentWorkspace = prefs.getString('workspace');

  return currentWorkspace;
}
