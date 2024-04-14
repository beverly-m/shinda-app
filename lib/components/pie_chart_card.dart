import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:shinda_app/components/custom_card.dart' show CustomCard;
import 'package:shinda_app/components/indicator.dart' show Indicator;
import 'package:shinda_app/constants/text_syles.dart' show subtitle1, surface3;
import 'package:shinda_app/responsive/responsive_layout.dart' show Responsive;

class PieChartCard extends StatefulWidget {
  const PieChartCard({super.key, required this.salesData});
  final Map<String, dynamic> salesData;

  @override
  State<PieChartCard> createState() => _PieChartCardState();
}

class _PieChartCardState extends State<PieChartCard> {
  int touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    return CustomCard(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Expanded(
                  child: Text(
                    "Daily Income by Mode of Payment",
                    textAlign: TextAlign.left,
                    overflow: TextOverflow.ellipsis,
                    softWrap: false,
                    style: subtitle1.copyWith(fontSize: 18),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20.0),
          AspectRatio(
            aspectRatio: Responsive.isDesktop(context)
                ? 1.8
                : Responsive.isTablet(context)
                    ? 2.7
                    : 1.9,
            child: PieChart(
              PieChartData(
                pieTouchData: PieTouchData(
                  touchCallback: (FlTouchEvent event, pieTouchResponse) {
                    setState(() {
                      if (!event.isInterestedForInteractions ||
                          pieTouchResponse == null ||
                          pieTouchResponse.touchedSection == null) {
                        touchedIndex = -1;
                        return;
                      }
                      touchedIndex =
                          pieTouchResponse.touchedSection!.touchedSectionIndex;
                    });
                  },
                ),
                borderData: FlBorderData(show: false),
                sectionsSpace: 0,
                centerSpaceRadius: 40,
                sections: showSections(),
              ),
            ),
          ),
          Responsive.isDesktop(context)
              ? const SizedBox(height: 6.0)
              : const Expanded(child: SizedBox()),
          GridView.count(
            crossAxisCount: 2,
            mainAxisSpacing: 4.0,
            shrinkWrap: true,
            padding: const EdgeInsets.all(16.0),
            childAspectRatio:
                Responsive.isTablet(context) || Responsive.isMobile(context)
                    ? 8
                    : 5,
            children: const [
              Indicator(
                color: Color.fromRGBO(9, 82, 86, 1),
                text: 'Cash',
                isSquare: false,
                size: 16,
                textColor: Colors.black87,
              ),
              Indicator(
                color: Color.fromRGBO(187, 159, 6, 1),
                text: 'Mobile money',
                isSquare: false,
                size: 16,
                textColor: Colors.black87,
              ),
              Indicator(
                color: Color.fromRGBO(8, 127, 140, 1),
                text: 'Card',
                isSquare: false,
                size: 16,
                textColor: Colors.black87,
              ),
              Indicator(
                color: Colors.pink,
                text: 'Bank transfer',
                isSquare: false,
                size: 16,
                textColor: Colors.black87,
              ),
              Indicator(
                color: surface3,
                text: 'No Data',
                isSquare: false,
                size: 16,
                textColor: Colors.black87,
              ),
            ],
          ),
        ],
      ),
    );
  }

  List<PieChartSectionData> showSections() {
    return List.generate(5, (i) {
      final isTouched = i == touchedIndex;
      final fontSize = isTouched ? 25.0 : 16.0;
      final radius = isTouched ? 50.0 : 40.0;
      switch (i) {
        case 0:
          return PieChartSectionData(
            color: const Color.fromRGBO(9, 82, 86, 1),
            value: widget.salesData['cash'] == 0
                ? 0
                : (widget.salesData['cash'] / widget.salesData['income']) * 100,
            title: '${widget.salesData['cash'] / 1000}k',
            radius: radius,
            titleStyle: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          );
        case 1:
          return PieChartSectionData(
            color: const Color.fromRGBO(187, 159, 6, 1),
            value: widget.salesData['momo'] == 0
                ? 0
                : (widget.salesData['momo'] / widget.salesData['income']) * 100,
            title: '${widget.salesData['momo'] / 1000}k',
            radius: radius,
            titleStyle: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          );
        case 2:
          return PieChartSectionData(
            color: const Color.fromRGBO(8, 127, 140, 1),
            value: widget.salesData['card'] == 0
                ? 0
                : (widget.salesData['card'] / widget.salesData['income']) * 100,
            title: '${widget.salesData['card'] / 1000}k',
            radius: radius,
            titleStyle: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          );
        case 3:
          return PieChartSectionData(
            color: Colors.pink,
            value: widget.salesData['bank'] == 0
                ? 0
                : (widget.salesData['bank'] / widget.salesData['income']) * 100,
            title: '${widget.salesData['bank'] / 1000}k',
            radius: radius,
            titleStyle: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          );
        case 4:
          return PieChartSectionData(
            color: surface3,
            value: widget.salesData['bank'] == 0 &&
                    widget.salesData['card'] == 0 &&
                    widget.salesData['momo'] == 0 &&
                    widget.salesData['cash'] == 0
                ? 100
                : 0,
            showTitle: false,
            radius: radius,
          );
        default:
          throw Error();
      }
    });
  }
}
