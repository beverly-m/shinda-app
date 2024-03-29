import 'dart:developer';

import 'package:currency_text_input_formatter/currency_text_input_formatter.dart';
import 'package:flutter/material.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:provider/provider.dart';
import 'package:shinda_app/constants/text_syles.dart';
import 'package:shinda_app/enums/dropdown_menu.dart';
import 'package:shinda_app/services/workspace/workspace_service.dart';
import 'package:shinda_app/utilities/helpers/db_helper.dart';
import 'package:shinda_app/utilities/models/cart_model.dart';
import 'package:shinda_app/utilities/providers/cart_provider.dart';
import 'package:shinda_app/views/dashboard/new_transaction_view.dart';

class CartItemsView extends StatefulWidget {
  const CartItemsView({super.key});

  @override
  State<CartItemsView> createState() => _CartItemsViewState();
}

class _CartItemsViewState extends State<CartItemsView> {
  DBHelper? dbHelper = DBHelper();
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
  String? _currentWorkspace;
  final GlobalKey<FormState> _formKey = GlobalKey();
  String _phoneNumberWithCode = "";
  PhoneNumber number = PhoneNumber(isoCode: 'RW');
  bool _isLoading = false;

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

  Future<void> _showAddCreditPurchaseDialog({
    required BuildContext context,
    required String workspaceId,
    required double subTotal,
    // required String paymentMode,
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
          title: const Text("Credit Purchase Details"),
          contentPadding: const EdgeInsets.all(24.0),
          content: SizedBox(
            width: MediaQuery.of(context).size.width * 0.4,
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    cursorColor: const Color.fromRGBO(0, 121, 107, 1),
                    decoration: const InputDecoration(
                      hoverColor: Color.fromRGBO(0, 121, 107, 1),
                      focusColor: Color.fromRGBO(0, 121, 107, 1),
                      labelText: "Client Name",
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
                  const SizedBox(height: 16.0),
                  InternationalPhoneNumberInput(
                    cursorColor: const Color.fromRGBO(0, 121, 107, 1),
                    initialValue: number,
                    onInputChanged: (PhoneNumber number) {
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
                  const SizedBox(height: 16.0),
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
              onPressed: () {
                _addDebtor(
                  workspaceId: workspaceId,
                  subTotal: subTotal,
                  // paymentMode: paymentMode,
                  grandTotal: grandTotal,
                  isPaid: isPaid,
                  products: products,
                  cart: cart,
                );
              },
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
    final isValid = _formKey.currentState?.validate();

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
          // paymentMode: _paymentModeController.text,
          grandTotal: grandTotal,
          isPaid: false,
          products: products,
          clientName: clientName,
          phoneNumber: phoneNumber,
          address: address.isNotEmpty ? address : null,
        );

        setState(() {
          _isLoading = false;
        });
        cart.clearCart();
        if (!mounted) {
          return;
        }
        Navigator.of(context).pop();
        Navigator.of(context).pop();
      } catch (e) {
        log(e.toString());
        setState(() {
          _isLoading = false;
        });
      }

      setState(() {
        _isLoading = false;
      });
    }
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Shopping Cart"),
      ),
      body: SingleChildScrollView(
          child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Consumer<CartProvider>(
          builder: (context, provider, widget) {
            return provider.cart.isEmpty
                ? SizedBox(
                    height: MediaQuery.of(context).size.height * 0.8,
                    child: const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Center(
                          child: Icon(
                            Icons.shopping_cart_checkout_outlined,
                            size: 200,
                            color: surface3,
                          ),
                        ),
                        SizedBox(height: 24.0),
                        Center(
                          child: Text(
                            "Cart empty",
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                      ],
                    ),
                  )
                : SizedBox(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ListView.builder(
                          shrinkWrap: true,
                          itemCount: provider.cart.length,
                          itemBuilder: (context, index) {
                            return Card(
                              elevation: 0,
                              color: surface1,
                              shape: RoundedRectangleBorder(
                                side: const BorderSide(color: surface3),
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      width: 48.0,
                                      height: 48.0,
                                      decoration: BoxDecoration(
                                        borderRadius:
                                            BorderRadius.circular(8.0),
                                        color: surface1,
                                      ),
                                      child: const Icon(
                                        Icons.shopping_bag_outlined,
                                        color: Colors.black12,
                                        size: 24.0,
                                      ),
                                    ),
                                    Column(
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          provider.cart[index].productName,
                                          style: body1,
                                        ),
                                        const Flexible(child: SizedBox()),
                                        Text(
                                          "RWF ${provider.cart[index].productPrice}",
                                          style:
                                              body2.copyWith(color: neutral4),
                                        ),
                                      ],
                                    ),
                                    const Expanded(child: SizedBox()),
                                    ValueListenableBuilder<int>(
                                      valueListenable:
                                          provider.cart[index].quantity,
                                      builder: (context, value, child) {
                                        return PlusMinusButtons(
                                          addQuantity: () {
                                            cart.addQuantity(
                                                provider.cart[index].productId);
                                            setState(() {
                                              cart.addTotalPrice(double.parse(
                                                  provider
                                                      .cart[index].productPrice
                                                      .toString()));
                                            });
                                            // });
                                          },
                                          deleteQuantity: () {
                                            cart.deleteQuantity(
                                                provider.cart[index].productId);
                                          },
                                          text: value.toString(),
                                        );
                                      },
                                    ),
                                    IconButton(
                                      onPressed: () {
                                        dbHelper!.deleteCartItem(
                                            provider.cart[index].productId);
                                        provider.removeItem(
                                            provider.cart[index].productId);
                                        provider.removeCounter();
                                      },
                                      icon: const Icon(Icons.delete_outline),
                                    )
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 24.0),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            DropdownMenu<PaymentModeLabel>(
                              menuStyle: MenuStyle(
                                shape: MaterialStatePropertyAll(
                                  RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                ),
                              ),
                              controller: _paymentModeController,
                              requestFocusOnTap: true,
                              label: const Text(
                                'Payment Mode',
                                style: body1,
                              ),
                              onSelected: (PaymentModeLabel? paymentMode) {
                                setState(() {
                                  selectedPaymentMode = paymentMode;
                                });
                              },
                              dropdownMenuEntries: PaymentModeLabel.values
                                  .map<DropdownMenuEntry<PaymentModeLabel>>(
                                      (PaymentModeLabel paymentMode) {
                                return DropdownMenuEntry<PaymentModeLabel>(
                                  value: paymentMode,
                                  label: paymentMode.label,
                                  enabled: paymentMode.label != 'Grey',
                                  style: MenuItemButton.styleFrom(
                                      textStyle: body1),
                                );
                              }).toList(),
                            ),
                          ],
                        ),
                        const SizedBox(height: 48.0),
                        const Flexible(
                          child: SizedBox(),
                        ),
                        Consumer<CartProvider>(
                          builder:
                              (BuildContext context, value, Widget? child) {
                            final ValueNotifier<double?> totalPrice =
                                ValueNotifier(null);
                            for (var element in value.cart) {
                              totalPrice.value = (element.productPrice *
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
                                        value: r'RWF ' +
                                            (val?.toStringAsFixed(2) ?? '0.00'),
                                      );
                                    }),
                                const ReusableWidget(
                                  title: 'Tax',
                                  value: 'RWF 0.00',
                                ),
                                ValueListenableBuilder<double?>(
                                    valueListenable: totalPrice,
                                    builder: (context, val, child) {
                                      return ReusableWidget(
                                        title: 'Total',
                                        value: r'RWF ' +
                                            (val?.toStringAsFixed(2) ?? '0.00'),
                                        style: priceText,
                                      );
                                    }),
                              ],
                            );
                          },
                        ),
                        const SizedBox(
                          height: 24.0,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            OutlinedButton(
                              onPressed: () async {
                                double? totalPrice;

                                for (var element in provider.cart) {
                                  totalPrice = (element.productPrice *
                                          element.quantity.value) +
                                      (totalPrice ?? 0);
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
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24.0,
                                  vertical: 8.0,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                              ),
                              child: const Text(
                                "Credit Purchase",
                                style: secondaryButtonStyle,
                              ),
                            ),
                            const SizedBox(
                              width: 24.0,
                            ),
                            FilledButton(
                              onPressed: () async {
                                try {
                                  double? totalPrice;

                                  for (var element in provider.cart) {
                                    totalPrice = (element.productPrice *
                                            element.quantity.value) +
                                        (totalPrice ?? 0);
                                  }
                                  await WorkspaceService().addTransaction(
                                    workspaceId: _currentWorkspace!,
                                    subTotal: totalPrice!,
                                    paymentMode: _paymentModeController.text,
                                    grandTotal: totalPrice,
                                    isPaid: true,
                                    products: provider.cart,
                                  );

                                  provider.clearCart();

                                  if (!mounted) {
                                    return;
                                  } else {
                                    Navigator.of(context).pop();
                                    Navigator.of(context).pop();
                                  }
                                } catch (e) {
                                  log(e.toString());
                                }
                              },
                              style: FilledButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24.0,
                                  vertical: 8.0,
                                ),
                                backgroundColor: primary,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                              ),
                              child: const Text("Checkout"),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
          },
        ),
      )),
    );
  }
}
