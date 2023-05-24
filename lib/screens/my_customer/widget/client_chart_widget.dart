import 'package:flutter/material.dart';
import 'package:gc_customer_app/primitives/color_system.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'dart:math';

class ClientsChartWidget extends StatelessWidget {
  final List<int> data;
  final Function onChartTapped;
  ClientsChartWidget(
      {Key? key, required this.data, required this.onChartTapped})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    var maxValue = data.reduce(max);
    var chartData = [
      _ChartData(data[0], data[0] / maxValue * 100, 'High'),
      _ChartData(data[1], data[1] / maxValue * 100, 'Medium'),
      _ChartData(data[2], data[2] / maxValue * 100, 'Low'),
    ];
    return SizedBox(
      height: MediaQuery.of(context).size.width / 2.5,
      width: MediaQuery.of(context).size.width / 2.5,
      child: SfCircularChart(
        series: <CircularSeries<_ChartData, String>>[
          DoughnutSeries<_ChartData, String>(
              dataSource: chartData,
              xValueMapper: (_ChartData data, _) => data.x.toString(),
              yValueMapper: (_ChartData data, _) => data.y,
              dataLabelSettings: DataLabelSettings(
                  isVisible: false,
                  angle: 302,
                  textStyle: TextStyle(fontSize: 8))),
        ],
        onChartTouchInteractionDown: (tapArgs) {
          onChartTapped();
        },
        palette: <Color>[
          ColorSystem.additionalGreen,
          Colors.amber,
          ColorSystem.lavender
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
