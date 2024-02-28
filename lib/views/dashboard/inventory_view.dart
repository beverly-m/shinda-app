import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:currency_text_input_formatter/currency_text_input_formatter.dart';
import 'package:flutter/services.dart';

class InventoryView extends StatefulWidget {
  const InventoryView({super.key});

  @override
  State<InventoryView> createState() => _InventoryViewState();
}

class _InventoryViewState extends State<InventoryView> {
  final GlobalKey<FormState> _formKey = GlobalKey();

  final CurrencyTextInputFormatter _formatter =
      CurrencyTextInputFormatter(symbol: "RWF ");

  late final TextEditingController _productName;
  late final TextEditingController _description;
  late final TextEditingController _price;
  late final TextEditingController _quantity;
  late final TextEditingController _unit;
  late final TextEditingController _expirationDate;
  late final TextEditingController _reorderLevel;

  @override
  void initState() {
    super.initState();

    _productName = TextEditingController();
    _description = TextEditingController();
    _price = TextEditingController();
    _quantity = TextEditingController();
    _expirationDate = TextEditingController();
    _reorderLevel = TextEditingController();
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
      child: Column(
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

  void _addProduct() {
    final isValid = _formKey.currentState?.validate();
    final productName = _productName.text.trim();
    final description = _description.text.trim();
    final price = _price.text.trim().substring(4);
    final quantity = _quantity.text.trim();
    final reorderLevel = _reorderLevel.text.trim();
    final expirationDate = _expirationDate.text.trim();

    log("IsValid: $isValid...$productName, $description, $price, $quantity, $reorderLevel, $expirationDate");
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
                Navigator.pop(context);
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
