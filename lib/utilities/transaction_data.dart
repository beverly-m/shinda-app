import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:pluto_grid/pluto_grid.dart';
import 'package:shinda_app/components/buttons.dart';
import 'package:shinda_app/constants/text_syles.dart';
import 'package:shinda_app/services/workspace/workspace_exceptions.dart';
import 'package:shinda_app/services/workspace/workspace_service.dart';
import 'package:shinda_app/utilities/get_workspace.dart';

class TransactionDataGrid extends StatefulWidget {
  const TransactionDataGrid({super.key, required this.data});

  final List<Map<String, dynamic>> data;

  @override
  State<TransactionDataGrid> createState() => _TransactionDataGridState();
}

class _TransactionDataGridState extends State<TransactionDataGrid> {
  bool _isLoading = false;
  bool _isLoading2 = false;

  List<Map<String, dynamic>>? _transactionItemsData;
  Map<String, dynamic>? _debtorData;

  List<PlutoColumn> transactionDataColumns = [
    PlutoColumn(
      title: 'Transaction id',
      field: 'transaction_id',
      type: PlutoColumnType.text(),
    ),
    PlutoColumn(
      title: 'Mode of payment',
      field: 'payment_mode',
      type: PlutoColumnType.text(),
    ),
    PlutoColumn(
      title: 'Total Cost',
      field: 'total_cost',
      type: PlutoColumnType.currency(
        name: 'RWF',
        symbol: 'RWF',
        decimalDigits: 2,
      ),
    ),
    PlutoColumn(
      title: 'Paid',
      field: 'paid',
      type: PlutoColumnType.select(['true', 'false']),
    ),
    PlutoColumn(
      title: 'Date created',
      field: 'date_created',
      type: PlutoColumnType.date(),
    ),
    PlutoColumn(
      title: 'Details',
      field: 'details',
      type: PlutoColumnType.text(),
    ),
  ];

  final List<PlutoRow> transactionDataRows = [];
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
      transactionDataRows.add(
        PlutoRow(
          cells: {
            'transaction_id': PlutoCell(value: element['transaction_id']),
            'payment_mode': PlutoCell(value: element['payment_mode']),
            'total_cost': PlutoCell(value: element['grand_total']),
            'paid': PlutoCell(value: element['is_paid']),
            'date_created': PlutoCell(value: element['created_at']),
            'details': PlutoCell(value: 'View Details'),
          },
        ),
      );
    }

    setState(() {
      _isLoading = false;
    });
  }

  void _openDetail({
    required PlutoRow row,
    required List<Map<String, dynamic>> items,
    Map<String, dynamic>? debtor,
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
              height: 300.0,
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
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(
                                height: 16.0,
                              ),
                              const Divider(
                                height: 0.5,
                                thickness: 0.5,
                                color: surface3,
                              ),
                              const SizedBox(
                                height: 16.0,
                              ),
                              const Text(
                                "Client details",
                                style: dashboardSubtitle,
                              ),
                              const SizedBox(height: 8.0),
                              ListTile(
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
                                    Icons.person_outline,
                                    color: Colors.black12,
                                    size: 24.0,
                                  ),
                                ),
                                title: Text(debtor!['client_name']),
                                subtitle: Text.rich(
                                  TextSpan(
                                    text: debtor['phone_number'],
                                    children: [
                                      debtor['address'] != null
                                          ? TextSpan(
                                              text: ' | ${debtor['address']}')
                                          : const TextSpan()
                                    ],
                                  ),
                                ),
                                trailing: OutlinedAppButton(
                                  onPressed: () {},
                                  labelText: "Mark As Paid",
                                ),
                              ),
                            ],
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

  Future<void> _getDebtorData({required String transactionId}) async {
    try {
      final currentWorkspace = await getCurrentWorkspaceId();

      final Map<String, dynamic> item = await WorkspaceService().getDebtor(
        workspaceId: currentWorkspace!,
        transactionId: transactionId,
      );

      setState(() {
        _debtorData = item;
      });
    } on GenericWorkspaceException {
      log("Error occurred");
    } catch (e) {
      log(e.toString());
    }
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
              mode: PlutoGridMode.selectWithOneTap,
              columns: transactionDataColumns,
              rows: transactionDataRows,
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
                  Text("No transactions yet"),
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
                      .toList()[0]
                      .toString();
                  bool isPaid = event.row!.cells.entries
                      .map((e) => e.value.value)
                      .toList()[3] as bool;
                  await _getTransactionItemsData(transactionId: transactionId);
                  if (!isPaid) {
                    await _getDebtorData(transactionId: transactionId);
                  }
                  log(transactionId);
                  _openDetail(
                    row: event.row!,
                    items: _transactionItemsData!,
                    isPaid: isPaid,
                    debtor: _debtorData,
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
