import 'package:flutter/material.dart';
import 'dart:math' as math;

import 'package:gc_customer_app/primitives/color_system.dart';

class HorizontalBarChart extends StatelessWidget {
  final Size chartSize;
  final List<double> orderData;
  HorizontalBarChart(
      {Key? key, required this.chartSize, required this.orderData})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    var maxValue = orderData.reduce(math.max);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: orderData.map<Widget>((data) {
        var barHeight = ((data / maxValue) * chartSize.height) - 2;
        if (barHeight < 0) barHeight = 0;
        return Container(
          width: (chartSize.width / orderData.length) / 2,
          height: barHeight,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(3),
            color: ColorSystem.orderBarChartColor,
          ),
        );
      }).toList(),
    );
  }
}
