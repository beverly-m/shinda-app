import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:pluto_grid/pluto_grid.dart';
import 'package:shinda_app/components/circular_progress_indicator.dart';
import 'package:shinda_app/components/custom_card.dart';
import 'package:shinda_app/constants/text_syles.dart';

class ExpiringProductsCard extends StatefulWidget {
  const ExpiringProductsCard({super.key, this.expiredProductsData});
  final List? expiredProductsData;

  @override
  State<ExpiringProductsCard> createState() => _ExpiringProductsCardState();
}

class _ExpiringProductsCardState extends State<ExpiringProductsCard> {
  bool _isLoading = true;
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

  @override
  void initState() {
    super.initState();
    _getData();
  }

  void _getData() {
    setState(() {
      _isLoading = true;
    });

    if (widget.expiredProductsData != null) {
      for (var element in widget.expiredProductsData!) {
        dataRows.add(
          PlutoRow(
            cells: {
              'product': PlutoCell(value: element["product"]['name']),
              'expiry': PlutoCell(value: element["expiration_date"]),
            },
          ),
        );
      }
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return _isLoading
        ? const Center(child: AppCircularProgressIndicator())
        : CustomCard(
            child: SizedBox(
            height: 200,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 4.0, vertical: 8.0),
                        child: Text(
                          "Products expiring",
                          overflow: TextOverflow.ellipsis,
                          softWrap: false,
                          style: subtitle1.copyWith(fontSize: 18),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8.0),
                    Chip(
                      label: const Text("In 7 Days"),
                      color: const MaterialStatePropertyAll(surface3),
                      shape: RoundedRectangleBorder(
                          side: const BorderSide(color: primary),
                          borderRadius: BorderRadius.circular(8.0)),
                    ),
                  ],
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
                    onChanged: (PlutoGridOnChangedEvent event) {
                      log(event.toString());
                    },
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
