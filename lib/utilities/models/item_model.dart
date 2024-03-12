class Item {
  final String productId;
  final String name;
  final double price;
  final int quantity;
  final String? image;

  Item({
    required this.productId,
    required this.name,
    required this.price,
    required this.quantity,
    this.image,
  });

  Map toJson() {
    return {
      'productId': productId,
      'name': name,
      'price': price,
      'quantity': quantity,
      'image': image,
    };
  }
}
