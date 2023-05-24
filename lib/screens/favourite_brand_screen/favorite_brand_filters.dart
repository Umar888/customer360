import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gc_customer_app/bloc/favourite_brand_screen_bloc/favourite_brand_screen_bloc.dart';
import 'package:gc_customer_app/bloc/inventory_search_bloc/inventory_search_bloc.dart';
import 'package:gc_customer_app/common_widgets/app_bar_widget.dart';
import 'package:gc_customer_app/common_widgets/filter_widgets/filter_widgets.dart';
import 'package:gc_customer_app/common_widgets/filter_widgets/price_widget.dart';
import 'package:gc_customer_app/primitives/color_system.dart';
import 'package:gc_customer_app/primitives/constants.dart';
import 'package:gc_customer_app/primitives/icon_system.dart';
import 'package:gc_customer_app/primitives/size_system.dart';

import 'package:gc_customer_app/models/inventory_search/add_search_model.dart'
    as filter;

import '../../models/common_models/facet.dart';

class FavoriteBrandScreenFilters extends StatefulWidget {
  InventorySearchBloc inventorySearchBloc;
  FavoriteBrandScreenFilters(
      {super.key,
      required this.inventorySearchBloc,
      required this.listOfFilters});
  final List<Facet> listOfFilters;

  @override
  State<FavoriteBrandScreenFilters> createState() =>
      _FavoriteBrandScreenFiltersState();
}

class _FavoriteBrandScreenFiltersState extends State<FavoriteBrandScreenFilters>
    with TickerProviderStateMixin {
  late FavouriteBrandScreenBloc favouriteBrandScreenBloc;

  TextEditingController minAmountController = TextEditingController();
  TextEditingController maxAmountController = TextEditingController();

  @override
  void initState() {
    favouriteBrandScreenBloc = context.read<FavouriteBrandScreenBloc>();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double heightOfScreen = MediaQuery.of(context).size.height;
    double widthOfScreen = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(65),
        child: AppBarWidget(
          paddingFromleftLeading: widthOfScreen * 0.034,
          paddingFromRightActions: widthOfScreen * 0.034,
          textThem: Theme.of(context).textTheme,
          leadingWidget: Icon(
            Icons.arrow_back_ios,
            color: Colors.black,
            size: 30,
          ),
          onPressedLeading: () {
            Navigator.of(context).pop();
          },
          titletxt: 'FILTERS',
          actionsWidget: Center(
            child: InkWell(
              onTap: () {
                // favouriteBrandScreenBloc.add(OnClearFilters(
                //     searchDetailModel: state.searchDetailModel,buildOnTap: false,));
              },
              child: Text(
                'Clear All',
                style: TextStyle(
                    fontSize: SizeSystem.size17,
                    fontFamily: kRubik,
                    fontWeight: FontWeight.w600,
                    color: ColorSystem.lavender3),
              ),
            ),
          ),
          actionOnPress: () => () {},
        ),
      ),
      body: SizedBox(
          height: heightOfScreen,
          width: widthOfScreen,
          child: Padding(
            padding: EdgeInsets.only(top: 10),
            child: Column(
              children: [
                Expanded(
                  child: BlocBuilder<InventorySearchBloc, InventorySearchState>(
                      builder: (context, state) {
                    return state.searchDetailModel.first.wrapperinstance!
                                .facet !=
                            null
                        ? ListView.builder(
                            shrinkWrap: true,
                            itemCount: state.searchDetailModel.first
                                .wrapperinstance!.facet!.length,
                            itemBuilder: (context, index) => Column(
                              children: [
                                if (index == 0)
                                  Divider(
                                    color: ColorSystem.greyDark,
                                  ),
                                state.searchDetailModel.first.wrapperinstance!
                                            .facet![index].dimensionName ==
                                        'Price'
                                    ? BlocProvider.value(
                                        value: favouriteBrandScreenBloc,
                                        child: PriceTileWidget(
                                          nameOfTile: state
                                              .searchDetailModel
                                              .first
                                              .wrapperinstance!
                                              .facet![index]
                                              .dimensionName!,
                                          index: index,
                                          minAmountController:
                                              minAmountController,
                                          maxAmountController:
                                              maxAmountController,
                                        ),
                                      )
                                    : BlocProvider.value(
                                        value: favouriteBrandScreenBloc,
                                        child: FilterWidgetTile(
                                          nameOfTile: state
                                              .searchDetailModel
                                              .first
                                              .wrapperinstance!
                                              .facet![index]
                                              .dimensionName!
                                              .replaceAll('_', ' '),
                                          index: index,
                                        ),
                                      ),
                              ],
                            ),
                          )
                        : Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(
                                  height: SizeSystem.size50,
                                ),
                                SvgPicture.asset(
                                  IconSystem.noDataFound,
                                  package: 'gc_customer_app',
                                ),
                                SizedBox(
                                  height: SizeSystem.size24,
                                ),
                                Text(
                                  'NO DATA FOUND!',
                                  style: TextStyle(
                                    color: Theme.of(context).primaryColor,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: kRubik,
                                    fontSize: SizeSystem.size20,
                                  ),
                                )
                              ],
                            ),
                          );
                  }),
                ),
              ],
            ),
          )),
    );
  }
}
