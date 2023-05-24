import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gc_customer_app/bloc/inventory_search_bloc/inventory_search_bloc.dart';
import 'package:gc_customer_app/bloc/landing_screen_bloc/landing_screen_bloc_bloc.dart';
import 'package:gc_customer_app/bloc/recommended_screen_bloc/browser_history/recommendation_browse_history_bloc.dart';
import 'package:gc_customer_app/bloc/zip_store_list_bloc/zip_store_list_bloc.dart';
import 'package:gc_customer_app/common_widgets/landing_screen/activity_landing_widget.dart';
import 'package:gc_customer_app/data/reporsitories/recommendation_screen_repository/recommendation_screen_repository.dart';
import 'package:gc_customer_app/primitives/constants.dart';
import 'package:gc_customer_app/screens/order_history/open_order_widget.dart';
import 'package:gc_customer_app/screens/recommendation_screen/browse_history_page.dart';
import 'package:gc_customer_app/screens/recommendation_screen/browse_history_web_page.dart';
import 'package:gc_customer_app/bloc/product_detail_bloc/product_detail_bloc.dart'
    as pdb;

import '../../constants/colors.dart';
import '../../primitives/icon_system.dart';
import '../../screens/recommendation_screen/recommendation_screen_main.dart';

class ActivityWidget extends StatefulWidget {
  ActivityWidget({
    super.key,
  });

  @override
  State<ActivityWidget> createState() => _ActivityWidgetState();
}

class _ActivityWidgetState extends State<ActivityWidget> {
  late LandingScreenBloc landingScreenBloc;

  late InventorySearchBloc inventorySearchBloc;
  late pdb.ProductDetailBloc productDetailBloc;
  late ZipStoreListBloc zipStoreListBloc;

  @override
  void initState() {
    landingScreenBloc = context.read<LandingScreenBloc>();
    landingScreenBloc.add(LoadActivity());
    inventorySearchBloc = context.read<InventorySearchBloc>();
    productDetailBloc = context.read<pdb.ProductDetailBloc>();
    zipStoreListBloc = context.read<ZipStoreListBloc>();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    var textThem = Theme.of(context).textTheme;
    return BlocBuilder<LandingScreenBloc, LandingScreenState>(
        builder: (context, state) {
      if (state.landingScreenStatus == LandingScreenStatus.success) {
        if (!state.gettingActivity!) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ActivityLandingWidget(
                onTap: () {
                  Navigator.of(context).push(CupertinoPageRoute(
                      builder: (context) => OpenOrdersScreen(
                          customerId: state.customerInfoModel!.records![0].id!,
                          customer: state.customerInfoModel!,
                          landingScreenState: state)));
                },
                valueOfOrder: double.parse(state.openOrder!.valueOfOrder!)
                    .toStringAsFixed(2),
                typeOfOrder: state.openOrder!.typeOfOrder!,
                numberOfOrders: state.openOrder!.numberOfOrders!,
                dateoforder: state.openOrder!.dateoforder!,
                itemsOfOrder: state.openOrder!.itemsOfOrder!,
                colors: AppColors.pinkHex,
                size: size,
              ),
              SizedBox(
                height: 20,
              ),
              ActivityLandingWidget(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => BlocProvider<
                              RecommendationBrowseHistoryBloc>(
                          create: (context) => RecommendationBrowseHistoryBloc(
                              recommendationScreenRepository:
                                  RecommendationScreenRepository()),
                          child: Scaffold(
                            appBar: AppBar(
                              title: Text('Browsing History',
                                  style: TextStyle(
                                      fontFamily: kRubik,
                                      fontWeight: FontWeight.w600,
                                      letterSpacing: 1.5,
                                      fontSize: 15)),
                              centerTitle: true,
                            ),
                            body: kIsWeb
                                ? BrowseHistoryWebPage(
                                    customerInfoModel: state.customerInfoModel!)
                                : BrowseHistoryPage(
                                    customerInfoModel: state.customerInfoModel!,
                                    inventorySearchBloc: inventorySearchBloc,
                                    state: inventorySearchBloc.state,
                                  ),
                          )),
                    ),
                  );
                },
                valueOfOrder: double.parse(state.browsingHistory!.valueOfOrder!)
                    .toStringAsFixed(2),
                typeOfOrder: state.browsingHistory!.typeOfOrder!,
                numberOfOrders: state.browsingHistory!.numberOfOrders!,
                dateoforder: state.browsingHistory!.dateoforder!,
                itemsOfOrder: state.browsingHistory!.itemsOfOrder!,
                colors: AppColors.greenHex,
                size: size,
              ),
            ],
          );
        } else {
          return SizedBox(
            height: size.height * 0.15,
            child: Center(child: CircularProgressIndicator()),
          );
        }
      } else {
        return SizedBox(
          height: size.height * 0.15,
          child: Center(child: Text(state.toString())),
        );
      }
    });
  }
}
