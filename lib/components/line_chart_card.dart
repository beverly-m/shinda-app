import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:shinda_app/components/custom_card.dart';
import 'package:shinda_app/constants/text_syles.dart';

class LineChartCard extends StatelessWidget {
  const LineChartCard({super.key, required this.salesData});
  final List salesData;
  List<String> get weekDays =>
      const ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  @override
  Widget build(BuildContext context) {
    final data = LineData(data: salesData);
    data.getSpots();
    log("Sales data---------");
    log(salesData.toString());
    log(salesData.length.toString());
    // int day = DateTime.timestamp().weekday;
    // log("Day");
    // log('${DateTime.timestamp()}, ${weekDays[day - 1]}');

    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              "Sales Overview",
              style: subtitle1.copyWith(fontSize: 18),
            ),
          ),
          const SizedBox(height: 20),
          AspectRatio(
            aspectRatio: 16 / 6,
            child: LineChart(
              LineChartData(
                lineTouchData: LineTouchData(
                  handleBuiltInTouches: true,
                  touchTooltipData: LineTouchTooltipData(
                    tooltipBgColor: Colors.white,
                    tooltipBorder: const BorderSide(color: primary),
                    getTooltipItems: (List<LineBarSpot> touchedBarSpots) {
                      return touchedBarSpots.map((barSpot) {
                        final flSpot = barSpot;

                        TextAlign textAlign;
                        switch (flSpot.x.toInt()) {
                          case 1:
                            textAlign = TextAlign.left;
                            break;
                          case 7:
                            textAlign = TextAlign.right;
                            break;
                          default:
                            textAlign = TextAlign.center;
                        }

                        return LineTooltipItem(
                          '${weekDays[flSpot.x.toInt() - 1]} \n',
                          const TextStyle(
                            color: Colors.black87,
                            fontWeight: FontWeight.bold,
                          ),
                          children: [
                            TextSpan(
                              text:
                                  "RWF ${(flSpot.y * 1000).toStringAsFixed(2)}",
                              style: const TextStyle(
                                  color: Colors.black87,
                                  fontWeight: FontWeight.normal),
                            ),
                          ],
                          textAlign: textAlign,
                        );
                      }).toList();
                    },
                  ),
                ),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 10,
                  getDrawingHorizontalLine: (value) {
                    return const FlLine(
                      color: Colors.black12,
                      strokeWidth: 0.5,
                      dashArray: [4, 2],
                    );
                  },
                ),
                titlesData: FlTitlesData(
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (double value, TitleMeta meta) {
                        return data.bottomTitle[value.toInt()] != null &&
                                value != 7.5
                            ? SideTitleWidget(
                                axisSide: meta.axisSide,
                                child: Text(
                                    data.bottomTitle[value.toInt()].toString(),
                                    style: TextStyle(
                                        fontSize: 12, color: Colors.grey[400])),
                              )
                            : const SizedBox();
                      },
                      interval: 1,
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      getTitlesWidget: (double value, TitleMeta meta) {
                        return data.leftTitle[value.toInt()] != null
                            ? Text(data.leftTitle[value.toInt()].toString(),
                                style: TextStyle(
                                    fontSize: 12, color: Colors.grey[400]))
                            : const SizedBox();
                      },
                      showTitles: true,
                      interval: 1,
                      reservedSize: 42,
                    ),
                  ),
                ),
                borderData: FlBorderData(
                    show: true, border: Border.all(color: Colors.black12)),
                lineBarsData: [
                  LineChartBarData(
                    color: primary,
                    barWidth: 2,
                    isCurved: true,
                    belowBarData: BarAreaData(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [primary.withOpacity(0.5), surface3],
                      ),
                      show: true,
                    ),
                    dotData: FlDotData(
                      getDotPainter: (spot, percent, barData, index) {
                        return FlDotCirclePainter(
                          radius: 2,
                          color: surface1,
                          strokeWidth: 2,
                          strokeColor: primary,
                        );
                      },
                    ),
                    spots: data.getSpots(),
                  )
                ],
                minX: 0.5,
                maxX: 7.5,
                maxY: 100,
                minY: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class LineData {
  LineData({required this.data});
  final List data;

  List<FlSpot> spots = const [];
  // final spots = const [
  //   FlSpot(1.0, 21.04),
  //   FlSpot(2.0, 36.23),
  //   FlSpot(3.0, 39.82),
  //   FlSpot(4.0, 44.49),
  //   FlSpot(5.0, 19.82),
  //   FlSpot(6.0, 23.50),
  //   FlSpot(7.0, 29.57),
  // ];

  final leftTitle = {
    0: '0',
    20: '20K',
    40: '40K',
    60: '60K',
    80: '80K',
    100: '100K'
  };

  final bottomTitle = {
    1: 'Mon',
    2: 'Tue',
    3: 'Wed',
    4: 'Thu',
    5: 'Fri',
    6: 'Sat',
    7: 'Sun',
  };

  List<FlSpot> getSpots() {
    List<FlSpot> spotsData = [];

    for (var element in data) {
      int day = DateTime.parse(element['day']).weekday;
      double amount = element['sum'] / 1000;

      log("Spots-----------");
      log(bottomTitle[day]!);
      log(amount.toString());

      spots = spots + [FlSpot(day.toDouble(), amount)];

      spotsData.add(FlSpot(day.toDouble(), amount));

      // spots.add(FlSpot(day.toDouble(), amount));
    }
    return spotsData;
  }
}
