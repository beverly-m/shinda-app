import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:pluto_grid/pluto_grid.dart';
import 'package:shinda_app/components/custom_card.dart';
import 'package:shinda_app/constants/text_syles.dart';

class ProductsStockCard extends StatefulWidget {
  const ProductsStockCard({super.key});

  @override
  State<ProductsStockCard> createState() => _ProductsStockCardState();
}

class _ProductsStockCardState extends State<ProductsStockCard> {
  List<PlutoColumn> dataColumns = [
    PlutoColumn(
      title: 'Product',
      field: 'product',
      type: PlutoColumnType.text(),
    ),
    PlutoColumn(
      title: 'Expiry',
      field: 'expiry',
      type: PlutoColumnType.date(),
    ),
  ];

  List<PlutoRow> dataRows = [];

  // Widget _title(String title) {
  //   return Padding(
  //     padding: const EdgeInsets.only(bottom: 8.0, top: 4.0),
  //     child: Text(
  //       title,
  //       style: subtitle1,
  //     ),
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    return CustomCard(
      child: SizedBox(
        height: 280,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 8.0),
            child: Text(
              "Products low on stock",
              style: subtitle1.copyWith(fontSize: 18),
            ),
          ),
          const SizedBox(
            height: 8.0,
          ),
          const Padding(
            padding: EdgeInsets.only(left: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ChartLine(title: 'Fat', number: 1800, total: 1800, rate: 1),
                ChartLine(title: 'Protein', number: 600, total: 1800, rate: 0.4)
              ],
            ),
          ),
        ]),
      ),
    );
  }
}

class ChartLine extends StatelessWidget {
  const ChartLine({
    Key? key,
    required this.rate,
    required this.title,
    required this.number,
    required this.total,
  })  : assert(rate > 0),
        assert(rate <= 1),
        super(key: key);

  final double rate;
  final String title;
  final int number;
  final double total;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final lineWidget = constraints.maxWidth * rate;
      return Padding(
        padding: const EdgeInsets.only(bottom: 8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              constraints: BoxConstraints(minWidth: lineWidget),
              child: IntrinsicWidth(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(width: 16.0),
                    Text(
                      "${number.toString()} left",
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Stack(children: [
              Container(
                height: 8,
                width: total,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8.0),
                  color: surface3,
                ),
              ),
              Container(
                height: 8,
                width: lineWidget,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8.0),
                  color: primary,
                ),
              ),
            ]),
          ],
        ),
      );
    });
  }
}
