import 'package:flutter/material.dart';
import 'package:shinda_app/constants/text_syles.dart';

class ProductCard extends StatelessWidget {
  final String productName;
  final double productPrice;
  final int quantityInStock;
  final void Function() onPressed;
  const ProductCard({
    super.key,
    required this.productName,
    required this.productPrice,
    required this.quantityInStock,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0.0,
      surfaceTintColor: Colors.white,
      shape: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.0),
        borderSide: const BorderSide(color: surface3),
      ),
      child: AspectRatio(
        aspectRatio: 1,
        child: Container(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8.0),
                    color: surface1,
                  ),
                  child: const Icon(
                    Icons.shopping_bag_outlined,
                    color: Colors.black12,
                    size: 32.0,
                  ),
                ),
              ),
              const SizedBox(height: 16.0),
              Text(
                productName,
                style: body1.copyWith(overflow: TextOverflow.ellipsis),
                maxLines: 1,
              ),
              const SizedBox(height: 4.0),
              Text(
                "RWF ${productPrice.toStringAsFixed(2)}",
                style: priceText2,
              ),
              const SizedBox(height: 8.0),
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    "${quantityInStock.toString()} in stock",
                    style: labelText,
                  ),
                  const Expanded(child: SizedBox()),
                  IconButton(
                    style: IconButton.styleFrom(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0)),
                      side: const BorderSide(color: primary),
                    ),
                    onPressed: onPressed,
                    icon: const Icon(
                      Icons.add,
                      size: 24.0,
                      color: primary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
