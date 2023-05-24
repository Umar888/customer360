import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gc_customer_app/data/reporsitories/recommendation_screen_repository/recommendation_screen_repository.dart';
import 'package:gc_customer_app/models/landing_screen/customer_info_model.dart';
import 'package:gc_customer_app/screens/recommendation_screen/recommendation_screen.dart';

class RecommendationScreenMain extends StatelessWidget {
  final CustomerInfoModel customerInfoModel;
  final String? selectedItemId;
  RecommendationScreenMain(
      {Key? key, required this.customerInfoModel, this.selectedItemId})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return RecommendationScreen(
      customerInfoModel: customerInfoModel,
      selectedItemId: selectedItemId,
    );
  }
}
