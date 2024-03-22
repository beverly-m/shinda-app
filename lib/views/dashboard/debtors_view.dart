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
                                          "Owing: RWF ${_debtorsData![index]['amount_owed'].toStringAsFixed(2)}"),
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
              // const SizedBox(height: 48.0),
              // FilledButton(
              //   style: const ButtonStyle(
              //     backgroundColor: MaterialStatePropertyAll(
              //       Color.fromRGBO(0, 121, 107, 1),
              //     ),
              //   ),
              //   onPressed: () async {
              //     await _showAddDebtorDialog(context);
              //   },
              //   child: const Text(
              //     "Add Debtor",
              //     style: TextStyle(fontSize: 16.0),
              //   ),
              // ),
            ],
          );
  }

  // Future<void> _showAddDebtorDialog(BuildContext context) {
  //   return showDialog(
  //       context: context,
  //       builder: (BuildContext context) {
  //         return AlertDialog(
  //           backgroundColor: Colors.white,
  //           surfaceTintColor: const Color.fromRGBO(241, 249, 249, 1),
  //           scrollable: true,
  //           title: const Text("New debtor"),
  //           contentPadding: const EdgeInsets.all(48.0),
  //           content: SizedBox(
  //             width: MediaQuery.of(context).size.width * 0.6,
  //             // height: MediaQuery.of(context).size.height * 0.6,
  //             child: Form(
  //               key: _formKey,
  //               child: Column(
  //                 crossAxisAlignment: CrossAxisAlignment.start,
  //                 children: [
  //                   Row(
  //                     children: [
  //                       Expanded(
  //                         child: TextFormField(
  //                           cursorColor: const Color.fromRGBO(0, 121, 107, 1),
  //                           decoration: const InputDecoration(
  //                             hoverColor: Color.fromRGBO(0, 121, 107, 1),
  //                             focusColor: Color.fromRGBO(0, 121, 107, 1),
  //                             labelText: "Client name",
  //                             hintText: "Enter the name of the client",
  //                           ),
  //                           controller: _clientName,
  //                           validator: (value) {
  //                             if (value == null || value.isEmpty) {
  //                               return 'Client name required';
  //                             } else if (value.length < 3) {
  //                               return "At least 3 characters";
  //                             }
  //                             return null;
  //                           },
  //                         ),
  //                       ),
  //                       const SizedBox(
  //                         width: 16.0,
  //                       ),
  //                       Expanded(
  //                         child: InternationalPhoneNumberInput(
  //                           cursorColor: const Color.fromRGBO(0, 121, 107, 1),
  //                           initialValue: number,
  //                           onInputChanged: (PhoneNumber number) {
  //                             setState(() {
  //                               _phoneNumberWithCode = number.phoneNumber!;
  //                             });
  //                             log(_phoneNumberWithCode);
  //                           },
  //                           onInputValidated: (bool value) {
  //                             log(value.toString());
  //                           },
  //                           selectorConfig: const SelectorConfig(
  //                               selectorType: PhoneInputSelectorType.DROPDOWN),
  //                           ignoreBlank: false,
  //                           keyboardType: const TextInputType.numberWithOptions(
  //                             signed: true,
  //                             decimal: true,
  //                           ),
  //                           textFieldController: _phoneNumber,
  //                         ),
  //                       ),
  //                     ],
  //                   ),
  //                   const SizedBox(
  //                     height: 16.0,
  //                   ),
  //                   TextFormField(
  //                     cursorColor: const Color.fromRGBO(0, 121, 107, 1),
  //                     decoration: const InputDecoration(
  //                       hoverColor: Color.fromRGBO(0, 121, 107, 1),
  //                       focusColor: Color.fromRGBO(0, 121, 107, 1),
  //                       labelText: "Address",
  //                       hintText: "Enter your address here",
  //                     ),
  //                     controller: _address,
  //                   ),
  //                   const SizedBox(height: 24.0),
  //                   const Text(
  //                     "Select ordered items",
  //                     style: TextStyle(
  //                       fontSize: 18,
  //                       fontWeight: FontWeight.bold,
  //                     ),
  //                   ),
  //                   const SizedBox(height: 8.0),
  //                   _productsData != null && _productsData!.isNotEmpty
  //                       ? TextField(
  //                           cursorColor: const Color.fromRGBO(0, 121, 107, 1),
  //                           controller: _searchController,
  //                           decoration: InputDecoration(
  //                             hoverColor: const Color.fromRGBO(0, 121, 107, 1),
  //                             focusColor: const Color.fromRGBO(0, 121, 107, 1),
  //                             contentPadding: const EdgeInsets.all(0),
  //                             prefixIcon: const Icon(Icons.search),
  //                             hintText: 'Product name...',
  //                             border: OutlineInputBorder(
  //                               borderRadius: BorderRadius.circular(8),
  //                               borderSide:
  //                                   const BorderSide(color: Colors.black12),
  //                             ),
  //                           ),
  //                         )
  //                       : const Text("Add products to pick"),
  //                   _productsData != null && _productsData!.isNotEmpty
  //                       ? const SizedBox(height: 16.0)
  //                       : const SizedBox(),
  //                   _productsData != null && _productsData!.isNotEmpty
  //                       ? Container(
  //                           decoration: BoxDecoration(
  //                             border: Border.all(color: Colors.black12),
  //                             borderRadius: BorderRadius.circular(8.0),
  //                           ),
  //                           height: 80,
  //                           child: ListView.builder(
  //                               scrollDirection: Axis.vertical,
  //                               itemCount: _productsData!.length,
  //                               shrinkWrap: true,
  //                               itemBuilder: (context, index) {
  //                                 return ListTile(
  //                                   title: Text(_productsData![index]['product']
  //                                       ['name']),
  //                                   trailing: IconButton(
  //                                     icon: const Icon(Icons.add),
  //                                     onPressed: () {
  //                                       _incrementProduct(
  //                                           product: _productsData![index]);
  //                                     },
  //                                   ),
  //                                 );
  //                               }),
  //                         )
  //                       : const SizedBox(),
  //                 ],
  //               ),
  //             ),
  //           ),
  //           actions: [
  //             TextButton(
  //               onPressed: () {
  //                 _clientName.clear();
  //                 _address.clear();
  //                 _phoneNumber.clear();
  //                 Navigator.of(context).pop();
  //               },
  //               child: const Text(
  //                 "Cancel",
  //                 style: TextStyle(
  //                   fontSize: 16,
  //                   color: Color.fromRGBO(0, 121, 107, 1),
  //                 ),
  //               ),
  //             ),
  //             FilledButton(
  //               onPressed: _addDebtor,
  //               style: const ButtonStyle(
  //                 backgroundColor: MaterialStatePropertyAll(
  //                   Color.fromRGBO(0, 121, 107, 1),
  //                 ),
  //               ),
  //               child: const Text(
  //                 "Add Debtor",
  //                 style: TextStyle(
  //                   fontSize: 16,
  //                 ),
  //               ),
  //             ),
  //           ],
  //         );
  //       });
  // }

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

  // void _addDebtor() async {
  //   final isValid = _formKey.currentState?.validate();

  //   setState(() {
  //     _isLoading = true;
  //   });

  //   log("${_clientName.text}, ${_address.text}, ${_phoneNumber.text}");

  //   if (isValid != null && isValid) {
  //     Navigator.of(context).pop();

  //     final clientName = _clientName.text.trim();
  //     final address = _address.text.trim();
  //     final phoneNumber = _phoneNumberWithCode;

  //     _clientName.clear();
  //     _address.clear();
  //     _phoneNumber.clear();

  //     log("$clientName, $address, $phoneNumber");

  //     setState(() {
  //       _isLoading = false;
  //     });
  //   }

  //   setState(() {
  //     _isLoading = false;
  //   });
  // }

  // void _incrementProduct({required Map<String, dynamic> product}) {
  //   log("incrementtttt");
  //   log(product.keys.toString());
  //   log(product['product'].toString());
  //   bool isFound = false;
  //   for (var element in _orderData) {
  //     if (element.productId == product['product']['product_id']) {
  //       isFound = true;
  //       element.quantity = element.quantity + 1;
  //     }
  //   }

  //   log(isFound.toString());

  //   if (!isFound) {
  //     _orderData.add(
  //       CartItem(
  //         productId: product['product']['product_id'],
  //         price: product['product']['price'],
  //         quantity: 1,
  //         productName: product['product']['name'],
  //       ),
  //     );
  //   }

  //   log(_orderData.toString());
  // }
}
