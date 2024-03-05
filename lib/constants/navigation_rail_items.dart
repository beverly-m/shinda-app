import 'package:flutter/material.dart';
import 'package:shinda_app/constants/text_syles.dart';

final List<NavigationRailDestination> navigationRailItems = [
  const NavigationRailDestination(
    label: Text(
      "Dashboard",
      style: body2,
    ),
    icon: Icon(Icons.home_outlined),
    selectedIcon: Icon(Icons.home),
    padding: EdgeInsets.symmetric(horizontal: 24.0),
  ),
  const NavigationRailDestination(
    label: Text(
      "Transactions",
      style: body2,
    ),
    icon: Icon(Icons.receipt_long_outlined),
    selectedIcon: Icon(Icons.receipt_long),
    padding: EdgeInsets.symmetric(horizontal: 24.0),
  ),
  const NavigationRailDestination(
    label: Text(
      "Inventory",
      style: body2,
    ),
    icon: Icon(Icons.inventory_2_outlined),
    selectedIcon: Icon(Icons.inventory),
    padding: EdgeInsets.symmetric(horizontal: 24.0),
  ),
  const NavigationRailDestination(
    label: Text(
      "Debtors",
      style: body2,
    ),
    icon: Icon(Icons.monetization_on_outlined),
    selectedIcon: Icon(Icons.monetization_on),
    padding: EdgeInsets.symmetric(horizontal: 24.0),
  ),
  const NavigationRailDestination(
    label: Text(
      "Reports",
      style: body2,
    ),
    icon: Icon(Icons.auto_graph_outlined),
    selectedIcon: Icon(Icons.auto_graph),
    padding: EdgeInsets.symmetric(horizontal: 24.0),
  ),
  const NavigationRailDestination(
    label: Text(
      "Management",
      style: body2,
    ),
    icon: Icon(Icons.person_4_outlined),
    selectedIcon: Icon(Icons.person_4),
    padding: EdgeInsets.symmetric(horizontal: 24.0),
  ),
  const NavigationRailDestination(
    label: Text(
      "Settings",
      style: body2,
    ),
    icon: Icon(Icons.settings_outlined),
    selectedIcon: Icon(Icons.settings),
    padding: EdgeInsets.symmetric(horizontal: 24.0),
  ),
  const NavigationRailDestination(
    label: Text(
      "Logout",
      style: body2,
    ),
    icon: Icon(Icons.logout_outlined),
    selectedIcon: Icon(Icons.logout),
    padding: EdgeInsets.symmetric(horizontal: 24.0),
  ),
];
