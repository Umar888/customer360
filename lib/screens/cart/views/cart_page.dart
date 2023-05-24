import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import 'package:gc_customer_app/models/landing_screen/customer_info_model.dart';
import 'package:gc_customer_app/utils/routes/cart_page_arguments.dart';

import '../../../bloc/cart_bloc/cart_bloc.dart';
import '../../../data/data_sources/cart_data_source/cart_data_source.dart';
import '../../../data/reporsitories/cart_reporsitory/cart_repository.dart';
import 'cart_list.dart';

class CartPage extends StatelessWidget {
  final CartArguments cartArguments;

  CartPage(this.cartArguments);

  static const routeName = '/cartPage';

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        return Future.value(false);
      },
      child: Container(
        color: Colors.grey.shade50,
        child: SafeArea(
          left: true,
          top: true,
          right: true,
          bottom: false,
          child: BlocProvider(
            create: (context) {
              return CartBloc(
                cartRepository:
                    CartRepository(cartDataSource: CartDataSource()),
              );
            },
            child: CartList(
                email: cartArguments.email,
                phone: cartArguments.phone,
                userName: cartArguments.userName,
                orderLineItemId: cartArguments.orderNumber,
                customerInfoModel: cartArguments.customerInfoModel,
                orderNumber: cartArguments.orderNumber,
                userId: cartArguments.userId,
                orderId: cartArguments.orderId,
                orderDate: cartArguments.orderDate,
                isFromNotificaiton: cartArguments.isFromNotificaiton),
          ),
        ),
      ),
    );
  }
}
