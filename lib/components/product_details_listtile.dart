import 'package:flutter/material.dart';
import 'package:shinda_app/constants/text_syles.dart' show subtitle2, surface1;

class ProductDetailsListTile extends StatelessWidget {
  const ProductDetailsListTile({
    super.key,
    required this.productName,
    required this.quantity,
    required this.pricePerItem,
  });
  final String productName;
  final int quantity;
  final double pricePerItem;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(vertical: 4.0),
      leading: Container(
        width: 48.0,
        height: 48.0,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8.0),
          color: surface1,
        ),
        child: const Icon(
          Icons.shopping_bag_outlined,
          color: Colors.black12,
          size: 24.0,
        ),
      ),
      title: Text.rich(TextSpan(
        text: productName,
        children: [
          TextSpan(text: ' x${quantity.toString()}'),
        ],
      )),
      subtitle: Text.rich(
        TextSpan(
          text: 'RWF ',
          children: [
            TextSpan(
              text: pricePerItem.toStringAsFixed(2),
            )
          ],
        ),
      ),
      trailing: Text.rich(
        TextSpan(
          text: 'RWF ',
          children: [
            TextSpan(
              text: (pricePerItem * quantity).toStringAsFixed(2),
            )
          ],
        ),
        style: subtitle2,
      ),
    );
  }
}
