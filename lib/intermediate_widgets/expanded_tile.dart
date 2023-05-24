import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_debounce/easy_debounce.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart' as intl;
import 'package:provider/provider.dart';

import '../primitives/color_system.dart';
import '../primitives/constants.dart';
import '../primitives/icon_system.dart';
import '../primitives/size_system.dart';


class ExpandedTile extends StatefulWidget {
  bool isExpanded;
  List<String> contents;
  String title;
  String selectedDiscount;
  String selectedAvailibilty;
  String selectedSort;
  final Function(String) onTap;

  ExpandedTile({Key? key, required this.selectedDiscount, required this.selectedAvailibilty, required this.selectedSort, required this.onTap, required this.isExpanded, required this.title, required this.contents}) : super(key: key);

  @override
  State<ExpandedTile> createState() => _ExpandedTileState();
}

class _ExpandedTileState extends State<ExpandedTile>  with TickerProviderStateMixin{

  late AnimationController _controller;
  late Animation<double> _iconTurns;



  static final Animatable<double> _easeOutTween = CurveTween(curve: Curves.easeOut);
  static final Animatable<double> _easeInTween = CurveTween(curve: Curves.easeIn);
  static final Animatable<double> _halfTween = Tween<double>(begin: 0.0, end: 0.5);

  String dateFormatter(String? orderDate) {
    if (orderDate == null) {
      return '--';
    } else {
      return intl.DateFormat('MMM dd, yyyy').format(DateTime.parse(orderDate));
    }
  }

  @override
  initState() {
    super.initState();
    _controller = AnimationController(duration: Duration(milliseconds: 200), vsync: this);
    _iconTurns = _controller.drive(_halfTween.chain(_easeInTween));
  }





  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.symmetric(vertical: 2,horizontal: 0),
      title: InkWell(
        onTap: (){
          setState(() {
            widget.isExpanded = !widget.isExpanded;
            if (widget.isExpanded) {
              _controller.forward();
            }
            else {
              _controller.reverse();
            }
          });
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                RotationTransition(
                  turns: _iconTurns,
                  child: Icon(Icons.expand_more),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 25.0),
                  child: Text(widget.title, style: TextStyle(
                    color: Theme.of(context).primaryColor,
                    fontWeight: FontWeight.w500,
                    fontFamily: kRubik,
                    fontSize: SizeSystem.size18,
                  ),),
                ),
              ],
            ),
            SizedBox(height: 10,),
            Divider(color: ColorSystem.greyDark,)
          ],
        ),
      ),
      subtitle: widget.isExpanded?Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: widget.contents.map((e){
          return InkWell(
           splashColor: Colors.transparent,
           onTap: (){
//             setState((){
               widget.onTap(e);
//             });
           },
            child: Padding(
              padding: EdgeInsets.only(left: 60.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 10,),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(e, style:  TextStyle(
                        color: widget.title == "Offers" && widget.selectedDiscount == e?
                         Colors.red:
                        widget.title == "Available" && widget.selectedAvailibilty == e?
                         Colors.red:
                        widget.title == "Price" && widget.selectedSort == e?
                        Colors.red:Theme.of(context).primaryColor,
                        fontWeight: FontWeight.w500,
                        fontFamily: kRubik,
                        fontSize: SizeSystem.size18,
                      ),),
                      widget.title == "Offers" && widget.selectedDiscount == e?
                      SvgPicture.asset(IconSystem.in_stock_tick,color: Colors.red,):
                      widget.title == "Available" && widget.selectedAvailibilty == e?
                      SvgPicture.asset(IconSystem.in_stock_tick,color: Colors.red,):
                      widget.title == "Price" && widget.selectedSort == e?
                      SvgPicture.asset(IconSystem.in_stock_tick,color: Colors.red,):
                      Container()

                    ],
                  ),

                  SizedBox(height: 10,),
                  Divider(color: ColorSystem.greyDark,)
                ],
              ),
            ),
          );

        }).toList(),
      ):null,

    );
  }
}

