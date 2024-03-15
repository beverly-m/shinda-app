import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:shinda_app/utilities/helpers/db_helper.dart';
import 'package:shinda_app/utilities/models/cart_model.dart';
import 'package:shinda_app/utilities/providers/cart_provider.dart';

void saveData(
    {required Map<String, dynamic> data,
    required CartProvider cartProvider,
    required DBHelper? dbHelper}) {
  // data.forEach(
  //   (key, value) {
  //     log("$key: ${value.toString()}");
  //   },
  // );
  log(data.keys.toString());
  dbHelper!
      .insert(
    Cart(
      productId: data["product"]["product_id"],
      productName: data["product"]["name"],
      initialPrice: data["product"]['price'],
      productPrice: data["product"]['price'],
      quantity: ValueNotifier<int>(data['quantity']),
    ),
  )
      .then((value) {
    cartProvider.addTotalPrice(data["product"]['price']);
    cartProvider.addCounter();
    log('Product Added to cart');
  }).onError((error, stackTrace) {
    log(error.toString());
  });
}
