import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:gc_customer_app/constants/text_strings.dart';
import 'package:gc_customer_app/models/user_profile_model.dart';
import 'dart:math' as math;

import 'package:gc_customer_app/primitives/color_system.dart';
import 'package:gc_customer_app/screens/profile/address_widget.dart';

import '../../../models/address_model.dart';

class Addresses extends StatelessWidget {
  final BoxConstraints constraints;
  final UserProfile? userProfile;
  Addresses(this.constraints, this.userProfile, {Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    var textTheme = Theme.of(context).textTheme;
    double addressWidth = (constraints.maxWidth - 48) / 2;
    double widgetHeight = addressWidth / 1.54;
    List<Address> addresses = [];
    addresses.add(
      Address(name: 'My home #1', address: userProfile?.persionMailing ?? ''),
    );
    return Container(
      margin: EdgeInsets.only(left: 12, bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            addressestxt,
            style: textTheme.headline2?.copyWith(fontWeight: FontWeight.w500),
          ),
          SizedBox(height: 12),
          SizedBox(
            height: widgetHeight,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                Padding(
                  padding: EdgeInsets.only(right: 12),
                  child: DottedBorder(
                    dashPattern: [5, 5],
                    borderType: BorderType.RRect,
                    color: ColorSystem.black,
                    radius: Radius.circular(15),
                    child: Container(
                      height: widgetHeight,
                      width: addressWidth / 2.76,
                      alignment: Alignment.center,
                      child: Icon(Icons.add),
                    ),
                  ),
                ),
                ...addresses
                    .map<Widget>((ad) => Container(
                          height: widgetHeight,
                          width: addressWidth,
                          margin: EdgeInsets.only(right: 12),
                          child: AddressWidget(
                            address: ad,
                            isDefault: ad.hashCode == addresses.first.hashCode,
                          ),
                        ))
                    .toList()
              ],
            ),
          )
        ],
      ),
    );
  }
}
