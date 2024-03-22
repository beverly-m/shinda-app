import 'package:flutter/material.dart';
import 'package:shinda_app/views/dashboard/dashboard_view.dart';
import 'package:shinda_app/views/dashboard/debtors_view.dart';
import 'package:shinda_app/views/dashboard/inventory_view.dart';
import 'package:shinda_app/views/dashboard/new_transaction_view.dart';
import 'package:shinda_app/views/dashboard/transactions_view.dart';

final List<Widget> drawerViewsDesktop = <Widget>[
  const NewTransactionView(),
  const DashboardView(),
  const TransactionsView(),
  const InventoryView(),
  // const ProductsView(),
  const DebtorsView(),
  // const ReportsView(),
  // const ManageWorkspaceView(),
  // const SettingsView(),
];

final List<Widget> drawerViewsMobileTablet = <Widget>[
  // const NewTransactionView(),
  const DashboardView(),
  const TransactionsView(),
  const InventoryView(),
  // const ProductsView(),
  const DebtorsView(),
  // const ReportsView(),
  // const ManageWorkspaceView(),
  // const SettingsView(),
];
