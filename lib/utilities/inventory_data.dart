import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pluto_grid/pluto_grid.dart';
import 'package:shinda_app/components/buttons.dart';
import 'package:shinda_app/components/circular_progress_indicator.dart';
import 'package:shinda_app/components/snackbar.dart';
import 'package:shinda_app/components/textfields.dart';
import 'package:shinda_app/constants/text_syles.dart';
import 'package:shinda_app/services/workspace/workspace_exceptions.dart';
import 'package:shinda_app/services/workspace/workspace_service.dart';
import 'package:shinda_app/utilities/get_workspace.dart';
import 'package:shinda_app/utilities/show_error_dialog.dart';

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
  final GlobalKey<FormState> _formKey = GlobalKey();
  late final TextEditingController _quantity;
  late final TextEditingController _expirationDate;
  bool _isLoading = false;

  List<PlutoColumn> inventoryDataColumns = [
    PlutoColumn(
      title: 'Name',
      field: 'name',
      type: PlutoColumnType.text(),
      minWidth: 150.0,
    ),
    PlutoColumn(
      title: 'Stock id',
      field: 'stock_id',
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
    // PlutoColumn(
    //   title: 'Defective',
    //   field: 'defective',
    //   type: PlutoColumnType.number(),
    // ),
    PlutoColumn(
      title: 'Reorder Level',
      field: 'reorder_level',
      type: PlutoColumnType.number(),
    ),
    PlutoColumn(
      title: 'Details',
      field: 'details',
      type: PlutoColumnType.text(),
      width: 50,
    ),
  ];

  final List<PlutoRow> inventoryDataRows = [];
  late final PlutoGridStateManager stateManager;

  @override
  void initState() {
    super.initState();

    _quantity = TextEditingController();
    _expirationDate = TextEditingController();

    _getData();
  }

  @override
  void dispose() {
    _quantity.dispose();
    _expirationDate.dispose();

    super.dispose();
  }

  void _getData() {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
    });
    for (var element in widget.data) {
      inventoryDataRows.add(
        PlutoRow(
          cells: {
            'name': PlutoCell(value: element["product"]['name']),
            'stock_id': PlutoCell(value: element["stock_id"]),
            'price_rwf': PlutoCell(value: element["product"]['price']),
            'date_of_expiry': PlutoCell(value: element["expiration_date"]),
            'quantity': PlutoCell(value: element['quantity']),
            'sold': PlutoCell(value: element['quantity_sold']),
            'available': PlutoCell(value: element['quantity_available']),
            // 'defective': PlutoCell(value: element['quantity_defective']),
            'reorder_level': PlutoCell(value: element['reorder_level']),
            'details': PlutoCell(value: 'Edit Details'),
          },
        ),
      );
    }
    if (!mounted) return;
    setState(() {
      _isLoading = false;
    });
  }

  void _openDetail({required PlutoRow row}) async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        final quantityAvailable =
            row.cells.entries.map((e) => e.value.value).toList()[6];
        final reorderLevel =
            row.cells.entries.map((e) => e.value.value).toList()[7];
        return AlertDialog(
          backgroundColor: Colors.white,
          surfaceTintColor: const Color.fromRGBO(241, 249, 249, 1),
          shape: OutlineInputBorder(
            borderSide: BorderSide.none,
            borderRadius: BorderRadius.circular(8.0),
          ),
          scrollable: true,
          title: const Text(
            "Edit Inventory Item",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          contentPadding: const EdgeInsets.all(24.0),
          content: SizedBox(
            width: MediaQuery.of(context).size.width * 0.5,
            height: 300.0,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  ListTile(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      side: const BorderSide(color: surface3),
                    ),
                    leading: const Icon(
                      Icons.circle,
                      color: primary,
                    ),
                    title: Text.rich(
                      TextSpan(
                        text: row.cells.entries
                            .map((e) => e.value.value.toString())
                            .toList()[0]
                            .toString(),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                        children: [
                          TextSpan(
                              text: " | $quantityAvailable items left",
                              style: const TextStyle(color: Colors.black54))
                        ],
                      ),
                    ),
                    subtitle: Text(
                        "RWF ${row.cells.entries.map((e) => e.value.value).toList()[2].toStringAsFixed(2)}"),
                    trailing: reorderLevel >= quantityAvailable ||
                            quantityAvailable == 0
                        ? Chip(
                            label: Text(
                              "Low in stock",
                              style: subtitle2.copyWith(
                                color: Colors.red[900],
                              ),
                            ),
                            backgroundColor: Colors.red[100],
                            side: BorderSide.none,
                          )
                        : null,
                  ),
                  const SizedBox(height: 24.0),
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        NormalTextFormField(
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly
                          ],
                          controller: _quantity,
                          hintText: '0',
                          labelText: 'Add More Quantity',
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Quantity required';
                            } else if (value == "0") {
                              return "Quantity must be more than 0";
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 24.0),
                        NormalTextFormField(
                          controller: _expirationDate,
                          hintText: '0000-00-00 00:00:000',
                          labelText: 'New expiration date (optional)',
                          readOnly: true,
                          onTap: () async {
                            FocusScope.of(context).requestFocus(FocusNode());

                            DateTime? date = await showDatePicker(
                              context: context,
                              initialDate: DateTime.now(),
                              firstDate: DateTime.now(),
                              lastDate: DateTime(2040),
                            );

                            if (date != null) {
                              _expirationDate.text = date.toString();
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.6,
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedAppButton(
                        onPressed: () {
                          _updateInventory(
                            oldQuantity: row.cells.entries
                                .map((e) => e.value.value.toString())
                                .toList()[4]
                                .toString(),
                            stockId: row.cells.entries
                                .map((e) => e.value.value.toString())
                                .toList()[1]
                                .toString(),
                            quantityAvailable: quantityAvailable.toString(),
                          );
                        },
                        labelText: 'Update stock'),
                  ),
                  const SizedBox(width: 16.0),
                  Expanded(
                    child: TextAppButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        labelText: 'Cancel'),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  void _updateInventory({
    required String oldQuantity,
    required String stockId,
    required String quantityAvailable,
  }) async {
    final isValid = _formKey.currentState?.validate();

    if (isValid != null && isValid) {
      Navigator.of(context).pop();
      final quantity = _quantity.text.trim();
      final expirationDate = _expirationDate.text.trim();
      final workspaceId = await getCurrentWorkspaceId();

      _quantity.clear();
      _expirationDate.clear();

      try {
        await WorkspaceService().updateProduct(
          stockId: stockId,
          workspaceId: workspaceId!,
          quantity: quantity,
          oldQuantity: oldQuantity,
          expirationDate: expirationDate,
          quantityAvailable: quantityAvailable,
        );

        SnackBarService.showSnackBar(content: "Product updated.");

      } on GenericWorkspaceException {
        if (mounted) {
          showErrorDialog(context, "Failed to add product. Try again");
        }
      } catch (e) {
        if (mounted) {
          showErrorDialog(context, e.toString());
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return _isLoading
        ? const Center(
            child: AppCircularProgressIndicator()
          )
        : SizedBox(
            width: MediaQuery.of(context).size.width * 0.9,
            height: MediaQuery.of(context).size.height,
            child: PlutoGrid(
              rowColorCallback: (rowColorContext) {
                return rowColorContext.row.cells['reorder_level']?.value >=
                        rowColorContext.row.cells['available']?.value
                    ? Colors.red[50]!
                    : Colors.white;
              },
              mode: PlutoGridMode.selectWithOneTap,
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
                // stateManager = event.stateManager;
                // stateManager.setShowColumnFilter(true);

                event.stateManager
                    .setSelectingMode(PlutoGridSelectingMode.none);
              },
              onChanged: (PlutoGridOnChangedEvent event) {
                log(event.toString());
              },
              onSelected: (PlutoGridOnSelectedEvent event) {
                if (event.row != null) {
                  String stockId = event.row!.cells.entries
                      .map((e) => e.value.value.toString())
                      .toList()[1]
                      .toString();
                  log("Stock id: $stockId");

                  _openDetail(
                    row: event.row!,
                  );
                }
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
