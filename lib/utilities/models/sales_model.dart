import 'package:flutter/material.dart';
import 'package:shinda_app/constants/text_syles.dart';
import 'package:shinda_app/responsive/responsive_layout.dart';

class SalesModel {
  final Icon icon;
  final String value;
  final String title;

  SalesModel({
    required this.icon,
    required this.value,
    required this.title,
  });
}

class SalesDetails {
  SalesDetails({
    required this.totalIncome,
    required this.transactions,
    required this.outstandingPayments,
    required this.productsLowInStock,
    required this.productsExpiring,
  });

  final double totalIncome;
  final int transactions;
  final int outstandingPayments;
  final int productsLowInStock;
  final int productsExpiring;

  List<SalesModel> salesData(BuildContext context) {
    return [
      if (Responsive.isDesktop(context))
        SalesModel(
          icon: const Icon(
            Icons.point_of_sale_outlined,
            size: 30,
            color: primary,
          ),
          value: 'RWF ${totalIncome.toStringAsFixed(2)}',
          title: "Total Income",
        ),
      SalesModel(
        icon: const Icon(
          Icons.currency_exchange_outlined,
          size: 30,
          color: primary,
        ),
        value: '$transactions',
        title: "Transactions",
      ),
      SalesModel(
        icon: const Icon(
          Icons.people_alt_outlined,
          size: 30,
          color: primary,
        ),
        value: '$outstandingPayments',
        title: "Outstanding client payments",
      ),
      SalesModel(
        icon: const Icon(
          Icons.production_quantity_limits_outlined,
          size: 30,
          color: primary,
        ),
        value: '$productsLowInStock',
        title: "Products low in stock",
      ),
      SalesModel(
        icon: const Icon(
          Icons.remove_shopping_cart_outlined,
          size: 30,
          color: primary,
        ),
        value: '$productsExpiring',
        title: "Products expiring",
      ),
    ];
  }
}
