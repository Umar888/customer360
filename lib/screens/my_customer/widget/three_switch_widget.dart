import 'package:flutter/material.dart';
import 'package:gc_customer_app/primitives/color_system.dart';

class ThreeFilterWidget extends StatefulWidget {
  final AnimationController animationController;
  final Function onLeftTapped;
  final Function onRightTapped;
  final Function onMidTapped;
  final String leftTitle;
  final String rightTitle;
  final String midTitle;

  ThreeFilterWidget(
      {Key? key,
      required this.animationController,
      required this.onLeftTapped,
      required this.onRightTapped,
      required this.leftTitle,
      required this.rightTitle,
      required this.onMidTapped,
      required this.midTitle})
      : super(key: key);

  @override
  State<ThreeFilterWidget> createState() => _ThreeFilterWidgetState();
}

class _ThreeFilterWidgetState extends State<ThreeFilterWidget> {
  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context).textTheme;
    var widgetWidth = MediaQuery.of(context).size.width / 2;
    var swipeItemWidth = widgetWidth / 3;
    return Container(
      height: 30,
      width: widgetWidth,
      child: Stack(
        children: [
          Container(
            height: 30,
            width: double.infinity,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                color: ColorSystem.lavender.withOpacity(0.4)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                InkWell(
                  splashColor: Colors.transparent,
                  child: Container(
                    height: 27,
                    width: swipeItemWidth,
                    alignment: Alignment.center,
                    child: Text(widget.leftTitle,
                        style: theme.caption?.copyWith(
                            fontWeight: FontWeight.w500, letterSpacing: 1.2)),
                  ),
                  onTap: () {
                    widget.onLeftTapped();
                  },
                ),
                InkWell(
                  splashColor: Colors.transparent,
                  child: Container(
                    height: 27,
                    width: swipeItemWidth,
                    alignment: Alignment.center,
                    child: Text(widget.midTitle,
                        style: theme.caption?.copyWith(
                            fontWeight: FontWeight.w500, letterSpacing: 1.2)),
                  ),
                  onTap: () {
                    widget.onMidTapped();
                  },
                ),
                InkWell(
                  splashColor: Colors.transparent,
                  child: Container(
                    height: 27,
                    width: swipeItemWidth,
                    alignment: Alignment.center,
                    child: Text(widget.rightTitle,
                        style: theme.caption?.copyWith(
                            fontWeight: FontWeight.w500, letterSpacing: 1.2)),
                  ),
                  onTap: () {
                    widget.onRightTapped();
                  },
                ),
              ],
            ),
          ),
          AnimatedBuilder(
            animation: widget.animationController,
            builder: (context, child) => AnimatedAlign(
              duration: Duration(milliseconds: 200),
              alignment: widget.animationController.value == 0
                  ? Alignment.centerLeft
                  : widget.animationController.value == 0.5
                      ? Alignment.center
                      : Alignment.centerRight,
              child: Container(
                height: 27,
                width: widget.animationController.value == 0.5
                    ? swipeItemWidth + 8
                    : swipeItemWidth - 8,
                margin: EdgeInsets.symmetric(horizontal: 2),
                decoration: BoxDecoration(
                    color: ColorSystem.white,
                    borderRadius: BorderRadius.circular(16)),
                alignment: Alignment.center,
                child: Text(
                  widget.animationController.value == 0
                      ? widget.leftTitle
                      : widget.animationController.value == 0.5
                          ? widget.midTitle
                          : widget.rightTitle,
                  style: theme.caption?.copyWith(
                      fontWeight: FontWeight.w500, letterSpacing: 1.2),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
