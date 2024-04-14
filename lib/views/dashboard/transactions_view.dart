import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:shinda_app/components/circular_progress_indicator.dart';
import 'package:shinda_app/constants/text_syles.dart';
import 'package:shinda_app/services/workspace/workspace_exceptions.dart';
import 'package:shinda_app/services/workspace/workspace_service.dart';
import 'package:shinda_app/utilities/get_workspace.dart';
import 'package:shinda_app/utilities/transaction_data.dart';
import 'package:shinda_app/responsive/responsive_layout.dart';
import 'package:shinda_app/views/mobile_views/transaction_details_view.dart';

class TransactionsView extends StatefulWidget {
  const TransactionsView({super.key});

  @override
  State<TransactionsView> createState() => _TransactionsViewState();
}

class _TransactionsViewState extends State<TransactionsView> {
  bool _isLoading = false;
  List<Map<String, dynamic>>? _transactionsData;

  @override
  void initState() {
    super.initState();

    _getTransactionData();
  }

  void _getTransactionData() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
    });

    try {
      final currentWorkspace = await getCurrentWorkspaceId();

      final List<Map<String, dynamic>> transactions = await WorkspaceService()
          .getTransactions(workspaceId: currentWorkspace!);

      if (!mounted) return;
      setState(() {
        _transactionsData = transactions;
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

  @override
  Widget build(BuildContext context) {
    return _isLoading
        ? SizedBox(
            height: MediaQuery.of(context).size.height * 0.8,
            child: const Center(
              child: Padding(
                padding: EdgeInsets.all(24.0),
                child: AppCircularProgressIndicator(),
              ),
            ),
          )
        : Column(
            children: [
              const Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Transactions",
                    style: dashboardHeadline,
                  ),
                ],
              ),
              const SizedBox(height: 16.0),

              // ***WITH TRANSACTION DATA***
              _transactionsData != null && _transactionsData!.isNotEmpty

                  // *** MOBILE WITH TRANSACTION DATA ***
                  ? Responsive.isMobile(context)
                      ? ListView.builder(
                          physics: const NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          itemBuilder: (BuildContext context, int index) {
                            DateTime date = DateTime.parse(
                                _transactionsData![index]['created_at']);

                            return Padding(
                              padding: const EdgeInsets.only(bottom: 8.0),
                              child: Container(
                                decoration: BoxDecoration(
                                  border: Border.all(color: surface3),
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 4.0,
                                        horizontal: 4.0,
                                      ),
                                      child: Row(
                                        children: [
                                          Chip(
                                            side: BorderSide.none,
                                            backgroundColor: surface1,
                                            padding: const EdgeInsets.all(4.0),
                                            label: Text(
                                                "${date.year}-${date.month}-${date.day}"),
                                          ),
                                          if (!_transactionsData![index]
                                              ['is_paid'])
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  left: 8.0),
                                              child: Chip(
                                                side: BorderSide.none,
                                                backgroundColor:
                                                    Colors.red[100],
                                                padding:
                                                    const EdgeInsets.all(4.0),
                                                label: Text(
                                                  "Payment pending",
                                                  style: TextStyle(
                                                      color: Colors.red[900]),
                                                ),
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),
                                    ListTile(
                                      isThreeLine: true,
                                      title: Text(
                                        "Id: ${_transactionsData![index]['transaction_id']}",
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      subtitle: Text(
                                          "Total: RWF ${_transactionsData![index]['grand_total'].toStringAsFixed(2)}"),
                                      trailing: IconButton(
                                        icon: const Icon(
                                            Icons.chevron_right_outlined),
                                        onPressed: () {
                                          Navigator.of(context).push(
                                            MaterialPageRoute(
                                              builder: (BuildContext context) =>
                                                  TransactionDetailsView(
                                                id: _transactionsData![index]
                                                    ['transaction_id'],
                                                isPaid:
                                                    _transactionsData![index]
                                                        ['is_paid'],
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                          itemCount: _transactionsData!.length,
                        )

                      // ***TABLET & DESKTOP WITH TRANSACTION DATA***
                      : SizedBox(
                          width: MediaQuery.of(context).size.width * 0.9,
                          child: TransactionDataGrid(data: _transactionsData!),
                        )

                  // ***WITH NO TRANSACTION DATA***
                  : SizedBox(
                      height: MediaQuery.of(context).size.height * 0.6,
                      child: const Center(
                        child: Padding(
                          padding: EdgeInsets.all(48.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.point_of_sale_outlined,
                                size: 180,
                                color: surface3,
                              ),
                              SizedBox(height: 48.0),
                              Text(
                                "No transactions yet",
                                style: body1,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
            ],
          );
  }
}
