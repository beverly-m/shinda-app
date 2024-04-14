import 'package:flutter/material.dart';
import 'package:shinda_app/views/dashboard/dashboard_view.dart'
    show DashboardView;
import 'package:shinda_app/views/dashboard/debtors_view.dart' show DebtorsView;
import 'package:shinda_app/views/dashboard/inventory_view.dart'
    show InventoryView;
import 'package:shinda_app/views/dashboard/new_transaction_view.dart'
    show NewTransactionView;
import 'package:shinda_app/views/dashboard/transactions_view.dart'
    show TransactionsView;

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
