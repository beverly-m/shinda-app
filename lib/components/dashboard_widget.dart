import 'package:flutter/material.dart';
import 'package:shinda_app/components/line_chart_card.dart';
import 'package:shinda_app/components/side_dashboard_widget.dart';
import 'package:shinda_app/responsive/responsive_layout.dart';

class DashboardWidget extends StatefulWidget {
  const DashboardWidget({super.key, required this.workspaceId});
  final String workspaceId;

  @override
  State<DashboardWidget> createState() => _DashboardWidgetState();
}

class _DashboardWidgetState extends State<DashboardWidget> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(
            height: 24.0,
          ),
          const SizedBox(height: 16),
          const LineChartCard(),
          if (Responsive.isDesktop(context))
            const SizedBox(
              height: 16,
            ),
          if (Responsive.isTablet(context) || Responsive.isMobile(context))
            const SideDashboardWidget(),
        ],
      ),
    );
  }
}
