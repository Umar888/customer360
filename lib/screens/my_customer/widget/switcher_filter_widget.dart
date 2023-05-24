import 'package:flutter/material.dart';
import 'package:gc_customer_app/primitives/color_system.dart';

class SwitcherFilterWidget extends StatefulWidget {
  final AnimationController animationController;
  final Function onLeftTapped;
  final Function onRightTapped;
  final String leftTitle;
  final String rightTitle;

  SwitcherFilterWidget(
      {Key? key,
      required this.animationController,
      required this.onLeftTapped,
      required this.onRightTapped,
      required this.leftTitle,
      required this.rightTitle})
      : super(key: key);

  @override
  State<SwitcherFilterWidget> createState() => _SwitcherFilterWidgetState();
}

class _SwitcherFilterWidgetState extends State<SwitcherFilterWidget> {
  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context).textTheme;
    var swipeItemWidth = MediaQuery.of(context).size.width / 2 - 24;
    return Container(
      height: 47,
      width: double.infinity,
      child: Stack(
        children: [
          Container(
            height: 47,
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
                    height: 40,
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
                SizedBox(width: 1),
                InkWell(
                  splashColor: Colors.transparent,
                  child: Container(
                    height: 40,
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
                  : Alignment.centerRight,
              child: Container(
                height: 40,
                width: MediaQuery.of(context).size.width / 2 - 24,
                margin: EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                    color: ColorSystem.white,
                    borderRadius: BorderRadius.circular(16)),
                alignment: Alignment.center,
                child: Text(
                  widget.animationController.value == 0
                      ? widget.leftTitle
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
