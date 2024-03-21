import 'package:flutter/material.dart';
import 'package:shinda_app/components/line_chart_card.dart';
import 'package:shinda_app/components/sales_details_card.dart';

class DashboardWidget extends StatefulWidget {
  const DashboardWidget({super.key});

  @override
  State<DashboardWidget> createState() => _DashboardWidgetState();
}

class _DashboardWidgetState extends State<DashboardWidget> {
  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        SizedBox(
          height: 24.0,
        ),
        SalesDetailsCard(),
        SizedBox(height: 16),
        LineChartCard(),
      ],
    );
  }
}
