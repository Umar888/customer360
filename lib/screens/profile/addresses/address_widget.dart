import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gc_customer_app/models/address_models/address_model.dart';
import 'package:gc_customer_app/primitives/color_system.dart';
import 'package:gc_customer_app/primitives/icon_system.dart';
import 'package:gc_customer_app/primitives/shadow_system.dart';
import 'package:gc_customer_app/screens/profile/addresses/add_address_bottom_sheet.dart';

class AddressWidget extends StatelessWidget {
  final AddressList address;
  final bool isDefault;
  AddressWidget({super.key, required this.address, this.isDefault = false});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: kIsWeb
          ? null
          : () => showModalBottomSheet(
                context: context,
                backgroundColor: Colors.transparent,
                barrierColor: Color.fromARGB(25, 92, 106, 196),
                isScrollControlled: true,
                builder: (context) {
                  return AddAddressBottomSheet(addressModel: address);
                },
              ),
      child: Stack(
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: BoxDecoration(
                border: Border.all(
                    color: isDefault ? Color(0xFFFF7643) : ColorSystem.white),
                borderRadius: BorderRadius.circular(12),
                color:
                    isDefault || kIsWeb ? ColorSystem.white : Color(0xFFF9F9F9),
                boxShadow: kIsWeb ? ShadowSystem.webWidgetShadow : null),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    SvgPicture.asset(
                        color: ColorSystem.primary,
                        package: 'gc_customer_app',
                        IconSystem.addressIcon),
                    SizedBox(width: 8),
                    // Flexible(
                    //   child: Text(
                    //     address.addressLabel ?? '',
                    //     style: Theme.of(context).textTheme.bodyText1,
                    //   ),
                    // )
                  ],
                ),
                SizedBox(height: 7),
                Text(
                  '${address.address1 ?? ''},',
                  maxLines: 3,
                  style: TextStyle(
                      color: ColorSystem.primary,
                      fontSize: 14,
                      fontWeight: FontWeight.w400),
                ),
                Text(
                  '${(address.address2 ?? '').isNotEmpty ? '${address.address2}, ' : ''}${address.city ?? ''}, ${address.state ?? ''}, ${address.postalCode}',
                  maxLines: 3,
                  style: TextStyle(
                      color: ColorSystem.primary,
                      fontSize: 14,
                      fontWeight: FontWeight.w400),
                ),
              ],
            ),
          ),
          if (isDefault)
            Positioned(
              top: 4,
              right: 5,
              child: Text(
                'Default',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  color: ColorSystem.lavender3,
                  decorationStyle: TextDecorationStyle.wavy,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
