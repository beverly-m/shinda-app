import 'package:flutter/material.dart';
import 'package:shinda_app/constants/text_syles.dart';

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
  final List<SalesModel> salesData = [
    SalesModel(
      icon: const Icon(
        Icons.point_of_sale_outlined,
        size: 30,
        color: primary,
      ),
      value: 'RWF 100,000.00',
      title: "Total Income",
    ),
    SalesModel(
      icon: const Icon(
        Icons.currency_exchange_outlined,
        size: 30,
        color: primary,
      ),
      value: '56',
      title: "Transactions",
    ),
    SalesModel(
      icon: const Icon(
        Icons.production_quantity_limits_outlined,
        size: 30,
        color: primary,
      ),
      value: '3',
      title: "Products low in stock",
    ),
    SalesModel(
      icon: const Icon(
        Icons.people_alt_outlined,
        size: 30,
        color: primary,
      ),
      value: '5',
      title: "Outstanding client payments",
    ),
  ];
}
