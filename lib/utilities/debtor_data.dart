import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:pluto_grid/pluto_grid.dart';
import 'package:shinda_app/components/buttons.dart';
import 'package:shinda_app/components/circular_progress_indicator.dart';
import 'package:shinda_app/constants/text_syles.dart';
import 'package:shinda_app/services/workspace/workspace_exceptions.dart';
import 'package:shinda_app/services/workspace/workspace_service.dart';
import 'package:shinda_app/utilities/get_workspace.dart';

class DebtorDataGrid extends StatefulWidget {
  const DebtorDataGrid({super.key, required this.data});

  final List<Map<String, dynamic>> data;

  @override
  State<DebtorDataGrid> createState() => _DebtorDataGridState();
}

class _DebtorDataGridState extends State<DebtorDataGrid> {
  bool _isLoading = false;
  bool _isLoading2 = false;

  List<Map<String, dynamic>>? _transactionItemsData;

  List<PlutoColumn> debtorDataColumns = [
    PlutoColumn(
      title: 'Client name',
      field: 'client_name',
      type: PlutoColumnType.text(),
    ),
    PlutoColumn(
      title: 'Amount owed',
      field: 'amount_owed',
      type: PlutoColumnType.currency(
        name: 'RWF',
        symbol: 'RWF',
        decimalDigits: 2,
      ),
    ),
    PlutoColumn(
      title: 'Phone number',
      field: 'phone_number',
      type: PlutoColumnType.text(),
    ),
    PlutoColumn(
      title: 'Address',
      field: 'address',
      type: PlutoColumnType.text(),
    ),
    PlutoColumn(
      title: 'Date paid',
      field: 'date_paid',
      type: PlutoColumnType.date(),
    ),
    PlutoColumn(
      title: 'Paid',
      field: 'paid',
      type: PlutoColumnType.select(['true', 'false']),
    ),
    PlutoColumn(
      title: 'Transaction Id',
      field: 'transaction_id',
      type: PlutoColumnType.text(),
    ),
    PlutoColumn(
      title: 'Details',
      field: 'details',
      type: PlutoColumnType.text(),
    ),
  ];

  final List<PlutoRow> debtorDataRows = [];
  late final PlutoGridStateManager stateManager;

  @override
  void initState() {
    super.initState();
    _getData();
  }

  void _getData() {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
    });

    for (var element in widget.data) {
      debtorDataRows.add(
        PlutoRow(
          cells: {
            'client_name': PlutoCell(value: element['client_name']),
            'amount_owed': PlutoCell(value: element['amount_owed']),
            'phone_number': PlutoCell(value: element['phone_number']),
            'address': PlutoCell(value: element['address']),
            'date_paid': PlutoCell(value: element['date_paid']),
            'paid': PlutoCell(value: element['transaction']['is_paid']),
            'transaction_id':
                PlutoCell(value: element['transaction']['transaction_id']),
            'details': PlutoCell(value: 'View Details'),
          },
        ),
      );
    }
    
    if (!mounted) return;
    setState(() {
      _isLoading = false;
    });
  }

  void _openDetail({
    required PlutoRow row,
    required List<Map<String, dynamic>> items,
    required bool isPaid,
  }) async {
    double totalPrice = 0;
    for (var element in items) {
      totalPrice =
          totalPrice + (element['price_per_item'] * element['quantity']);
    }
    String? value = await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: Colors.white,
            surfaceTintColor: const Color.fromRGBO(241, 249, 249, 1),
            shape: OutlineInputBorder(
              borderSide: BorderSide.none,
              borderRadius: BorderRadius.circular(8.0),
            ),
            scrollable: true,
            title: const Text("Transaction Details"),
            contentPadding: const EdgeInsets.all(48.0),
            content: SizedBox(
              width: MediaQuery.of(context).size.width * 0.5,
              height: 200.0,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Products",
                      style: dashboardSubtitle,
                    ),
                    const SizedBox(height: 8.0),
                    ListView.builder(
                        shrinkWrap: true,
                        itemCount: items.length,
                        itemBuilder: (BuildContext context, int index) {
                          return ListTile(
                            contentPadding:
                                const EdgeInsets.symmetric(vertical: 4.0),
                            leading: Container(
                              width: 48.0,
                              height: 48.0,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8.0),
                                color: surface1,
                              ),
                              child: const Icon(
                                Icons.shopping_bag_outlined,
                                color: Colors.black12,
                                size: 24.0,
                              ),
                            ),
                            title: Text.rich(TextSpan(
                              text: items[index]['product']['name'],
                              children: [
                                TextSpan(
                                    text:
                                        ' x${items[index]['quantity'].toString()}'),
                              ],
                            )),
                            subtitle: Text.rich(
                              TextSpan(
                                text: 'RWF ',
                                children: [
                                  TextSpan(
                                    text: items[index]['price_per_item']
                                        .toStringAsFixed(2),
                                  )
                                ],
                              ),
                            ),
                            trailing: Text.rich(
                              TextSpan(
                                text: 'RWF ',
                                children: [
                                  TextSpan(
                                    text: (items[index]['price_per_item'] *
                                            items[index]['quantity'])
                                        .toStringAsFixed(2),
                                  )
                                ],
                              ),
                              style: subtitle2,
                            ),
                          );
                        }),
                    const SizedBox(height: 24.0),
                    Row(
                      children: [
                        const Text(
                          "Total price",
                          style: priceText2,
                        ),
                        const Expanded(child: SizedBox()),
                        Text.rich(
                          TextSpan(
                            text: 'RWF ',
                            children: [
                              TextSpan(text: totalPrice.toStringAsFixed(2))
                            ],
                          ),
                          style: priceText2,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16.0),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          "Payment status",
                          style: priceText2,
                        ),
                        const Expanded(child: SizedBox()),
                        Chip(
                          label: Text(
                            isPaid ? "Paid" : "Payment pending",
                            style: subtitle2.copyWith(
                              color: isPaid ? primary : Colors.red[900],
                            ),
                          ),
                          backgroundColor: isPaid ? surface3 : Colors.red[100],
                          side: BorderSide.none,
                        )
                      ],
                    ),
                    isPaid
                        ? const SizedBox()
                        : Padding(
                            padding: const EdgeInsets.only(top: 48.0),
                            child: OutlinedAppButton(
                              onPressed: () {},
                              labelText: "Mark As Paid",
                            ),
                          ),
                  ],
                ),
              ),
            ),
            actions: [
              Row(
                children: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text(
                      "Close",
                      style: body1.copyWith(color: primary),
                    ),
                  ),
                ],
              ),
            ],
          );
        });
  }

  Future<void> _getTransactionItemsData({required String transactionId}) async {
    if (!mounted) return;
    setState(() {
      _isLoading2 = true;
    });

    try {
      final currentWorkspace = await getCurrentWorkspaceId();

      final List<Map<String, dynamic>> items =
          await WorkspaceService().getTransactionItems(
        workspaceId: currentWorkspace!,
        transactionId: transactionId,
      );
      
      if (!mounted) return;
      setState(() {
        _transactionItemsData = items;
        _isLoading2 = false;
      });
    } on GenericWorkspaceException {
      log("Error occurred");
      _isLoading2 = false;
    } catch (e) {
      log(e.toString());
      _isLoading2 = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return _isLoading
        ? const Center(child: AppCircularProgressIndicator())
        : SizedBox(
            width: MediaQuery.of(context).size.width * 0.9,
            height: MediaQuery.of(context).size.height,
            child: PlutoGrid(
              rowColorCallback: (rowColorContext) {
                return rowColorContext.row.cells['paid']?.value == false
                    ? Colors.red[50]!
                    : Colors.white;
              },
              mode: PlutoGridMode.selectWithOneTap,
              columns: debtorDataColumns,
              rows: debtorDataRows,
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
                  Text("No debtors added"),
                ],
              ),
              onLoaded: (PlutoGridOnLoadedEvent event) {
                stateManager = event.stateManager;
                // stateManager.setShowColumnFilter(true);
                stateManager.setSelectingMode(PlutoGridSelectingMode.none);
              },
              onChanged: (PlutoGridOnChangedEvent event) {
                log(event.toString());
              },
              onSelected: (PlutoGridOnSelectedEvent event) async {
                if (event.row != null) {
                  String transactionId = event.row!.cells.entries
                      .map((e) => e.value.value.toString())
                      .toList()[6]
                      .toString();
                  bool isPaid = event.row!.cells.entries
                      .map((e) => e.value.value)
                      .toList()[5] as bool;
                  await _getTransactionItemsData(transactionId: transactionId);
                  log(transactionId);
                  _openDetail(
                    row: event.row!,
                    items: _transactionItemsData!,
                    isPaid: isPaid,
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
