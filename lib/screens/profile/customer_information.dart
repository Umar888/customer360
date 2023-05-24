import 'package:flutter/material.dart';
import 'package:gc_customer_app/constants/colors.dart';
import 'package:gc_customer_app/constants/text_strings.dart';
import 'package:gc_customer_app/models/user_profile_model.dart';
import 'package:gc_customer_app/primitives/color_system.dart';
import 'package:gc_customer_app/services/extensions/string_extension.dart';
import 'package:gc_customer_app/utils/utils_functions.dart';

class CustomerInformation extends StatelessWidget {
  final UserProfile? userProfile;
  CustomerInformation(this.userProfile, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var textTheme = Theme.of(context).textTheme;
    print(userProfile?.persionMailing ?? '');
    return Padding(
      padding: EdgeInsets.only(right: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            customerInfotxt,
            style: textTheme.headline2?.copyWith(fontWeight: FontWeight.w500),
          ),
          SizedBox(height: 6),
          InkWell(
            onTap: () {
              makephoneCall(userProfile!.accountPhoneC != null
                  ? userProfile!.accountPhoneC!.toMobileFormat()
                  : userProfile!.accountPhoneC == null &&
                          userProfile!.phoneC != null
                      ? userProfile!.phoneC!.toMobileFormat()
                      : userProfile!.accountPhoneC == null &&
                              userProfile!.phoneC == null &&
                              userProfile!.phone != null
                          ? userProfile!.phone!.toMobileFormat()
                          : "");
            },
            child: Text(
              userProfile!.accountPhoneC != null
                  ? userProfile!.accountPhoneC!.toMobileFormat()
                  : userProfile!.accountPhoneC == null &&
                          userProfile!.phoneC != null
                      ? userProfile!.phoneC!.toMobileFormat()
                      : userProfile!.accountPhoneC == null &&
                              userProfile!.phoneC == null &&
                              userProfile!.phone != null
                          ? userProfile!.phone!.toMobileFormat()
                          : "",
              style: textTheme.headline3?.copyWith(
                  color: ColorSystem.lavender3, fontWeight: FontWeight.w500),
            ),
          ),
          if ((userProfile?.accountEmailC ?? '').isNotEmpty)
            Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Text(
                '${userProfile?.accountEmailC}',
                style: textTheme.headline3,
              ),
            ),
          if ((userProfile?.persionMailing?.replaceAll(',', '').trim() ?? '')
              .isNotEmpty)
            Text(
              '${userProfile?.persionMailing ?? ''}',
              style: textTheme.headline3,
            ),
        ],
      ),
    );
  }
}
