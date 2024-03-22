import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:shinda_app/constants/text_syles.dart';
import 'package:shinda_app/services/workspace/workspace_exceptions.dart';
import 'package:shinda_app/services/workspace/workspace_service.dart';
import 'package:shinda_app/utilities/get_workspace.dart';

class DebtorDetailsView extends StatefulWidget {
  const DebtorDetailsView({super.key, required this.id, required this.isPaid});
  final String id;
  final bool isPaid;

  @override
  State<DebtorDetailsView> createState() => _DebtorDetailsViewState();
}

class _DebtorDetailsViewState extends State<DebtorDetailsView> {
  bool _isLoading = false;
  List<Map<String, dynamic>>? _transactionItemsData;

  @override
  void initState() {
    super.initState();
    _getTransactionItemsData(transactionId: widget.id);
  }

  void _getTransactionItemsData({required String transactionId}) async {
    setState(() {
      _isLoading = true;
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
        _isLoading = false;
      });
    } on GenericWorkspaceException {
      log("Error occurred");
    } catch (e) {
      log(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Debtor Details"),
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
                    ]),
              ),
            ),
    );
  }
}
