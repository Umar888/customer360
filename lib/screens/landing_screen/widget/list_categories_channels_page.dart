import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gc_customer_app/bloc/navigator_web_bloc/navigator_web_bloc.dart';
import 'package:gc_customer_app/primitives/color_system.dart';
import 'package:gc_customer_app/primitives/constants.dart';
import 'package:gc_customer_app/utils/double_extention.dart';

class ListCategoriesChannels extends StatefulWidget {
  final List<List<String>> values;
  final bool isCategories;
  ListCategoriesChannels({
    Key? key,
    required this.values,
    required this.isCategories,
  }) : super(key: key);

  @override
  State<ListCategoriesChannels> createState() => _ListCategoriesChannelsState();
}

class _ListCategoriesChannelsState extends State<ListCategoriesChannels> {
  StreamSubscription? navigatorListener;

  @override
  void initState() {
    if (kIsWeb) {
      context.read<NavigatorWebBloC>().selectedTabIndex = 0;
      navigatorListener =
          context.read<NavigatorWebBloC>().selectedTab.listen((event) {
        if (event != 0 && Navigator.canPop(context)) {
          Navigator.pop(context);
        }
      });
    }
    super.initState();
  }

  @override
  void dispose() {
    navigatorListener?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
            'Purchase History by ${widget.isCategories ? 'Category' : 'Channel'}',
            style: TextStyle(
                fontFamily: kRubik,
                fontWeight: FontWeight.w600,
                letterSpacing: 1.2,
                fontSize: 16)),
      ),
      body: _body(),
    );
  }

  Widget _item(String title, String value, Color color, double percent) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Expanded(
            child: Text(
              title,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                  color: Colors.black, fontFamily: kRubik, fontSize: 15),
            ),
          ),
          Expanded(
            child: Text("\$${double.parse(value).toStringAsFixed(2)}",
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 22, color: Colors.black, fontFamily: kRubik)),
          ),
          Expanded(
            child: Text("${percent.toStringAsFixed(2)}%",
                textAlign: TextAlign.end,
                style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                    fontFamily: kRubik)),
          ),
        ],
      ),
    );
  }

  Widget _body() {
    double sum = widget.values
        .map((e) => double.parse(e.last))
        .toList()
        .reduce((a, b) => a + b);
    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: 18),
      itemCount: widget.values.length,
      itemBuilder: (context, index) {
        double percent =
            ((double.parse(widget.values[index].last) / sum) * 100);
        return Column(
          children: [
            _item(
                widget.values[index].first,
                widget.values[index].last,
                index % 4 == 0
                    ? ColorSystem.chartPink
                    : index % 4 == 1
                        ? ColorSystem.chartPurple
                        : index % 4 == 2
                            ? ColorSystem.chartBlue
                            : ColorSystem.additionalGreen,
                percent),
            Divider(height: 1),
          ],
        );
      },
    );
  }
}
