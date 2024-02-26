import 'package:flutter/material.dart';
import 'package:shinda_app/views/dashboard/dashboard_view.dart';
import 'package:shinda_app/views/dashboard/debtors_view.dart';
import 'package:shinda_app/views/dashboard/inventory_view.dart';
import 'package:shinda_app/views/dashboard/products_view.dart';
import 'package:shinda_app/views/dashboard/reports_view.dart';
import 'package:shinda_app/views/dashboard/sales_view.dart';
import 'package:shinda_app/views/dashboard/settings_view.dart';
import 'package:shinda_app/views/dashboard/users_view.dart';

final List<Widget> drawerViews = <Widget>[
  const DashboardView(),
  const SalesView(),
  const InventoryView(),
  const ProductsView(),
  const DebtorsView(),
  const ReportsView(),
  const UsersView(),
  const SettingsView(),
];
