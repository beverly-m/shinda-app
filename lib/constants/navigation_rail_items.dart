import 'package:flutter/material.dart';
import 'package:shinda_app/constants/text_syles.dart' show body2, primary;

final List<NavigationRailDestination> navigationRailItems = [
  NavigationRailDestination(
    label: const Text(
      "",
      style: body2,
    ),
    icon: Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.0),
        color: primary,
      ),
      child: const Icon(
        Icons.add_card_outlined,
        color: Colors.white,
      ),
    ),
    selectedIcon: Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.0),
        color: primary,
      ),
      child: const Icon(
        Icons.add_card,
        color: Colors.white,
      ),
    ),
    padding: const EdgeInsets.symmetric(horizontal: 8.0),
  ),
  const NavigationRailDestination(
    label: Text(
      "Dashboard",
      overflow: TextOverflow.fade,
      maxLines: 1,
      style: body2,
    ),
    icon: Icon(Icons.home_outlined),
    selectedIcon: Icon(Icons.home),
    padding: EdgeInsets.symmetric(horizontal: 8.0),
  ),
  const NavigationRailDestination(
    label: Text(
      "Transactions",
      overflow: TextOverflow.fade,
      maxLines: 1,
      style: body2,
    ),
    icon: Icon(Icons.receipt_long_outlined),
    selectedIcon: Icon(Icons.receipt_long),
    padding: EdgeInsets.symmetric(horizontal: 8.0),
  ),
  const NavigationRailDestination(
    label: Text(
      "Inventory",
      overflow: TextOverflow.fade,
      maxLines: 1,
      style: body2,
    ),
    icon: Icon(Icons.inventory_2_outlined),
    selectedIcon: Icon(Icons.inventory),
    padding: EdgeInsets.symmetric(horizontal: 8.0),
  ),
  const NavigationRailDestination(
    label: Text(
      "Debtors",
      overflow: TextOverflow.fade,
      maxLines: 1,
      style: body2,
    ),
    icon: Icon(Icons.monetization_on_outlined),
    selectedIcon: Icon(Icons.monetization_on),
    padding: EdgeInsets.symmetric(horizontal: 8.0),
  ),
  // const NavigationRailDestination(
  //   label: Text(
  //     "Reports",
  //     overflow: TextOverflow.fade,
  //     maxLines: 1,
  //     style: body2,
  //   ),
  //   icon: Icon(Icons.auto_graph_outlined),
  //   selectedIcon: Icon(Icons.auto_graph),
  //   padding: EdgeInsets.symmetric(horizontal: 8.0),
  // ),
  // const NavigationRailDestination(
  //   label: Text(
  //     "Management",
  //     overflow: TextOverflow.fade,
  //     maxLines: 1,
  //     style: body2,
  //   ),
  //   icon: Icon(Icons.person_4_outlined),
  //   selectedIcon: Icon(Icons.person_4),
  //   padding: EdgeInsets.symmetric(horizontal: 8.0),
  // ),
  // const NavigationRailDestination(
  //   label: Text(
  //     "Settings",
  //     overflow: TextOverflow.fade,
  //     maxLines: 1,
  //     style: body2,
  //   ),
  //   icon: Icon(Icons.settings_outlined),
  //   selectedIcon: Icon(Icons.settings),
  //   padding: EdgeInsets.symmetric(horizontal: 8.0),
  // ),
  const NavigationRailDestination(
    label: Text(
      "Logout",
      overflow: TextOverflow.fade,
      maxLines: 1,
      style: body2,
    ),
    icon: Icon(Icons.logout_outlined),
    selectedIcon: Icon(Icons.logout),
    padding: EdgeInsets.symmetric(horizontal: 8.0),
  ),
];
