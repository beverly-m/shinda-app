import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:shinda_app/constants/text_syles.dart';
import 'package:shinda_app/services/workspace/workspace_exceptions.dart';
import 'package:shinda_app/services/workspace/workspace_service.dart';
import 'package:shinda_app/utilities/get_workspace.dart';
import 'package:shinda_app/utilities/transaction_data.dart';

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
    setState(() {
      _isLoading = true;
    });

    try {
      final currentWorkspace = await getCurrentWorkspaceId();

      final List<Map<String, dynamic>> transactions = await WorkspaceService()
          .getTransactions(workspaceId: currentWorkspace!);

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
        ? const Center(
            child: Padding(
              padding: EdgeInsets.all(24.0),
              child: CircularProgressIndicator(
                color: primary,
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
              _transactionsData != null && _transactionsData!.isNotEmpty
                  ? SizedBox(
                      width: MediaQuery.of(context).size.width * 0.9,
                      child: TransactionDataGrid(data: _transactionsData!),
                    )
                  : const Center(
                      child: Padding(
                        padding: EdgeInsets.all(48.0),
                        child: Column(
                          children: [
                            Icon(
                              Icons.point_of_sale_outlined,
                              size: 200,
                              color: Color.fromRGBO(219, 240, 239, 1),
                            ),
                            SizedBox(height: 48.0),
                            Text(
                              "No transactions yet",
                              style: TextStyle(fontSize: 16),
                            ),
                          ],
                        ),
                      ),
                    ),
            ],
          );
  }
}
