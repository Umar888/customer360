import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gc_customer_app/bloc/promotion_bloc/promotion_bloc.dart';
import 'package:gc_customer_app/data/reporsitories/promotions_screen_repository/promotions_screen_repository.dart';
import 'package:gc_customer_app/primitives/color_system.dart';
import 'package:gc_customer_app/screens/notification/notification_screen.dart';

class NotificationBottonWidget extends StatelessWidget {
  NotificationBottonWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(right: 12),
      child: IconButton(
          onPressed: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => BlocProvider<PromotionBloC>(
                      create: (context) =>
                          PromotionBloC(PromotionsScreenRepository()),
                      child: NotificationScreen()),
                ));
          },
          icon: Icon(
            Icons.notifications_active_outlined,
            color: ColorSystem.lavender3,
          )),
    );
  }
}
