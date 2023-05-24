import 'package:flutter/material.dart';

class CustomTabBarExtendedDigital extends StatefulWidget {
  final Widget? child;
  final Function(int)? onTap;
  final EdgeInsets? margin;
  final EdgeInsets? padding;
  final double? height;
  final double? width;
  final double containerBorderRadius;
  final double tabBorderRadius;
  final Color? containerColor;
  final Color? tabColor;
  final Color? labelColor;
  final Color? unSelectLabelColor;
  final TabController? tabController;
  final List<BoxShadow>? boxShadow;
  final List<String>? tabs;
  final TextStyle? labelTextStyle;

  CustomTabBarExtendedDigital({
    this.margin,
    this.onTap,
    this.padding,
    this.height,
    this.width,
    this.containerColor,
    this.child,
    this.tabController,
    this.containerBorderRadius = 0,
    this.tabBorderRadius = 0,
    this.boxShadow,
    this.tabs,
    this.tabColor,
    this.labelColor,
    this.unSelectLabelColor,
    this.labelTextStyle,
  });

  @override
  State<CustomTabBarExtendedDigital> createState() =>
      _CustomTabBarExtendedDigitalState();
}

class _CustomTabBarExtendedDigitalState
    extends State<CustomTabBarExtendedDigital>
    with SingleTickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Row(
          children: [
            Container(
              padding: widget.padding,
              margin: widget.margin,
              child: Container(
                height: widget.height,
                width: 30,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                      colors: [Colors.grey.shade400, Colors.white],
                      stops: [0.3, 0.65]),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(widget.containerBorderRadius),
                    bottomLeft: Radius.circular(widget.containerBorderRadius),
                  ),
                ),
              ),
            ),
            Expanded(
              child: Container(
                padding: widget.padding,
                margin: widget.margin,
                child: Container(
                  height: widget.height,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    // borderRadius: BorderRadius.circular(
                    //   widget.containerBorderRadius,
                    // ),
                  ),
                ),
              ),
            ),
            Container(
              padding: widget.padding,
              margin: widget.margin,
              child: Container(
                height: widget.height,
                width: 30,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                      colors: [Colors.white, Colors.grey.shade400],
                      stops: [0.3, 0.7]),
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(widget.containerBorderRadius),
                    bottomRight: Radius.circular(widget.containerBorderRadius),
                  ),
                ),
              ),
            ),
          ],
        ),
        Container(
          padding: widget.padding,
          margin: widget.margin,
          child: Container(
            height: widget.height,
            decoration: BoxDecoration(
              color: widget.containerColor,
              borderRadius: BorderRadius.circular(widget.containerBorderRadius),
            ),
            child: TabBar(
                isScrollable: true,
                onTap: widget.onTap,
                padding: EdgeInsets.symmetric(horizontal: 0, vertical: 8),
                controller: widget.tabController,
                physics: NeverScrollableScrollPhysics(),
                // give the indicator a decoration (color and border radius)
                indicator: BoxDecoration(
                  borderRadius: BorderRadius.circular(widget.tabBorderRadius),
                  boxShadow: widget.boxShadow,
                  color: widget.tabColor,
                ),
                labelColor: widget.labelColor,
                unselectedLabelColor: widget.unSelectLabelColor,
                labelStyle: widget.labelTextStyle,
                tabs: widget.tabs!.map((e) {
                  return Tab(text: e);
                }).toList()),
          ),
        ),
      ],
    );
  }
}
