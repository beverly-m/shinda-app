import 'package:flutter/material.dart';
import 'package:shinda_app/components/drawer_item.dart';

final List<DrawerItem> drawerItems = [
  const DrawerItem(title: "DASHBOARD", icon: Icons.home_outlined),
  const DrawerItem(title: "SALES", icon: Icons.sell_outlined),
  const DrawerItem(title: "INVENTORY", icon: Icons.inventory_outlined),
  const DrawerItem(title: "PRODUCTS", icon: Icons.shopping_cart_outlined),
  const DrawerItem(title: "DEBTORS", icon: Icons.monetization_on_outlined),
  const DrawerItem(title: "REPORTS", icon: Icons.auto_graph_outlined),
  const DrawerItem(title: "USERS", icon: Icons.person_outlined),
  const DrawerItem(title: "SETTINGS", icon: Icons.settings_outlined),
  const DrawerItem(title: "LOGOUT", icon: Icons.logout_outlined),
];
