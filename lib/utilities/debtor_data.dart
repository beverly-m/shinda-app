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

List<DataColumn> debtorDataColumns = [
  const DataColumn(
    label: Text(
      "Client name",
      style: TextStyle(
        fontWeight: FontWeight.bold,
      ),
    ),
  ),
  const DataColumn(
    label: Text(
      "Total Amount Owed",
      style: TextStyle(
        fontWeight: FontWeight.bold,
      ),
    ),
  ),
  const DataColumn(
    label: Text(
      "Phone number",
      style: TextStyle(
        fontWeight: FontWeight.bold,
      ),
    ),
  ),
  const DataColumn(
    label: Text(
      "Address",
      style: TextStyle(
        fontWeight: FontWeight.bold,
      ),
    ),
  ),
];
