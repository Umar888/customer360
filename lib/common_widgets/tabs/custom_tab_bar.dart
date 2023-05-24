import 'package:flutter/material.dart';

class CustomTabBarExtended extends StatefulWidget {
  final Widget? child;
  final EdgeInsets? margin;
  final EdgeInsets? padding;
  final double? height;
  final double? width;
  final double? containerBorderRadius;
  final double? tabBorderRadius;
  final Color? containerColor;
  final Color? tabColor;
  final Color? labelColor;
  final Color? unSelectLabelColor;
  final TabController? tabController;
  final List<BoxShadow>? boxShadow;
  final String? tabOneName;
  final String? tabTwoName;
  final String? tabThreeName;
  final TextStyle? labelTextStyle;

  CustomTabBarExtended({
    Key? key,
    this.margin,
    this.padding,
    this.height,
    this.width,
    this.containerColor,
    this.child,
    this.tabController,
    this.containerBorderRadius,
    this.tabBorderRadius,
    this.boxShadow,
    this.tabOneName,
    this.tabTwoName,
    this.tabThreeName,
    this.tabColor,
    this.labelColor,
    this.unSelectLabelColor,
    this.labelTextStyle,
  }) : super(key: key);

  @override
  State<CustomTabBarExtended> createState() => _CustomTabBarExtendedState();
}

class _CustomTabBarExtendedState extends State<CustomTabBarExtended>
    with SingleTickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: widget.padding,
      margin: widget.margin,
      child: Container(
        height: widget.height,
        decoration: BoxDecoration(
          color: widget.containerColor,
          borderRadius: BorderRadius.circular(
            widget.containerBorderRadius ?? 0,
          ),
        ),
        child: TabBar(
          onTap: (index) {
            print(index);
            if (index == 0) {
            } else if (index == 1) {
            } else {}
          },
          controller: widget.tabController,

          // give the indicator a decoration (color and border radius)
          indicator: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.tabBorderRadius ?? 0),
            boxShadow: widget.boxShadow,
            color: widget.tabColor,
          ),
          labelColor: widget.labelColor,
          unselectedLabelColor: widget.unSelectLabelColor,
          labelStyle: widget.labelTextStyle,
          tabs: [
            FittedBox(
              child: Tab(
                text: widget.tabOneName,
              ),
            ),
            FittedBox(
              child: Tab(
                text: widget.tabTwoName,
              ),
            ),
            FittedBox(
              child: Tab(
                text: widget.tabThreeName,
              ),
            ),
          ],
          
        ),
      ),
    );
  }
}
