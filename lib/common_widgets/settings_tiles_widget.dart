import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../constants/colors.dart';

class SettingTilesWidget extends StatefulWidget {
  SettingTilesWidget({
    Key? key,
    required this.widthOfScreen,
    required this.nameOfAssociate,
    required this.iconpath,
    this.imageUrl,
    required this.onChanged,
    required this.toggleButtonStatus,
    required this.isDisabled,
    required this.isSaving,
    required this.onClick,
  }) : super(key: key);

  final double widthOfScreen;
  final String nameOfAssociate;
  final String iconpath;
  final String? imageUrl;
  final ValueChanged<bool> onChanged;
  final bool toggleButtonStatus;
  final bool isDisabled;
  final bool isSaving;
  final bool onClick;

  @override
  State<SettingTilesWidget> createState() => _SettingTilesWidgetState();
}

class _SettingTilesWidgetState extends State<SettingTilesWidget>
    with SingleTickerProviderStateMixin {
  Animation? _circleAnimation;
  AnimationController? _animationController;

  var _enable = false;

  @override
  void initState() {
    super.initState();
    if (widget.toggleButtonStatus == true) {
      _enable = true;
      // ignore: unrelated_type_equality_checks
      _circleAnimation != Alignment.centerLeft;
    }

    _animationController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 60));
    _circleAnimation = AlignmentTween(
            begin: _enable ? Alignment.centerRight : Alignment.centerLeft,
            end: _enable ? Alignment.centerLeft : Alignment.centerRight)
        .animate(CurvedAnimation(
            parent: _animationController!, curve: Curves.linear));
  }

  @override
  void dispose() {
    _animationController!.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var textThem = Theme.of(context).textTheme;

    return ListTile(
        contentPadding: EdgeInsets.only(
            left: 0.0, right: widget.widthOfScreen * 0.05, top: 0),
        leading: Container(
          height: 50,
          width: 50,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(25),
            color: AppColors.greybackgroundContainer,
          ),
          child: Center(
            child: Padding(
              padding: EdgeInsets.all(10.0),
              child: SvgPicture.asset(
                widget.iconpath,
                package: 'gc_customer_app',
              ),
            ),
          ),
        ),
        title: Text(
          widget.nameOfAssociate,
          style: textThem.headline4,
        ),
        trailing: widget.isSaving
            ? CupertinoActivityIndicator(
                color: Colors.black,
              )
            : AnimatedBuilder(
                animation: _animationController!,
                builder: (context, child) {
                  return GestureDetector(
                    onTap: widget.onClick
                        ? () {
                            if (_animationController!.isCompleted) {
                              _animationController!.reverse();
                            } else {
                              _animationController!.forward();
                            }
                            _enable == false ? _enable = true : _enable = false;
                            _enable == false
                                ? widget.onChanged(false)
                                : widget.onChanged(true);
                          }
                        : null,
                    child: Container(
                      width: 60.0,
                      height: 32.0,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(24.0),
                        color:
                            _circleAnimation!.value == Alignment.centerLeft &&
                                    _enable == false
                                ? Colors.grey
                                : Colors.black,
                      ),
                      child: Padding(
                        padding: EdgeInsets.only(
                            top: 2.0, bottom: 2.0, right: 2.0, left: 2.0),
                        child: Stack(
                          children: [
                            Container(
                              alignment: _enable
                                  ? Alignment.centerRight
                                  : Alignment.centerLeft,
                              child: Container(
                                width: 28.0,
                                height: 28.0,
                                decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: widget.isDisabled
                                        ? Colors.grey[400]
                                        : Colors.white),
                              ),
                            ),
                            Positioned(
                                left: 2,
                                top: 2,
                                child: Icon(Icons.check,
                                    color: widget.isDisabled
                                        ? Colors.grey[400]
                                        : Colors.white)),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ));
  }
}
