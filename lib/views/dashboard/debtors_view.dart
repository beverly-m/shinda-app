import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:shinda_app/components/circular_progress_indicator.dart';
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
    if (!mounted) return;
    setState(() {
      _isLoading = true;
    });

    try {
      final currentWorkspace = await getCurrentWorkspaceId();

      final List<Map<String, dynamic>> debtors =
          await WorkspaceService().getDebtors(workspaceId: currentWorkspace!);

      if (!mounted) return;
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
                    "Debtors",
                    style: dashboardHeadline,
                  ),
                ],
              ),
              const SizedBox(height: 16.0),

              // WITH DEBTORS DATA
              _debtorsData != null && _debtorsData!.isNotEmpty

                  // MOBILE WITH DEBTORS DATA
                  ? Responsive.isMobile(context)
                      ? ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemBuilder: (BuildContext context, int index) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 8.0),
                              child: InkWell(
                                borderRadius: BorderRadius.circular(8.0),
                                onTap: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (BuildContext context) =>
                                          DebtorDetailsView(
                                        id: _debtorsData![index]['transaction']
                                            ['transaction_id'],
                                        isPaid: _debtorsData![index]
                                            ['transaction']['is_paid'],
                                      ),
                                    ),
                                  );
                                },
                                hoverColor: Colors.transparent,
                                child: Container(
                                  decoration: BoxDecoration(
                                    border: Border.all(color: surface3),
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      !_debtorsData![index]['transaction']
                                              ['is_paid']
                                          ? Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                vertical: 8.0,
                                                horizontal: 4.0,
                                              ).copyWith(bottom: 0.0),
                                              child: Padding(
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
                                            )
                                          : Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                vertical: 8.0,
                                                horizontal: 4.0,
                                              ).copyWith(bottom: 0.0),
                                              child: Padding(
                                                padding: const EdgeInsets.only(
                                                    left: 8.0),
                                                child: Chip(
                                                  side: BorderSide.none,
                                                  backgroundColor:
                                                      Colors.green[100],
                                                  padding:
                                                      const EdgeInsets.all(4.0),
                                                  label: Text(
                                                    "Paid",
                                                    style: TextStyle(
                                                        color:
                                                            Colors.green[900]),
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
                                                builder:
                                                    (BuildContext context) =>
                                                        DebtorDetailsView(
                                                  id: _debtorsData![index]
                                                          ['transaction']
                                                      ['transaction_id'],
                                                  isPaid: _debtorsData![index]
                                                          ['transaction']
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
                              ),
                            );
                          },
                          itemCount: _debtorsData!.length,
                        )

                      // TABLET & DESKTOP WITH DEBTORS DATA
                      : SizedBox(
                          width: MediaQuery.of(context).size.width * 0.9,
                          child: DebtorDataGrid(data: _debtorsData!),
                        )

                  // WITH NO DEBTORS DATA
                  : SizedBox(
                      height: MediaQuery.of(context).size.height * 0.6,
                      child: const Center(
                        child: Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.wallet_outlined,
                                size: 180,
                                color: surface3,
                              ),
                              SizedBox(height: 48.0),
                              Text(
                                "Clients who buy on credit will appear here",
                                textAlign: TextAlign.center,
                                style: TextStyle(fontSize: 16),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
            ],
          );
  }

  void _getProductData() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
    });

    try {
      final currentWorkspace = await getCurrentWorkspaceId();

      final List<Map<String, dynamic>> products =
          await WorkspaceService().getProducts(workspaceId: currentWorkspace!);

      if (!mounted) return;
      setState(() {
        _productsData = products;
      });

      for (var element in _productsData!) {
        log(element.toString());
      }

      if (!mounted) return;
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
