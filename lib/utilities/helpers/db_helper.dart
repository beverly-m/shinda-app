import 'package:drift/drift.dart';
import 'package:shinda_app/database.dart';
import 'package:shinda_app/utilities/models/cart_model.dart';

class DBHelper {
  static MyDatabase? _database;

  MyDatabase get database {
    if (_database != null) {
      return _database!;
    }

    _database = MyDatabase();
    return _database!;
  }

  // insert data into table
  Future<Cart> insert(Cart cart) async {
    MyDatabase dbClient = database;

    await dbClient.into(dbClient.transactionItems).insert(
          TransactionItemsCompanion.insert(
            productId: cart.productId,
            productName: cart.productName,
            initialPrice: cart.initialPrice,
            productPrice: cart.productPrice,
            quantity: cart.quantity.value,
            unitTag: Value(cart.unitTag),
            image: Value(cart.image),
          ),
        );

    return cart;
  }

  // getting all the items in the list from the database
  Future<List<Cart>> getCartList() async {
    MyDatabase dbClient = database;

    List<TransactionItem> queryResult =
        await dbClient.select(dbClient.transactionItems).get();

    return queryResult.map((result) => Cart.fromMap(result as Map)).toList();
  }

  // update quantity
  Future updateQuantity(Cart cart) {
    MyDatabase dbClient = database;

    return (dbClient.update(dbClient.transactionItems)
          ..where((tbl) => tbl.productId.equals(cart.productId)))
        .write(TransactionItemsCompanion(
      quantity: Value(cart.quantity.value),
    ));
  }

  // deleting an item from the cart screen
  Future<int> deleteCartItem(int productId) {
    MyDatabase dbClient = database;

    return (dbClient.delete(dbClient.transactionItems)
          ..where((tbl) => tbl.productId.equals(productId)))
        .go();
  }
}
