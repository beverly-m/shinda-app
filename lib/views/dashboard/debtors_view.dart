import 'package:flutter/material.dart';

class DebtorsView extends StatelessWidget {
  const DebtorsView({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        "Debtors",
        style: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
