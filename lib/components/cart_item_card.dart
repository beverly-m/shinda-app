import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shinda_app/components/buttons.dart';
import 'package:shinda_app/constants/text_syles.dart';

class CartItemCard extends StatelessWidget {
  final String productName;
  final String productPrice;
  final ValueListenable<int> valueListenable;
  final void Function() addQuantity;
  final void Function() deleteQuantity;
  final void Function() onPressedDeleteButton;

  const CartItemCard({
    super.key,
    required this.productName,
    required this.productPrice,
    required this.valueListenable,
    required this.addQuantity,
    required this.deleteQuantity,
    required this.onPressedDeleteButton,
  });

  @override
  Widget build(BuildContext context) {
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
                borderRadius: BorderRadius.circular(8.0),
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  productName,
                  style: body1,
                ),
                const Flexible(child: SizedBox()),
                Text(
                  productPrice,
                  style: body2.copyWith(color: neutral4),
                ),
              ],
            ),
            const Expanded(child: SizedBox()),
            ValueListenableBuilder<int>(
              valueListenable: valueListenable,
              builder: (context, value, child) {
                return PlusMinusButtons(
                  addQuantity: addQuantity,
                  deleteQuantity: deleteQuantity,
                  text: value.toString(),
                );
              },
            ),
            IconButton(
              onPressed: onPressedDeleteButton,
              icon: const Icon(Icons.delete_outline),
            )
          ],
        ),
      ),
    );
  }
}
