class CartItem {
  final String productId;
  final double price;
  int quantity;
  final String productName;

  CartItem({
    required this.productId,
    required this.price,
    required this.quantity,
    required this.productName,
  });
}
