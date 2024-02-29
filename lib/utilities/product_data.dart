import 'package:flutter/material.dart';

class ProductData extends DataTableSource {
  ProductData({required this.data});

  final List<Map<String, dynamic>> data;

  @override
  DataRow? getRow(int index) {
    return DataRow(cells: [
      DataCell(Text(data[index]["product"]['name'])),
      DataCell(Text(data[index]["product"]['price'].toStringAsFixed(2))),
      DataCell(Text(data[index]['quantity'].toString())),
      DataCell(Text(data[index]['quantity_sold'].toString())),
      DataCell(Text(data[index]['quantity_available'].toString())),
      DataCell(Text(data[index]['quantity_defective'].toString())),
    ]);
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => data.length;

  @override
  int get selectedRowCount => 0;
}

List<DataColumn> productDataColumns = [
  const DataColumn(
    label: Text(
      "Product name",
      style: TextStyle(
        fontWeight: FontWeight.bold,
      ),
    ),
  ),
  const DataColumn(
    label: Text(
      "Price (RWF)",
      style: TextStyle(
        fontWeight: FontWeight.bold,
      ),
    ),
  ),
  const DataColumn(
    label: Text(
      "Quantity",
      style: TextStyle(
        fontWeight: FontWeight.bold,
      ),
    ),
  ),
  const DataColumn(
    label: Text(
      "Sold",
      style: TextStyle(
        fontWeight: FontWeight.bold,
      ),
    ),
  ),
  const DataColumn(
    label: Text(
      "Available",
      style: TextStyle(
        fontWeight: FontWeight.bold,
      ),
    ),
  ),
  const DataColumn(
    label: Text(
      "Defective",
      style: TextStyle(
        fontWeight: FontWeight.bold,
      ),
    ),
  ),
];
