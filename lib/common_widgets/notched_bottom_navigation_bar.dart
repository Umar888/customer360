import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:gc_customer_app/models/inventory_search/cart_model.dart';

import '../models/common_models/records_class_model.dart';
import '../models/inventory_search/add_search_model.dart';
import '../primitives/constants.dart';
import '../primitives/size_system.dart';
import '../utils/bottom_navigation_bar_painter.dart';

class NotchedBottomNavigationBar extends StatefulWidget {
  final List<Widget> actions;
  final FloatingActionButton centerButton;
  List<ItemsOfCart> productsInCart;

  NotchedBottomNavigationBar({
    Key? key,
    required this.actions,
    required this.centerButton,
    required this.productsInCart,
  }) : super(key: key);

  @override
  State<NotchedBottomNavigationBar> createState() =>
      _NotchedBottomNavigationBarState();
}

class _NotchedBottomNavigationBarState
    extends State<NotchedBottomNavigationBar> {
  @override
  Widget build(BuildContext context) {
    widget.productsInCart =
        LinkedHashSet<ItemsOfCart>.from(widget.productsInCart).toList();

    return Container(
      width: MediaQuery.of(context).size.width,
      color: Colors.transparent,
      height: 80,
      child: Stack(
        children: [
          CustomPaint(
            size: Size(MediaQuery.of(context).size.width, 80),
            painter: BottomNavigationBarPainter(context:context),
            child: Center(
              heightFactor: 1,
              child: SizedBox(
                height: 80,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Flexible(
                        flex: 1,
                        child: Row(
                          children: [
                            widget.actions[1],
                            widget.actions[3],
                          ],
                        )),
//                    widget.actions[1],
                    Flexible(
                      flex: 1,
                      child: SizedBox(
                        width: MediaQuery.of(context).size.width * 0.2,
                      ),
                    ),
                    Flexible(
                        child: Padding(
                      padding: EdgeInsets.only(left: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          widget.actions[2],
                          widget.actions[0],
                        ],
                      ),
                    ))
//                    widget.actions[3],
                  ],
                ),
              ),
            ),
          ),
          Center(
            heightFactor: 0.3,
            child: Stack(
              children: [
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.35,
                  height: MediaQuery.of(context).size.width * 0.35,
                  child: FittedBox(
                    child: Padding(
                      padding: EdgeInsets.all(5.0),
                      child: widget.centerButton,
                    ),
                  ),
                ),
                widget.productsInCart.isNotEmpty &&
                        widget.productsInCart
                            .where((element) =>
                                double.parse(element.itemQuantity) > 0)
                            .isNotEmpty
                    ? Positioned(
                        right: 0,
                        top: 0,
                        child: Card(
                          elevation: 2,
                          color: Colors.red,
                          shadowColor: Colors.red.shade100,

//                    shape: CircleBorder(),
                          child: Padding(
                            padding: EdgeInsets.all(5.0),
                            child: Text(
                              widget.productsInCart
                                      .where((element) =>
                                          double.parse(element.itemQuantity) >
                                          0)
                                      .length
                                      .toString() +
                                  r" : $" +
                                  widget.productsInCart.fold(
                                      "0",
                                      (a, b) => (double.parse(a) +
                                              (double.parse(b.itemQuantity) *
                                                  (double.parse(b.itemPrice)+double.parse(b.itemProCoverage))))
                                          .toStringAsFixed(2)),
                              style: TextStyle(
                                  fontSize: SizeSystem.size12,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                  fontFamily: kRubik),
                            ),
                          ),
                        ),
                      )
                    : SizedBox(
                        width: 0,
                        height: 0,
                      ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
