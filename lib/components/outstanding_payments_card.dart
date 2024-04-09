import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:pluto_grid/pluto_grid.dart';
import 'package:shinda_app/components/custom_card.dart';
import 'package:shinda_app/constants/text_syles.dart';

class OutstandingPaymentsCard extends StatefulWidget {
  const OutstandingPaymentsCard({super.key, required this.data});

  final List<Map<String, dynamic>> data;

  @override
  State<OutstandingPaymentsCard> createState() =>
      _OutstandingPaymentsCardState();
}

class _OutstandingPaymentsCardState extends State<OutstandingPaymentsCard> {
  bool _isLoading = false;
  late final PlutoGridStateManager stateManager;

  final List<PlutoRow> debtorDataRows = [];

  List<PlutoColumn> debtorDataColumns = [
    PlutoColumn(
      title: 'Client name',
      field: 'client_name',
      type: PlutoColumnType.text(),
    ),
    PlutoColumn(
      title: 'Amount owed',
      field: 'amount_owed',
      type: PlutoColumnType.currency(
        name: 'RWF',
        symbol: 'RWF',
        decimalDigits: 2,
      ),
    ),
    PlutoColumn(
      title: 'Transaction Id',
      field: 'transaction_id',
      type: PlutoColumnType.text(),
    ),
    PlutoColumn(
      title: 'Phone number',
      field: 'phone_number',
      type: PlutoColumnType.text(),
    ),
    PlutoColumn(
      title: 'Address',
      field: 'address',
      type: PlutoColumnType.text(),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _getData();
  }

  void _getData() {
    setState(() {
      _isLoading = true;
    });

    for (var element in widget.data) {
      debtorDataRows.add(
        PlutoRow(
          cells: {
            'client_name': PlutoCell(value: element['client_name']),
            'amount_owed': PlutoCell(value: element['amount_owed']),
            'transaction_id':
                PlutoCell(value: element['transaction']['transaction_id']),
            'phone_number': PlutoCell(value: element['phone_number']),
            'address': PlutoCell(value: element['address']),
          },
        ),
      );
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return _isLoading
        ? const Center(
            child: CircularProgressIndicator(
              color: primary,
            ),
          )
        : CustomCard(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      Text(
                        "Outstanding payments/Debtors",
                        style: subtitle1.copyWith(fontSize: 18),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8.0),
                SizedBox(
                  height: 200,
                  child: PlutoGrid(
                    columns: debtorDataColumns,
                    rows: debtorDataRows,
                    noRowsWidget: const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [ 
                          Icon(
                            Icons.table_chart_outlined,
                            size: 32,
                            color: surface3,
                          ),
                          SizedBox(
                            height: 16.0,
                          ),
                          Text("No outstanding payments"),
                        ],
                      ),
                    ),
                    onLoaded: (PlutoGridOnLoadedEvent event) {
                      stateManager = event.stateManager;
                      stateManager
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
                        rowColor: surface1,
                      ),
                      columnSize: const PlutoGridColumnSizeConfig(
                          autoSizeMode: PlutoAutoSizeMode.equal),
                    ),
                  ),
                ),
              ],
            ),
          );
  }
}
