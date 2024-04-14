import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:currency_text_input_formatter/currency_text_input_formatter.dart';
import 'package:flutter/services.dart';
import 'package:shinda_app/components/buttons.dart';
import 'package:shinda_app/components/circular_progress_indicator.dart';
import 'package:shinda_app/components/snackbar.dart';
import 'package:shinda_app/components/textfields.dart';
import 'package:shinda_app/constants/text_syles.dart';
import 'package:shinda_app/responsive/responsive_layout.dart';
import 'package:shinda_app/services/workspace/workspace_exceptions.dart';
import 'package:shinda_app/services/workspace/workspace_service.dart';
import 'package:shinda_app/utilities/get_workspace.dart';
import 'package:shinda_app/utilities/inventory_data.dart';

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

                          _getProductData();
                        },
                        labelText: 'Update'),
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

        SnackBarService.showSnackBar(content: "Product updated.");

        // _getProductData();
      } on GenericWorkspaceException {
        SnackBarService.showSnackBar(
            content: "Failed to update product. Try again");
      } catch (e) {
        log(e.toString());
      }
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
                  child: AppCircularProgressIndicator()),
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

                  // ***WITH INVENTORY DATA***
                  _productsData != null && _productsData!.isNotEmpty

                      // ***DESKTOP CREATE PRODUCT BUTTON***
                      ? Responsive.isDesktop(context)
                          ? FilledAppButton(
                              onPressed: () async {
                                await _showAddProductDialog(context);
                              },
                              labelText: "Add Product")
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

              // ***WITH INVENTORY DATA***
              _productsData != null && _productsData!.isNotEmpty

                  // ***MOBILE WITH INVENTORY DATA***
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

                      // ***DESKTOP WITH INVENTORY DATA***
                      : SizedBox(
                          width: MediaQuery.of(context).size.width * 0.9,
                          child: InventoryDataGrid(data: _productsData!),
                        )

                  // ***WITH NO INVENTORY DATA***
                  : Center(
                      child: Padding(
                        padding: const EdgeInsets.all(48.0),
                        child: Column(
                          children: [
                            const Icon(
                              Icons.inventory_2_outlined,
                              size: 180,
                              color: surface3,
                            ),
                            const SizedBox(height: 48.0),
                            const Text(
                              "Add a new product to get started",
                              style: body1,
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 48.0),
                            FilledAppButton(
                              onPressed: () async {
                                await _showAddProductDialog(context);
                              },
                              labelText: "Add Product",
                            ),
                          ],
                        ),
                      ),
                    ),
            ],
          );
  }

  void _addProduct() async {
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

        SnackBarService.showSnackBar(content: "Product created!");

        _getProductData();
      } on GenericWorkspaceException {
        SnackBarService.showSnackBar(
            content: "Failed to add product. Try again");
      } catch (e) {
        log('${e.toString()}---addProduct');
      }
    }
  }

  void _getProductData() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
    });

    try {
      final currentWorkspace = await getCurrentWorkspaceId();

      if (currentWorkspace == null) {
        setState(() {
          _isLoading = false;
        });
        return;
      }

      final List<Map<String, dynamic>> products =
          await WorkspaceService().getProducts(workspaceId: currentWorkspace);

      if (!mounted) return;
      setState(() {
        _productsData = products;
        _isLoading = false;
      });
    } on GenericWorkspaceException {
      log("Error occurred---getProductData");
      _isLoading = false;
    } catch (e) {
      log('${e.toString()}---getProductData');
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
          title: const Text(
            "New product",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          contentPadding: Responsive.isDesktop(context)
              ? const EdgeInsets.all(48.0)
              : const EdgeInsets.all(16.0),
          content: SizedBox(
            width: Responsive.isDesktop(context)
                ? MediaQuery.of(context).size.width * 0.6
                : MediaQuery.of(context).size.width,
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  NormalTextFormField(
                    controller: _productName,
                    hintText: 'Enter the product name',
                    labelText: 'Name',
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Product name required';
                      } else if (value.length < 3) {
                        return "At least 3 characters";
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24.0),
                  NormalTextFormField(
                    controller: _description,
                    hintText: 'Enter description',
                    labelText: 'Description (optional)',
                    maxLines: 3,
                  ),
                  const SizedBox(height: 24.0),
                  NormalTextFormField(
                    controller: _price,
                    hintText: '0.00',
                    labelText: 'Selling Price',
                    keyboardType: TextInputType.number,
                    inputFormatters: <TextInputFormatter>[_formatter],
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Price required';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24.0),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: NormalTextFormField(
                          controller: _quantity,
                          hintText: '0',
                          labelText: 'Quantity',
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly
                          ],
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Quantity required';
                            } else if (value == "0") {
                              return "Quantity must be more than 0";
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 24.0),
                      Expanded(
                        child: NormalTextFormField(
                          controller: _reorderLevel,
                          hintText: '0',
                          labelText: 'Reorder quantity level',
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24.0),
                  NormalTextFormField(
                    controller: _expirationDate,
                    hintText: '0000-00-00 00:00:00.000',
                    labelText: 'Expiration date (optional)',
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
            SizedBox(
              width: Responsive.isDesktop(context)
                  ? MediaQuery.of(context).size.width * 0.6
                  : MediaQuery.of(context).size.width,
              child: Row(
                children: [
                  Expanded(
                    child: TextAppButton(
                      onPressed: () {
                        _productName.clear();
                        _description.clear();
                        _price.clear();
                        _quantity.clear();
                        _reorderLevel.clear();
                        _expirationDate.clear();
                        Navigator.of(context).pop();
                      },
                      labelText: 'Cancel',
                    ),
                  ),
                  const SizedBox(width: 16.0),
                  Expanded(
                      child: FilledAppButton(
                    onPressed: _addProduct,
                    labelText: 'Create',
                  )),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
