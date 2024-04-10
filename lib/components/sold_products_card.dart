import 'package:flutter/material.dart';
import 'package:pluto_grid/pluto_grid.dart';
import 'package:shinda_app/components/custom_card.dart';
import 'package:shinda_app/constants/text_syles.dart';

class SoldProductsCard extends StatefulWidget {
  const SoldProductsCard({super.key, required this.soldProductsData});
  final Map soldProductsData;

  @override
  State<SoldProductsCard> createState() => _SoldProductsCardState();
}

class _SoldProductsCardState extends State<SoldProductsCard> {
  bool _isLoading = true;
  List<PlutoColumn> dataColumns = [
    PlutoColumn(
      title: 'Product',
      field: 'product',
      type: PlutoColumnType.text(),
    ),
    PlutoColumn(
      title: 'Quantity sold',
      field: 'sold',
      type: PlutoColumnType.number(),
      sort: PlutoColumnSort.descending,
    ),
  ];

  List<PlutoRow> dataRows = [];

  @override
  void initState() {
    super.initState();
    _getData();
  }

  void _getData() {
    setState(() {
      _isLoading = true;
    });

    widget.soldProductsData.forEach((key, value) {
      dataRows.add(PlutoRow(cells: {
        'product': PlutoCell(value: value[1]),
        'sold': PlutoCell(value: value[0]),
      }));
    });

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return _isLoading
        ? const Center(child: CircularProgressIndicator())
        : CustomCard(
            child: SizedBox(
            height: 200,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 4.0, vertical: 8.0),
                  child: Text(
                    "Products sold",
                    style: subtitle1.copyWith(fontSize: 18),
                  ),
                ),
                const SizedBox(
                  height: 8.0,
                ),
                Expanded(
                  flex: 4,
                  child: PlutoGrid(
                    columns: dataColumns,
                    rows: dataRows,
                    noRowsWidget: const Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.date_range_outlined,
                            size: 24,
                            color: surface3,
                          ),
                          SizedBox(
                            height: 16.0,
                          ),
                          Text("No products yet"),
                        ],
                      ),
                    ),
                    onLoaded: (PlutoGridOnLoadedEvent event) {
                      event.stateManager
                          .setSelectingMode(PlutoGridSelectingMode.none);
                    },
                    onChanged: (PlutoGridOnChangedEvent event) {},
                    configuration: PlutoGridConfiguration(
                      style: PlutoGridStyleConfig(
                        gridBorderRadius: BorderRadius.circular(8.0),
                        gridBackgroundColor: surface1,
                        gridBorderColor: surface3,
                      ),
                      columnSize: const PlutoGridColumnSizeConfig(
                          autoSizeMode: PlutoAutoSizeMode.equal),
                    ),
                  ),
                ),
              ],
            ),
          ));
  }
}
