import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:pluto_grid/pluto_grid.dart';
import 'package:shinda_app/components/buttons.dart';
import 'package:shinda_app/constants/text_syles.dart';
import 'package:shinda_app/enums/dropdown_menu.dart';
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

  List<Map<String, dynamic>>? _transactionsData;
  List<Map<String, dynamic>>? _transactionItemsData;
  Map<String, dynamic>? _debtorData;

  late final TextEditingController _paymentModeController;
  PaymentModeLabel? selectedPaymentMode = PaymentModeLabel.cash;

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
  late final PlutoGridStateManager? stateManager;

  @override
  void initState() {
    super.initState();
    _paymentModeController = TextEditingController();
    _getData();
  }

  @override
  void dispose() {
    _paymentModeController.dispose();
    super.dispose();
  }

  void _getData() async {
    setState(() {
      _isLoading = true;
      // _transactionsData = widget.data;
    });

    try {
      final currentWorkspace = await getCurrentWorkspaceId();

      final List<Map<String, dynamic>> transactions = await WorkspaceService()
          .getTransactions(workspaceId: currentWorkspace!);

      setState(() {
        _transactionsData = transactions;
      });

      transactionDataRows.clear();

      for (var element in _transactionsData!) {
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
    } on GenericWorkspaceException {
      log("Error occurred");
      _isLoading = false;
    } catch (e) {
      log(e.toString());
      _isLoading = false;
    }
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
                                  onPressed: () {
                                    _showUpdateTransactionDialog(
                                        transactionId: debtor['transaction']
                                            ['transaction_id']);
                                  },
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

  Future<void> _showUpdateTransactionDialog({required String transactionId}) {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: Colors.white,
            surfaceTintColor: surface1,
            shape: OutlineInputBorder(
              borderSide: BorderSide.none,
              borderRadius: BorderRadius.circular(8.0),
            ),
            title: const Text("Update Transaction"),
            contentPadding: const EdgeInsets.all(24.0),
            content: SizedBox(
              height: 120,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 16.0),
                  DropdownMenu<PaymentModeLabel>(
                    menuStyle: MenuStyle(
                      shape: MaterialStatePropertyAll(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                    ),
                    initialSelection: PaymentModeLabel.cash,
                    controller: _paymentModeController,
                    requestFocusOnTap: true,
                    label: const Text(
                      'Payment Mode',
                      style: body1,
                    ),
                    onSelected: (PaymentModeLabel? paymentMode) {
                      setState(() {
                        selectedPaymentMode = paymentMode;
                      });
                    },
                    dropdownMenuEntries: PaymentModeLabel.values
                        .map<DropdownMenuEntry<PaymentModeLabel>>(
                            (PaymentModeLabel paymentMode) {
                      return DropdownMenuEntry<PaymentModeLabel>(
                        value: paymentMode,
                        label: paymentMode.label,
                        enabled: paymentMode.label != 'Grey',
                        style: MenuItemButton.styleFrom(
                          textStyle: body1,
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
            actions: [
              Row(
                children: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(
                    width: 16.0,
                  ),
                  FilledButton(
                    onPressed: () {
                      _updateTransaction(
                        transactionId: transactionId,
                        paymentMode: selectedPaymentMode!.label,
                      );
                      Navigator.of(context).pop();
                    },
                    child: const Text('Update Transaction'),
                  ),
                ],
              )
            ],
          );
        });
  }

  Future<void> _updateTransaction({
    required String transactionId,
    required String paymentMode,
  }) async {
    setState(() {
      _isLoading = true;
    });
    try {
      final currentWorkspace = await getCurrentWorkspaceId();

      await WorkspaceService().updateTransaction(
        workspaceId: currentWorkspace!,
        transactionId: transactionId,
        paymentMode: paymentMode,
      );

      if (!mounted) {
        return;
      }
      Navigator.of(context).pop();

      setState(() {
        _isLoading = false;
      });

      _getData();
    } on GenericWorkspaceException {
      log("Error occurred");
      _isLoading = false;
    } catch (e) {
      log(e.toString());
      _isLoading = false;
    }
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
                // stateManager = event.stateManager;
                // stateManager.setShowColumnFilter(true);
                event.stateManager
                    .setSelectingMode(PlutoGridSelectingMode.none);
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
