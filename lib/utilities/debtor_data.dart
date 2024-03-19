import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:pluto_grid/pluto_grid.dart';
import 'package:shinda_app/constants/text_syles.dart';

class DebtorDataGrid extends StatefulWidget {
  const DebtorDataGrid({super.key, required this.data});

  final List<Map<String, dynamic>> data;

  @override
  State<DebtorDataGrid> createState() => _DebtorDataGridState();
}

class _DebtorDataGridState extends State<DebtorDataGrid> {
  bool _isLoading = false;

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
      title: 'Phone number',
      field: 'phone_number',
      type: PlutoColumnType.text(),
    ),
    PlutoColumn(
      title: 'Address',
      field: 'address',
      type: PlutoColumnType.text(),
    ),
    PlutoColumn(
      title: 'Date paid',
      field: 'date_paid',
      type: PlutoColumnType.date(),
    ),
    PlutoColumn(
      title: 'Paid',
      field: 'paid',
      type: PlutoColumnType.select(['true', 'false']),
    ),
  ];

  final List<PlutoRow> debtorDataRows = [];
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
      debtorDataRows.add(
        PlutoRow(
          cells: {
            'client_name': PlutoCell(value: element['client_name']),
            'amount_owed': PlutoCell(value: element['amount_owed']),
            'phone_number': PlutoCell(value: element['phone_number']),
            'address': PlutoCell(value: element['address']),
            'date_paid': PlutoCell(value: element['date_paid']),
            'paid': PlutoCell(value: element['transaction']['is_paid']),
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
        : SizedBox(
            width: MediaQuery.of(context).size.width * 0.9,
            height: MediaQuery.of(context).size.height,
            child: PlutoGrid(
              mode: PlutoGridMode.readOnly,
              columns: debtorDataColumns,
              rows: debtorDataRows,
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
                  Text("No debtors added"),
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
