import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:shinda_app/components/custom_card.dart';
import 'package:shinda_app/constants/text_syles.dart';

class LineChartCard extends StatelessWidget {
  const LineChartCard({super.key, required this.salesData});
  final List salesData;
  List<String> get weekDays =>
      ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  /// Find the first date of the week which contains the provided date.
  String findFirstDateOfTheWeek(DateTime dateTime) {
    DateTime firstDate =
        dateTime.subtract(Duration(days: dateTime.weekday - 1));

    return "${firstDate.day}/${firstDate.month}/${firstDate.year}";
  }

  /// Find last date of the week which contains provided date.
  String findLastDateOfTheWeek(DateTime dateTime) {
    DateTime lastDate =
        dateTime.add(Duration(days: DateTime.daysPerWeek - dateTime.weekday));
    return "${lastDate.day}/${lastDate.month}/${lastDate.year}";
  }

  @override
  Widget build(BuildContext context) {
    final data = LineData(data: salesData);
    data.getSpots();

    // Find first date and last date of THIS WEEK
    DateTime today = DateTime.now();

    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Text(
                  "Weekly Sales Overview",
                  style: subtitle1.copyWith(fontSize: 18),
                ),
                const Expanded(child: SizedBox()),
                Chip(
                  label: Text(
                    '${findFirstDateOfTheWeek(today)} - ${findLastDateOfTheWeek(today).toString()}',
                    style: const TextStyle(color: Colors.white),
                  ),
                  side: BorderSide.none,
                  backgroundColor: primary,
                )
              ],
            ),
          ),
          const SizedBox(height: 20),
          AspectRatio(
            aspectRatio: 16 / 7,
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

  final leftTitle = {
    0: '0',
    20: '20K',
    40: '40K',
    60: '60K',
    80: '80K',
    100: '100K'
  };

  final Map<int, String> bottomTitle = {
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
    int startIndex = (DateTime.timestamp().weekday);

    for (var element in data) {
      int day = DateTime.parse(element['day']).weekday;
      if (day <= startIndex) {
        double amount = element['sum'] / 1000;
        spots = spots + [FlSpot(day.toDouble(), amount)];
        spotsData.add(FlSpot(day.toDouble(), amount));
      }
    }
    return spotsData;
  }
}
