import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../constants/colors.dart';
import '../primitives/icon_system.dart';
import '../primitives/size_system.dart';

class SearchBaarWidget extends StatelessWidget {
  SearchBaarWidget({
    Key? key,
    required this.widthOfScreen,
    required this.heightOfScreen,
    required this.textOfSearchBar,
    required this.onTapSearchText,
    required this.onTapSearchButton,
    required this.showNotification,
    required this.numberOfNotifications, required this.searchBarTextColor,
  }) : super(key: key);

  final double widthOfScreen;
  final double heightOfScreen;
  final String textOfSearchBar;
  final Function onTapSearchText;
  final Function onTapSearchButton;
  final bool showNotification;
  final String numberOfNotifications;
  final Color searchBarTextColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: widthOfScreen,
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.favoriteContainerBorder),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: heightOfScreen * 0.08,
            child: Center(
              child: Row(
                children: [
                  InkWell(
                    onTap: () => onTapSearchText(),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                            margin: EdgeInsets.only(
                                right: 20, left: widthOfScreen * 0.04),
                            child: Icon(
                              Icons.keyboard_arrow_down_sharp,
                              color: Colors.black87,
                            )),
                        Text(
                          textOfSearchBar,
                          style: TextStyle(
                            fontSize: SizeSystem.size18,
                            fontWeight: FontWeight.w500,
                            color: searchBarTextColor,
                          ),
                        ),
                        SizedBox(width: widthOfScreen * 0.2),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Flex(
                      direction: Axis.horizontal,
                      children: [
                        Expanded(
                          flex: 1,
                          child: Row(
                            children: [
                              Container(
                                color: AppColors.favoriteContainerBorder,
                                width: 1,
                              ),
                              Expanded(
                                child: Center(
                                  child: IconButton(
                                      onPressed: () => onTapSearchButton(),
                                      icon: SvgPicture.asset(
                                        IconSystem.searchIcon,
                                        width: 25,
                                        height: 25,
                                      )),
                                ),
                              )
                            ],
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: Row(
                            children: [
                              Container(
                                color: AppColors.favoriteContainerBorder,
                                width: 1,
                              ),
                              Expanded(
                                child: Center(
                                  child: Stack(
                                    clipBehavior: Clip.none,
                                    children: [
                                      IconButton(
                                          onPressed: () {},
                                          icon: SvgPicture.asset(
                                            IconSystem.filterIcon,
                                            width: 30,
                                            height: 30,
                                          )),
                                      if (showNotification)
                                        Positioned(
                                          right: -4,
                                          top: -10,
                                          child: Card(
                                            elevation: 2,
                                            color: Colors.red,
                                            shadowColor: Colors.red.shade100,
                                            shape: CircleBorder(),
                                            child: Padding(
                                              padding:
                                                  EdgeInsets.all(8.0),
                                              child: Text(
                                                numberOfNotifications,
                                                style: TextStyle(
                                                  fontSize: SizeSystem.size14,
                                                  fontWeight: FontWeight.w500,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ),
                                          ),
                                        )
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
          Divider(
            height: 1,
            color: Colors.grey.shade300,
          )
        ],
      ),
    );
  }
}
