import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:gc_customer_app/bloc/landing_screen_bloc/landing_screen_bloc_bloc.dart';
import 'package:gc_customer_app/models/landing_screen/landing_screen_order_history.dart';
import 'package:gc_customer_app/screens/order_history/order_history_page.dart';
import 'package:gc_customer_app/screens/order_history/order_history_web_page.dart';

import '../../models/landing_screen/customer_info_model.dart';

class OrderHistoryMain extends StatelessWidget {
  LandingScreenState landingScreenState;
  String customerId;
  CustomerInfoModel customer;
  List<OrderHistoryLandingScreen> orderHistoryLandingScreen;
  bool isOtherUser;
  bool isOnlyShowOrderHistory;
  OrderHistoryMain({
    super.key,
    required this.customerId,
    required this.orderHistoryLandingScreen,
    required this.customer,
    required this.landingScreenState,
    this.isOtherUser = false,
    this.isOnlyShowOrderHistory = false,
  });

  @override
  Widget build(BuildContext context) {
    return kIsWeb
        ? OrderHistoryWebScreen(
            customer: customer,
            customerId: customerId,
            landingScreenState: landingScreenState,
            isOnlyShowOrderHistory: isOnlyShowOrderHistory,
          )
        : OrderHistoryScreen(
            customer: customer,
            customerId: customerId,
            orderHistoryLandingScreen: orderHistoryLandingScreen,
            landingScreenState: landingScreenState,
            isOtherUser: isOtherUser,
            isOnlyShowOrderHistory: isOnlyShowOrderHistory,
          );
  }
}
