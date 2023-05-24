import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gc_customer_app/primitives/constants.dart';

import '../constants/colors.dart';
import '../primitives/color_system.dart';
import '../primitives/icon_system.dart';

class OtherTilesWidget extends StatelessWidget {
  OtherTilesWidget({
    Key? key,
    required this.widthOfScreen,
    required this.textThem,
    required this.nameOfAssociate,
    required this.subtitleOftile,
    required this.iconpath,
    required this.isWidget,
    required this.ontapList,
    this.imageUrl,
    this.isSelected = false,
  }) : super(key: key);

  final double widthOfScreen;
  final TextTheme textThem;
  final String nameOfAssociate;
  final String subtitleOftile;
  final String iconpath;
  final bool isWidget;
  final void Function() ontapList;
  final String? imageUrl;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: ontapList,
      child: ListTile(
        tileColor: isSelected ? ColorSystem.greyMild : null,
        contentPadding: EdgeInsets.only(
            left: kIsWeb ? 14 : 0.0,
            right: kIsWeb ? 14 : widthOfScreen * 0.05,
            top: 0),
        leading: !isWidget
            ? Container(
                height: 50,
                width: 50,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(25),
                  color: AppColors.greybackgroundContainer,
                ),
                child: Center(
                  child: SvgPicture.asset(
                    iconpath,
                    package: 'gc_customer_app',
                  ),
                ),
              )
            : ClipOval(
                child: CachedNetworkImage(
                  height: 50,
                  width: 50,
                  fit: BoxFit.cover,
                  imageUrl: imageUrl!,
                  placeholder: (context, url) => CircularProgressIndicator(),
                  errorWidget: (context, url, error) => Icon(Icons.error),
                ),
              ),
        title: Text(
          nameOfAssociate,
          style: TextStyle(fontFamily: kRubik, color: ColorSystem.greyDark),
        ),
        subtitle: Text(
          subtitleOftile,
          style: TextStyle(
              fontFamily: kRubik,
              fontSize: 15,
              color: Colors.black87,
              fontWeight: FontWeight.bold),
        ),
        trailing: kIsWeb
            ? isSelected
                ? Container(
                    height: 60,
                    width: 5,
                    decoration: BoxDecoration(
                        color: ColorSystem.lavender3,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(55),
                          bottomLeft: Radius.circular(55),
                        )),
                  )
                : null
            : SvgPicture.asset(IconSystem.gotoArrow,
                package: 'gc_customer_app', width: 30, height: 30),
      ),
    );
  }
}
