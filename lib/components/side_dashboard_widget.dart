import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:shinda_app/components/expiring_products_card.dart'
    show ExpiringProductsCard;
import 'package:shinda_app/components/linear_progress_indicator.dart'
    show AppLinearProgressIndicator;
import 'package:shinda_app/components/products_stock_card.dart'
    show ProductsStockCard;
import 'package:shinda_app/components/sold_products_card.dart'
    show SoldProductsCard;
import 'package:shinda_app/constants/text_syles.dart' show primary;
import 'package:shinda_app/services/workspace/workspace_exceptions.dart'
    show GenericWorkspaceException;
import 'package:shinda_app/services/workspace/workspace_service.dart'
    show WorkspaceService;

class SideDashboardWidget extends StatefulWidget {
  const SideDashboardWidget({super.key, required this.workspaceId});
  final String workspaceId;

  @override
  State<SideDashboardWidget> createState() => _SideDashboardWidgetState();
}

class _SideDashboardWidgetState extends State<SideDashboardWidget> {
  List? _expiredProductsData;
  List? _lowInStockProductsData;
  Map? _mostSoldProductsData;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    getProductsMetadata();
  }

  void getProductsMetadata() async {
    final Map<String, dynamic> dashboardMetadata;

    if (!mounted) return;
    setState(() {
      _isLoading = true;
    });

    try {
      dashboardMetadata = await WorkspaceService()
          .getDashboardMeta(workspaceId: widget.workspaceId);
      
      if (!mounted) return;
      setState(() {
        _expiredProductsData = dashboardMetadata["expiredProductsData"];

        _lowInStockProductsData = dashboardMetadata["productsLowInStockData"];

        _mostSoldProductsData = dashboardMetadata["mostSoldProductsData"];

        _isLoading = false;
      });
    } on GenericWorkspaceException {
      log("Error occurred---getProductsMetadata");
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
        ? Center(
            child: SizedBox(
              width: 64.0,
              height: 2.0,
              child: AppLinearProgressIndicator(
                color: primary.withOpacity(0.5),
              ),
            ),
          )
        : Column(
            children: [
              const SizedBox(height: 16.0),
              SoldProductsCard(soldProductsData: _mostSoldProductsData!),
              const SizedBox(height: 16.0),
              ProductsStockCard(
                  lowInStockProductsData: _lowInStockProductsData!),
              const SizedBox(height: 16.0),
              ExpiringProductsCard(expiredProductsData: _expiredProductsData),
            ],
          );
  }
}
