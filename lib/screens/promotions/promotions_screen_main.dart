import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gc_customer_app/bloc/promotion_bloc/promotion_bloc.dart';
import 'package:gc_customer_app/data/reporsitories/promotions_screen_repository/promotions_screen_repository.dart';
import 'package:gc_customer_app/screens/promotions/promotions_screen.dart';

class PromotionsScreenMain extends StatelessWidget {
  PromotionsScreenMain({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider<PromotionBloC>(
        create: (context) => PromotionBloC(PromotionsScreenRepository()),
        child: PromotionsScreen());
  }
}
