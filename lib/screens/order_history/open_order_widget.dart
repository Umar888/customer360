import 'package:flutter/material.dart';
import 'package:gc_customer_app/bloc/landing_screen_bloc/landing_screen_bloc_bloc.dart';
import 'package:gc_customer_app/common_widgets/order_history/open_order_widget.dart';
import 'package:gc_customer_app/models/landing_screen/customer_info_model.dart';
import 'package:gc_customer_app/primitives/color_system.dart';
import 'package:gc_customer_app/primitives/constants.dart';

class OpenOrdersScreen extends StatefulWidget {
  final String customerId;
  final CustomerInfoModel customer;
  final LandingScreenState landingScreenState;
  OpenOrdersScreen(
      {super.key,
      required this.customerId,
      required this.customer,
      required this.landingScreenState});

  @override
  State<OpenOrdersScreen> createState() => _OpenOrdersScreenState();
}

class _OpenOrdersScreenState extends State<OpenOrdersScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('OPEN ORDERS',
            style: TextStyle(
                fontFamily: kRubik,
                color: ColorSystem.black,
                fontWeight: FontWeight.w600,
                letterSpacing: 1.5,
                fontSize: 15)),
      ),
      body: ListView(
        children: [
          OpenOrderWidget(
            landingScreenState: widget.landingScreenState,
            customerInfoModel: widget.customer,
            customerId: widget.customerId,
            isOnlyShowOpenOrder: true,
          )
        ],
      ),
    );
  }
}
