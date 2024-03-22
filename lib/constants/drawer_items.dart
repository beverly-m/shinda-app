import 'package:flutter/material.dart';
import 'package:shinda_app/components/drawer_item.dart';

final List<DrawerItem> drawerItems = [
  const DrawerItem(
    title: "Dashboard",
    icon: Icons.home_outlined,
  ),
  const DrawerItem(
    title: "Transactions",
    icon: Icons.receipt_long_outlined,
  ),
  const DrawerItem(
    title: "Inventory",
    icon: Icons.inventory_2_outlined,
  ),
  const DrawerItem(
    title: "Debtors",
    icon: Icons.monetization_on_outlined,
  ),
  // const DrawerItem(
  //   title: "Reports",
  //   icon: Icons.auto_graph_outlined,
  // ),
  // const DrawerItem(
  //   title: "Management",
  //   icon: Icons.person_4_outlined,
  // ),
  // const DrawerItem(
  //   title: "Settings",
  //   icon: Icons.settings_outlined,
  // ),
  const DrawerItem(
    title: "Logout",
    icon: Icons.logout_outlined,
  ),
];
