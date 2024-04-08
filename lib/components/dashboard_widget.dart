import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:shinda_app/components/line_chart_card.dart';
import 'package:shinda_app/components/side_dashboard_widget.dart';
import 'package:shinda_app/responsive/responsive_layout.dart';
import 'package:shinda_app/services/workspace/workspace_exceptions.dart';
import 'package:shinda_app/services/workspace/workspace_service.dart';

class DashboardWidget extends StatefulWidget {
  const DashboardWidget({super.key, required this.workspaceId});
  final String workspaceId;

  @override
  State<DashboardWidget> createState() => _DashboardWidgetState();
}

class _DashboardWidgetState extends State<DashboardWidget> {
  bool _isLoading = false;
  List? _salesData;
  
  @override
  void initState() {
    super.initState();
    getDashboardMetadata();
  }

  void getDashboardMetadata() async {
    final Map<String, dynamic> dashboardMeta;
    Map<String, dynamic>? _dashboardMetadata;

    setState(() {
      _isLoading = true;
    });

    try {
      dashboardMeta = await WorkspaceService()
          .getDashboardMeta(workspaceId: widget.workspaceId);

      setState(() {
        _dashboardMetadata = dashboardMeta;
        log('dashboardMeta');
        log(_dashboardMetadata!.toString());
        _salesData = _dashboardMetadata!['salesData'];
        _isLoading = false;
      });
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
          LineChartCard(salesData: _salesData!,),
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
