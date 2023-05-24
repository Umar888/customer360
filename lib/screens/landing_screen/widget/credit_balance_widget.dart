import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gc_customer_app/bloc/landing_screen_bloc/credit_balance_bloc/credit_balance_bloc.dart';
import 'package:gc_customer_app/constants/text_strings.dart';
import 'package:gc_customer_app/models/landing_screen/credit_balance.dart';
import 'package:gc_customer_app/primitives/color_system.dart';
import 'package:gc_customer_app/primitives/shadow_system.dart';
import 'package:gc_customer_app/utils/constant_functions.dart';
import 'package:intl/intl.dart' as intl;

class CreditBalanceWidget extends StatefulWidget {
  final bool isHaveEmail;
  final bool isHaveBackground;
  CreditBalanceWidget(
      {super.key, required this.isHaveEmail, this.isHaveBackground = true});

  @override
  State<CreditBalanceWidget> createState() => _CreditBalanceWidgetState();
}

class _CreditBalanceWidgetState extends State<CreditBalanceWidget> {
  @override
  void initState() {
    context.read<CreditBalanceBloc>().add(LoadCreditData());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context).textTheme;
    final formatter = intl.NumberFormat.decimalPattern();

    return Container(
      margin: widget.isHaveBackground ? EdgeInsets.only(top: 12) : null,
      padding: EdgeInsets.symmetric(
          horizontal: widget.isHaveBackground
              ? kIsWeb
                  ? 24
                  : 12
              : 0,
          vertical: 12),
      decoration: widget.isHaveBackground
          ? BoxDecoration(
              color: ColorSystem.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: ShadowSystem.webWidgetShadow)
          : null,
      child: BlocBuilder<CreditBalanceBloc, CreditBalanceState>(
          builder: (context, state) {
        Widget value = SizedBox.shrink();
        CreditBalance? balance;
        if (!widget.isHaveEmail) {
          value = Text(
            customerEmailNotInOMStxt,
            style: theme.caption
                ?.copyWith(fontSize: 16, fontWeight: FontWeight.w500),
          );
        } else if (state is CreditBalanceSuccess) {
          balance = state.balance;
          value = Row(
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    availableCredittxt,
                    style: theme.headline5?.copyWith(fontSize: 12),
                  ),
                  SizedBox(height: 4),
                  RichText(
                    text: TextSpan(
                        text: '\$',
                        style: theme.caption?.copyWith(
                            fontSize: 12, fontWeight: FontWeight.w400),
                        children: [
                          TextSpan(
                              text: balance?.availableAmount == '0'
                                  ? double.parse(
                                          balance?.availableAmount ?? '0.0')
                                      .toStringAsFixed(2)
                                  : '${double.parse(balance?.availableAmount ?? '0.0').toStringAsFixed(2)}',
                              style: theme.caption?.copyWith(
                                  fontSize: 24, fontWeight: FontWeight.w500))
                        ]),
                  ),
                ],
              ),
            ],
          );
        }
        if (state is CreditBalanceProgress)
          return Container(
              height: 80,
              width: 120,
              child: Center(child: CircularProgressIndicator()));
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              creditOnAccounttxt,
              style: theme.headline5?.copyWith(fontWeight: FontWeight.w500),
            ),
            SizedBox(height: 13),
            SizedBox(
              height: 50,
              child: value,
            ),
          ],
        );
      }),
    );
  }

  String formattedNumber(double value) {
    var f = intl.NumberFormat.compact(locale: "en_US");
    try {
      return f.format(value);
    } catch (e) {
      return '0';
    }
  }
}
