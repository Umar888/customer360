import 'dart:math';

import 'package:flutter/material.dart';
import 'package:gc_customer_app/primitives/color_system.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class CircularChartWidget extends StatelessWidget {
  final List<int> data;
  final List<String> dataName;
  final Function onChartTapped;
  final bool isHaveThreeValue;
  CircularChartWidget(
      {Key? key,
      required this.data,
      required this.dataName,
      required this.onChartTapped,
      this.isHaveThreeValue = false})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    var maxValue = data.reduce(max);
    var chartData = [
      _ChartData(data[0], data[0] / maxValue * 100, dataName[0]),
      _ChartData(data[1], data[1] / maxValue * 100, dataName[1]),
    ];
    if (isHaveThreeValue) {
      chartData.add(_ChartData(data[2], data[2] / maxValue * 100, dataName[2]));
    }
    return SizedBox(
      height: MediaQuery.of(context).size.width / 2.5,
      width: MediaQuery.of(context).size.width / 2.5,
      child: SfCircularChart(
        series: <CircularSeries<_ChartData, String>>[
          PieSeries<_ChartData, String>(
              dataSource: chartData,
              xValueMapper: (_ChartData data, _) => data.z,
              yValueMapper: (_ChartData data, _) => data.y,
              dataLabelSettings: DataLabelSettings(
                  isVisible: false,
                  angle: 302,
                  textStyle: TextStyle(fontSize: 8))),
        ],
        onChartTouchInteractionDown: (tapArgs) {
          onChartTapped();
        },
        palette: isHaveThreeValue
            ? <Color>[
                ColorSystem.additionalGreen,
                Colors.amber,
                ColorSystem.lavender,
              ]
            : <Color>[
                ColorSystem.lavender,
                Color.fromARGB(255, 199, 202, 255),
              ],
        margin: EdgeInsets.zero,
      ),
    );
  }
}

class _ChartData {
  int x;
  double y;
  String z;

  _ChartData(this.x, this.y, this.z);
}
