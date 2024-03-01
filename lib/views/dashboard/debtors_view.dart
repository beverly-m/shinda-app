import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:shinda_app/components/product.dart';
import 'package:shinda_app/services/workspace/workspace_exceptions.dart';
import 'package:shinda_app/services/workspace/workspace_service.dart';
import 'package:shinda_app/utilities/debtor_data.dart';
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

  List<CartItem>? _orderData;

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
                child: CircularProgressIndicator(),
              ),
            )
          : Column(
              children: [
                const Center(
                  child: Text(
                    "Debtors",
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
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
                const SizedBox(height: 48.0),
                FilledButton(
                  onPressed: () async {
                    await _showAddDebtorDialog(context);
                  },
                  child: const Text("Add Debtor"),
                ),
              ],
            ),
    );
  }

  Future<void> _showAddDebtorDialog(BuildContext context) {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            scrollable: true,
            title: const Text("New debtor"),
            contentPadding: const EdgeInsets.all(48.0),
            content: SizedBox(
              width: MediaQuery.of(context).size.width * 0.6,
              height: MediaQuery.of(context).size.height * 0.6,
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            decoration: const InputDecoration(
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
                      decoration: const InputDecoration(
                        labelText: "Address",
                        hintText: "Enter your address here",
                      ),
                      controller: _address,
                    ),
                    const SizedBox(height: 24.0),
                    const Divider(),
                    const SizedBox(height: 8.0),
                    const Text(
                      "Ordered Items",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    _productsData != null
                        ? TextField(
                            controller: _searchController,
                            decoration: InputDecoration(
                              prefixIcon: const Icon(Icons.search),
                              hintText: 'Product name...',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide:
                                    const BorderSide(color: Colors.black38),
                              ),
                            ),
                          )
                        : const Text("Add products to pick"),
                    _productsData != null
                        ? ListView.builder(
                            scrollDirection: Axis.vertical,
                            itemCount: _productsData!.length,
                            shrinkWrap: true,
                            itemBuilder: (context, index) {
                              return Row(
                                children: [
                                  Expanded(
                                    child: ListTile(
                                      title: Text(_productsData![index]
                                          ['product']['name']),
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: IconButton(
                                          onPressed: () {},
                                          icon: const Icon(Icons.add),
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      const Expanded(
                                        child: Text(
                                          '1',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        child: IconButton(
                                          onPressed: () {},
                                          icon: const Icon(Icons.remove),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              );
                            })
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
                child: const Text("Cancel"),
              ),
              TextButton(
                onPressed: _addDebtor,
                child: const Text("Add Debtor"),
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
      final currentWorkspace = await getCurrentWorkspace();

      final List<Map<String, dynamic>> products =
          await WorkspaceService().getProducts(workspaceId: currentWorkspace!);

      setState(() {
        _productsData = products;
      });

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
}
