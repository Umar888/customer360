import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gc_customer_app/bloc/profile_screen_bloc/profile_screen_bloc.dart';
import 'package:gc_customer_app/models/user_profile_model.dart';
import 'package:gc_customer_app/primitives/color_system.dart';
import 'package:gc_customer_app/primitives/constants.dart';
import 'package:gc_customer_app/primitives/shadow_system.dart';
import 'package:gc_customer_app/utils/double_extention.dart';

class UserInformationBusinessWidget extends StatefulWidget {
  final UserProfile userProfile;
  UserInformationBusinessWidget({Key? key, required this.userProfile})
      : super(key: key);

  @override
  State<UserInformationBusinessWidget> createState() =>
      _UserInformationBusinessWidgetState();
}

class _UserInformationBusinessWidgetState
    extends State<UserInformationBusinessWidget> {
  @override
  Widget build(BuildContext context) {
    var textTheme = Theme.of(context).textTheme;
    return Expanded(
      child: Container(
        margin: EdgeInsets.only(top: 12, right: 12),
        height: 105,
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 12)
            .copyWith(bottom: 18),
        decoration: BoxDecoration(
            color: ColorSystem.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: ShadowSystem.webWidgetShadow),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            businessValue(textTheme, 'LTV',
                widget.userProfile.lifetimeNetSalesAmountC ?? 0),
            // Row(
            //   crossAxisAlignment: CrossAxisAlignment.start,
            //   children: [
            //     Text(
            //       'LTV: \$',
            //       style: TextStyle(
            //         fontSize: 16,
            //         fontFamily: kRubik,
            //         fontWeight: FontWeight.w500,
            //         color: Theme.of(context).primaryColor,
            //       ),
            //     ),
            //     SizedBox(height: 4),
            //     Text(
            //       (widget.userProfile.lifetimeNetSalesAmountC ?? 0).toHumanRead(),
            //       style: TextStyle(
            //         fontSize: 16,
            //         fontFamily: kRubik,
            //         fontWeight: FontWeight.w500,
            //         color: Theme.of(context).primaryColor,
            //       ),
            //     )
            //   ],
            // ),
            SizedBox(height: 5),
            businessValue(
                textTheme,
                'AOV',
                (widget.userProfile.lifetimeNetSalesAmountC ?? 0) /
                    (widget.userProfile.lifetimeNetSalesTransactionsC ?? 1)),
            // Row(
            //   crossAxisAlignment: CrossAxisAlignment.start,
            //   children: [
            //     Text(
            //       'AOV: \$',
            //       style: TextStyle(
            //         fontSize: 16,
            //         fontFamily: kRubik,
            //         fontWeight: FontWeight.w500,
            //         color: Theme.of(context).primaryColor,
            //       ),
            //     ),
            //     SizedBox(height: 4),
            //     Text(
            //       ((widget.userProfile.lifetimeNetSalesAmountC ?? 0) /
            //               (widget.userProfile.lifetimeNetSalesTransactionsC ?? 1))
            //           .toHumanRead(),
            //       style: TextStyle(
            //         fontSize: 16,
            //         fontFamily: kRubik,
            //         fontWeight: FontWeight.w500,
            //         color: Theme.of(context).primaryColor,
            //       ),
            //     )
            //   ],
            // ),
            // SizedBox(height: 5),
          ],
        ),
      ),
    );
  }

  Widget businessValue(
    TextTheme textTheme,
    String title,
    double value,
  ) =>
      Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(title, style: textTheme.headline5?.copyWith(fontSize: 13)),
          SizedBox(width: 8),
          RichText(
              text: TextSpan(
                  text: '\$',
                  style: textTheme.caption
                      ?.copyWith(fontSize: 14, fontWeight: FontWeight.w400),
                  children: [
                TextSpan(
                  text: '${value.toHumanRead()}',
                  style: textTheme.headline3
                      ?.copyWith(fontSize: 24, fontWeight: FontWeight.w500),
                )
              ]))
          // Text(
          //   '\$${value.toHumanRead()}',
          //   style: textTheme.headline3
          //       ?.copyWith(fontSize: 24, fontWeight: FontWeight.w500),
          // )
        ],
      );
}
