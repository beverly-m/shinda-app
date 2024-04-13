import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:shinda_app/components/buttons.dart';
import 'package:shinda_app/components/snackbar.dart';
import 'package:shinda_app/constants/text_syles.dart';
import 'package:shinda_app/enums/dropdown_menu.dart';
import 'package:shinda_app/services/auth/auth_exceptions.dart';
import 'package:shinda_app/services/workspace/workspace_exceptions.dart';
import 'package:shinda_app/services/workspace/workspace_service.dart';
import 'package:shinda_app/utilities/get_workspace.dart';
import 'package:shinda_app/utilities/show_error_dialog.dart';

class TransactionDetailsView extends StatefulWidget {
  const TransactionDetailsView(
      {super.key, required this.id, required this.isPaid});

  final String id;
  final bool isPaid;

  @override
  State<TransactionDetailsView> createState() => _TransactionDetailsViewState();
}

class _TransactionDetailsViewState extends State<TransactionDetailsView> {
  bool _isLoading = false;
  List<Map<String, dynamic>>? _transactionItemsData;
  Map<String, dynamic>? _debtor;
  late final TextEditingController _paymentModeController;
  PaymentModeLabel? selectedPaymentMode = PaymentModeLabel.cash;
  String? _currentWorkspaceId;

  @override
  void initState() {
    super.initState();
    _paymentModeController = TextEditingController();
    _getTransactionItemsData(transactionId: widget.id);
  }

  @override
  void dispose() {
    _paymentModeController.dispose();
    super.dispose();
  }

  void _getTransactionItemsData({required String transactionId}) async {
    setState(() {
      _isLoading = true;
    });

    try {
      Map<String, dynamic>? debtor;
      final currentWorkspace = await getCurrentWorkspaceId();

      final List<Map<String, dynamic>> items =
          await WorkspaceService().getTransactionItems(
        workspaceId: currentWorkspace!,
        transactionId: transactionId,
      );

      if (!widget.isPaid) {
        debtor = await WorkspaceService().getDebtor(
          workspaceId: currentWorkspace,
          transactionId: transactionId,
        );

        setState(() {
          _debtor = debtor;
        });
      }

      setState(() {
        _transactionItemsData = items;
        _currentWorkspaceId = currentWorkspace;
        _isLoading = false;
      });
    } on GenericWorkspaceException {
      log("Error occurred");
    } catch (e) {
      log(e.toString());
    }
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
            title: const Text(
              "Update Transaction",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            contentPadding: const EdgeInsets.all(16.0),
            content: SizedBox(
              height: 120,
              width: MediaQuery.of(context).size.width,
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
                  Expanded(
                    child: TextAppButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      labelText: 'Cancel',
                    ),
                  ),
                  const SizedBox(
                    width: 16.0,
                  ),
                  Expanded(
                    child: FilledAppButton(
                      onPressed: () {
                        _updateTransaction(
                          transactionId: transactionId,
                          paymentMode: selectedPaymentMode!.label,
                        );
                        Navigator.of(context).pop();
                      },
                      labelText: 'Update',
                    ),
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

      SnackBarService.showSnackBar(content: "Transaction status updated");

      setState(() {
        _isLoading = false;
      });

      _getTransactionItemsData(transactionId: transactionId);
    } on GenericWorkspaceException {
      log("Error occurred");
      _isLoading = false;
    } catch (e) {
      log(e.toString());
      _isLoading = false;
    }
  }

  Future<bool> _showDeleteTransactionDialog(BuildContext context) async {
    return showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          surfaceTintColor: surface1,
          title: const Text(
            'Delete transaction',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: const Text(
            "Are you sure you want to delete this transaction? This will delete every record associated with it.",
            style: body1,
          ),
          actions: [
            Row(
              children: [
                Expanded(
                  child: TextAppButton(
                      onPressed: () {
                        Navigator.of(context).pop(false);
                      },
                      labelText: 'Cancel'),
                ),
                const SizedBox(width: 16.0),
                Expanded(
                  child: FilledAppButton(
                    backgroundColor: Colors.red[900]!,
                    onPressed: () {
                      Navigator.of(context).pop(true);
                    },
                    labelText: 'Delete',
                  ),
                ),
              ],
            ),
          ],
        );
      },
    ).then((value) => value ?? false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Transaction Details",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: _isLoading
          ? const Center(
              child: Padding(
                padding: EdgeInsets.all(24.0),
                child: CircularProgressIndicator(
                  color: primary,
                ),
              ),
            )
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Products",
                      style: dashboardSubtitle,
                    ),
                    const SizedBox(height: 16.0),
                    ListView.builder(
                        shrinkWrap: true,
                        itemCount: _transactionItemsData!.length,
                        itemBuilder: (BuildContext context, int index) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: ListTile(
                              shape: RoundedRectangleBorder(
                                  side: const BorderSide(color: surface3),
                                  borderRadius: BorderRadius.circular(8.0)),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 8.0,
                                vertical: 4.0,
                              ),
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
                                text: _transactionItemsData![index]['product']
                                    ['name'],
                                children: [
                                  TextSpan(
                                      text:
                                          ' x${_transactionItemsData![index]['quantity'].toString()}'),
                                ],
                              )),
                              subtitle: Text.rich(
                                TextSpan(
                                  text: 'RWF ',
                                  children: [
                                    TextSpan(
                                      text: _transactionItemsData![index]
                                              ['price_per_item']
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
                                      text: (_transactionItemsData![index]
                                                  ['price_per_item'] *
                                              _transactionItemsData![index]
                                                  ['quantity'])
                                          .toStringAsFixed(2),
                                    )
                                  ],
                                ),
                                style: subtitle2,
                              ),
                            ),
                          );
                        }),
                    if (_debtor != null)
                      Column(
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
                            title: Text(_debtor!['client_name']),
                            subtitle: Text.rich(
                              TextSpan(
                                text: _debtor!['phone_number'],
                                children: [
                                  _debtor!['address'] != null
                                      ? TextSpan(
                                          text: ' | ${_debtor!['address']}')
                                      : const TextSpan()
                                ],
                              ),
                            ),
                            trailing: OutlinedAppButton(
                              onPressed: () {
                                _showUpdateTransactionDialog(
                                    transactionId: _debtor!['transaction']
                                        ['transaction_id']);
                              },
                              labelText: "Mark As Paid",
                            ),
                          ),
                        ],
                      ),
                    Column(
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
                          "Edit transaction",
                          style: dashboardSubtitle,
                        ),
                        const SizedBox(height: 16.0),
                        OutlinedAppButton(
                          onPressed: () async {
                            final isDelete =
                                await _showDeleteTransactionDialog(context);

                            if (isDelete) {
                              try {
                                await WorkspaceService().deleteTransaction(
                                  transactionId: widget.id,
                                  workspaceId: _currentWorkspaceId!,
                                );

                                SnackBarService.showSnackBar(
                                    content: "Transaction deleted");

                                if (context.mounted) {
                                  Navigator.of(context).pop();
                                }
                              } on GenericAuthException {
                                if (context.mounted) {
                                  await showErrorDialog(
                                    context,
                                    "An error occurred. Try again.",
                                  );
                                }
                              } catch (_) {
                                log(_.toString());
                                if (context.mounted) {
                                  await showErrorDialog(
                                    context,
                                    "An error occurred. Try again.",
                                  );
                                }
                              }
                            }
                          },
                          labelText: 'Delete Transaction',
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
