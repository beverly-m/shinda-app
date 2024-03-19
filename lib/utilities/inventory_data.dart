import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:pluto_grid/pluto_grid.dart';
import 'package:shinda_app/constants/text_syles.dart';

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

class InventoryDataGrid extends StatefulWidget {
  const InventoryDataGrid({super.key, required this.data});

  final List<Map<String, dynamic>> data;

  @override
  State<InventoryDataGrid> createState() => _InventoryDataGridState();
}

class _InventoryDataGridState extends State<InventoryDataGrid> {
  bool _isLoading = false;

  List<PlutoColumn> inventoryDataColumns = [
    PlutoColumn(
      title: 'Name',
      field: 'name',
      type: PlutoColumnType.text(),
    ),
    PlutoColumn(
      title: 'Price (RWF)',
      field: 'price_rwf',
      type: PlutoColumnType.currency(
        name: 'RWF',
        symbol: 'RWF',
        decimalDigits: 2,
      ),
    ),
    PlutoColumn(
      title: 'Date of expiry',
      field: 'date_of_expiry',
      type: PlutoColumnType.date(),
    ),
    PlutoColumn(
      title: 'Start Quantity',
      field: 'quantity',
      type: PlutoColumnType.number(),
    ),
    PlutoColumn(
      title: 'Sold',
      field: 'sold',
      type: PlutoColumnType.number(),
    ),
    PlutoColumn(
      title: 'Available',
      field: 'available',
      type: PlutoColumnType.number(),
    ),
    PlutoColumn(
      title: 'Defective',
      field: 'defective',
      type: PlutoColumnType.number(),
    ),
    PlutoColumn(
      title: 'Reorder Level',
      field: 'reorder_level',
      type: PlutoColumnType.number(),
    ),
  ];

  final List<PlutoRow> inventoryDataRows = [];
  late final PlutoGridStateManager stateManager;

  @override
  void initState() {
    super.initState();
    _getData();
  }

  void _getData() {
    setState(() {
      _isLoading = true;
    });
    for (var element in widget.data) {
      inventoryDataRows.add(
        PlutoRow(
          cells: {
            'name': PlutoCell(value: element["product"]['name']),
            'price_rwf': PlutoCell(value: element["product"]['price']),
            'date_of_expiry': PlutoCell(value: element["expiration_date"]),
            'quantity': PlutoCell(value: element['quantity']),
            'sold': PlutoCell(value: element['quantity_sold']),
            'available': PlutoCell(value: element['quantity_available']),
            'defective': PlutoCell(value: element['quantity_defective']),
            'reorder_level': PlutoCell(value: element['reorder_level']),
          },
        ),
      );
    }
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return _isLoading
        ? const Center(
            child: CircularProgressIndicator(
              color: primary,
            ),
          )
        : SizedBox(
            width: MediaQuery.of(context).size.width * 0.9,
            height: MediaQuery.of(context).size.height,
            child: PlutoGrid(
              mode: PlutoGridMode.readOnly,
              columns: inventoryDataColumns,
              rows: inventoryDataRows,
              noRowsWidget: const Column(
                children: [
                  Icon(
                    Icons.table_chart_outlined,
                    size: 32,
                    color: surface3,
                  ),
                  SizedBox(
                    height: 16.0,
                  ),
                  Text("No products in stock"),
                ],
              ),
              onLoaded: (PlutoGridOnLoadedEvent event) {
                stateManager = event.stateManager;
                stateManager.setShowColumnFilter(true);
              },
              onChanged: (PlutoGridOnChangedEvent event) {
                log(event.toString());
              },
              configuration: PlutoGridConfiguration(
                style: PlutoGridStyleConfig(
                  gridBorderRadius: BorderRadius.circular(8.0),
                ),
                columnSize: const PlutoGridColumnSizeConfig(
                    autoSizeMode: PlutoAutoSizeMode.equal),
              ),
            ),
          );
  }
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
