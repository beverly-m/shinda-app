import 'package:flutter/material.dart';
import 'package:shinda_app/components/custom_card.dart' show CustomCard;
import 'package:shinda_app/components/linear_progress_indicator.dart'
    show AppLinearProgressIndicator;
import 'package:shinda_app/constants/text_syles.dart'
    show primary, subtitle1, surface3;

class ProductsStockCard extends StatefulWidget {
  const ProductsStockCard({super.key, required this.lowInStockProductsData});

  final List lowInStockProductsData;

  @override
  State<ProductsStockCard> createState() => _ProductsStockCardState();
}

class _ProductsStockCardState extends State<ProductsStockCard> {
  bool _isLoading = true;
  List<ChartLine> data = [];

  @override
  void initState() {
    super.initState();
    _getData();
  }

  void _getData() {
    setState(() {
      _isLoading = true;
    });
    for (var element in widget.lowInStockProductsData) {
      data.add(ChartLine(
          title: element["product"]["name"],
          number: element["quantity_available"],
          total: element["quantity"],
          rate: element["quantity_available"] / element["quantity"]));
    }
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return _isLoading
        ? const Center(child: AppLinearProgressIndicator())
        : CustomCard(
            child: SizedBox(
              height: 180,
              width: double.infinity,
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 4.0, vertical: 8.0),
                        child: Text(
                          "Products low on stock",
                          overflow: TextOverflow.ellipsis,
                          softWrap: false,
                          style: subtitle1.copyWith(fontSize: 18),
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 8.0,
                    ),
                    SizedBox(
                      height: 120,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: data,
                          ),
                        ),
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
  })  : assert(rate >= 0),
        assert(rate <= 1),
        super(key: key);

  final double rate;
  final String title;
  final int number;
  final int total;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final lineWidget = constraints.maxWidth * rate;
      return Padding(
        padding: const EdgeInsets.only(bottom: 12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              constraints: BoxConstraints(minWidth: lineWidget),
              child: SizedBox(
                width: double.infinity,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        overflow: TextOverflow.ellipsis,
                        softWrap: false,
                        style: const TextStyle(
                          fontSize: 16,
                        ),
                      ),
                    ),
                    const Expanded(child: SizedBox()),
                    Text(
                      "${number.toString()} of ${total.toString()} left",
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 4.0),
            Stack(children: [
              Container(
                height: 8,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8.0),
                  border: Border.all(color: surface3, width: 0.5),
                  color: Colors.white,
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
