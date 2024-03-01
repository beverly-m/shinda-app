import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shinda_app/components/product.dart';
import 'package:shinda_app/services/workspace/workspace_exceptions.dart';
import 'package:shinda_app/services/workspace/workspace_service.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:shinda_app/utilities/get_workspace.dart';

class DebtorsView extends StatefulWidget {
  const DebtorsView({super.key});

  @override
  State<DebtorsView> createState() => _DebtorsViewState();
}

class _DebtorsViewState extends State<DebtorsView> {
  final GlobalKey<FormState> _formKey = GlobalKey();

  bool _isLoading = false;
  String _phoneNumberWithCode = "";
  PhoneNumber number = PhoneNumber(isoCode: 'RW');

  late final TextEditingController _clientName;
  late final TextEditingController _phoneNumber;
  late final TextEditingController _address;
  late final TextEditingController _searchController;

  List<Map<String, dynamic>>? _debtorsData;

  List<Map<String, dynamic>>? _productsData;

  final List<CartItem> _orderData = [];

  late DataTableSource _debtorsDataSource;

  @override
  void initState() {
    super.initState();
    _clientName = TextEditingController();
    _phoneNumber = TextEditingController();
    _address = TextEditingController();
    _searchController = TextEditingController();

    _getProductData();
  }

  @override
  void dispose() {
    _clientName.dispose();
    _phoneNumber.dispose();
    _address.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: _isLoading
          ? const Center(
              child: Padding(
                padding: EdgeInsets.all(24.0),
                child: CircularProgressIndicator(
                  color: Color.fromRGBO(0, 121, 107, 1),
                ),
              ),
            )
          : Center(
              child: Padding(
                padding: const EdgeInsets.all(128.0),
                child: Column(
                  children: [
                    Center(
                      child: Text(
                        "Debtors",
                        style: GoogleFonts.eczar(
                            textStyle: const TextStyle(
                          fontSize: 40,
                          fontWeight: FontWeight.bold,
                          color: Color.fromRGBO(0, 121, 107, 1),
                        )),
                      ),
                    ),
                    // _debtorsData != null
                    //     ? SizedBox(
                    //         width: MediaQuery.of(context).size.width * 0.8,
                    //         child: PaginatedDataTable(
                    //           columns: debtorDataColumns,
                    //           source: _debtorsDataSource,
                    //           rowsPerPage: 10,
                    //           columnSpacing: 100,
                    //         ),
                    //       )
                    //     : const SizedBox(),
                    const Icon(
                      Icons.wallet_outlined,
                      size: 200,
                      color: Color.fromRGBO(219, 240, 239, 1),
                    ),
                    const SizedBox(height: 48.0),
                    FilledButton(
                      style: const ButtonStyle(
                        backgroundColor: MaterialStatePropertyAll(
                          Color.fromRGBO(0, 121, 107, 1),
                        ),
                      ),
                      onPressed: () async {
                        await _showAddDebtorDialog(context);
                      },
                      child: const Text(
                        "Add Debtor",
                        style: TextStyle(fontSize: 16.0),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Future<void> _showAddDebtorDialog(BuildContext context) {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: Colors.white,
            surfaceTintColor: const Color.fromRGBO(241, 249, 249, 1),
            scrollable: true,
            title: const Text("New debtor"),
            contentPadding: const EdgeInsets.all(48.0),
            content: SizedBox(
              width: MediaQuery.of(context).size.width * 0.6,
              // height: MediaQuery.of(context).size.height * 0.6,
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            cursorColor: const Color.fromRGBO(0, 121, 107, 1),
                            decoration: const InputDecoration(
                              hoverColor: Color.fromRGBO(0, 121, 107, 1),
                              focusColor: Color.fromRGBO(0, 121, 107, 1),
                              labelText: "Client name",
                              hintText: "Enter the name of the client",
                            ),
                            controller: _clientName,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Client name required';
                              } else if (value.length < 3) {
                                return "At least 3 characters";
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(
                          width: 16.0,
                        ),
                        Expanded(
                          child: InternationalPhoneNumberInput(
                            cursorColor: const Color.fromRGBO(0, 121, 107, 1),
                            initialValue: number,
                            onInputChanged: (PhoneNumber number) {
                              setState(() {
                                _phoneNumberWithCode = number.phoneNumber!;
                              });
                              log(_phoneNumberWithCode);
                            },
                            onInputValidated: (bool value) {
                              log(value.toString());
                            },
                            selectorConfig: const SelectorConfig(
                                selectorType: PhoneInputSelectorType.DROPDOWN),
                            ignoreBlank: false,
                            keyboardType: const TextInputType.numberWithOptions(
                              signed: true,
                              decimal: true,
                            ),
                            textFieldController: _phoneNumber,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 16.0,
                    ),
                    TextFormField(
                      cursorColor: const Color.fromRGBO(0, 121, 107, 1),
                      decoration: const InputDecoration(
                        hoverColor: Color.fromRGBO(0, 121, 107, 1),
                        focusColor: Color.fromRGBO(0, 121, 107, 1),
                        labelText: "Address",
                        hintText: "Enter your address here",
                      ),
                      controller: _address,
                    ),
                    const SizedBox(height: 24.0),
                    const Text(
                      "Select ordered items",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8.0),
                    _productsData != null && _productsData!.isNotEmpty
                        ? TextField(
                            cursorColor: const Color.fromRGBO(0, 121, 107, 1),
                            controller: _searchController,
                            decoration: InputDecoration(
                              hoverColor: const Color.fromRGBO(0, 121, 107, 1),
                              focusColor: const Color.fromRGBO(0, 121, 107, 1),
                              contentPadding: const EdgeInsets.all(0),
                              prefixIcon: const Icon(Icons.search),
                              hintText: 'Product name...',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide:
                                    const BorderSide(color: Colors.black12),
                              ),
                            ),
                          )
                        : const Text("Add products to pick"),
                    _productsData != null && _productsData!.isNotEmpty
                        ? const SizedBox(height: 16.0)
                        : const SizedBox(),
                    _productsData != null && _productsData!.isNotEmpty
                        ? Container(
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.black12),
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            height: 80,
                            child: ListView.builder(
                                scrollDirection: Axis.vertical,
                                itemCount: _productsData!.length,
                                shrinkWrap: true,
                                itemBuilder: (context, index) {
                                  return ListTile(
                                    title: Text(_productsData![index]['product']
                                        ['name']),
                                    trailing: IconButton(
                                      icon: const Icon(Icons.add),
                                      onPressed: () {
                                        _incrementProduct(
                                            product: _productsData![index]);
                                      },
                                    ),
                                  );
                                }),
                          )
                        : const SizedBox(),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  _clientName.clear();
                  _address.clear();
                  _phoneNumber.clear();
                  Navigator.of(context).pop();
                },
                child: const Text(
                  "Cancel",
                  style: TextStyle(
                    fontSize: 16,
                    color: Color.fromRGBO(0, 121, 107, 1),
                  ),
                ),
              ),
              FilledButton(
                onPressed: _addDebtor,
                style: const ButtonStyle(
                  backgroundColor: MaterialStatePropertyAll(
                    Color.fromRGBO(0, 121, 107, 1),
                  ),
                ),
                child: const Text(
                  "Add Debtor",
                  style: TextStyle(
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          );
        });
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

  void _addDebtor() async {
    final isValid = _formKey.currentState?.validate();

    setState(() {
      _isLoading = true;
    });

    log("${_clientName.text}, ${_address.text}, ${_phoneNumber.text}");

    if (isValid != null && isValid) {
      Navigator.of(context).pop();

      final clientName = _clientName.text.trim();
      final address = _address.text.trim();
      final phoneNumber = _phoneNumberWithCode;

      _clientName.clear();
      _address.clear();
      _phoneNumber.clear();

      log("$clientName, $address, $phoneNumber");

      setState(() {
        _isLoading = false;
      });
    }

    setState(() {
      _isLoading = false;
    });
  }

  void _incrementProduct({required Map<String, dynamic> product}) {
    log("incrementtttt");
    log(product.keys.toString());
    log(product['product'].toString());
    bool isFound = false;
    for (var element in _orderData) {
      if (element.productId == product['product']['product_id']) {
        isFound = true;
        element.quantity = element.quantity + 1;
      }
    }

    log(isFound.toString());

    if (!isFound) {
      _orderData.add(
        CartItem(
          productId: product['product']['product_id'],
          price: product['product']['price'],
          quantity: 1,
          productName: product['product']['name'],
        ),
      );
    }

    log(_orderData.toString());
  }
}
