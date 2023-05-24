import 'package:flutter/material.dart';

class EmptyPaymentWidget extends StatelessWidget {
  EmptyPaymentWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          'NO PAYMENT METHODS AVAILABLE',
          style: Theme.of(context)
              .textTheme
              .caption
              ?.copyWith(fontWeight: FontWeight.w500, fontSize: 18),
        )
      ],
    );
  }
}
