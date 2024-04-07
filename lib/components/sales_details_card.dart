import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shinda_app/components/custom_card.dart';
import 'package:shinda_app/constants/text_syles.dart';
import 'package:shinda_app/responsive/responsive_layout.dart';
import 'package:shinda_app/services/workspace/workspace_exceptions.dart';
import 'package:shinda_app/services/workspace/workspace_service.dart';
import 'package:shinda_app/utilities/models/sales_model.dart';

class SalesDetailsCard extends StatefulWidget {
  const SalesDetailsCard({super.key, required this.workspaceId});
  final String workspaceId;
  @override
  State<SalesDetailsCard> createState() => _SalesDetailsCardState();
}

class _SalesDetailsCardState extends State<SalesDetailsCard> {
  bool _isLoading = false;
  Map<String, dynamic>? _dashboardMetadata;
  SalesDetails? _salesDetails;

  @override
  void initState() {
    super.initState();
    getDashboardMetadata();
  }

  void getDashboardMetadata() async {
    final Map<String, dynamic> dashboardMeta;

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
        _salesDetails = SalesDetails(
          totalIncome: _dashboardMetadata!['income'] ?? 0,
          transactions: _dashboardMetadata!['transactions'],
          outstandingPayments: _dashboardMetadata!['outstandingPayments'],
          productsLowInStock: _dashboardMetadata!['productsLowInStock'],
          productsExpiring: _dashboardMetadata!['expiredProducts'],
        );
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

    return _isLoading
        ? const CircularProgressIndicator()
        : GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: Responsive.isMobile(context) ? 2 : 5,
              crossAxisSpacing: Responsive.isMobile(context) ? 8.0 : 16.0,
              mainAxisSpacing: Responsive.isMobile(context) ? 8.0 : 16.0,
            ),
            itemBuilder: (context, index) => CustomCard(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  _salesDetails!.salesData()[index].icon,
                  const SizedBox(height: 16.0),
                  Text(
                    _salesDetails!.salesData()[index].value,
                    style: GoogleFonts.eczar(
                      textStyle: TextStyle(
                          fontSize: Responsive.isMobile(context) ? 20.0 : 24.0),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4.0),
                  Text(
                    _salesDetails!.salesData()[index].title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: neutral4),
                  ),
                ],
              ),
            ),
            itemCount: _salesDetails!.salesData().length,
            shrinkWrap: true,
            physics: const ScrollPhysics(),
          );
  }
}
