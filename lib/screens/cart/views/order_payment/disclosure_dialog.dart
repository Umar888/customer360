import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:gc_customer_app/primitives/color_system.dart';
import 'package:gc_customer_app/primitives/constants.dart';

class DisclosureDialog extends StatelessWidget {
  final String message;
  DisclosureDialog({Key? key, required this.message}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Dialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.0)),
          backgroundColor: ColorSystem.white,
          child: LayoutBuilder(builder: (context, constraints) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(height: 20),
                Text(
                  'Disclosure',
                  style: TextStyle(
                      fontSize: 17,
                      fontFamily: kRubik,
                      fontWeight: FontWeight.w600),
                ),
                SizedBox(height: 8),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        message,
                        textAlign: TextAlign.start,
                        style: TextStyle(
                            fontSize: 13, fontFamily: kRubik, height: 1.3),
                      ),
                      Text(
                        'Do you agree to these term?',
                        textAlign: TextAlign.start,
                        style: TextStyle(
                          fontSize: 13,
                          fontFamily: kRubik,
                        ),
                      )
                    ],
                  ),
                ),
                SizedBox(height: 18),
                Divider(height: 1, color: ColorSystem.secondary),
                Row(
                  children: [
                    InkWell(
                      onTap: () => Navigator.pop(context, false),
                      child: Container(
                        height: 44,
                        width: (constraints.maxWidth / 2),
                        child: Center(
                          child: Text(
                            'Reject',
                            style: TextStyle(
                                fontSize: 17,
                                fontFamily: kRubik,
                                color: ColorSystem.pureRed),
                          ),
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: () => Navigator.pop(context, true),
                      child: Container(
                        height: 44,
                        width: (constraints.maxWidth / 2),
                        decoration: BoxDecoration(
                            border: Border(
                                left:
                                    BorderSide(color: ColorSystem.secondary))),
                        child: Center(
                          child: Text(
                            'Accept',
                            style: TextStyle(
                                fontSize: 17,
                                fontFamily: kRubik,
                                color: Colors.blue,
                                fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),
                    ),
                    // ElevatedButton(onPressed: () {}, child: Text('Reject')),
                    // ElevatedButton(onPressed: () {}, child: Text('Accept')),
                  ],
                )
              ],
            );
          }),
        ));
  }
}

class RejectedDisclosureDialog extends StatelessWidget {
  RejectedDisclosureDialog({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Dialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.0)),
          backgroundColor: ColorSystem.white,
          child: LayoutBuilder(builder: (context, constraints) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(height: 20),
                Text(
                  'Disclosure',
                  style: TextStyle(
                      fontSize: 17,
                      fontFamily: kRubik,
                      fontWeight: FontWeight.w600),
                ),
                SizedBox(height: 8),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24),
                  child: Text(
                    '''To proceed with using your Guitar Center Gear Card with promotional financing, you must accept disclosure terms; otherwise, please either select the non-promotional plan or use an alternate form of payment to continue with your purchase.''',
                    textAlign: TextAlign.start,
                    style: TextStyle(
                        fontSize: 13, fontFamily: kRubik, height: 1.3),
                  ),
                ),
                SizedBox(height: 18),
                Divider(height: 1, color: ColorSystem.secondary),
                Row(
                  children: [
                    InkWell(
                      onTap: () => Navigator.pop(context, false),
                      child: Container(
                        height: 44,
                        width: (constraints.maxWidth / 2),
                        child: Center(
                          child: Text(
                            'Cancel',
                            style: TextStyle(
                                fontSize: 17,
                                fontFamily: kRubik,
                                color: ColorSystem.pureRed),
                          ),
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: () => Navigator.pop(context, true),
                      child: Container(
                        height: 44,
                        width: (constraints.maxWidth / 2),
                        decoration: BoxDecoration(
                            border: Border(
                                left:
                                    BorderSide(color: ColorSystem.secondary))),
                        child: Center(
                          child: Text(
                            'Go to Disclosure',
                            style: TextStyle(
                                fontSize: 17,
                                fontFamily: kRubik,
                                color: Colors.blue,
                                fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),
                    ),
                    // ElevatedButton(onPressed: () {}, child: Text('Reject')),
                    // ElevatedButton(onPressed: () {}, child: Text('Accept')),
                  ],
                )
              ],
            );
          }),
        ));
  }
}
