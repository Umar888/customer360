import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gc_customer_app/models/address_model.dart';
import 'package:gc_customer_app/primitives/color_system.dart';
import 'package:gc_customer_app/primitives/icon_system.dart';

class AddressWidget extends StatelessWidget {
  final Address address;
  final bool isDefault;
  AddressWidget(
      {super.key, required this.address, this.isDefault = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.5, vertical: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
            color: isDefault ? Color(0xFFFF7643) : ColorSystem.white),
        color: isDefault ? ColorSystem.white : Color(0xFFF9F9F9),
      ),
      child: Column(
        children: [
          Row(
            children: [
              SvgPicture.asset(IconSystem.addressIcon),
              SizedBox(width: 8),
              Text(
                address.name,
                style: Theme.of(context).textTheme.bodyText2,
              )
            ],
          ),
          SizedBox(height: 7),
          Text(
            address.address,
            maxLines: 3,
            style: TextStyle(
                color: Theme.of(context).primaryColor,
                fontSize: 14,
                fontWeight: FontWeight.w400),
          )
        ],
      ),
    );
  }
}
