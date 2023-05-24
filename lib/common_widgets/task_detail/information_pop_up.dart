import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:gc_customer_app/primitives/color_system.dart';
import 'package:gc_customer_app/primitives/constants.dart';
import 'package:gc_customer_app/primitives/padding_system.dart';
import 'package:gc_customer_app/primitives/size_system.dart';
import 'package:url_launcher/url_launcher_string.dart';

class InformationPopUp extends StatelessWidget {
  InformationPopUp({Key? key}) : super(key: key);
  Future<void> openUserGuide() async {
    try {
      await launchUrlString(
        'https://guitarcenter.sharepoint.com/:b:/r/sites/Retailoperations/GC%20COM/Connected%20Associate/GC%20Customer%20App%20User%20Guide.pdf?csf=1&web=1',
      );
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BackdropFilter(
      filter: ImageFilter.blur(
        sigmaY: 10,
        sigmaX: 10,
      ),
      child: Center(
        child: Container(
          margin: EdgeInsets.symmetric(
            horizontal: PaddingSystem.padding40,
          ),
          padding: EdgeInsets.all(
            PaddingSystem.padding20,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(
              SizeSystem.size12,
            ),
            color: Colors.white,
          ),
          child: Material(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'KEY',
                  style: TextStyle(
                    fontSize: SizeSystem.size16,
                    color: Theme.of(context).primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(
                  height: SizeSystem.size8,
                ),
                RichText(
                  text: TextSpan(
                      style: TextStyle(
                        fontFamily: kRubik,
                      ),
                      children: [
                        TextSpan(
                          text: '\u2022 ',
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                        TextSpan(
                          text: 'Complete = Action successful',
                          style: TextStyle(
                            fontFamily: kRubik,
                            fontSize: SizeSystem.size14,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                      ]),
                ),
                SizedBox(
                  height: SizeSystem.size4,
                ),
                RichText(
                  text: TextSpan(
                    style: TextStyle(
                      fontFamily: kRubik,
                    ),
                    children: [
                      TextSpan(
                        text: '\u2022 ',
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                      TextSpan(
                        text: 'Reschedule = Date change',
                        style: TextStyle(
                          fontFamily: kRubik,
                          fontSize: SizeSystem.size14,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: SizeSystem.size4,
                ),
                RichText(
                  text: TextSpan(
                    style: TextStyle(
                      fontFamily: kRubik,
                    ),
                    children: [
                      TextSpan(
                        text: '\u2022 ',
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                      TextSpan(
                        text: 'Force Close = Actioned, but unsuccessful (select reason)',
                        style: TextStyle(
                          fontFamily: kRubik,
                          fontSize: SizeSystem.size14,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                Text(
                  'TIPS',
                  style: TextStyle(
                    fontSize: SizeSystem.size16,
                    color: Theme.of(context).primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(
                  height: SizeSystem.size8,
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '\u2022 ',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                    Expanded(
                      child: RichText(
                        text: TextSpan(
                          style: TextStyle(
                            fontFamily: kRubik,
                          ),
                          children: [
                            TextSpan(
                              text: 'Click on ',
                              style: TextStyle(
                                fontFamily: kRubik,
                                fontSize: SizeSystem.size14,
                                color: Theme.of(context).primaryColor,
                              ),
                            ),
                            TextSpan(
                              text: 'large',
                              style: TextStyle(
                                fontFamily: kRubik,
                                fontWeight: FontWeight.bold,
                                fontSize: SizeSystem.size14,
                                color: Theme.of(context).primaryColor,
                              ),
                            ),
                            TextSpan(
                              text:
                                  ' buttons (bottom) to update all items in an order.',
                              style: TextStyle(
                                fontFamily: kRubik,
                                fontSize: SizeSystem.size14,
                                color: Theme.of(context).primaryColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: SizeSystem.size8,
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '\u2022 ',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                    Expanded(
                      child: RichText(
                        text: TextSpan(
                            style: TextStyle(
                              fontFamily: kRubik,
                            ),
                            children: [
                              TextSpan(
                                text: 'Click on ',
                                style: TextStyle(
                                  fontFamily: kRubik,
                                  fontSize: SizeSystem.size14,
                                  color: Theme.of(context).primaryColor,
                                ),
                              ),
                              TextSpan(
                                text: 'small',
                                style: TextStyle(
                                  fontFamily: kRubik,
                                  fontWeight: FontWeight.bold,
                                  fontSize: SizeSystem.size14,
                                  color: Theme.of(context).primaryColor,
                                ),
                              ),
                              TextSpan(
                                text:
                                    ' buttons (under each item) to update single item.',
                                style: TextStyle(
                                  fontFamily: kRubik,
                                  fontSize: SizeSystem.size14,
                                  color: Theme.of(context).primaryColor,
                                ),
                              ),
                            ]),
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 20,
                ),
                Row(
                  children: [
                    Text(
                      'Click ',
                      style: TextStyle(
                        fontFamily: kRubik,
                        fontSize: SizeSystem.size14,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                    InkWell(
                      focusColor: Colors.transparent,
                      splashColor: Colors.transparent,
                      highlightColor: Colors.transparent,
                      hoverColor: Colors.transparent,
                      onTap: () {
                        openUserGuide();
                      },
                      child: Text(
                        'here',
                        style: TextStyle(
                          fontFamily: kRubik,
                          fontWeight: FontWeight.bold,
                          fontSize: SizeSystem.size14,
                          color: ColorSystem.lavender3,
                        ),
                      ),
                    ),
                    Text(
                      ' to view user guide.',
                      style: TextStyle(
                        fontFamily: kRubik,
                        fontSize: SizeSystem.size14,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
