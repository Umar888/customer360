import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gc_customer_app/bloc/inventory_search_bloc/inventory_search_bloc.dart';
import 'package:gc_customer_app/bloc/landing_screen_bloc/landing_screen_bloc_bloc.dart';
import 'package:gc_customer_app/models/user_profile_model.dart';
import 'package:gc_customer_app/primitives/color_system.dart';
import 'package:gc_customer_app/primitives/constants.dart';
import 'package:gc_customer_app/primitives/icon_system.dart';
import 'package:gc_customer_app/primitives/padding_system.dart';
import 'package:gc_customer_app/primitives/size_system.dart';
import 'package:gc_customer_app/screens/landing_screen/landing_screen_main.dart';
import 'package:gc_customer_app/services/storage/shared_preferences_service.dart';
import 'package:gc_customer_app/utils/enums/music_instrument_enum.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../landing_screen/landing_screen_page.dart';

class CustomerDetailsCard extends StatefulWidget {
  final UserProfile customer;
  final VoidCallback onTap;
  final bool isNameSearch;

  CustomerDetailsCard({
    Key? key,
    required this.customer,
    required this.onTap,
    this.isNameSearch = true,
  }) : super(key: key);

  @override
  _CustomerDetailsCardState createState() => _CustomerDetailsCardState();
}

class _CustomerDetailsCardState extends State<CustomerDetailsCard> {
  var dateFormat = DateFormat('MM-dd-yyyy');
  String formattedNumber(double value) {
    if (value == 0.0) {
      return '0.00';
    }
    var f = NumberFormat.compact(locale: "en_US");
    try {
      return f.format(value);
    } catch (e) {
      return '0';
    }
  }

  String formatPhoneNumber(String number) {
    if (number.length == 10 && !number.contains(')')) {
      var formattedNumber =
          '(${number.substring(0, 3)}) ${number.substring(3, 6)}-${number.substring(6, 10)}';
      return formattedNumber;
    } else {
      return number;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        if (widget.customer.id == null) {
          try {
            await launchUrlString(
                'salesforce1://sObject/${widget.customer.id}/view');
          } catch (e) {
            print(e);
          }
        } else {
          print("widget.customer.id! ${widget.customer.id!}");
          if (widget.customer.id != null) {
            await SharedPreferenceService()
                .setKey(key: agentId, value: widget.customer.id!);
          }
          if (widget.customer.accountEmailC != null) {
            await SharedPreferenceService().setKey(
                key: savedAgentName, value: widget.customer.accountEmailC!);
          }
          context
              .read<InventorySearchBloc>()
              .add(SetCart(itemOfCart: [], records: [], orderId: ''));
          if (widget.isNameSearch) {
            Navigator.pop(context, true);
          }
          if (!kIsWeb) {

            Navigator.of(context).push(CupertinoPageRoute(
                settings: RouteSettings(name: 'CustomerLandingScreen'),
                builder: (context) => CustomerLandingScreen()));
          } else {
            context.read<LandingScreenBloc>().add(LoadData());
          }
        }
      },
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 10),
        color: Colors.transparent,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              RichText(
                textAlign: TextAlign.left,
                text: TextSpan(
                  style: TextStyle(
                    fontFamily: kRubik,
                  ),
                  children: [
                    TextSpan(
                      text: '${widget.customer.name} •',
                      style: TextStyle(
                        overflow: TextOverflow.ellipsis,
                        fontWeight: FontWeight.bold,
                        fontSize: SizeSystem.size16,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                    WidgetSpan(
                        child: SizedBox(
                      width: SizeSystem.size5,
                    )),
                    TextSpan(
                      text: 'GC',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: SizeSystem.size14,
                        color: ColorSystem.greyDark,
                      ),
                    )
                  ],
                ),
              ),
              SizedBox(
                height: SizeSystem.size5,
              ),
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  children: [
                    WidgetSpan(
                      child: SvgPicture.asset(
                        IconSystem.badge,
                        package: 'gc_customer_app',
                        height: SizeSystem.size16,
                        color: getCustomerLevelColor(getCustomerLevel(
                            widget.customer.lifetimeNetSalesAmountC ?? 0)),
                      ),
                    ),
                    WidgetSpan(
                      child: SizedBox(
                        width: SizeSystem.size4,
                      ),
                    ),
                    TextSpan(
                      text: getCustomerLevel(
                          widget.customer.lifetimeNetSalesAmountC ?? 0),
                      style: TextStyle(
                        color: getCustomerLevelColor(getCustomerLevel(
                            widget.customer.lifetimeNetSalesAmountC ?? 0)),
                        fontWeight: FontWeight.bold,
                        fontSize: SizeSystem.size12,
                      ),
                    ),
                    if (widget.customer.lastTransactionDateC != null)
                      TextSpan(
                        text:
                            ' • Last Purchased : ${dateFormat.format(widget.customer.lastTransactionDateC!)}',
                        style: TextStyle(
                          fontSize: SizeSystem.size12,
                          color: ColorSystem.secondary,
                        ),
                      ),
                  ],
                ),
              ),
              if (widget.customer.accountEmailC != null)
                SizedBox(
                  height: SizeSystem.size10,
                ),
              if (widget.customer.accountEmailC != null)
                Text(
                  widget.customer.accountEmailC!,
                  style: TextStyle(
                    fontSize: SizeSystem.size12,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              if (widget.customer.accountPhoneC != null)
                SizedBox(
                  height: SizeSystem.size5,
                ),
              if (widget.customer.accountPhoneC != null)
                Text(
                  formatPhoneNumber(widget.customer.accountPhoneC!),
                  style: TextStyle(
                    fontSize: SizeSystem.size12,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
            ],
          ),
          SizedBox(
            height: SizeSystem.size10,
          ),
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            CustomerMicroDetails(
              label: 'LTV',
              value:
                  '\$${formattedNumber(widget.customer.lifetimeNetSalesAmountC ?? 0).toLowerCase()}',
            ),
            if ((widget.customer.lifetimeNetSalesAmountC ?? 0) /
                    (widget.customer.lifetimeNetSalesTransactionsC ?? 1) !=
                null)
              CustomerMicroDetails(
                label: 'AOV',
                value:
                    '\$${formattedNumber((widget.customer.lifetimeNetSalesAmountC ?? 0) / (widget.customer.lifetimeNetSalesTransactionsC ?? 1)).toLowerCase()}',
              ),
            if (widget.customer.primaryInstrumentCategoryC != null)
              MusicInstrument.getInstrumentIcon(
                          MusicInstrument.getMusicInstrumentFromString(
                              widget.customer.primaryInstrumentCategoryC!)) ==
                      '--'
                  ? CustomerMicroDetails(
                      label: widget.customer.primaryInstrumentCategoryC!,
                      value: '--',
                    )
                  : CustomerMicroDetails(
                      label: widget.customer.primaryInstrumentCategoryC!,
                      value: '',
                      icon: SvgPicture.asset(
                          color: Theme.of(context).primaryColor,
                          package: 'gc_customer_app',
                          MusicInstrument.getInstrumentIcon(
                              MusicInstrument.getMusicInstrumentFromString(
                                  widget
                                      .customer.primaryInstrumentCategoryC!))),
                    ),
          ])
        ]),
      ),
    );
  }

  Color getCustomerLevelColor(String level) {
    switch (level) {
      case 'LOW':
        return ColorSystem.purple;
      case 'MEDIUM':
        return ColorSystem.darkOchre;
      case 'HIGH':
        return ColorSystem.complimentary;
      default:
        return ColorSystem.complimentary;
    }
  }

  String getCustomerLevel(double ltv) {
    if (ltv <= 500) {
      return 'LOW';
    } else if (ltv > 500 && ltv <= 1000) {
      return 'MEDIUM';
    } else {
      return 'HIGH';
    }
  }
}

class CustomerMicroDetails extends StatefulWidget {
  CustomerMicroDetails(
      {Key? key, required this.value, required this.label, this.icon})
      : super(key: key);
  final String value;
  final String label;
  final Widget? icon;

  @override
  _CustomerMicroDetailsState createState() => _CustomerMicroDetailsState();
}

class _CustomerMicroDetailsState extends State<CustomerMicroDetails> {
  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Container(
        margin: EdgeInsets.symmetric(horizontal: PaddingSystem.padding5),
        alignment: Alignment.center,
        height: kIsWeb ? 60 : MediaQuery.of(context).size.width * 0.15,
        width: kIsWeb ? 60 : MediaQuery.of(context).size.width * 0.15,
        // padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(PaddingSystem.padding10),
            color: ColorSystem.secondary.withOpacity(0.1)),
        child: widget.icon ??
            Text(widget.value,
                style: TextStyle(
                  color: Theme.of(context).primaryColor,
                  fontFamily: kRubik,
                )),
      ),
      SizedBox(
        height: SizeSystem.size10,
      ),
      SizedBox(
        // width: MediaQuery.of(context).size.width * 0.16,
        child: Center(
          child: Text(
            widget.label,
            textAlign: TextAlign.center,
            maxLines: 2,
            style: TextStyle(
              overflow: TextOverflow.ellipsis,
              color: ColorSystem.secondary,
              fontSize: SizeSystem.size12,
              fontFamily: kRubik,
            ),
          ),
        ),
      )
    ]);
  }
}
