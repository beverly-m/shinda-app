import 'package:flutter/material.dart';

final List<NavigationRailDestination> navigationRailItems = [
  const NavigationRailDestination(
    label: Text("DASHBOARD"),
    icon: Icon(Icons.home_outlined),
    selectedIcon: Icon(Icons.home),
  ),
  const NavigationRailDestination(
    label: Text("TRANSACTIONS"),
    icon: Icon(Icons.sell_outlined),
    selectedIcon: Icon(Icons.sell),
  ),
  const NavigationRailDestination(
    label: Text("INVENTORY"),
    icon: Icon(Icons.inventory_2_outlined),
    selectedIcon: Icon(Icons.inventory),
  ),
  // const NavigationRailDestination(
  //   label: Text("PRODUCTS"),
  //   icon: Icon(Icons.shopping_cart_outlined),
  //   selectedIcon: Icon(Icons.shopping_cart),
  // ),
  const NavigationRailDestination(
    label: Text("DEBTORS"),
    icon: Icon(Icons.monetization_on_outlined),
    selectedIcon: Icon(Icons.monetization_on),
  ),
  const NavigationRailDestination(
    label: Text("REPORTS"),
    icon: Icon(Icons.auto_graph_outlined),
    selectedIcon: Icon(Icons.auto_graph),
  ),
  const NavigationRailDestination(
    label: Text("MANAGE WORKSPACE"),
    icon: Icon(Icons.person_4_outlined),
    selectedIcon: Icon(Icons.person_4),
  ),
  const NavigationRailDestination(
    label: Text("SETTINGS"),
    icon: Icon(Icons.settings_outlined),
    selectedIcon: Icon(Icons.settings),
  ),
  const NavigationRailDestination(
    label: Text("LOGOUT"),
    icon: Icon(Icons.logout_outlined),
    selectedIcon: Icon(Icons.logout),
  ),
];
