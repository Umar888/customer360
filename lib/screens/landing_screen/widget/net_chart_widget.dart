import 'dart:math';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:gc_customer_app/models/landing_screen/customer_info_model.dart';
import 'package:gc_customer_app/primitives/color_system.dart';
import 'package:gc_customer_app/primitives/shadow_system.dart';
import 'package:gc_customer_app/screens/profile/purchase_metrics/horizontal_bar_chart.dart';
import 'package:gc_customer_app/utils/double_extention.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
// import 'package:syncfusion_flutter_charts/charts.dart';

class NetChartWidget extends StatefulWidget {
  final CustomerInfoModel customerInfoModel;
  NetChartWidget({Key? key, required this.customerInfoModel})
      : super(key: key);

  @override
  State<NetChartWidget> createState() => _NetChartWidgetState();
}

class _NetChartWidgetState extends State<NetChartWidget> {
  late List<_ChartData> data;

  @override
  void initState() {
    var userInfo = widget.customerInfoModel.records!.first;

    var value = [
      userInfo.netSalesAmount12MOC ?? 0,
      userInfo.lifetimeNetSalesAmountC ?? 0
    ];
    var maxValue = value.reduce(max);
    var valuePercent = value.map((v) => v * 100 / maxValue).toList();
    data = [
      _ChartData(
          'Net Sale Amount\n(0-12 months): \$${(userInfo.netSalesAmount12MOC ?? 0).toHumanRead()}',
          userInfo.netSalesAmount12MOC ?? 0,
          valuePercent[0].toString() == "NaN"?0:valuePercent[0],
          ColorSystem.pink),
      _ChartData(
          'Lifetime Net Sale\n\$${(userInfo.lifetimeNetSalesAmountC ?? 0).toHumanRead()}',
          userInfo.lifetimeNetSalesAmountC ?? 0,
          valuePercent[1].toString() == "NaN"?0:valuePercent[1],
          ColorSystem.chartPurple),
    ];
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var userInfo = widget.customerInfoModel.records!.first;

    return Container(
      height: 100,
      width: MediaQuery.of(context).size.width,
      decoration: BoxDecoration(
          color: ColorSystem.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: ShadowSystem.webWidgetShadow),
      child:  SfCartesianChart(
          primaryXAxis: CategoryAxis(
            borderWidth: 0,
            isVisible: true,
            isInversed: true,
            majorGridLines: MajorGridLines(width: 0),
            //Hide the axis line of x-axis
            axisLine: AxisLine(width: 0),
            maximumLabelWidth: 140,
            majorTickLines: MajorTickLines(size: 0),

            //Minor tick line customization.
            minorTickLines: MinorTickLines(size: 0),
          ),
          plotAreaBorderWidth: 0,
          borderWidth: 0,
          primaryYAxis: NumericAxis(
            minimum: 0,
            maximum: 100,
            isVisible: false,
          ),
          borderColor: Colors.transparent,
          series: <ChartSeries<_ChartData, String>>[
            BarSeries<_ChartData, String>(
                dataSource: data,
                xValueMapper: (_ChartData data, _) => data.name,
                yValueMapper: (_ChartData data, _) => data.percent,
                pointColorMapper: (datum, index) => datum.color,
                borderRadius: BorderRadius.circular(12))
          ]),
    );
  }
}

class _ChartData {
  _ChartData(this.name, this.value, this.percent, this.color);

  final String name;
  final double value;
  final double percent;
  final Color color;
}
