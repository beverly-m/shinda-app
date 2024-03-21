import 'package:flutter/material.dart';
import 'package:shinda_app/components/expiring_products_card.dart';
import 'package:shinda_app/components/products_stock_card.dart';

class SideDashboardWidget extends StatefulWidget {
  const SideDashboardWidget({super.key});

  @override
  State<SideDashboardWidget> createState() => _SideDashboardWidgetState();
}

class _SideDashboardWidgetState extends State<SideDashboardWidget> {
  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        SizedBox(
          height: 24.0,
        ),
        ExpiringProductsCard(),
        SizedBox(height: 16.0),
        ProductsStockCard(),
      ],
    );
  }
}
