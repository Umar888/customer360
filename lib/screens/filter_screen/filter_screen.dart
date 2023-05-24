import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gc_customer_app/app.dart';
import 'package:gc_customer_app/common_widgets/app_bar_widget.dart';
import 'package:gc_customer_app/common_widgets/filter_widgets/filter_widgets.dart';
import 'package:gc_customer_app/common_widgets/filter_widgets/price_widget.dart';
import 'package:gc_customer_app/primitives/color_system.dart';
import 'package:gc_customer_app/primitives/constants.dart';
import 'package:gc_customer_app/primitives/icon_system.dart';
import 'package:gc_customer_app/primitives/size_system.dart';

import 'package:gc_customer_app/bloc/inventory_search_bloc/inventory_search_bloc.dart'
    as inventoryBloc;

import '../../bloc/favourite_brand_screen_bloc/favourite_brand_screen_bloc.dart';
import '../../data/reporsitories/favourite_brand-screen_repository/favourite_brand_screen_repository.dart';
import '../../models/favorite_brands_model/favorite_brand_detail_model.dart';

class FilterScreen extends StatefulWidget {
  FilterScreen({super.key});

  @override
  State<FilterScreen> createState() => _FilterScreenState();
}

class _FilterScreenState extends State<FilterScreen>
    with TickerProviderStateMixin {
  late inventoryBloc.InventorySearchBloc inventorySearchBloc;

  TextEditingController minAmountController = TextEditingController();
  TextEditingController maxAmountController = TextEditingController();
  ScrollController scrollController = ScrollController();

  int minAmount = 0;
  int maxAmount = 0;

  @override
  void initState() {
    inventorySearchBloc = context.read<inventoryBloc.InventorySearchBloc>();
    super.initState();
  }

  late bool isTileSelected;

  bool isFilterselected(inventoryBloc.InventorySearchState state) {
    isTileSelected = state.searchDetailModel.first.wrapperinstance!.facet!.any(
      (element) {
        if (element.selectedRefinement!.isEmpty &&
            element.refinement!.isEmpty) {
          return true;
        } else if (state.searchDetailModel.first.lengthOfSelectedFilters > 0) {
          return true;
        } else if (element.selectedRefinement!.isEmpty &&
            element.refinement!.isNotEmpty) {
          return false;
        }
        return element.selectedRefinement!.isNotEmpty;
      },
    );
    print(isTileSelected);
    return isTileSelected;
  }

  @override
  Widget build(BuildContext context) {
    double widthOfScreen = MediaQuery.of(context).size.width;
    return BlocConsumer<inventoryBloc.InventorySearchBloc,
        inventoryBloc.InventorySearchState>(
      listener: (context, state) {
        if (state.message.isNotEmpty &&
            state.message != "done" &&
            state.message != "zebon") {
          Future.delayed(Duration.zero, () {
            setState(() {});
            showMessage(context: context,message:state.message);
          });
        }
        inventorySearchBloc.add(inventoryBloc.EmptyMessage());
      },
      builder: (context, state) {
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
                isFilterselected(state);
                Navigator.of(context).pop(isTileSelected ? true : false);
              },
              titletxt: 'FILTERS',
              actionsWidget: Center(
                child: InkWell(
                  onTap: () {
                    inventorySearchBloc.add(
                      inventoryBloc.OnClearFilters(
                        searchDetailModel: state.searchDetailModel,
                        buildOnTap: false,
                        isFavouriteScreen: false,
                        brandName: '',
                        primaryInstrument: '',
                        brandItems: [],
                        favouriteBrandScreenBloc: FavouriteBrandScreenBloc(
                          favouriteBrandScreenRepository:
                              FavouriteBrandScreenRepository(),
                        ),
                        favoriteItems: FavoriteBrandDetailModel(),
                        productsInCart: state.productsInCart,
                      ),
                    );
                    isFilterselected(state);

                    isTileSelected
                        ? Navigator.of(context)
                            .pop(isTileSelected ? true : false)
                        : null;
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
          body: SafeArea(
            child: Column(
              children: [
                SizedBox(
                  height: 10,
                ),
                Expanded(
                  child: CustomScrollView(
                    slivers: [
                      SliverToBoxAdapter(
                        child: BlocBuilder<inventoryBloc.InventorySearchBloc,
                                inventoryBloc.InventorySearchState>(
                            builder: (context, state) {
                          return state.searchDetailModel.first.wrapperinstance!
                                          .facet !=
                                      null &&
                                  state.searchDetailModel.first.wrapperinstance!
                                      .facet!.isNotEmpty
                              ? CustomScrollView(
                                  shrinkWrap: true,
                                  controller: scrollController,
                                  physics: NeverScrollableScrollPhysics(),
                                  slivers: state.searchDetailModel.first
                                      .wrapperinstance!.facet!
                                      .map((e) {
                                    int index = state.searchDetailModel.first
                                        .wrapperinstance!.facet!
                                        .indexOf(e);
                                    return SliverToBoxAdapter(
                                      child: CustomScrollView(
                                        shrinkWrap: true,
                                        physics: NeverScrollableScrollPhysics(),
                                        slivers: [
                                          if (index == 0)
                                            SliverToBoxAdapter(
                                              child: Divider(
                                                color: ColorSystem.greyDark,
                                              ),
                                            ),
                                          state
                                                      .searchDetailModel
                                                      .first
                                                      .wrapperinstance!
                                                      .facet![index]
                                                      .dimensionName ==
                                                  'Price'
                                              ? SliverToBoxAdapter(
                                                  child: BlocProvider.value(
                                                    value: inventorySearchBloc,
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
                                                  ),
                                                )
                                              : SliverToBoxAdapter(
                                                  child: BlocProvider.value(
                                                    value: inventorySearchBloc,
                                                    child: FilterWidgetTile(
                                                      nameOfTile: state
                                                          .searchDetailModel
                                                          .first
                                                          .wrapperinstance!
                                                          .facet![index]
                                                          .displayName!
                                                          .replaceAll('_', ' '),
                                                      index: index,
                                                    ),
                                                  ),
                                                )
                                        ],
                                      ),
                                    );
                                  }).toList())
                              : CustomScrollView(
                                  shrinkWrap: true,
                                  physics: NeverScrollableScrollPhysics(),
                                  slivers: [
                                    SliverToBoxAdapter(
                                        child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        SizedBox(
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .height *
                                              0.2,
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
                                            color:
                                                Theme.of(context).primaryColor,
                                            fontWeight: FontWeight.bold,
                                            fontFamily: kRubik,
                                            fontSize: SizeSystem.size20,
                                          ),
                                        ),
                                      ],
                                    )),
                                  ],
                                );
                        }),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
