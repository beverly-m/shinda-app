import 'dart:developer';

import 'package:currency_text_input_formatter/currency_text_input_formatter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shinda_app/components/buttons.dart';
import 'package:shinda_app/constants/text_syles.dart';
import 'package:shinda_app/services/workspace/workspace_exceptions.dart';
import 'package:shinda_app/services/workspace/workspace_service.dart';
import 'package:shinda_app/utilities/get_workspace.dart';
import 'package:shinda_app/utilities/product_data.dart';
import 'package:shinda_app/utilities/show_error_dialog.dart';

class NewTransactionView extends StatefulWidget {
  const NewTransactionView({super.key});

  @override
  State<NewTransactionView> createState() => _NewTransactionViewState();
}

class _NewTransactionViewState extends State<NewTransactionView> {
  bool _isLoading = false;
  List<Map<String, dynamic>>? _productsData;
  final GlobalKey<FormState> _formKey = GlobalKey();
  late final TextEditingController _productName;
  late final TextEditingController _description;
  late final TextEditingController _price;
  late final TextEditingController _quantity;
  late final TextEditingController _expirationDate;
  late final TextEditingController _reorderLevel;
  final CurrencyTextInputFormatter _formatter =
      CurrencyTextInputFormatter(symbol: "RWF ", turnOffGrouping: true);
  late DataTableSource _productsDataSource;

  final List<Map> myProducts = List.generate(
    10,
    (index) => {
      "id": index,
      "product": "Product $index",
    },
  ).toList();

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

  Future<void> _showAddProductDialog(BuildContext context) {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          surfaceTintColor: const Color.fromRGBO(241, 249, 249, 1),
          shape: OutlineInputBorder(
            borderSide: BorderSide.none,
            borderRadius: BorderRadius.circular(8.0),
          ),
          scrollable: true,
          title: const Text("New product"),
          contentPadding: const EdgeInsets.all(48.0),
          content: SizedBox(
            width: MediaQuery.of(context).size.width * 0.6,
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    cursorColor: const Color.fromRGBO(0, 121, 107, 1),
                    decoration: const InputDecoration(
                      hoverColor: Color.fromRGBO(0, 121, 107, 1),
                      focusColor: Color.fromRGBO(0, 121, 107, 1),
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
                    cursorColor: const Color.fromRGBO(0, 121, 107, 1),
                    decoration: const InputDecoration(
                        hoverColor: Color.fromRGBO(0, 121, 107, 1),
                        focusColor: Color.fromRGBO(0, 121, 107, 1),
                        labelText: "Description (optional)",
                        hintText: "Enter description"),
                    controller: _description,
                    maxLines: 3,
                  ),
                  const SizedBox(height: 16.0),
                  TextFormField(
                    cursorColor: const Color.fromRGBO(0, 121, 107, 1),
                    keyboardType: TextInputType.number,
                    inputFormatters: <TextInputFormatter>[_formatter],
                    decoration: const InputDecoration(
                        hoverColor: Color.fromRGBO(0, 121, 107, 1),
                        focusColor: Color.fromRGBO(0, 121, 107, 1),
                        labelText: "Selling Price"),
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
                    cursorColor: const Color.fromRGBO(0, 121, 107, 1),
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    decoration: const InputDecoration(
                        hoverColor: Color.fromRGBO(0, 121, 107, 1),
                        focusColor: Color.fromRGBO(0, 121, 107, 1),
                        labelText: "Quantity"),
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
                    cursorColor: const Color.fromRGBO(0, 121, 107, 1),
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    decoration: const InputDecoration(
                        hoverColor: Color.fromRGBO(0, 121, 107, 1),
                        focusColor: Color.fromRGBO(0, 121, 107, 1),
                        labelText: "Reorder quantity level"),
                    controller: _reorderLevel,
                  ),
                  const SizedBox(height: 16.0),
                  TextFormField(
                    cursorColor: const Color.fromRGBO(0, 121, 107, 1),
                    decoration: const InputDecoration(
                        hoverColor: Color.fromRGBO(0, 121, 107, 1),
                        focusColor: Color.fromRGBO(0, 121, 107, 1),
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
              child: const Text(
                "Cancel",
                style: TextStyle(
                  fontSize: 16,
                  color: Color.fromRGBO(0, 121, 107, 1),
                ),
              ),
            ),
            FilledButton(
              onPressed: _addProduct,
              style: const ButtonStyle(
                  backgroundColor:
                      MaterialStatePropertyAll(Color.fromRGBO(0, 121, 107, 1))),
              child: const Text(
                "Add product",
                style: TextStyle(
                  fontSize: 16,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _addProduct() async {
    setState(() {
      _isLoading = true;
    });

    final isValid = _formKey.currentState?.validate();

    if (isValid != null && isValid) {
      Navigator.of(context).pop();

      final productName = _productName.text.trim();
      final description = _description.text.trim();
      final price = _price.text.trim().substring(4);
      final quantity = _quantity.text.trim();
      final reorderLevel = _reorderLevel.text.trim();
      final expirationDate = _expirationDate.text.trim();
      final workspaceId = await getCurrentWorkspaceId();

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
      final currentWorkspace = await getCurrentWorkspaceId();

      final List<Map<String, dynamic>> products =
          await WorkspaceService().getProducts(workspaceId: currentWorkspace!);

      setState(() {
        _productsData = products;
      });

      if (_productsData != null) {
        setState(() {
          _productsDataSource = ProductData(data: _productsData!);
        });
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
        : SizedBox(
            width: double.infinity,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "New Transaction",
                  style: dashboardHeadline,
                ),
                const SizedBox(height: 16.0),
                _productsData != null && _productsData!.isNotEmpty
                    ? Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: SingleChildScrollView(
                              child: SizedBox(
                                height: MediaQuery.of(context).size.height,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        const Text(
                                          "Products",
                                          style: dashboardSubtitle,
                                        ),
                                        Expanded(
                                          child: SizedBox(
                                            width: MediaQuery.of(context)
                                                .size
                                                .width,
                                          ),
                                        ),
                                        OutlinedAppButton(
                                          onPressed: () async {
                                            await _showAddProductDialog(
                                                context);
                                          },
                                          labelText: "New Product",
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 16.0),
                                    Expanded(
                                      child: GridView.builder(
                                        gridDelegate:
                                            const SliverGridDelegateWithMaxCrossAxisExtent(
                                          maxCrossAxisExtent: 216.0,
                                          crossAxisSpacing: 16.0,
                                          mainAxisSpacing: 16.0,
                                          childAspectRatio: 0.675,
                                        ),
                                        itemCount: _productsData!.length,
                                        shrinkWrap: true,
                                        itemBuilder: (context, index) {
                                          return Card(
                                            elevation: 0.0,
                                            surfaceTintColor: Colors.white,
                                            shape: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8.0),
                                              borderSide: const BorderSide(
                                                  color: surface3),
                                            ),
                                            child: Container(
                                              width: 200.0,
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Container(
                                                    width: double.infinity,
                                                    height: 122.0,
                                                    decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              8.0),
                                                      color: surface1,
                                                    ),
                                                    child: const Icon(
                                                      Icons
                                                          .shopping_bag_outlined,
                                                      color: Colors.black12,
                                                      size: 32.0,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 16.0),
                                                  Text(
                                                    _productsData![index]
                                                        ["product"]['name'],
                                                    style: body1,
                                                  ),
                                                  const SizedBox(height: 4.0),
                                                  Text(
                                                    "RWF ${_productsData![index]["product"]['price'].toStringAsFixed(2)}",
                                                    style: priceText,
                                                  ),
                                                  const SizedBox(height: 8.0),
                                                  Row(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .baseline,
                                                    textBaseline:
                                                        TextBaseline.alphabetic,
                                                    children: [
                                                      Text(
                                                        "${_productsData![index]['quantity_available'].toString()} in stock",
                                                        style: labelText,
                                                      ),
                                                      const Expanded(
                                                          child: SizedBox()),
                                                      IconButton(
                                                        style: IconButton
                                                            .styleFrom(
                                                          shape: RoundedRectangleBorder(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          8.0)),
                                                          side:
                                                              const BorderSide(
                                                                  color:
                                                                      primary),
                                                        ),
                                                        onPressed: () {},
                                                        icon: const Icon(
                                                          Icons.add,
                                                          size: 24.0,
                                                          color: primary,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ],
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
                          ),
                          const SizedBox(width: 48.0),
                          Container(
                            width: MediaQuery.of(context).size.width * 0.25,
                            decoration: BoxDecoration(
                              border: Border.all(color: surface1),
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            child: const Padding(
                              padding: EdgeInsets.all(24.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Cart",
                                    style: dashboardHeadings,
                                  ),
                                  SizedBox(height: 24.0),
                                  Center(
                                    child: Icon(
                                      Icons.shopping_cart_checkout_outlined,
                                      size: 200,
                                      color: Color.fromRGBO(219, 240, 239, 1),
                                    ),
                                  ),
                                  SizedBox(height: 24.0),
                                  Center(
                                    child: Text(
                                      "Cart items shown here",
                                      style: TextStyle(fontSize: 16),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      )
                    : Center(
                        child: Padding(
                          padding: const EdgeInsets.all(48.0),
                          child: Column(
                            children: [
                              const Icon(
                                Icons.inventory_2_outlined,
                                size: 200,
                                color: Color.fromRGBO(219, 240, 239, 1),
                              ),
                              const SizedBox(height: 48.0),
                              const Text(
                                "Add a new product to get started",
                                style: TextStyle(fontSize: 16),
                              ),
                              const SizedBox(height: 48.0),
                              FilledButton(
                                style: const ButtonStyle(
                                  backgroundColor: MaterialStatePropertyAll(
                                    Color.fromRGBO(0, 121, 107, 1),
                                  ),
                                ),
                                onPressed: () async {
                                  await _showAddProductDialog(context);
                                },
                                child: const Text(
                                  "Add Product",
                                  style: TextStyle(fontSize: 16.0),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
              ],
            ),
          );
  }
}
