import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:currency_text_input_formatter/currency_text_input_formatter.dart';
import 'package:flutter/services.dart';
import 'package:shinda_app/components/buttons.dart';
import 'package:shinda_app/components/textfields.dart';
import 'package:shinda_app/constants/text_syles.dart';
import 'package:shinda_app/responsive/responsive_layout.dart';
import 'package:shinda_app/services/workspace/workspace_exceptions.dart';
import 'package:shinda_app/services/workspace/workspace_service.dart';
import 'package:shinda_app/utilities/get_workspace.dart';
import 'package:shinda_app/utilities/inventory_data.dart';
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
  late final TextEditingController _quantity2;
  late final TextEditingController _expirationDate2;

  bool _isLoading = false;

  List<Map<String, dynamic>>? _productsData;

  final GlobalKey<FormState> _formKey2 = GlobalKey();

  @override
  void initState() {
    super.initState();

    _productName = TextEditingController();
    _description = TextEditingController();
    _price = TextEditingController();
    _quantity = TextEditingController();
    _expirationDate = TextEditingController();
    _quantity2 = TextEditingController();
    _expirationDate2 = TextEditingController();
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

  void _openDetail({required Map<String, dynamic> productData}) async {
    await showDialog(
      context: context,
      builder: (context) {
        final quantityAvailable = productData['quantity_available'];
        final reorderLevel = productData['reorder_level'];

        return AlertDialog(
          backgroundColor: Colors.white,
          surfaceTintColor: const Color.fromRGBO(241, 249, 249, 1),
          shape: OutlineInputBorder(
            borderSide: BorderSide.none,
            borderRadius: BorderRadius.circular(8.0),
          ),
          scrollable: true,
          title: const Text(
            "Edit Inventory Item",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          contentPadding: const EdgeInsets.all(24.0),
          content: SizedBox(
            width: MediaQuery.of(context).size.width,
            height: 300.0,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  ListTile(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      side: const BorderSide(color: surface3),
                    ),
                    leading: const Icon(
                      Icons.circle,
                      color: primary,
                    ),
                    title: Text.rich(
                      TextSpan(
                        text: productData['product']['name'],
                        style: const TextStyle(fontWeight: FontWeight.bold),
                        children: [
                          TextSpan(
                              text: " | $quantityAvailable items left",
                              style: const TextStyle(color: Colors.black54))
                        ],
                      ),
                    ),
                    subtitle: Text(
                        "RWF ${productData['product']['price'].toStringAsFixed(2)}"),
                    trailing: reorderLevel >= quantityAvailable ||
                            quantityAvailable == 0
                        ? Chip(
                            label: Text(
                              "Low in stock",
                              style: subtitle2.copyWith(
                                color: Colors.red[900],
                              ),
                            ),
                            backgroundColor: Colors.red[100],
                            side: BorderSide.none,
                          )
                        : null,
                  ),
                  const SizedBox(height: 24.0),
                  Form(
                    key: _formKey2,
                    child: Column(
                      children: [
                        NormalTextFormField(
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly
                          ],
                          controller: _quantity2,
                          hintText: '0',
                          labelText: 'Add More Quantity',
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Quantity required';
                            } else if (value == "0") {
                              return "Quantity must be more than 0";
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 24.0),
                        NormalTextFormField(
                          controller: _expirationDate2,
                          hintText: '0000-00-00 00:00:000',
                          labelText: 'New expiration date (optional)',
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
                              _expirationDate2.text = date.toString();
                            }
                          },
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
          actions: [
            SizedBox(
              width: MediaQuery.of(context).size.width,
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedAppButton(
                        onPressed: () {
                          _updateInventory(
                            oldQuantity: productData['quantity'].toString(),
                            stockId: productData['stock_id'].toString(),
                            quantityAvailable: quantityAvailable.toString(),
                          );
                        },
                        labelText: 'Update stock'),
                  ),
                  const SizedBox(width: 16.0),
                  Expanded(
                    child: TextAppButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        labelText: 'Cancel'),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  void _updateInventory({
    required String oldQuantity,
    required String stockId,
    required String quantityAvailable,
  }) async {
    final isValid = _formKey2.currentState?.validate();

    if (isValid != null && isValid) {
      Navigator.of(context).pop();
      final quantity2 = _quantity2.text.trim();
      final expirationDate2 = _expirationDate2.text.trim();
      final workspaceId = await getCurrentWorkspaceId();

      _quantity2.clear();
      _expirationDate2.clear();

      try {
        await WorkspaceService().updateProduct(
          stockId: stockId,
          workspaceId: workspaceId!,
          quantity: quantity2,
          oldQuantity: oldQuantity,
          expirationDate: expirationDate2,
          quantityAvailable: quantityAvailable,
        );
      } on GenericWorkspaceException {
        if (mounted) {
          showErrorDialog(context, "Failed to add product. Try again");
        }
      } catch (e) {
        if (mounted) {
          showErrorDialog(context, e.toString());
        }
      }
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
              Row(
                children: [
                  const Text(
                    "Inventory",
                    style: dashboardHeadline,
                  ),
                  const Expanded(child: SizedBox()),
                  _productsData != null && _productsData!.isNotEmpty
                      ? Responsive.isDesktop(context)
                          ? FilledButton(
                              style: const ButtonStyle(
                                backgroundColor: MaterialStatePropertyAll(
                                  primary,
                                ),
                              ),
                              onPressed: () async {
                                await _showAddProductDialog(context);
                              },
                              child: const Text(
                                "Add Product",
                                style: TextStyle(fontSize: 16.0),
                              ),
                            )
                          : OutlinedAppButton(
                              onPressed: () async {
                                await _showAddProductDialog(context);
                              },
                              labelText: "Add Product",
                            )
                      : const SizedBox(),
                ],
              ),
              const SizedBox(height: 16.0),
              _productsData != null && _productsData!.isNotEmpty
                  ? Responsive.isMobile(context)
                      ? GridView.builder(
                          shrinkWrap: true,
                          itemCount: _productsData!.length,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 8.0,
                            mainAxisSpacing: 8.0,
                            // childAspectRatio: 0.7,
                          ),
                          itemBuilder: (BuildContext context, int index) {
                            return Card(
                              elevation: 0.0,
                              surfaceTintColor: Colors.white,
                              shape: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8.0),
                                borderSide: const BorderSide(color: surface3),
                              ),
                              child: AspectRatio(
                                aspectRatio: 1,
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(8.0),
                                  onTap: () {
                                    log(_productsData![index]['stock_id']
                                        .toString());
                                    _openDetail(
                                        productData: _productsData![index]);
                                  },
                                  hoverColor: Colors.transparent,
                                  child: Container(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Expanded(
                                          child: Container(
                                            width: double.infinity,
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(8.0),
                                              color: surface1,
                                            ),
                                            child: const Icon(
                                              Icons.shopping_bag_outlined,
                                              color: Colors.black12,
                                              size: 32.0,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 16.0),
                                        Text(
                                          _productsData![index]["product"]
                                              ['name'],
                                          style: body1.copyWith(
                                              overflow: TextOverflow.ellipsis),
                                          maxLines: 1,
                                        ),
                                        const SizedBox(height: 4.0),
                                        Text(
                                          "RWF ${_productsData![index]["product"]['price'].toStringAsFixed(2)}",
                                          style: priceText2,
                                        ),
                                        const SizedBox(height: 8.0),
                                        Text(
                                          "${_productsData![index]['quantity_available'].toString()} in stock",
                                          style: labelText,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            );
                          })
                      : SizedBox(
                          width: MediaQuery.of(context).size.width * 0.9,
                          child: InventoryDataGrid(data: _productsData!),
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
}
