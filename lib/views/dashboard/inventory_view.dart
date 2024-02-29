import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:currency_text_input_formatter/currency_text_input_formatter.dart';
import 'package:flutter/services.dart';
import 'package:shinda_app/services/workspace/workspace_exceptions.dart';
import 'package:shinda_app/services/workspace/workspace_service.dart';
import 'package:shinda_app/utilities/get_workspace.dart';
import 'package:shinda_app/utilities/show_error_dialog.dart';

class InventoryView extends StatefulWidget {
  const InventoryView({super.key});

  @override
  State<InventoryView> createState() => _InventoryViewState();
}

class _InventoryViewState extends State<InventoryView> {
  final GlobalKey<FormState> _formKey = GlobalKey();

  final CurrencyTextInputFormatter _formatter = CurrencyTextInputFormatter(
    symbol: "RWF ",
    turnOffGrouping: true,
  );

  late final TextEditingController _productName;
  late final TextEditingController _description;
  late final TextEditingController _price;
  late final TextEditingController _quantity;
  late final TextEditingController _expirationDate;
  late final TextEditingController _reorderLevel;

  bool _isLoading = false;

  List<Map<String, dynamic>>? _productsData;

  @override
  void initState() {
    super.initState();

    _productName = TextEditingController();
    _description = TextEditingController();
    _price = TextEditingController();
    _quantity = TextEditingController();
    _expirationDate = TextEditingController();
    _reorderLevel = TextEditingController();

    _getProductData();
  }

  @override
  void dispose() {
    _productName.dispose();
    _description.dispose();
    _price.dispose();
    _quantity.dispose();
    _expirationDate.dispose();
    _reorderLevel.dispose();

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
                    "Inventory",
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                _productsData != null
                    ? Container(
                        padding: const EdgeInsets.all(16.0),
                        child: ListView.builder(
                          itemBuilder: (context, index) {
                            return Container(
                              margin: const EdgeInsets.only(bottom: 16.0),
                              decoration: BoxDecoration(
                                border: Border.all(
                                    color: const Color.fromARGB(
                                        100, 141, 166, 255),
                                    width: 2),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: SizedBox(
                                width: 300.0,
                                child: ListTile(
                                  title: Text(
                                      _productsData![index]["product"]['name']),
                                  subtitle: Text(_productsData![index]
                                          ['product']['price']
                                      .toString()),
                                  onTap: () {
                                    log(_productsData![index].toString());
                                  },
                                ),
                              ),
                            );
                          },
                          itemCount: _productsData!.length,
                          scrollDirection: Axis.vertical,
                          shrinkWrap: true,
                        ),
                      )
                    : const SizedBox(),
                const SizedBox(height: 48.0),
                FilledButton(
                  onPressed: () async {
                    await _showAddProductDialog(context);
                  },
                  child: const Text("Add Product"),
                ),
              ],
            ),
    );
  }

  void _addProduct() async {
    Navigator.of(context).pop();

    setState(() {
      _isLoading = true;
    });

    final isValid = _formKey.currentState?.validate();

    if (isValid != null && isValid) {
      final productName = _productName.text.trim();
      final description = _description.text.trim();
      final price = _price.text.trim().substring(4);
      final quantity = _quantity.text.trim();
      final reorderLevel = _reorderLevel.text.trim();
      final expirationDate = _expirationDate.text.trim();
      final workspaceId = await getCurrentWorkspace();

      _productName.clear();
      _description.clear();
      _price.clear();
      _quantity.clear();
      _reorderLevel.clear();
      _expirationDate.clear();

      try {
        await WorkspaceService().addProduct(
          workspaceId: workspaceId!,
          productName: productName,
          description: description,
          price: price,
          quantity: quantity,
          expirationDate: expirationDate,
          reorderQuantityLevel: reorderLevel,
        );

        _getProductData();

        setState(() {
          _isLoading = false;
        });
      } on GenericWorkspaceException {
        setState(() {
          _isLoading = false;
        });
        if (context.mounted) {
          showErrorDialog(context, "Failed to add product. Try again");
        }
      } catch (e) {
        setState(() {
          _isLoading = false;
        });
        if (context.mounted) {
          showErrorDialog(context, e.toString());
        }
      }
    }
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

  Future<void> _showAddProductDialog(BuildContext context) {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          scrollable: true,
          title: const Text("New product"),
          content: Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: "Name",
                    hintText: "Enter the product name",
                  ),
                  controller: _productName,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Product name required';
                    } else if (value.length < 3) {
                      return "At least 3 characters";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16.0),
                TextFormField(
                  decoration: const InputDecoration(
                      labelText: "Description (optional)",
                      hintText: "Enter description"),
                  controller: _description,
                  maxLines: 3,
                ),
                const SizedBox(height: 16.0),
                TextFormField(
                  keyboardType: TextInputType.number,
                  inputFormatters: <TextInputFormatter>[_formatter],
                  decoration: const InputDecoration(labelText: "Selling Price"),
                  controller: _price,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Price required';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16.0),
                TextFormField(
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: const InputDecoration(labelText: "Quantity"),
                  controller: _quantity,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Quantity required';
                    } else if (value == "0") {
                      return "Quantity must be more than 0";
                    }
                    return null;
                  },
                ),
                const SizedBox(width: 16.0),
                TextFormField(
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: const InputDecoration(
                      labelText: "Reorder quantity level"),
                  controller: _reorderLevel,
                ),
                const SizedBox(height: 16.0),
                TextFormField(
                  decoration: const InputDecoration(
                      labelText: "Expiration date (optional)"),
                  controller: _expirationDate,
                  readOnly: true,
                  onTap: () async {
                    FocusScope.of(context).requestFocus(FocusNode());

                    DateTime? date = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime.now(),
                      lastDate: DateTime(2040),
                    );

                    if (date != null) {
                      _expirationDate.text = date.toString();
                    }
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                _productName.clear();
                _description.clear();
                _price.clear();
                _quantity.clear();
                _reorderLevel.clear();
                _expirationDate.clear();
                Navigator.of(context).pop();
              },
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: _addProduct,
              child: const Text("Add product"),
            ),
          ],
        );
      },
    );
  }
}
