import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:pluto_grid/pluto_grid.dart';
import 'package:shinda_app/constants/text_syles.dart';

class TransactionDataGrid extends StatefulWidget {
  const TransactionDataGrid({super.key, required this.data});

  final List<Map<String, dynamic>> data;

  @override
  State<TransactionDataGrid> createState() => _TransactionDataGridState();
}

class _TransactionDataGridState extends State<TransactionDataGrid> {
  bool _isLoading = false;

  List<PlutoColumn> transactionDataColumns = [
    PlutoColumn(
      title: 'Transaction id',
      field: 'transaction_id',
      type: PlutoColumnType.text(),
    ),
    PlutoColumn(
      title: 'Mode of payment',
      field: 'payment_mode',
      type: PlutoColumnType.text(),
    ),
    PlutoColumn(
      title: 'Total Cost',
      field: 'total_cost',
      type: PlutoColumnType.currency(
        name: 'RWF',
        symbol: 'RWF',
        decimalDigits: 2,
      ),
    ),
    PlutoColumn(
      title: 'Paid',
      field: 'paid',
      type: PlutoColumnType.select(['true', 'false']),
    ),
    PlutoColumn(
      title: 'Date created',
      field: 'date_created',
      type: PlutoColumnType.date(),
    ),
  ];

  final List<PlutoRow> transactionDataRows = [];
  late final PlutoGridStateManager stateManager;

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
      transactionDataRows.add(PlutoRow(cells: {
        'transaction_id': PlutoCell(value: element['transaction_id']),
        'payment_mode': PlutoCell(value: element['payment_mode']),
        'total_cost': PlutoCell(value: element['grand_total']),
        'paid': PlutoCell(value: element['is_paid']),
        'date_created': PlutoCell(value: element['created_at']),
      }));
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
        : SizedBox(
            width: MediaQuery.of(context).size.width * 0.9,
            height: MediaQuery.of(context).size.height,
            child: PlutoGrid(
              mode: PlutoGridMode.readOnly,
              columns: transactionDataColumns,
              rows: transactionDataRows,
              noRowsWidget: const Column(
                children: [
                  Icon(
                    Icons.table_chart_outlined,
                    size: 32,
                    color: surface3,
                  ),
                  SizedBox(
                    height: 16.0,
                  ),
                  Text("No transactions yet"),
                ],
              ),
              onLoaded: (PlutoGridOnLoadedEvent event) {
                stateManager = event.stateManager;
                stateManager.setShowColumnFilter(true);
              },
              onChanged: (PlutoGridOnChangedEvent event) {
                log(event.toString());
              },
              configuration: PlutoGridConfiguration(
                style: PlutoGridStyleConfig(
                  gridBorderRadius: BorderRadius.circular(8.0),
                ),
                columnSize: const PlutoGridColumnSizeConfig(
                    autoSizeMode: PlutoAutoSizeMode.equal),
              ),
            ),
          );
  }
}
