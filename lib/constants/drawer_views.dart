import 'package:flutter/material.dart';
import 'package:shinda_app/views/dashboard/dashboard_view.dart';
import 'package:shinda_app/views/dashboard/debtors_view.dart';
import 'package:shinda_app/views/dashboard/inventory_view.dart';
import 'package:shinda_app/views/dashboard/new_transaction_view.dart';
import 'package:shinda_app/views/dashboard/reports_view.dart';
import 'package:shinda_app/views/dashboard/transactions_view.dart';
import 'package:shinda_app/views/dashboard/settings_view.dart';
import 'package:shinda_app/views/dashboard/users_view.dart';

final List<Widget> drawerViews = <Widget>[
  const NewTransactionView(),
  const DashboardView(),
  const TransactionsView(),
  const InventoryView(),
  // const ProductsView(),
  const DebtorsView(),
  const ReportsView(),
  const ManageWorkspaceView(),
  const SettingsView(),
];
