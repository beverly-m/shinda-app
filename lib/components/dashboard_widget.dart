import 'dart:developer' show log;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart' show GoogleFonts;
import 'package:shinda_app/components/custom_card.dart' show CustomCard;
import 'package:shinda_app/components/outstanding_payments_card.dart'
    show OutstandingPaymentsCard;
import 'package:shinda_app/components/line_chart_card.dart' show LineChartCard;
import 'package:shinda_app/components/pie_chart_card.dart' show PieChartCard;
import 'package:shinda_app/components/side_dashboard_widget.dart'
    show SideDashboardWidget;
import 'package:shinda_app/constants/text_syles.dart' show neutral4, primary;
import 'package:shinda_app/responsive/responsive_layout.dart' show Responsive;
import 'package:shinda_app/services/workspace/workspace_exceptions.dart'
    show GenericWorkspaceException;
import 'package:shinda_app/services/workspace/workspace_service.dart'
    show WorkspaceService;

class DashboardWidget extends StatefulWidget {
  const DashboardWidget({super.key, required this.workspaceId});
  final String workspaceId;

  @override
  State<DashboardWidget> createState() => _DashboardWidgetState();
}

class _DashboardWidgetState extends State<DashboardWidget> {
  bool _isLoading = false;
  List? _salesData;
  final Map<String, dynamic> _paymentModeData = {
    "income": 0,
    "momo": 0,
    "cash": 0,
    "card": 0,
    "bank": 0
  };
  List<Map<String, dynamic>>? _debtorsData;

  @override
  void initState() {
    super.initState();
    getDashboardMetadata();
  }

  void getDashboardMetadata() async {
    final Map<String, dynamic> dashboardMeta;
    Map<String, dynamic>? dashboardMetadata;

    if (!mounted) return;
    setState(() {
      _isLoading = true;
    });

    try {
      dashboardMeta = await WorkspaceService()
          .getDashboardMeta(workspaceId: widget.workspaceId);
          
      if (!mounted) return;
      setState(() {
        dashboardMetadata = dashboardMeta;
        _salesData = dashboardMetadata!['salesData'];

        _paymentModeData["income"] = dashboardMetadata!["income"];
        _paymentModeData["momo"] = dashboardMetadata!["momo"];
        _paymentModeData["cash"] = dashboardMetadata!["cash"];
        _paymentModeData["card"] = dashboardMetadata!["card"];
        _paymentModeData["bank"] = dashboardMetadata!["bank"];

        _debtorsData = dashboardMetadata!["outstandingPaymentsData"];

        _isLoading = false;
      });
    } on GenericWorkspaceException {
      log("Error occurred--getDashboardMetadata");
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      log(e.toString());
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return _isLoading
        ? const SizedBox()
        : SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: Responsive.isMobile(context) ? 8.0 : 16.0),
                Responsive.isMobile(context)
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AspectRatio(
                            aspectRatio: 2,
                            child: CustomCard(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  const Icon(
                                    Icons.point_of_sale_outlined,
                                    size: 30,
                                    color: primary,
                                  ),
                                  const SizedBox(height: 16.0),
                                  Text(
                                    'RWF ${_paymentModeData["income"].toStringAsFixed(2)}',
                                    style: GoogleFonts.eczar(
                                      textStyle: TextStyle(
                                          fontSize: Responsive.isMobile(context)
                                              ? 20.0
                                              : 24.0),
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 4.0),
                                  const Text(
                                    "Total Income",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(color: neutral4),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 8.0),
                          AspectRatio(
                            aspectRatio: 0.8,
                            child: PieChartCard(
                              salesData: _paymentModeData,
                            ),
                          ),
                        ],
                      )
                    : Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 3,
                            child: Responsive.isDesktop(context)
                                ? PieChartCard(
                                    salesData: _paymentModeData,
                                  )
                                : AspectRatio(
                                    aspectRatio: Responsive.isTablet(context)
                                        ? 1.1
                                        : 0.8,
                                    child: PieChartCard(
                                      salesData: _paymentModeData,
                                    ),
                                  ),
                          ),
                          SizedBox(
                              width: Responsive.isMobile(context) ? 8.0 : 16.0),
                          if (Responsive.isDesktop(context))
                            Expanded(
                              flex: 5,
                              child: LineChartCard(
                                salesData: _salesData!,
                              ),
                            ),
                          if (Responsive.isTablet(context) ||
                              Responsive.isMobile(context))
                            Expanded(
                              flex: 3,
                              child: AspectRatio(
                                aspectRatio:
                                    Responsive.isTablet(context) ? 1.1 : 0.8,
                                child: CustomCard(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      const Icon(
                                        Icons.point_of_sale_outlined,
                                        size: 30,
                                        color: primary,
                                      ),
                                      const SizedBox(height: 16.0),
                                      Text(
                                        'RWF ${_paymentModeData["income"].toStringAsFixed(2)}',
                                        style: GoogleFonts.eczar(
                                          textStyle: TextStyle(
                                              fontSize:
                                                  Responsive.isMobile(context)
                                                      ? 20.0
                                                      : 24.0),
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                      const SizedBox(height: 4.0),
                                      const Text(
                                        "Total Income",
                                        textAlign: TextAlign.center,
                                        style: TextStyle(color: neutral4),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                const SizedBox(
                  height: 16,
                ),
                if (Responsive.isTablet(context) ||
                    Responsive.isMobile(context))
                  LineChartCard(
                    salesData: _salesData!,
                  ),
                if (Responsive.isTablet(context) ||
                    Responsive.isMobile(context))
                  SideDashboardWidget(workspaceId: widget.workspaceId),
                if (Responsive.isTablet(context) ||
                    Responsive.isMobile(context))
                  const SizedBox(
                    height: 16,
                  ),
                OutstandingPaymentsCard(data: _debtorsData!),
              ],
            ),
          );
  }
}
