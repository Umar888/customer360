import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:gc_customer_app/models/my_customer/customer_model.dart';
import 'package:gc_customer_app/primitives/color_system.dart';
import 'package:gc_customer_app/screens/landing_screen/widget/order_history_by_year_chart_widget.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'dart:math';

class ClientsLineChartWidget extends StatelessWidget {
  final List<MyCustomerModel> data;
  final Function onChartTapped;
  ClientsLineChartWidget(
      {Key? key, required this.data, required this.onChartTapped})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    // var maxValue = data.reduce(max);
    // var chartData = [
    //   _ChartData(data[0], data[0] / maxValue * 100, 'High'),
    //   _ChartData(data[1], data[1] / maxValue * 100, 'Medium'),
    //   _ChartData(data[2], data[2] / maxValue * 100, 'Low'),
    // ];
    // var chartData = [ChartSampleData(year, value, percent)];
    // var chartData = data.map((e) => _ChartData(e, y, e.priority!)).toList();
    List<_ChartData> chartData = [];
    List<_ChartData> highData = [];
    List<_ChartData> mediumData = [];
    List<_ChartData> lowData = [];
    int maxValue;
    data.forEach((d) {
      switch (d.priority) {
        case 'High':
          highData.add(_ChartData(highData.length,
              d.record?.lastTransactionDateC?.year.toDouble() ?? 0));
          break;
        case 'Medium':
          mediumData.add(_ChartData(mediumData.length,
              d.record?.lastTransactionDateC?.year.toDouble() ?? 0));
          break;
        case 'Low':
          lowData.add(_ChartData(lowData.length,
              d.record?.lastTransactionDateC?.year.toDouble() ?? 2020));
          break;
        default:
      }
    });
    // highData.forEach((element) {
    //   print(element.toJson());
    // });
    // mediumData.forEach((element) {
    //   print(element.toJson());
    // });
    // lowData.forEach((element) {
    //   print(element.toJson());
    // });
    highData = [
      _ChartData(0, 1),
      _ChartData(1, 6),
      _ChartData(2, 5),
      _ChartData(3, 2),
    ];
    mediumData = [
      _ChartData(0, 5),
      _ChartData(1, 1),
      _ChartData(2, 1),
      _ChartData(3, 2),
    ];
    lowData = [
      _ChartData(0, 2),
      _ChartData(1, 8),
      _ChartData(2, 1),
      _ChartData(3, 4),
    ];
    int maxLength = highData.length;
    if (maxLength < mediumData.length) maxLength = mediumData.length;
    if (maxLength < lowData.length) maxLength = lowData.length;

    LineChartBarData lineChartBarData2_1 = LineChartBarData(
        color: ColorSystem.additionalGreen,
        isCurved: true,
        curveSmoothness: 0,
        barWidth: 4,
        isStrokeCapRound: true,
        dotData: FlDotData(show: false),
        belowBarData: BarAreaData(show: false),
        spots: highData.map((e) => FlSpot(e.x.toDouble(), e.y)).toList());

    LineChartBarData lineChartBarData2_2 = LineChartBarData(
        color: Colors.amber,
        isCurved: true,
        curveSmoothness: 0,
        barWidth: 4,
        isStrokeCapRound: true,
        dotData: FlDotData(show: false),
        belowBarData: BarAreaData(show: false),
        spots: mediumData.map((e) => FlSpot(e.x.toDouble(), e.y)).toList());

    LineChartBarData lineChartBarData2_3 = LineChartBarData(
        color: ColorSystem.lavender,
        isCurved: true,
        curveSmoothness: 0,
        barWidth: 4,
        isStrokeCapRound: true,
        dotData: FlDotData(show: false),
        belowBarData: BarAreaData(show: false),
        spots: lowData.map((e) => FlSpot(e.x.toDouble(), e.y)).toList());

    return SizedBox(
      height: MediaQuery.of(context).size.width / 2.5,
      width: MediaQuery.of(context).size.width / 2.5,
      child: LineChart(LineChartData(
        lineTouchData: LineTouchData(enabled: false),
        gridData: FlGridData(show: false),
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 32,
              interval: 1,
              getTitlesWidget: (value, meta) {
                if (value % 2 == 0) return Text(value.toStringAsFixed(0));
                return SizedBox.shrink();
              },
            ),
          ),
          rightTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              getTitlesWidget: (value, meta) {
                return Text(value.toString());
              },
              showTitles: true,
              interval: 1,
              reservedSize: 40,
            ),
          ),
        ),
        borderData: FlBorderData(
          show: true,
          border: Border(
            bottom: BorderSide(color: Color(0xff4e4965), width: 4),
            left: BorderSide(color: Colors.transparent),
            right: BorderSide(color: Colors.transparent),
            top: BorderSide(color: Colors.transparent),
          ),
        ),
        lineBarsData: [
          lineChartBarData2_1,
          lineChartBarData2_2,
          lineChartBarData2_3,
        ],
        minX: 0,
        maxX: maxLength.toDouble(),
        maxY: 6,
        minY: 0,
      )),
      // child: SfCartesianChart(
      //   series: <ChartSeries>[
      //     StackedLineSeries<_ChartData, String>(
      //         dataSource: chartData,
      //         xValueMapper: (_ChartData data, _) => data.z,
      //         yValueMapper: (_ChartData data, _) => data.x,
      //         name: 'High'),
      //     // StackedLineSeries<_ChartData, String>(
      //     //   dataSource: chartData,
      //     //   xValueMapper: (_ChartData data, _) => data.z,
      //     //   yValueMapper: (_ChartData data, _) => data.x,
      //     //   name: 'Medium',
      //     // ),
      //     // StackedLineSeries<_ChartData, String>(
      //     //   dataSource: chartData,
      //     //   xValueMapper: (_ChartData data, _) => data.z,
      //     //   yValueMapper: (_ChartData data, _) => data.x,
      //     //   name: 'Low',
      //     // ),
      //   ],
      //   onChartTouchInteractionDown: (tapArgs) {
      //     onChartTapped();
      //   },
      //   palette: <Color>[
      //     ColorSystem.additionalGreen,
      //     Colors.amber,
      //     ColorSystem.lavender
      //   ],
      //   margin: EdgeInsets.zero,
      // ),
    );
  }
}

class _ChartData {
  int x;
  double y;

  _ChartData(this.x, this.y);

  Map<String, dynamic>? toJson() => {
        'x': x,
        'y': y,
      };
}
