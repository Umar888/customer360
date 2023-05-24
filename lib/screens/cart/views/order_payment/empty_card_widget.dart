import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gc_customer_app/primitives/icon_system.dart';

class EmptyCardWidget extends StatelessWidget {
  EmptyCardWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SvgPicture.asset(
          IconSystem.emptyCard,
          package: 'gc_customer_app',
        ),
        SizedBox(height: 25),
        Text(
          'NO PAYMENT METHODS AVAILABLE',
          style: Theme.of(context)
              .textTheme
              .caption
              ?.copyWith(fontSize: 18, fontWeight: FontWeight.w500),
        ),
        SizedBox(height: 11),
      ],
    );
  }
}
