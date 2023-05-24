import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gc_customer_app/bloc/profile_screen_bloc/purchase_metrics_bloc/purchase_metrics_bloc.dart';
import 'package:gc_customer_app/constants/text_strings.dart';
import 'package:gc_customer_app/models/purchase_metrics_model.dart';
import 'package:gc_customer_app/primitives/color_system.dart';
import 'package:gc_customer_app/primitives/constants.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'dart:math' as math;

import 'horizontal_bar_chart.dart';
import 'metric_widget.dart';

class PurchaseMetrics extends StatefulWidget {
  PurchaseMetrics({super.key});

  @override
  State<PurchaseMetrics> createState() => _PurchaseMetricsState();
}

class _PurchaseMetricsState extends State<PurchaseMetrics> {
  late PurchaseMetricsBloc purchaseMetricsBloc;

  @override
  void initState() {
    super.initState();
    purchaseMetricsBloc = context.read<PurchaseMetricsBloc>();
    purchaseMetricsBloc.add(LoadMetricsData());
  }

  @override
  Widget build(BuildContext context) {
    var textTheme = Theme.of(context).textTheme;
    double metricWidgetWidth =
        (MediaQuery.of(context).size.width - 24) / (kIsWeb ? 8 : 2.5);
    double metricWidgetHeight = metricWidgetWidth * 1.53;
    var orderFrequencyData = [
      math.Random().nextDouble() * 256,
      math.Random().nextDouble() * 256,
      math.Random().nextDouble() * 256,
      math.Random().nextDouble() * 256,
      math.Random().nextDouble() * 256,
      math.Random().nextDouble() * 256,
      math.Random().nextDouble() * 256,
      math.Random().nextDouble() * 256,
      math.Random().nextDouble() * 256,
      math.Random().nextDouble() * 256,
    ];
    return BlocBuilder<PurchaseMetricsBloc, PurchaseMetricsState>(
        builder: (context, state) {
      if (state is PurchaseMetricsSuccess) {
        if (state.purchaseMetricsModel == null) return SizedBox.shrink();
        var purchaseMetrics = state.purchaseMetricsModel!;
        double sumCategory = 0;
        var purchaseCategories = purchaseMetrics.purchaseCategory;
        purchaseMetrics.purchaseCategory?.forEach(
            (key, value) => sumCategory += double.parse(value ?? '0.0'));
        if (purchaseCategories != null) {
          purchaseCategories = Map.fromEntries(
              purchaseCategories.entries.toList()
                ..sort((e1, e2) => double.parse(e2.value ?? '0.0') >
                        double.parse(e1.value ?? '0.0')
                    ? 1
                    : 0));
        }
        int index = 0;
        return Container(
          margin: EdgeInsets.symmetric(vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                purchaseMetricstxt,
                style:
                    textTheme.headline2?.copyWith(fontWeight: FontWeight.w500),
              ),
              SizedBox(height: 16),
              SizedBox(
                height: kIsWeb ? 200 : metricWidgetHeight,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    _channel(purchaseMetrics.purchaseChannel,
                        Size(metricWidgetWidth, metricWidgetHeight / 2.1)),
                    // MetricWidget(
                    //   chart: HorizontalBarChart(
                    //       chartSize:
                    //           Size(metricWidgetWidth, metricWidgetWidth / 2.6),
                    //       orderData: purchaseMetrics.historyPurchase
                    //               ?.map<double>((e) => double.parse(
                    //                   e.lineItems?.first.purchasedPrice ??
                    //                       '0.0'))
                    //               .toList() ??
                    //           []),
                    //   color: ColorSystem.pink,
                    //   title: 'ORDER\nFREQUENCY',
                    //   earned: '\$300 ',
                    //   target: '/Order',
                    //   desctiption: 'Weekly 1 Order',
                    // ),
                    ...purchaseCategories?.entries.map<Widget>((category) {
                          index++;
                          return _categoryChart(
                              category,
                              sumCategory,
                              Size(metricWidgetWidth, metricWidgetHeight / 2.1),
                              ColorSystem.lavender3
                                  .withOpacity(index % 2 == 0 ? 0.6 : 1));
                        }).toList() ??
                        [],
                  ],
                ),
              )
            ],
          ),
        );
      }
      if (state is PurchaseMetricsProgress) {
        return Center(child: CircularProgressIndicator());
      }
      return SizedBox(height: 20);
    });
  }

  Widget _categoryChart(MapEntry<String, String?> category,
      double sumCategories, Size size, Color backgroundColor) {
    String categoryData = category.value ?? '0.0';
    if (sumCategories == 0) sumCategories = 1;

    double categoryPercent = (double.parse(categoryData) * 100) / sumCategories;

    return MetricWidget(
      chart: Transform.rotate(
        angle: -20 * (math.pi / 180),
        child: SizedBox(
          height: kIsWeb ? 80 : size.height,
          width: kIsWeb ? 80 : size.width,
          child: SfCircularChart(
            series: <CircularSeries<_ChartData, String>>[
              DoughnutSeries<_ChartData, String>(
                dataSource: [
                  _ChartData(0, categoryPercent),
                  _ChartData(0, 100 - categoryPercent),
                ],
                xValueMapper: (_ChartData data, _) => data.x.toString(),
                yValueMapper: (_ChartData data, _) => data.y,
              ),
            ],
            palette: <Color>[
              ColorSystem.skyBlue,
              ColorSystem.additionalPurple,
            ],
            margin: EdgeInsets.zero,
          ),
        ),
      ),
      color: backgroundColor,
      title: category.key.toUpperCase(),
      earned: '${categoryPercent.toStringAsFixed(1)}% ',
      target: '',
      desctiption: '\$${double.parse(categoryData).toStringAsFixed(1)} Spent',
    );
  }

  Widget _channel(Map<String, String?>? channel, Size size) {
    String retailData = channel?[retail] ?? '0.0';
    String otherChannelName = '';
    double sumChannel = 0;
    channel
        ?.forEach((key, value) => sumChannel += double.parse(value ?? '0.0'));
    if (sumChannel == 0) sumChannel = 1;

    double retailPercent = (double.parse(retailData) * 100) / sumChannel;

    if ((channel?.length ?? 0) > 1) {
      otherChannelName =
          channel!.keys.firstWhere((key) => key.toLowerCase() != 'retail');
    }
    return MetricWidget(
      color: Color(0xFF4C5980),
      title: 'CHANNEL',
      earned: '\$${retailPercent.toStringAsFixed(1)}',
      target: ' Retail',
      desctiption:
          '\$${(100 - retailPercent).toStringAsFixed(1)} $otherChannelName',
      chart: Transform.rotate(
        angle: -20 * (math.pi / 180),
        child: SizedBox(
          height: kIsWeb ? 80 : size.height,
          width: kIsWeb ? 80 : size.width,
          child: SfCircularChart(
            series: <CircularSeries<_ChartData, String>>[
              DoughnutSeries<_ChartData, String>(
                dataSource: [
                  _ChartData(0, retailPercent),
                  _ChartData(0, 100 - retailPercent),
                ],
                xValueMapper: (_ChartData data, _) => data.x.toString(),
                yValueMapper: (_ChartData data, _) => data.y,
              ),
            ],
            palette: <Color>[
              ColorSystem.skyBlue,
              ColorSystem.pink,
            ],
            margin: EdgeInsets.zero,
          ),
        ),
      ),
    );
  }
}

class _ChartData {
  _ChartData(this.x, this.y);

  final double x;
  final double y;
}
