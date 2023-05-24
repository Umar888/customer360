import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gc_customer_app/bloc/order_history_bloc/order_history_bloc.dart';
import 'package:gc_customer_app/bloc/profile_screen_bloc/purchase_metrics_bloc/purchase_metrics_bloc.dart';
import 'package:gc_customer_app/models/order_history/order_history_model.dart';
import 'package:gc_customer_app/primitives/color_system.dart';
import 'package:gc_customer_app/primitives/shadow_system.dart';
import 'package:gc_customer_app/utils/double_extention.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class OrderHistoryByYearChartWidget extends StatefulWidget {
  OrderHistoryByYearChartWidget({super.key});

  @override
  State<OrderHistoryByYearChartWidget> createState() =>
      _OrderHistoryByYearChartWidgetState();
}

class _OrderHistoryByYearChartWidgetState
    extends State<OrderHistoryByYearChartWidget> {
  late OrderHistoryBloc orderHistoryBloc;
  List<ChartSampleData> chartData = <ChartSampleData>[];
  final StreamController<String?> selectedYearController =
      StreamController<String?>.broadcast();

  @override
  void initState() {
    super.initState();
    orderHistoryBloc = context.read<OrderHistoryBloc>();
    orderHistoryBloc.add(FetchOrderHistory());
  }

  @override
  Widget build(BuildContext context) {
    chartData.clear();
    return Container(
      margin: EdgeInsets.only(right: 12, top: 12, bottom: 0),
      // padding: EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
          color: ColorSystem.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: ShadowSystem.webWidgetShadow),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          BlocBuilder<PurchaseMetricsBloc, PurchaseMetricsState>(
            builder: (context, state) {
              if (state is PurchaseMetricsProgress) {
                return Center(child: CircularProgressIndicator());
              }
              if (state is PurchaseMetricsSuccess &&
                  (state.purchaseMetricsModel?.historyPurchase ?? [])
                      .isNotEmpty) {
                var histories = state.purchaseMetricsModel!.historyPurchase!;
                histories.sort((a, b) => (a.orderDate != null &&
                        DateTime.parse(a.orderDate?.toString() ??
                                DateTime(1900).toString())
                            .isBefore(DateTime.parse(b.orderDate?.toString() ??
                                DateTime(1900).toString()))
                    ? 1
                    : 0));
                if (histories.first.orderDate == null) {
                  return SizedBox.shrink();
                }

                List<String> years = [];
                var his = histories
                    .where((h) => !years.contains(
                        h.orderDate?.toString().split('-').first ?? ''))
                    .toSet();
                var yearsTemp = his
                    .map((e) => e.orderDate?.toString().split('-').first ?? '')
                    .toList()
                    .toSet();
                years = yearsTemp.toList();
                years.sort((a, b) => a.compareTo(b));

                List<double> dataInEachYear = [];
                years.forEach((year) {
                  var historyInYear = histories
                      .where((h) =>
                          year ==
                          (h.orderDate?.toString().split('-').first ?? ''))
                      .toList();
                  double sumInYear = 0;
                  historyInYear.forEach((element) {
                    element.lineItems?.forEach((item) {
                      sumInYear += double.parse(item.purchasedPrice ?? '0.0');
                    });
                  });
                  dataInEachYear.add(sumInYear);
                });

                double maxValue = dataInEachYear.reduce(max);

                List<double> percentInEachYear =
                    dataInEachYear.map((e) => (e / maxValue) * 100).toList();

                for (var i = 0; i < percentInEachYear.length; i++) {
                  chartData.add(ChartSampleData(
                      years[i],
                      dataInEachYear[i].toString(),
                      percentInEachYear[i].toString()));
                }
                return StreamBuilder<String?>(
                    stream: selectedYearController.stream,
                    builder: (context, snapshot) {
                      String selectedYear = snapshot.data ?? '';
                      if (selectedYear.isEmpty) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: EdgeInsets.only(left: 8, top: 8),
                              child: Text(
                                'Amount',
                                style: TextStyle(
                                    fontSize: 12,
                                    color: Theme.of(context).primaryColor),
                              ),
                            ),
                            Container(
                              height: 140,
                              width: MediaQuery.of(context).size.width,
                              child: SfCartesianChart(
                                isTransposed: true,
                                enableAxisAnimation: true,
                                plotAreaBorderWidth: 0,
                                borderWidth: 0,
                                plotAreaBackgroundColor: Colors.transparent,
                                borderColor: Colors.transparent,
                                primaryXAxis: CategoryAxis(
                                  isVisible: true,
                                  majorGridLines: MajorGridLines(width: 0),
                                  axisLine: AxisLine(width: 0),
                                ),
                                primaryYAxis: NumericAxis(
                                  minimum: 0,
                                  maximum: maxValue,
                                  axisLabelFormatter: (axisLabelRenderArgs) {
                                    return ChartAxisLabel(
                                        '\$${axisLabelRenderArgs.value.toDouble().toSmallerHumanRead()}',
                                        TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.w300,
                                            color: Theme.of(context)
                                                .primaryColor));
                                  },
                                ),
                                onChartTouchInteractionUp: (tapArgs) {
                                  var maxWidth =
                                      MediaQuery.of(context).size.width - 60;
                                  var chartValueWidth =
                                      maxWidth - 45; //From 45 to maxWidth
                                  var columnWidth =
                                      chartValueWidth / (years.length * 2);
                                  var spaceDoNotTouchData =
                                      (45 + columnWidth / 2);
                                  if (tapArgs.position.dx >
                                      spaceDoNotTouchData) {
                                    var selectedColumnIndex =
                                        ((tapArgs.position.dx -
                                                    spaceDoNotTouchData) /
                                                columnWidth)
                                            .floor();
                                    if (selectedColumnIndex % 2 == 0) {
                                      selectedColumnIndex =
                                          (selectedColumnIndex / 2).floor();
                                      selectedYearController
                                          .add(years[selectedColumnIndex]);
                                    }
                                  }
                                },
                                series: <BarSeries<ChartSampleData, String>>[
                                  BarSeries<ChartSampleData, String>(
                                    // Binding the chartData to the dataSource of the bar series.
                                    dataSource: chartData,
                                    xValueMapper: (ChartSampleData sales, _) =>
                                        sales.year,
                                    yValueMapper: (ChartSampleData sales, _) =>
                                        double.tryParse(sales.value),
                                    dataLabelMapper: (datum, index) =>
                                        '\$${datum.value}',
                                    // trendlines: chartData.length > 1
                                    //     ? chartData
                                    //         .map((data) => Trendline(
                                    //               color: ColorSystem.lavender,
                                    //               width: 1,
                                    //             ))
                                    //         .toList()
                                    //     : null,
                                    width: 1,
                                    color: ColorSystem.black,
                                    gradient: LinearGradient(
                                      colors: [
                                        ColorSystem.businessChartBlue,
                                        ColorSystem.businessChartPink
                                      ],
                                      begin: Alignment.bottomCenter,
                                      end: Alignment.topCenter,
                                    ),
                                    spacing: 0.5,
                                    trackPadding: 0,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        );
                      } else {
                        var historiesInYear = histories
                            .where((h) =>
                                selectedYear ==
                                (h.orderDate?.toString().split('-').first ??
                                    ''))
                            .toList();

                        List<double> dataEachMonth = [];
                        List<int> months = [];
                        for (var i = 0; i < 12; i++) {
                          months.add(i + 1);
                          var ordersInMonth = historiesInYear.where((h) {
                            return int.parse(
                                    h.orderDate?.toString().split('-')[1] ??
                                        '0') ==
                                (i + 1);
                          });
                          double sumInMonth = 0.0;
                          ordersInMonth.forEach((oim) {
                            oim.lineItems?.forEach((item) {
                              sumInMonth +=
                                  double.parse(item.purchasedPrice ?? '0.0');
                            });
                          });
                          dataEachMonth.add(sumInMonth);
                        }

                        double maxValueMonth = dataEachMonth.reduce(max);

                        List<double> percentInEachMonth = dataEachMonth
                            .map((e) => (e / maxValueMonth) * 100)
                            .toList();
                        List<ChartSampleData> chartDataMonth =
                            <ChartSampleData>[];

                        for (var i = 0; i < months.length; i++) {
                          chartDataMonth.add(ChartSampleData(
                              months[i].toString(),
                              dataEachMonth[i].toString(),
                              percentInEachMonth[i].toString()));
                        }

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Padding(
                                  padding: EdgeInsets.only(
                                    left: 8,
                                  ),
                                  child: Text(
                                    'Amount',
                                    style: TextStyle(
                                        fontSize: 12,
                                        color: Theme.of(context).primaryColor),
                                  ),
                                ),
                                TextButton(
                                    onPressed: () {
                                      selectedYearController.add(null);
                                    },
                                    child: Text('Back')),
                              ],
                            ),
                            Container(
                                height: 140,
                                width: MediaQuery.of(context).size.width,
                                child: SfCartesianChart(
                                  isTransposed: true,
                                  enableAxisAnimation: true,
                                  plotAreaBorderWidth: 0,
                                  borderWidth: 0,
                                  plotAreaBackgroundColor: Colors.transparent,
                                  borderColor: Colors.transparent,
                                  primaryXAxis: CategoryAxis(
                                    isVisible: true,
                                    interval: 2,
                                    majorGridLines: MajorGridLines(width: 0),
                                    axisLine: AxisLine(width: 0),
                                  ),
                                  primaryYAxis: NumericAxis(
                                    minimum: 0,
                                    maximum: maxValueMonth,
                                    axisLabelFormatter: (axisLabelRenderArgs) =>
                                        ChartAxisLabel(
                                      '\$${axisLabelRenderArgs.value.toDouble().toSmallerHumanRead()}',
                                      TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w300,
                                          color:
                                              Theme.of(context).primaryColor),
                                    ),
                                  ),
                                  series: <BarSeries<ChartSampleData, String>>[
                                    BarSeries<ChartSampleData, String>(
                                      dataSource: chartDataMonth,
                                      xValueMapper:
                                          (ChartSampleData sales, _) =>
                                              convertMonthIndexToName(
                                                  int.parse(sales.year)),
                                      yValueMapper:
                                          (ChartSampleData sales, _) =>
                                              double.parse(sales.value),
                                      // trendlines: chartDataMonth
                                      //     .map((data) => Trendline(
                                      //           color: ColorSystem.lavender,
                                      //           width: 1,
                                      //         ))
                                      //     .toList(),
                                      width: 1,
                                      color: ColorSystem.black,
                                      gradient: LinearGradient(
                                        colors: [
                                          ColorSystem.businessChartBlue,
                                          ColorSystem.businessChartPink
                                        ],
                                        begin: Alignment.bottomCenter,
                                        end: Alignment.topCenter,
                                      ),
                                      spacing: 0.5,
                                      trackPadding: 0,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ],
                                )),
                          ],
                        );
                      }
                    });
              }
              return SizedBox.shrink();
            },
          ),
        ],
      ),
    );
  }

  String convertMonthIndexToName(int index) {
    var months = [
      "Jan",
      "Feb",
      "Mar",
      "Apr",
      "May",
      "Jun",
      "Jul",
      "Aug",
      "Sep",
      "Oct",
      "Nov",
      "Dec"
    ];
    return months[index - 1];
  }
}

class ChartSampleData {
  final String year;
  final String value;
  final String percent;

  ChartSampleData(this.year, this.value, this.percent);

  String toString() {
    return "${this.year} : ${this.value} - ${this.percent}";
  }
}
