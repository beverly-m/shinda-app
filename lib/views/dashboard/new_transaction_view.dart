import 'dart:developer';

import 'package:currency_text_input_formatter/currency_text_input_formatter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:provider/provider.dart';
import 'package:shinda_app/components/buttons.dart';
import 'package:shinda_app/components/cart_item_card.dart';
import 'package:shinda_app/components/circular_progress_indicator.dart';
import 'package:shinda_app/components/product_card.dart';
import 'package:shinda_app/components/textfields.dart';
import 'package:shinda_app/constants/text_syles.dart';
import 'package:shinda_app/enums/dropdown_menu.dart';
import 'package:shinda_app/responsive/responsive_layout.dart';
import 'package:shinda_app/services/workspace/workspace_exceptions.dart';
import 'package:shinda_app/services/workspace/workspace_service.dart';
import 'package:shinda_app/utilities/get_workspace.dart';
import 'package:shinda_app/utilities/helpers/db_helper.dart';
import 'package:shinda_app/utilities/models/cart_model.dart';
import 'package:shinda_app/utilities/providers/cart_provider.dart';
import 'package:shinda_app/utilities/show_error_dialog.dart';
import 'package:shinda_app/views/mobile_views/new_sale_view.dart';
import 'package:shinda_app/components/snackbar.dart';

class NewTransactionView extends StatefulWidget {
  const NewTransactionView({super.key});

  @override
  State<NewTransactionView> createState() => _NewTransactionViewState();
}

class _NewTransactionViewState extends State<NewTransactionView> {
  bool _isLoading = false;
  List<Map<String, dynamic>>? _productsData;
  String _phoneNumberWithCode = "";
  PhoneNumber number = PhoneNumber(isoCode: 'RW');
  final GlobalKey<FormState> _formKey = GlobalKey();
  final GlobalKey<FormState> _formKey2 = GlobalKey();
  late final TextEditingController _productName;
  late final TextEditingController _description;
  late final TextEditingController _price;
  late final TextEditingController _quantity;
  late final TextEditingController _expirationDate;
  late final TextEditingController _reorderLevel;
  late final TextEditingController _paymentModeController;
  late final TextEditingController _clientName;
  late final TextEditingController _phoneNumber;
  late final TextEditingController _address;
  PaymentModeLabel? selectedPaymentMode;
  final CurrencyTextInputFormatter _formatter =
      CurrencyTextInputFormatter(symbol: "RWF ", turnOffGrouping: true);
  DBHelper? dbHelper = DBHelper();
  final cartItems = [];
  String? _currentWorkspace;

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
    _paymentModeController = TextEditingController();
    _clientName = TextEditingController();
    _phoneNumber = TextEditingController();
    _address = TextEditingController();

    context.read<CartProvider>().getData();

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
    _address.dispose();
    _clientName.dispose();
    _phoneNumber.dispose();
    _paymentModeController.dispose();

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
          title: const Text(
            "New product",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          contentPadding: const EdgeInsets.all(48.0),
          content: SizedBox(
            width: MediaQuery.of(context).size.width * 0.6,
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
                  Row(
                    children: [
                      Expanded(
                        child: NormalTextFormField(
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
                      ),
                      const SizedBox(width: 24.0),
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
                    ],
                  ),
                  const SizedBox(height: 24.0),
                  NormalTextFormField(
                    controller: _reorderLevel,
                    hintText: '0',
                    labelText: 'Reorder quantity level',
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
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
            TextAppButton(
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
            FilledAppButton(
              onPressed: _addProduct,
              labelText: 'Add product',
            ),
          ],
        );
      },
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

        SnackBarService.showSnackBar(content: "Product added.");

        _getProductData();
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

      final List<Map<String, dynamic>> products = await WorkspaceService()
          .getPOSProducts(workspaceId: currentWorkspace);

      if (!mounted) return;
      setState(() {
        _productsData = products;
        _currentWorkspace = currentWorkspace;
      });

      if (_productsData != null) {
        setState(() {});
      }

      if (!mounted) return;
      setState(() {
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

  Future<void> _showAddCreditPurchaseDialog({
    required BuildContext context,
    required String workspaceId,
    required double subTotal,
    required double grandTotal,
    required bool isPaid,
    required List<Cart> products,
    required CartProvider cart,
  }) {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          surfaceTintColor: surface1,
          shape: OutlineInputBorder(
            borderSide: BorderSide.none,
            borderRadius: BorderRadius.circular(8.0),
          ),
          scrollable: true,
          title: const Text("Credit Purchase Details",
              style: TextStyle(fontWeight: FontWeight.bold)),
          contentPadding: const EdgeInsets.all(24.0),
          content: SizedBox(
            width: MediaQuery.of(context).size.width * 0.4,
            child: Form(
              key: _formKey2,
              child: Column(
                children: [
                  NormalTextFormField(
                    controller: _clientName,
                    hintText: "Enter the name of the client",
                    labelText: "Client Name",
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Client name required';
                      } else if (value.length < 3) {
                        return "At least 3 characters";
                      }
                      return null;
                    },
                  ),
                  // TextFormField(
                  //   cursorColor: const Color.fromRGBO(0, 121, 107, 1),
                  //   decoration: const InputDecoration(
                  //     hoverColor: Color.fromRGBO(0, 121, 107, 1),
                  //     focusColor: Color.fromRGBO(0, 121, 107, 1),
                  //     labelText: "Client Name",
                  //     hintText: "Enter the name of the client",
                  //   ),
                  //   controller: _clientName,
                  //   validator: (value) {
                  //     if (value == null || value.isEmpty) {
                  //       return 'Client name required';
                  //     } else if (value.length < 3) {
                  //       return "At least 3 characters";
                  //     }
                  //     return null;
                  //   },
                  // ),
                  const SizedBox(height: 24.0),
                  InternationalPhoneNumberInput(
                    cursorColor: const Color.fromRGBO(0, 121, 107, 1),
                    initialValue: number,
                    onInputChanged: (PhoneNumber number) {
                      if (!mounted) return;
                      setState(() {
                        _phoneNumberWithCode = number.phoneNumber!;
                      });
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
                  const SizedBox(height: 24.0),
                  NormalTextFormField(
                      controller: _address,
                      hintText: "Enter your address here",
                      labelText: "Address"),
                  // TextFormField(
                  //   cursorColor: const Color.fromRGBO(0, 121, 107, 1),
                  //   decoration: const InputDecoration(
                  //     hoverColor: Color.fromRGBO(0, 121, 107, 1),
                  //     focusColor: Color.fromRGBO(0, 121, 107, 1),
                  //     labelText: "Address",
                  //     hintText: "Enter your address here",
                  //   ),
                  //   controller: _address,
                  // ),
                ],
              ),
            ),
          ),
          actions: [
            TextAppButton(
                onPressed: () {
                  _clientName.clear();
                  _address.clear();
                  _phoneNumber.clear();
                  Navigator.of(context).pop();
                },
                labelText: "Cancel"),
            FilledAppButton(
                onPressed: () {
                  _addDebtor(
                    workspaceId: workspaceId,
                    subTotal: subTotal,
                    grandTotal: grandTotal,
                    isPaid: isPaid,
                    products: products,
                    cart: cart,
                  );
                },
                labelText: "Add Debtor"),
          ],
        );
      },
    );
  }

  void _addDebtor({
    required String workspaceId,
    required double subTotal,
    // String? paymentMode,
    required double grandTotal,
    required bool isPaid,
    required List<Cart> products,
    required CartProvider cart,
  }) async {
    final isValid = _formKey2.currentState?.validate();

    if (!mounted) return;
    setState(() {
      _isLoading = true;
    });

    if (isValid != null && isValid) {
      Navigator.of(context).pop();

      final clientName = _clientName.text.trim();
      final address = _address.text.trim();
      final phoneNumber = _phoneNumberWithCode;

      _clientName.clear();
      _address.clear();
      _phoneNumber.clear();

      try {
        await WorkspaceService().addTransaction(
          workspaceId: workspaceId,
          subTotal: subTotal,
          grandTotal: grandTotal,
          isPaid: false,
          products: products,
          clientName: clientName,
          phoneNumber: phoneNumber,
          address: address.isNotEmpty ? address : null,
        );

        SnackBarService.showSnackBar(content: "Credit purchase added");

        if (!mounted) return;
        setState(() {
          _isLoading = false;
        });

        cart.clearCart();

        _getProductData();
      } catch (e) {
        log(e.toString());
        if (!mounted) return;
        setState(() {
          _isLoading = false;
        });
      }

      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
    }

    if (!mounted) return;
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context);

    return _isLoading
        ? Container(
            height: MediaQuery.of(context).size.height * 0.8,
            width: MediaQuery.of(context).size.width,
            color: Colors.white,
            child: const Center(
              child: Padding(
                padding: EdgeInsets.all(24.0),
                child: AppCircularProgressIndicator(),
              ),
            ),
          )

        // *** DESKTOP ***
        : Responsive.isDesktop(context)
            ? SizedBox(
                width: double.infinity,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "New Transaction",
                      style: dashboardHeadline,
                    ),
                    const SizedBox(height: 16.0),

                    // ***DESKTOP WITH PRODUCTS***
                    _productsData != null && _productsData!.isNotEmpty
                        ? Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                flex: 5,
                                child: SingleChildScrollView(
                                  child: SizedBox(
                                    height: MediaQuery.of(context).size.height *
                                        0.8,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            const Text(
                                              "Products",
                                              style: dashboardSubtitle,
                                            ),
                                            const Expanded(child: SizedBox()),
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
                                                const SliverGridDelegateWithFixedCrossAxisCount(
                                              crossAxisSpacing: 16.0,
                                              mainAxisSpacing: 16.0,
                                              crossAxisCount: 3,
                                            ),
                                            itemCount: _productsData!.length,
                                            shrinkWrap: true,
                                            itemBuilder: (context, index) {
                                              return _productsData![index][
                                                          'quantity_available'] <
                                                      0
                                                  ? null
                                                  : AspectRatio(
                                                      aspectRatio: 0.9,
                                                      child: ProductCard(
                                                          productName:
                                                              _productsData![
                                                                          index]
                                                                      [
                                                                      "product"]
                                                                  ['name'],
                                                          productPrice:
                                                              _productsData![
                                                                          index]
                                                                      [
                                                                      "product"]
                                                                  ['price'],
                                                          quantityInStock:
                                                              _productsData![
                                                                      index][
                                                                  'quantity_available'],
                                                          onPressed: () async {
                                                            await cart.saveData(
                                                                data:
                                                                    _productsData![
                                                                        index]);
                                                          }),
                                                    );
                                            },
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 24.0),
                              Expanded(
                                flex: 4,
                                child: Container(
                                  height:
                                      MediaQuery.of(context).size.height * 0.8,
                                  decoration: BoxDecoration(
                                    border: Border.all(color: surface3),
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(24.0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Row(
                                          children: [
                                            const Text(
                                              "Cart",
                                              style: dashboardHeadings,
                                            ),
                                            const SizedBox(width: 8.0),
                                            Badge(
                                              backgroundColor: primary,
                                              textColor: Colors.white,
                                              label: Consumer<CartProvider>(
                                                builder:
                                                    (context, value, child) {
                                                  return Text(value
                                                      .getCounter()
                                                      .toString());
                                                },
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 24.0),
                                        Expanded(
                                          child: Column(
                                            children: [
                                              Expanded(
                                                child: Consumer<CartProvider>(
                                                  builder: (context, provider,
                                                      widget) {
                                                    return provider.cart.isEmpty
                                                        ? const Column(
                                                            children: [
                                                              Center(
                                                                child: Icon(
                                                                  Icons
                                                                      .shopping_cart_checkout_outlined,
                                                                  size: 200,
                                                                  color:
                                                                      surface3,
                                                                ),
                                                              ),
                                                              SizedBox(
                                                                  height: 24.0),
                                                              Center(
                                                                child: Text(
                                                                  "Cart items shown here",
                                                                  style: TextStyle(
                                                                      fontSize:
                                                                          16),
                                                                ),
                                                              ),
                                                            ],
                                                          )
                                                        : SizedBox(
                                                            child:
                                                                SingleChildScrollView(
                                                              child: Column(
                                                                mainAxisSize:
                                                                    MainAxisSize
                                                                        .min,
                                                                children: [
                                                                  SizedBox(
                                                                      height:
                                                                          300.0,
                                                                      child: ListView
                                                                          .builder(
                                                                        shrinkWrap:
                                                                            true,
                                                                        itemCount: provider
                                                                            .cart
                                                                            .length,
                                                                        itemBuilder:
                                                                            (context,
                                                                                index) {
                                                                          return CartItemCard(
                                                                            productName:
                                                                                provider.cart[index].productName,
                                                                            productPrice:
                                                                                "RWF ${provider.cart[index].productPrice}",
                                                                            valueListenable:
                                                                                provider.cart[index].quantity,
                                                                            addQuantity:
                                                                                () {
                                                                              cart.addQuantity(provider.cart[index].productId);
                                                                              setState(() {
                                                                                cart.addTotalPrice(double.parse(provider.cart[index].productPrice.toString()));
                                                                              });
                                                                            },
                                                                            deleteQuantity:
                                                                                () {
                                                                              cart.deleteQuantity(provider.cart[index].productId);
                                                                            },
                                                                            onPressedDeleteButton:
                                                                                () {
                                                                              dbHelper!.deleteCartItem(provider.cart[index].productId);
                                                                              provider.removeItem(provider.cart[index].productId);
                                                                              provider.removeCounter();
                                                                            },
                                                                          );
                                                                        },
                                                                      )),
                                                                  const SizedBox(
                                                                      height:
                                                                          24.0),
                                                                  Column(
                                                                    crossAxisAlignment:
                                                                        CrossAxisAlignment
                                                                            .stretch,
                                                                    children: [
                                                                      DropdownMenu<
                                                                          PaymentModeLabel>(
                                                                        expandedInsets: const EdgeInsets
                                                                            .symmetric(
                                                                            horizontal:
                                                                                0.0),
                                                                        menuStyle:
                                                                            MenuStyle(
                                                                          shape:
                                                                              MaterialStatePropertyAll(
                                                                            RoundedRectangleBorder(
                                                                              borderRadius: BorderRadius.circular(8.0),
                                                                            ),
                                                                          ),
                                                                        ),
                                                                        initialSelection:
                                                                            PaymentModeLabel.cash,
                                                                        controller:
                                                                            _paymentModeController,
                                                                        requestFocusOnTap:
                                                                            true,
                                                                        label:
                                                                            const Text(
                                                                          'Payment Mode',
                                                                          style:
                                                                              body1,
                                                                        ),
                                                                        onSelected:
                                                                            (PaymentModeLabel?
                                                                                paymentMode) {
                                                                          setState(
                                                                              () {
                                                                            selectedPaymentMode =
                                                                                paymentMode;
                                                                          });
                                                                        },
                                                                        dropdownMenuEntries: PaymentModeLabel
                                                                            .values
                                                                            .map<DropdownMenuEntry<PaymentModeLabel>>((PaymentModeLabel
                                                                                paymentMode) {
                                                                          return DropdownMenuEntry<
                                                                              PaymentModeLabel>(
                                                                            value:
                                                                                paymentMode,
                                                                            label:
                                                                                paymentMode.label,
                                                                            enabled:
                                                                                paymentMode.label != 'Grey',
                                                                            style:
                                                                                MenuItemButton.styleFrom(textStyle: body1),
                                                                          );
                                                                        }).toList(),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                  const SizedBox(
                                                                      height:
                                                                          48.0),
                                                                  const Flexible(
                                                                    child:
                                                                        SizedBox(),
                                                                  ),
                                                                  Consumer<
                                                                      CartProvider>(
                                                                    builder: (BuildContext
                                                                            context,
                                                                        value,
                                                                        Widget?
                                                                            child) {
                                                                      final ValueNotifier<
                                                                              double?>
                                                                          totalPrice =
                                                                          ValueNotifier(
                                                                              null);
                                                                      for (var element
                                                                          in value
                                                                              .cart) {
                                                                        totalPrice
                                                                            .value = (element.productPrice *
                                                                                element.quantity.value) +
                                                                            (totalPrice.value ?? 0);
                                                                      }
                                                                      return Column(
                                                                        children: [
                                                                          ValueListenableBuilder<double?>(
                                                                              valueListenable: totalPrice,
                                                                              builder: (context, val, child) {
                                                                                return ReusableWidget(
                                                                                  title: 'Sub Total',
                                                                                  value: r'RWF ' + (val?.toStringAsFixed(2) ?? '0.00'),
                                                                                );
                                                                              }),
                                                                          const ReusableWidget(
                                                                            title:
                                                                                'Tax',
                                                                            value:
                                                                                'RWF 0.00',
                                                                          ),
                                                                          ValueListenableBuilder<double?>(
                                                                              valueListenable: totalPrice,
                                                                              builder: (context, val, child) {
                                                                                return ReusableWidget(
                                                                                  title: 'Total',
                                                                                  value: r'RWF ' + (val?.toStringAsFixed(2) ?? '0.00'),
                                                                                  style: priceText,
                                                                                );
                                                                              }),
                                                                        ],
                                                                      );
                                                                    },
                                                                  ),
                                                                  const SizedBox(
                                                                    height:
                                                                        24.0,
                                                                  ),
                                                                  Row(
                                                                    children: [
                                                                      Expanded(
                                                                        child:
                                                                            OutlinedAppButton(
                                                                          onPressed:
                                                                              () async {
                                                                            double?
                                                                                totalPrice;

                                                                            for (var element
                                                                                in provider.cart) {
                                                                              totalPrice = (element.productPrice * element.quantity.value) + (totalPrice ?? 0);
                                                                            }

                                                                            try {
                                                                              await _showAddCreditPurchaseDialog(
                                                                                context: context,
                                                                                workspaceId: _currentWorkspace!,
                                                                                subTotal: totalPrice!,
                                                                                grandTotal: totalPrice,
                                                                                isPaid: false,
                                                                                products: provider.cart,
                                                                                cart: provider,
                                                                              );
                                                                            } catch (e) {
                                                                              log(e.toString());
                                                                            }
                                                                          },
                                                                          labelText:
                                                                              'Credit Purchase',
                                                                        ),
                                                                      ),
                                                                      const SizedBox(
                                                                        width:
                                                                            16.0,
                                                                      ),
                                                                      Expanded(
                                                                        child:
                                                                            FilledAppButton(
                                                                          onPressed:
                                                                              () async {
                                                                            try {
                                                                              double? totalPrice;

                                                                              for (var element in provider.cart) {
                                                                                totalPrice = (element.productPrice * element.quantity.value) + (totalPrice ?? 0);
                                                                              }
                                                                              await WorkspaceService().addTransaction(
                                                                                workspaceId: _currentWorkspace!,
                                                                                subTotal: totalPrice!,
                                                                                paymentMode: _paymentModeController.text,
                                                                                grandTotal: totalPrice,
                                                                                isPaid: true,
                                                                                products: provider.cart,
                                                                              );

                                                                              SnackBarService.showSnackBar(content: "Transaction added");

                                                                              provider.clearCart();

                                                                              _getProductData();
                                                                            } on GenericWorkspaceException {
                                                                              SnackBarService.showSnackBar(content: "Payment mode required.");
                                                                            } catch (e) {
                                                                              log(e.toString());
                                                                            }
                                                                          },
                                                                          labelText:
                                                                              'Checkout',
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
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          )

                        // ***DESKTOP WITHOUT PRODUCTS***
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
                ),
              )

            // ***TABLET & MOBILE VIEW***
            : const NewSaleView();
  }
}

class ReusableWidget extends StatelessWidget {
  final String title, value;
  final TextStyle style;
  const ReusableWidget({
    super.key,
    // Key? key,
    required this.title,
    required this.value,
    this.style = body1,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: style,
          ),
          Text(
            value.toString(),
            style: style,
          ),
        ],
      ),
    );
  }
}
