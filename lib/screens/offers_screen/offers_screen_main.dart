import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gc_customer_app/bloc/offers_screen_bloc/offers_screen_bloc.dart';
import 'package:gc_customer_app/data/reporsitories/offers_screen_repository/offers_screen_repository.dart';
import 'package:gc_customer_app/models/landing_screen/customer_info_model.dart';
import 'package:gc_customer_app/models/landing_screen/landing_scree_offers_model.dart';
import 'package:gc_customer_app/screens/offers_screen/offers_screen_page.dart';

class OffersScreenMain extends StatelessWidget {
  final CustomerInfoModel customerInfoModel;
  final List<Offers> offers;
  OffersScreenMain({super.key, required this.customerInfoModel, required this.offers});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<OffersScreenBloc>(
        create: (context) =>
            OffersScreenBloc(offersScreenRepository: OffersScreenRepository()),
        child:  OffersScreenPage(customerInfoModel: customerInfoModel,offers: offers,));
  }
}
