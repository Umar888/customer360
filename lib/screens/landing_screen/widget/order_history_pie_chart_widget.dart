import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gc_customer_app/bloc/profile_screen_bloc/purchase_metrics_bloc/purchase_metrics_bloc.dart';
import 'package:gc_customer_app/primitives/color_system.dart';
import 'package:gc_customer_app/primitives/constants.dart';
import 'package:gc_customer_app/primitives/shadow_system.dart';
import 'package:gc_customer_app/screens/landing_screen/widget/list_categories_channels_page.dart';
import 'package:gc_customer_app/utils/common_widgets.dart';
import 'package:gc_customer_app/utils/double_extention.dart';

class OrderHistoryPieChartWidget extends StatefulWidget {
  final Function onTapChart;
  final bool isFromLandingPage;
  const OrderHistoryPieChartWidget(
      {Key? key, required this.onTapChart, this.isFromLandingPage = true})
      : super(key: key);

  @override
  State<OrderHistoryPieChartWidget> createState() =>
      _OrderHistoryPieChartWidgetState();
}

class _OrderHistoryPieChartWidgetState
    extends State<OrderHistoryPieChartWidget> {
  SnackBar snackBar(String message) {
    return SnackBar(
        elevation: 4.0,
        backgroundColor: ColorSystem.lavender3,
        behavior: SnackBarBehavior.floating,
        margin:
            EdgeInsets.only(bottom: MediaQuery.of(context).size.height * 0.05),
        content: Text(
          message,
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ));
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PurchaseMetricsBloc, PurchaseMetricsState>(
        builder: (context, state) {
      if (state is PurchaseMetricsSuccess) {
        if (state.purchaseMetricsModel?.purchaseCategory == null)
          return SizedBox.shrink();
        Map<String, String> mapValues = {};
        state.purchaseMetricsModel?.purchaseCategory?.forEach((key, value) {
          mapValues.addAll({key.toString(): value.toString()});
        });
        List<List<String>> listValue = [];
        if(mapValues.isNotEmpty) {
          mapValues.forEach((key, value) {
            listValue.add([key, value]);
          });
          listValue.sort(
                  (a, b) =>
                  double.parse(b.last).compareTo(double.parse(a.last)));
        }
        bool isMoreThan4 = false;
        if (mapValues.length > 4) {
          isMoreThan4 = true;
        }
        return listValue.isNotEmpty?Container(
          margin: EdgeInsets.only(right: 8),
          padding: widget.isFromLandingPage
              ? EdgeInsets.symmetric(vertical: 12)
              : null,
          decoration: widget.isFromLandingPage
              ? BoxDecoration(
                  color: ColorSystem.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: ShadowSystem.webWidgetShadow)
              : null,
          child:  Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (widget.isFromLandingPage)
                Padding(
                  padding: const EdgeInsets.only(left: 12, bottom: 8),
                  child: Text(
                    'Purchase History by Category',
                    style: TextStyle(
                        color: ColorSystem.blueGrey,
                        fontFamily: kRubik,
                        fontWeight: FontWeight.w500),
                  ),
                ),
             Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  InkWell(
                    onTap: () => widget.onTapChart(),
                    child: Container(
                      height: 120,
                      width: 120,
                      alignment: Alignment.centerLeft,
                      child: PieChart(
                        PieChartData(
                          sectionsSpace: 0,
                          pieTouchData: PieTouchData(enabled: false),
                          sections: showingSections(
                            accessoriesValue:
                                mapValues.entries.map((e) => e.value).toList(),
                          ),
                          centerSpaceColor: ColorSystem.purple.withOpacity(0.1),
                          centerSpaceRadius: 24,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 8),
                  listValue.isNotEmpty?
                  Expanded(
                    child: SizedBox(
                      height: 130,
                      child: LayoutBuilder(builder: (context, constraints) {
                        return Wrap(
                          runSpacing: 8,
                          crossAxisAlignment: WrapCrossAlignment.start,
                          children: [
                            _item(listValue[0][0], listValue[0][1],
                                ColorSystem.chartPink, constraints.maxWidth),
                            listValue.length > 1
                                ? _item(
                                    listValue[1][0],
                                    listValue[1][1],
                                    ColorSystem.chartPurple,
                                    constraints.maxWidth)
                                : SizedBox.shrink(),
                            listValue.length > 2
                                ? _item(listValue[2][0], listValue[2][1],
                                    ColorSystem.chartBlue, constraints.maxWidth)
                                : SizedBox.shrink(),
                            listValue.length > 3
                                ? Stack(
                                    children: [
                                      _item(
                                          listValue[3][0],
                                          listValue[3][1],
                                          ColorSystem.additionalGreen,
                                          constraints.maxWidth),
                                      if (isMoreThan4)
                                        InkWell(
                                          onTap: () {
                                            Navigator.push(
                                                context,
                                                kIsWeb
                                                    ? webPageRoute(
                                                        ListCategoriesChannels(
                                                            values: listValue,
                                                            isCategories:
                                                                false))
                                                    : MaterialPageRoute(
                                                        builder: (context) =>
                                                            ListCategoriesChannels(
                                                                values:
                                                                    listValue,
                                                                isCategories:
                                                                    true),
                                                      ));
                                          },
                                          child: Container(
                                            height: 60,
                                            width: constraints.maxWidth / 2,
                                            color: Colors.grey.withOpacity(0.6),
                                            alignment: Alignment.center,
                                            child: Text(
                                              '+${mapValues.length - 3}',
                                              style: TextStyle(
                                                  fontSize: 26,
                                                  fontWeight: FontWeight.w500,
                                                  color: Colors.white,
                                                  fontFamily: kRubik),
                                            ),
                                          ),
                                        )
                                    ],
                                  )
                                : SizedBox.shrink()
                          ],
                        );
                      }),
                    ),
                  ):SizedBox.shrink()
                ],
              ),
            ],
          ),
        ):SizedBox.shrink();
      }
      if (state is PurchaseMetricsProgress) {
        return Center(child: CircularProgressIndicator());
      }
      return SizedBox.shrink();
    });
  }

  List<PieChartSectionData> showingSections(
      {required List<String> accessoriesValue}) {
    double sum = 0;
    if(accessoriesValue.isNotEmpty){
    sum = accessoriesValue
        .map((e) => double.parse(e))
        .toList()
        .reduce((a, b) => a + b);
    accessoriesValue.sort(
      (a, b) => double.parse(b).compareTo(double.parse(a)),
    );
    }
    return List.generate(accessoriesValue.length, (i) {
      const fontSize = 8.0;
      const radius = 26.0;
      double percent = ((double.parse(accessoriesValue[i]) / sum) * 100);
      List<Color> colors = [
        ColorSystem.chartPink,
        ColorSystem.chartPurple,
        Color.fromARGB(255, 159, 150, 248),
        Colors.blue,
        ColorSystem.chartBlue,
        Color.fromARGB(255, 38, 188, 63),
        Color.fromARGB(255, 113, 255, 137),
        Color(0xFF6B7A8D),
        Color(0xFF7D9983),
        Color(0xFFADA169),
        Color.fromARGB(255, 224, 56, 213),
        Color.fromARGB(255, 224, 120, 217),
        Color.fromARGB(255, 226, 182, 39),
        Color.fromARGB(255, 221, 193, 100),
      ];
      return PieChartSectionData(
        color: colors[i % 13],
        value: double.parse(percent.toStringAsFixed(2)),
        radius: radius,
        title: percent < 3 ? '' : percent.toStringAsFixed(2) + '%',
        titleStyle: TextStyle(
          fontSize: fontSize,
          color: ColorSystem.black,
        ),
      );
    });
  }

  Widget _item(String title, String value, Color color, double maxWidth) {
    return SizedBox(
      width: maxWidth / 2,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            height: 25,
            width: 5,
            decoration: BoxDecoration(
                color: color, borderRadius: BorderRadius.circular(20)),
          ),
          SizedBox(width: 4),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      r"$",
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: color,
                          fontFamily: kRubik),
                    ),
                    Text("${double.parse(value).toSmallerHumanRead()}",
                        style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: color,
                            fontFamily: kRubik))
                  ],
                ),
                Text(
                  title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style:
                      TextStyle(color: color, fontFamily: kRubik, fontSize: 13),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
