import 'package:flutter/material.dart';

class Cart {
  // late final int? id;
  final int productId;
  final String productName;
  final double initialPrice;
  final double productPrice;
  final ValueNotifier<int> quantity;
  final int quantityAvailable;
  final String? unitTag;
  final String? image;

  Cart({
    // required this.id,
    required this.productId,
    required this.productName,
    required this.initialPrice,
    required this.productPrice,
    required this.quantity,
    required this.quantityAvailable,
    this.unitTag,
    this.image,
  });

  Cart.fromMap(Map<dynamic, dynamic> data)
      : 
      // id = data['id'],
        productId = data['productId'],
        productName = data['productName'],
        initialPrice = data['initialPrice'],
        productPrice = data['productPrice'],
        quantity = ValueNotifier(data['quantity']),
        quantityAvailable = data['quantityAvailable'],
        unitTag = data['unitTag'],
        image = data['image'];

  Map<String, dynamic> toMap() {
    return {
      // 'id': id,
      'productId': productId,
      'productName': productName,
      'initialPrice': initialPrice,
      'productPrice': productPrice,
      'quantity': quantity.value,
      'quantityAvailable': quantityAvailable,
      'unitTag': unitTag,
      'image': image,
    };
  }
}
