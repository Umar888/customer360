import 'dart:math';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gc_customer_app/bloc/profile_screen_bloc/purchase_metrics_bloc/purchase_metrics_bloc.dart';
import 'package:gc_customer_app/models/order_history/order_history_model.dart';
import 'package:gc_customer_app/models/purchase_metrics_model.dart';
import 'package:gc_customer_app/primitives/color_system.dart';

class BusinessDataChart extends StatefulWidget {
  final List<OrderHistory> dataInNewestYear;
  final List<OrderHistory>? dataInPreviousYear;
  BusinessDataChart({
    Key? key,
    required this.dataInNewestYear,
    required this.dataInPreviousYear,
  }) : super(key: key);

  @override
  State<BusinessDataChart> createState() => _BusinessDataChartState();
}

class _BusinessDataChartState extends State<BusinessDataChart> {
  late List<FlSpot> oldData = [
    FlSpot(0, 0),
    FlSpot(1, 0),
    FlSpot(2, 0),
    FlSpot(3, 0),
    FlSpot(4, 0),
    FlSpot(5, 0),
    FlSpot(6, 0),
    FlSpot(7, 0),
    FlSpot(8, 0),
    FlSpot(9, 0),
    FlSpot(10, 0),
    FlSpot(11, 0),
  ];
  late List<List<int>> newData = [
    [0, 0],
    [1, 0],
    [2, 0],
    [3, 0],
    [4, 0],
    [5, 0],
    [6, 0],
    [7, 0],
    [8, 0],
    [9, 0],
    [10, 0],
    [11, 0],
  ];
  double maxData = 0;

  LinearGradient get _barsGradient => LinearGradient(
        colors: [ColorSystem.businessChartBlue, ColorSystem.businessChartPink],
        begin: Alignment.bottomCenter,
        end: Alignment.topCenter,
      );

  @override
  Widget build(BuildContext context) {
    List<int> newestYearEmptyMonth = [];
    List<List<int>> newestYearDataPercent = [];
    var newestData = _convertNewestDataToPercent(
        newestYearDataPercent, newestYearEmptyMonth);
    newestYearDataPercent = newestData[0];
    newestYearEmptyMonth = newestData[1];

    List<FlSpot> previousYearDataPercent = [];
    if (widget.dataInPreviousYear != null) {
      previousYearDataPercent =
          _convertPreviousYearDataToPercent(previousYearDataPercent);
    }

    return Stack(
      children: [
        BarChart(mainNewData(newestYearDataPercent, newestYearEmptyMonth)),
        if (widget.dataInPreviousYear != null)
          LineChart(mainOldData(previousYearDataPercent)),
      ],
    );
  }

  LineChartData mainOldData(List<FlSpot> oldHistoryPurchase) {
    return LineChartData(
      gridData: FlGridData(show: false),
      titlesData: FlTitlesData(show: false),
      borderData: FlBorderData(show: false),
      minX: -0.5,
      maxX: 11.5,
      minY: -25,
      maxY: 100,
      lineTouchData: LineTouchData(enabled: false),
      lineBarsData: [
        LineChartBarData(
          spots: oldHistoryPurchase.map<FlSpot>((e) => e).toList(),
          isCurved: true,
          curveSmoothness: 0.3,
          barWidth: 2,
          dotData: FlDotData(
            // show: false,
            show: true, //Temp
            checkToShowDot: (spot, barData) =>
                spot.x == DateTime.now().month - 1 ? true : false,
            getDotPainter: (p0, p1, p2, p3) => FlDotCirclePainter(
              color: Colors.black,
              radius: 3,
              strokeWidth: 5,
              strokeColor: Colors.white,
            ),
          ),
          color: ColorSystem.lineColor,
          belowBarData: BarAreaData(
            show: true,
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color.fromARGB(172, 188, 185, 255),
                Color.fromARGB(0, 255, 255, 255)
              ],
            ),
          ),
        ),
      ],
    );
  }

  BarChartData mainNewData(
      List<List<int>> newHistoryPurchase, List<int> emptyMonths) {
    return BarChartData(
        borderData: FlBorderData(show: false),
        barGroups: newHistoryPurchase
            .map<BarChartGroupData>((e) => BarChartGroupData(
                  x: e.first,
                  barRods: [
                    BarChartRodData(
                        toY: double.parse(e.last.toString()),
                        // gradient: _barsGradient,
                        gradient: emptyMonths.contains(e.first)
                            // e.first < DateTime.now().month
                            ? LinearGradient(
                                colors: [
                                  ColorSystem.additionalGrey,
                                  ColorSystem.additionalGrey,
                                ],
                                begin: Alignment.bottomCenter,
                                end: Alignment.topCenter,
                              )
                            : _barsGradient)
                  ],
                ))
            .toList(),
        gridData: FlGridData(show: false),
        maxY: 75,
        minY: 0,
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(axisNameWidget: Text('')),
          topTitles: AxisTitles(axisNameWidget: Text('')),
          leftTitles: AxisTitles(axisNameWidget: Text('')),
          rightTitles: AxisTitles(axisNameWidget: Text('')),
        ),
        alignment: BarChartAlignment.center,
        barTouchData: BarTouchData(enabled: false),
        groupsSpace: 8);
  }

  dynamic _convertNewestDataToPercent(
      List<List<int>> newestYearDataPercent, List<int> newestYearEmptyMonth) {
    widget.dataInNewestYear.removeWhere((e) => e.orderDate == null);
    for (var history in widget.dataInNewestYear) {
      var position = DateTime.parse(history.orderDate!).month - 1;
      int data = double.parse(history.lineItems?.first.purchasedPrice ?? '0.0')
          .round();
      if (newData[position][1] != 0) {
        newData[position] = [position, newData[position][1] + data];
      } else {
        newData[position] = [position, data];
      }
      if (newData[position].last > maxData) {
        maxData = newData[position].last.toDouble();
      }
    }

    //Change number to percent
    newestYearDataPercent = newData.map<List<int>>((data) {
      if (data.last == 0) {
        newestYearEmptyMonth.add(data.first);
        return [data.first, 100];
      }
      return [data.first, ((data.last * 100) / maxData).round()];
    }).toList();
    return [newestYearDataPercent, newestYearEmptyMonth];
  }

  List<FlSpot> _convertPreviousYearDataToPercent(
      List<FlSpot> previousYearDataPercent) {
    widget.dataInPreviousYear!.removeWhere((e) => e.orderDate == null);
    for (var history in widget.dataInPreviousYear!) {
      var position = DateTime.parse(history.orderDate!).month - 1;
      double data =
          double.parse(history.lineItems?.first.purchasedPrice ?? '0.0');
      if (oldData[position].y != 0) {
        oldData[position] =
            FlSpot(position.toDouble(), oldData[position].y + data);
      } else {
        oldData[position] = FlSpot(position.toDouble(), data);
      }

      if (oldData[position].y > maxData) {
        maxData = oldData[position].y.toDouble();
      }
    }

    // Change number to percent
    previousYearDataPercent = oldData
        .map<FlSpot>((data) => FlSpot(data.x, ((data.y * 100) / maxData)))
        .toList();
    return previousYearDataPercent;
  }
}
