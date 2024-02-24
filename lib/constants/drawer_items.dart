import 'package:flutter/material.dart';
import 'package:shinda_app/components/drawer_item.dart';

final List<DrawerItem> drawerItems = [
  const DrawerItem(title: "DASHBOARD", icon: Icons.home),
  const DrawerItem(title: "SALES", icon: Icons.sell),
  const DrawerItem(title: "INVENTORY", icon: Icons.inventory),
  const DrawerItem(title: "PRODUCTS", icon: Icons.shopping_cart),
  const DrawerItem(title: "DEBTORS", icon: Icons.monetization_on),
  const DrawerItem(title: "REPORTS", icon: Icons.auto_graph),
  const DrawerItem(title: "USERS", icon: Icons.person),
  const DrawerItem(title: "SETTINGS", icon: Icons.settings),
  const DrawerItem(title: "LOGOUT", icon: Icons.logout),
];
