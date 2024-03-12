import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shinda_app/utilities/helpers/db_helper.dart';
import 'package:shinda_app/utilities/models/cart_model.dart';

class CartProvider with ChangeNotifier {
  DBHelper dbHelper = DBHelper();
  int _counter = 0;
  int _quantity = 1;

  int get counter => _counter;
  int get quantity => _quantity;

  double _totalPrice = 0.0;

  double get totalPrice => _totalPrice;

  List<Cart> cart = [];

  Future<List<Cart>> getData() async {
    cart = await dbHelper.getCartList();
    notifyListeners();
    return cart;
  }

  void _setPrefsItems() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setInt('cartItems', _counter);
    prefs.setInt('itemQuantity', _quantity);
    prefs.setDouble('totalPrice', _totalPrice);
    notifyListeners();
  }

  void _getPrefsItems() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _counter = prefs.getInt('cartItems') ?? 0;
    _quantity = prefs.getInt('itemQuantity') ?? 1;
    _totalPrice = prefs.getDouble('totalPrice') ?? 0;
  }

  void addCounter() {
    _counter++;
    _setPrefsItems();
    notifyListeners();
  }

  void removeCounter() {
    _counter--;
    _setPrefsItems();
    notifyListeners();
  }

  int getCounter() {
    _getPrefsItems();
    return _counter;
  }

  void addQuantity(int productId) {
    final index = cart.indexWhere((element) => element.productId == productId);
    cart[index].quantity.value = cart[index].quantity.value + 1;
    _setPrefsItems();
    notifyListeners();
  }

  void deleteQuantity(int productId) {
    final index = cart.indexWhere((element) => element.productId == productId);
    final currentQuantity = cart[index].quantity.value;

    if (currentQuantity <= 1) {
      currentQuantity == 1;
    } else {
      cart[index].quantity.value = currentQuantity - 1;
    }

    _setPrefsItems();
    notifyListeners();
  }

  void removeItem(int productId) {
    final index = cart.indexWhere((element) => element.productId == productId);
    cart.removeAt(index);
    _setPrefsItems();
    notifyListeners(); 
  }

  int getQuantity(int quantity) {
    _getPrefsItems();
    return _quantity;
  }

  void addTotalPrice(double productPrice) {
    _totalPrice = _totalPrice + productPrice;
    _setPrefsItems();
    notifyListeners();
  }

  void removeTotalPrice(double productPrice) {
    _totalPrice = _totalPrice - productPrice;
    _setPrefsItems();
    notifyListeners();
  }

  double getTotalPrice() {
    _getPrefsItems();
    return _totalPrice;
  }
}