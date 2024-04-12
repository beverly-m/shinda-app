import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:shinda_app/constants/text_syles.dart';
import 'package:shinda_app/responsive/responsive_layout.dart';
import 'package:shinda_app/services/workspace/workspace_exceptions.dart';
import 'package:shinda_app/services/workspace/workspace_service.dart';
import 'package:shinda_app/utilities/debtor_data.dart';
import 'package:shinda_app/utilities/get_workspace.dart';
import 'package:shinda_app/views/mobile_views/debtor_details_view.dart';

class DebtorsView extends StatefulWidget {
  const DebtorsView({super.key});

  @override
  State<DebtorsView> createState() => _DebtorsViewState();
}

class _DebtorsViewState extends State<DebtorsView> {
  bool _isLoading = false;

  List<Map<String, dynamic>>? _debtorsData;

  List<Map<String, dynamic>>? _productsData;

  @override
  void initState() {
    super.initState();

    _getDebtorData();
  }

  void _getDebtorData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final currentWorkspace = await getCurrentWorkspaceId();

      final List<Map<String, dynamic>> debtors =
          await WorkspaceService().getDebtors(workspaceId: currentWorkspace!);

      setState(() {
        _debtorsData = debtors;
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
                    "Debtors",
                    style: dashboardHeadline,
                  ),
                ],
              ),
              const SizedBox(height: 16.0),
              _debtorsData != null && _debtorsData!.isNotEmpty
                  ? Responsive.isMobile(context)
                      ? ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemBuilder: (BuildContext context, int index) {
                            // DateTime date = DateTime.parse(
                            //     _debtorsData![index]['created_at']);

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
                                    if (!_debtorsData![index]['transaction']
                                        ['is_paid'])
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 4.0,
                                          horizontal: 4.0,
                                        ),
                                        child: Padding(
                                          padding:
                                              const EdgeInsets.only(left: 8.0),
                                          child: Chip(
                                            side: BorderSide.none,
                                            backgroundColor: Colors.red[100],
                                            padding: const EdgeInsets.all(4.0),
                                            label: Text(
                                              "Payment pending",
                                              style: TextStyle(
                                                  color: Colors.red[900]),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ListTile(
                                      isThreeLine: true,
                                      title: Text(
                                        _debtorsData![index]['client_name'],
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      subtitle: Text(
                                          "${!_debtorsData![index]['transaction']['is_paid'] ? "Owing" : "Paid"}: RWF ${_debtorsData![index]['amount_owed'].toStringAsFixed(2)}"),
                                      trailing: IconButton(
                                        icon: const Icon(
                                            Icons.chevron_right_outlined),
                                        onPressed: () {
                                          Navigator.of(context).push(
                                            MaterialPageRoute(
                                              builder: (BuildContext context) =>
                                                  DebtorDetailsView(
                                                id: _debtorsData![index]
                                                        ['transaction']
                                                    ['transaction_id'],
                                                isPaid: _debtorsData![index]
                                                    ['transaction']['is_paid'],
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
                          itemCount: _debtorsData!.length,
                        )
                      : SizedBox(
                          width: MediaQuery.of(context).size.width * 0.9,
                          child: DebtorDataGrid(data: _debtorsData!),
                        )
                  : const Center(
                      child: Padding(
                        padding: EdgeInsets.all(48.0),
                        child: Column(
                          children: [
                            Icon(
                              Icons.wallet_outlined,
                              size: 200,
                              color: Color.fromRGBO(219, 240, 239, 1),
                            ),
                            SizedBox(height: 48.0),
                            Text(
                              "Clients who buy on credit will appear here",
                              style: TextStyle(fontSize: 16),
                            ),
                          ],
                        ),
                      ),
                    ),
            ],
          );
  }

  void _getProductData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final currentWorkspace = await getCurrentWorkspaceId();

      final List<Map<String, dynamic>> products =
          await WorkspaceService().getProducts(workspaceId: currentWorkspace!);

      setState(() {
        _productsData = products;
      });

      for (var element in _productsData!) {
        log(element.toString());
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
}
