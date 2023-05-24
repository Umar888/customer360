import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:gc_customer_app/primitives/color_system.dart';

class MetricWidget extends StatelessWidget {
  final Color color;
  final String title;
  final Widget chart;
  final String earned;
  final String target;
  final String desctiption;
  MetricWidget(
      {Key? key,
      required this.title,
      required this.color,
      required this.chart,
      required this.earned,
      required this.target,
      required this.desctiption})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    double widgetWidth =
        kIsWeb ? 145 : (MediaQuery.of(context).size.width - 24) / 2.3;
    double widgetHeight = kIsWeb ? 215 : widgetWidth * 1.32;
    return Container(
      height: widgetHeight,
      width: widgetWidth,
      padding: EdgeInsets.only(
          left: widgetWidth / 13,
          right: widgetWidth / 13,
          top: widgetHeight / 8.75,
          bottom: widgetHeight / 11.67),
      decoration:
          BoxDecoration(borderRadius: BorderRadius.circular(16), color: color),
      margin: EdgeInsets.only(right: kIsWeb ? 18 : 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: ColorSystem.white),
          ),
          chart,
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              RichText(
                text: TextSpan(
                    text: earned,
                    style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w500,
                        color: ColorSystem.white),
                    children: [
                      TextSpan(
                        text: target,
                        style: TextStyle(
                            color: ColorSystem.white, fontSize: 14),
                      )
                    ]),
              ),
              SizedBox(height: 4),
              Text(
                desctiption,
                style: TextStyle(
                    color: ColorSystem.white.withOpacity(0.7), fontSize: 12),
              )
            ],
          ),
        ],
      ),
    );
  }
}
