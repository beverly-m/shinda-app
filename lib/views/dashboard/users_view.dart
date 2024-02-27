import 'package:flutter/material.dart';

class ManageWorkspaceView extends StatelessWidget {
  const ManageWorkspaceView({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        "Users",
        style: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
