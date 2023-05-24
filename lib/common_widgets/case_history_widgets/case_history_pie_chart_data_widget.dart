import 'package:flutter/material.dart';

class CaseHistoryPieChartDataWidget extends StatelessWidget {
  CaseHistoryPieChartDataWidget({
    Key? key,
    required this.heightOfScreen,
    required this.widthOfScreen,
    required this.numberOfOrders,
    required this.textOfItems,
    required this.colorOfVerticalBar,
  }) : super(key: key);

  final double heightOfScreen;
  final double widthOfScreen;
  final String numberOfOrders;
  final String textOfItems;
  final Color colorOfVerticalBar;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: 1,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                height: heightOfScreen * 0.03,
                width: 5,
                decoration:  BoxDecoration(
                  shape: BoxShape.rectangle,
                  color: colorOfVerticalBar,
                ),
              ),
              SizedBox(
                width: 5,
              ),
            ],
          ),
          SizedBox(
            width: widthOfScreen * 0.035,
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                numberOfOrders,
                style:
                    TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              SizedBox(
                height: 7,
              ),
              Text(
                textOfItems,
                style: TextStyle(fontSize: 12),
              )
            ],
          )
        ],
      ),
    );
  }
}