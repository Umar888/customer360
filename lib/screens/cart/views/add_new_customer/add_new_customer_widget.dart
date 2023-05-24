import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gc_customer_app/models/user_profile_model.dart';
import 'package:gc_customer_app/primitives/color_system.dart';
import 'package:gc_customer_app/primitives/constants.dart';
import 'package:gc_customer_app/primitives/icon_system.dart';
import 'package:gc_customer_app/primitives/padding_system.dart';
import 'package:gc_customer_app/primitives/size_system.dart';
import 'package:intl/intl.dart';

import '../../../../bloc/cart_bloc/add_customer_bloc/add_customer_bloc.dart';
import '../../../../bloc/cart_bloc/cart_bloc.dart';

class AddNewCustomerWidget extends StatefulWidget {
  final UserProfile customer;
  final CartState state;
  final CartBloc cartBloc;
  final String orderId;
  final void Function() function;
  final int index;
  final AddCustomerBloc addCustomerBloc;
  final VoidCallback onTap;
  final bool isNameSearch;

  AddNewCustomerWidget({
    Key? key,
    required this.function,
    required this.state,
    required this.cartBloc,
    required this.orderId,
    required this.customer,
    required this.addCustomerBloc,
    required this.index,
    required this.onTap,
    this.isNameSearch = true,
  }) : super(key: key);

  @override
  _AddNewCustomerWidgetState createState() => _AddNewCustomerWidgetState();
}

class _AddNewCustomerWidgetState extends State<AddNewCustomerWidget> {
  var dateFormat = DateFormat('MM-dd-yyyy');
  String formattedNumber(double value) {
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
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
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
                    ],
                  ),
                ),
                SizedBox(
                  height: SizeSystem.size5,
                ),
                if (widget.customer.accountPhoneC != null)
                  SizedBox(
                    height: SizeSystem.size5,
                  ),
                if (widget.customer.accountPhoneC != null)
                  Text(
                    formatPhoneNumber(widget.customer.accountPhoneC!),
                    style: TextStyle(
                      fontSize: SizeSystem.size13,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                if (widget.customer.accountPhoneC == null &&
                    widget.customer.phoneC != null)
                  SizedBox(
                    height: SizeSystem.size5,
                  ),
                if (widget.customer.accountPhoneC == null &&
                    widget.customer.phoneC != null)
                  Text(
                    formatPhoneNumber(widget.customer.phoneC!),
                    style: TextStyle(
                      fontSize: SizeSystem.size13,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                if (widget.customer.accountPhoneC == null &&
                    widget.customer.phoneC == null &&
                    widget.customer.phone != null)
                  SizedBox(
                    height: SizeSystem.size5,
                  ),
                if (widget.customer.accountPhoneC == null &&
                    widget.customer.phoneC == null &&
                    widget.customer.phone != null)
                  Text(
                    formatPhoneNumber(widget.customer.phone!),
                    style: TextStyle(
                      fontSize: SizeSystem.size13,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                if (widget.customer.accountEmailC != null)
                  SizedBox(
                    height: SizeSystem.size5,
                  ),
                if (widget.customer.accountEmailC != null)
                  Text(
                    widget.customer.accountEmailC!,
                    style: TextStyle(
                      fontSize: SizeSystem.size13,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                if (widget.customer.accountEmailC == null &&
                    widget.customer.emailC != null)
                  SizedBox(
                    height: SizeSystem.size5,
                  ),
                if (widget.customer.accountEmailC == null &&
                    widget.customer.emailC != null)
                  Text(
                    formatPhoneNumber(widget.customer.emailC!),
                    style: TextStyle(
                      fontSize: SizeSystem.size13,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                if (widget.customer.accountEmailC == null &&
                    widget.customer.emailC == null &&
                    widget.customer.personEmail != null)
                  SizedBox(
                    height: SizeSystem.size5,
                  ),
                if (widget.customer.accountEmailC == null &&
                    widget.customer.emailC == null &&
                    widget.customer.personEmail != null)
                  Text(
                    formatPhoneNumber(widget.customer.personEmail!),
                    style: TextStyle(
                      fontSize: SizeSystem.size13,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                if (widget.customer.persionMailing != null &&
                    widget.customer.persionMailing!.isNotEmpty)
                  SizedBox(
                    height: SizeSystem.size10,
                  ),
                if (widget.customer.persionMailing != null &&
                    widget.customer.persionMailing!.isNotEmpty)
                  Text(
                    widget.customer.persionMailing!,
                    style: TextStyle(
                      fontSize: SizeSystem.size13,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
              ],
            ),
          ),
          InkWell(
            onTap: () {
              widget.addCustomerBloc.add(SelectUser(
                  index: widget.index,
                  cartBloc: widget.cartBloc,
                  function: widget.function,
                  orderId: widget.orderId));
              // setState(() {
              //   widget.function();
              // });
            },
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 4.0),
              child: widget.customer.isSelected!
                  ? Container(
                      decoration: BoxDecoration(
                          color: ColorSystem.lavender3,
                          shape: BoxShape.circle,
                          border: Border.all(color: ColorSystem.lavender3)),
                      child: Padding(
                        padding:
                            EdgeInsets.symmetric(vertical: 7.0, horizontal: 7),
                        child: Center(
                          child: Icon(
                            Icons.check_rounded,
                            color: ColorSystem.white,
                          ),
                        ),
                      ),
                    )
                  : Container(
                      decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor,
                          borderRadius: BorderRadius.circular(5),
                          border: Border.all(
                              color: Theme.of(context).primaryColor)),
                      child: Padding(
                        padding:
                            EdgeInsets.symmetric(vertical: 7.0, horizontal: 10),
                        child: Center(
                          child: Text(
                            "Choose",
                            style: TextStyle(
                              fontFamily: kRubik,
                              fontSize: 13,
                              color: ColorSystem.white,
                            ),
                          ),
                        ),
                      ),
                    ),
            ),
          )
        ],
      ),
      SizedBox(
        height: SizeSystem.size10,
      ),
    ]);
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
