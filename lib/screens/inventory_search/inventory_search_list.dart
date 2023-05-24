import 'dart:async';
import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:dynamic_height_grid_view/dynamic_height_grid_view.dart';
import 'package:easy_debounce/easy_debounce.dart';
import 'package:easy_refresh/easy_refresh.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/cupertino.dart' as cuper;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_swipe_action_cell/flutter_swipe_action_cell.dart';
import 'package:gc_customer_app/app.dart';
import 'package:gc_customer_app/bloc/product_detail_bloc/product_detail_bloc.dart'
    as pdb;
import 'package:gc_customer_app/bloc/zip_store_list_bloc/zip_store_list_bloc.dart'
    as zlb;
import 'package:gc_customer_app/common_widgets/bottom_navigation_bar.dart';
import 'package:gc_customer_app/common_widgets/inventory_search/grid_item.dart';
import 'package:gc_customer_app/common_widgets/inventory_search/list_item.dart';
import 'package:gc_customer_app/common_widgets/no_data_found.dart';
import 'package:gc_customer_app/common_widgets/scanner_view.dart';
import 'package:gc_customer_app/data/reporsitories/favourite_brand-screen_repository/favourite_brand_screen_repository.dart';
import 'package:gc_customer_app/models/favorite_brands_model/favorite_brand_detail_model.dart'
    as fbdm;
import 'package:gc_customer_app/models/landing_screen/customer_info_model.dart'
    as cm;
import 'package:gc_customer_app/primitives/color_system.dart';
import 'package:gc_customer_app/screens/filter_screen/filter_screen.dart';
import 'package:gc_customer_app/screens/product_detail/product_detail_page.dart';
import 'package:gc_customer_app/services/extensions/list_sorting.dart';
import 'package:intl/intl.dart' as intl;

import '../../bloc/favourite_brand_screen_bloc/favourite_brand_screen_bloc.dart'
    as fbsb;
import '../../bloc/inventory_search_bloc/inventory_search_bloc.dart';
import '../../models/cart_model/cart_warranties_model.dart';
import '../../models/common_models/records_class_model.dart';
import '../../primitives/constants.dart';
import '../../primitives/icon_system.dart';
import '../../primitives/size_system.dart';
import '../../services/storage/shared_preferences_service.dart';

class InventorySearchList extends StatefulWidget {
  final String customerID;
  final cm.CustomerInfoModel? customer;
  final String? initSearchText;

  InventorySearchList(
      {Key? key, required this.customerID, this.customer, this.initSearchText})
      : super(key: key);

  @override
  State<InventorySearchList> createState() => _InventorySearchListState();
}

class _InventorySearchListState extends State<InventorySearchList>
    with TickerProviderStateMixin {
  late StreamController<void> streamController = StreamController();
  late StreamSubscription<InventorySearchState> subscription;
  TextEditingController _searchController = TextEditingController();
  TabController? _tabController;
  late pdb.ProductDetailBloc productDetailBloc;
  late zlb.ZipStoreListBloc zipStoreListBloc;

  final EasyRefreshController _controller = EasyRefreshController(
    controlFinishRefresh: true,
    controlFinishLoad: true,
  );

  String formattedNumber(double value) {
    var f = intl.NumberFormat.compact(locale: "en_US");
    try {
      return f.format(value);
    } catch (e) {
      return '0';
    }
  }

  final SwipeActionController controller = SwipeActionController();

  double aovCalculator(double? ltv, double? lnt) {
    if (ltv != null && lnt != null) {
      return ltv / lnt;
    } else {
      return 0;
    }
  }

  late InventorySearchBloc inventorySearchBloc;

  String dateFormatter(String? orderDate) {
    if (orderDate == null) {
      return '--';
    } else {
      return intl.DateFormat('MMM dd, yyyy').format(DateTime.parse(orderDate));
    }
  }

  @override
  initState() {
    super.initState();
    if (!kIsWeb)
      FirebaseAnalytics.instance
          .setCurrentScreen(screenName: 'InventorySearchScreen');
    inventorySearchBloc = context.read<InventorySearchBloc>();
    productDetailBloc = context.read<pdb.ProductDetailBloc>();
    zipStoreListBloc = context.read<zlb.ZipStoreListBloc>();

    _tabController = TabController(length: 3, vsync: this);

    _searchController.text = widget.initSearchText ?? "";
    searchNameInfield = widget.initSearchText!;
    inventorySearchBloc.add(PageLoad(
        name: widget.initSearchText ?? "", offset: 1, isFirstTime: false));

    inventorySearchBloc.add(AddOptions());
    subscription = inventorySearchBloc.stream.listen((state) {
      if (state.showDialog &&
          !state.fetchWarranties &&
          state.warrantiesRecord.isNotEmpty &&
          mounted &&
          ModalRoute.of(context) != null &&
          ModalRoute.of(context)!.isCurrent) {
        inventorySearchBloc.add(ChangeShowDialog(false));
        cuper.showCupertinoDialog(
          barrierDismissible: true,
          context: context,
          builder: (BuildContext dialogContext) {
            return BackdropFilter(
              filter: ImageFilter.blur(
                sigmaX: 8.0,
                sigmaY: 8.0,
              ),
              child: cuper.CupertinoAlertDialog(
                actions: [
                  Material(
                    color: Colors.white30,
                    child: SizedBox(
                      width: MediaQuery.of(context).size.width / 1.5,
                      child: state.warrantiesModel.isNotEmpty
                          ? Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Padding(
                                  padding: EdgeInsets.symmetric(vertical: 20.0),
                                  child: Text(
                                    "Pro Coverage",
                                    style: TextStyle(
                                        color: Colors.black87,
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                                Divider(
                                  color: Colors.black54,
                                  height: 1,
                                ),
                                Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: state.warrantiesModel
                                      .sortedBy((it) => it.price!)
                                      .map((Warranties value) {
                                    int index = state.warrantiesModel
                                        .sortedBy((it) => it.price!)
                                        .toList()
                                        .indexOf(value);
                                    return Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          InkWell(
                                            onTap: () {
                                              Navigator.pop(dialogContext);
                                              if (value.styleDescription1!
                                                  .isNotEmpty) {
                                                inventorySearchBloc.add(AddToCart(
                                                    favouriteBrandScreenBloc: context.read<
                                                        fbsb
                                                            .FavouriteBrandScreenBloc>(),
                                                    records: state
                                                        .warrantiesRecord.first,
                                                    customerID: widget
                                                            .customer!
                                                            .records!
                                                            .first
                                                            .id ??
                                                        "",
                                                    skUid: state
                                                                    .warrantiesRecord
                                                                    .first
                                                                    .records!
                                                                    .childskus !=
                                                                null &&
                                                            state
                                                                .warrantiesRecord
                                                                .first
                                                                .records!
                                                                .childskus!
                                                                .isNotEmpty
                                                        ? state
                                                            .warrantiesRecord
                                                            .first
                                                            .records!
                                                            .childskus!
                                                            .first
                                                            .skuENTId!
                                                        : "",
                                                    productId: state.warrantiesRecord.first.productId!,
                                                    orderID: state.orderId,
                                                    ifWarranties: true,
                                                    orderItem: "",
                                                    warranties: value));
                                              } else {
                                                inventorySearchBloc.add(AddToCart(
                                                    favouriteBrandScreenBloc:
                                                        context.read<
                                                            fbsb
                                                                .FavouriteBrandScreenBloc>(),
                                                    records: state
                                                        .warrantiesRecord.first,
                                                    customerID: widget
                                                            .customer!
                                                            .records!
                                                            .first
                                                            .id ??
                                                        "",
                                                    productId: state
                                                        .warrantiesRecord
                                                        .first
                                                        .productId!,
                                                    orderID: state.orderId,
                                                    ifWarranties: false,
                                                    orderItem: "",
                                                    warranties: Warranties()));
                                              }
                                            },
                                            child: Padding(
                                                padding: EdgeInsets.symmetric(
                                                    vertical: 15.0),
                                                child: value.price == 0.0
                                                    ? Text(
                                                        "${value.displayName}",
                                                        style: TextStyle(
                                                            fontSize: SizeSystem
                                                                .size16,
                                                            fontWeight:
                                                                FontWeight.w400,
                                                            color:
                                                                Colors.black87,
                                                            fontFamily: kRubik),
                                                      )
                                                    : Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        children: [
                                                          Text(
                                                            "${value.styleDescription1!.replaceAll("-", "")}: ",
                                                            style: TextStyle(
                                                                fontSize:
                                                                    SizeSystem
                                                                        .size16,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w400,
                                                                color: Colors
                                                                    .black87,
                                                                fontFamily:
                                                                    kRubik),
                                                          ),
                                                          Text(
                                                            "\$${value.price}",
                                                            style: TextStyle(
                                                                fontSize:
                                                                    SizeSystem
                                                                        .size16,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w400,
                                                                color: Colors
                                                                    .black87,
                                                                fontFamily:
                                                                    kRubik),
                                                          ),
                                                        ],
                                                      )),
                                          ),
                                          index ==
                                                  state.warrantiesModel
                                                          .sortedBy(
                                                              (it) => it.price!)
                                                          .toList()
                                                          .length -
                                                      1
                                              ? SizedBox.shrink()
                                              : Divider(
                                                  color: Colors.black54,
                                                  height: 1,
                                                ),
                                        ]);
                                  }).toList(),
                                )
                              ],
                            )
                          : Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Padding(
                                  padding: EdgeInsets.symmetric(vertical: 20.0),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        "Pro Coverage",
                                        style: TextStyle(
                                            color: Colors.black87,
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      SizedBox(
                                        height: 5,
                                      ),
                                      Text(
                                        "No Coverage plan available for this product",
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          color: Colors.black87,
                                          fontSize: 15,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Divider(
                                  color: Colors.black54,
                                  height: 1,
                                ),
                                InkWell(
                                  onTap: () {
                                    Navigator.pop(dialogContext);
                                    inventorySearchBloc.add(AddToCart(
                                        favouriteBrandScreenBloc: context.read<
                                            fbsb.FavouriteBrandScreenBloc>(),
                                        records: state.warrantiesRecord.first,
                                        customerID: widget.customerID,
                                        productId: state
                                            .warrantiesRecord.first.productId!,
                                        skUid: state.warrantiesRecord.first
                                                        .records!.childskus !=
                                                    null &&
                                                state
                                                    .warrantiesRecord
                                                    .first
                                                    .records!
                                                    .childskus!
                                                    .isNotEmpty
                                            ? state
                                                .warrantiesRecord
                                                .first
                                                .records!
                                                .childskus!
                                                .first
                                                .skuENTId!
                                            : "",
                                        orderID: state.orderId,
                                        ifWarranties: false,
                                        orderItem: "",
                                        warranties: Warranties()));
                                  },
                                  child: Padding(
                                    padding:
                                        EdgeInsets.symmetric(vertical: 15.0),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          "OK",
                                          style: TextStyle(
                                              color: Colors.blue,
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ],
                                    ),
                                  ),
                                )
                              ],
                            ),
                    ),
                  ),
                ],
              ),
            );
          },
        ).then((value) {
          inventorySearchBloc.add(ClearWarranties());
          inventorySearchBloc.add(ChangeShowDialog(false));
        });
      }
    });
    if (widget.customer == null ||
        widget.customer!.records == null ||
        widget.customer!.records!.isEmpty ||
        widget.customer!.records!.first.id == null) {
      setClear();
    }
  }

  setClear() async {
    await SharedPreferenceService().setKey(key: agentEmail, value: '');
    await SharedPreferenceService().setKey(key: agentId, value: '');
    await SharedPreferenceService().setKey(key: agentPhone, value: '');
    await SharedPreferenceService().setKey(key: savedAgentName, value: '');
    //inventorySearchBloc.add(SetCart(itemOfCart: [], records: [], orderId: ''));
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();

    inventorySearchBloc.add(UpdateIsFirst(value: true));
    streamController.close();
    print("inventory search disposed");
    subscription.cancel();
    _tabController?.dispose();
  }

  SnackBar snackBar(String message) {
    return SnackBar(
        elevation: 4.0,
        backgroundColor: ColorSystem.lavender3,
        behavior: SnackBarBehavior.floating,
        margin:
            EdgeInsets.only(bottom: MediaQuery.of(context).size.height * 0.05),
        content: Text(
          message,
          style: TextStyle(
            color: Colors.white,
            fontSize: SizeSystem.size18,
            fontWeight: FontWeight.bold,
          ),
        ));
  }

  CachedNetworkImage _imageContainer(String imageUrl, double width) {
    return CachedNetworkImage(
      imageUrl: imageUrl,
      placeholder: (context, url) => Padding(
        padding: EdgeInsets.all(15.0),
        child: cuper.CupertinoActivityIndicator(),
      ),
      imageBuilder: (context, imageProvider) {
        return Container(
          width: width,
          decoration: BoxDecoration(
            border: Border.all(
              color: Colors.transparent,
            ),
            borderRadius: BorderRadius.circular(0),
            color: Colors.transparent,
          ),
          child: Image(
            image: imageProvider,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return BlocConsumer<InventorySearchBloc, InventorySearchState>(
        listener: (context, state) {
      if (state.message == "Customer is not available for order") {
        Future.delayed(Duration.zero, () {
          setState(() {});
          ScaffoldMessenger.of(context).showSnackBar(snackBar(state.message));
        });
      }

      inventorySearchBloc.add(EmptyMessage());
    }, builder: (context, state) {
      var result = '';
      if (state.inventorySearchStatus == InventorySearchStatus.successState) {
        // inventorySearchBloc.add(FetchInventoryPaginationData(
        //                     currentPage: state.currentPage + 1,
        //                     searchDetailModel: state.searchDetailModel,
        //                     searchName: searchNameInfield));
        return Scaffold(
            // backgroundColor: ColorSystem.culturedGrey,
            body: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 10,
              ),
              child: Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      IconButton(
                          onPressed: () {
                            if (state.productsInCart.isNotEmpty) {
                              Navigator.pop(context, true);
                              searchNameInfield = '';
                            } else {
                              Navigator.pop(context, false);
                              searchNameInfield = '';
                            }
                          },
                          constraints: BoxConstraints(),
                          padding: EdgeInsets.zero,
                          icon: Icon(
                            Icons.arrow_back_ios_new,
                            color: ColorSystem.black,
                          )),
                      SizedBox(
                        width: SizeSystem.size20,
                      ),
                      Expanded(
                        child: TextFormField(
                          controller: _searchController,
                          autofocus: false,
                          cursorColor: Theme.of(context).primaryColor,
                          style: TextStyle(
                              fontSize: 22,
                              color: Color(0xFF222222),
                              fontFamily: kRubik),
                          onChanged: (name) {
                            EasyDebounce.cancelAll();
                            EasyDebounce.debounce(
                                'search_name_debounce', Duration(seconds: 1),
                                () {
                              inventorySearchBloc.add(InventorySearchFetch(
                                  name: name,
                                  productsInCart: state.productsInCart,
                                  choice: state.selectedChoice,
                                  searchDetailModel: state.searchDetailModel,
                                  isFavouriteScreen: false,
                                  favoriteItems:
                                      fbdm.FavoriteBrandDetailModel(),
                                  isOfferScreen: false));
                            });
                            searchNameInfield = name;
                          },
                          decoration: InputDecoration(
                            constraints: BoxConstraints(),
                            contentPadding: EdgeInsets.symmetric(
                                horizontal: 5, vertical: 2),
                            hintText: 'Search Name',
                            hintStyle: TextStyle(
                              color: ColorSystem.secondary,
                              fontSize: SizeSystem.size20,
                            ),
                            focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(
                                color: Theme.of(context).primaryColor,
                                width: 1,
                              ),
                            ),
/*                            suffixIcon: IconButton(
                                onPressed: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              ScannerView())).then((value) {
                                    if (value != null) {
                                      setState(() {
                                        _searchController.text = value;
                                      });
                                      EasyDebounce.cancelAll();
                                      EasyDebounce.debounce(
                                          'search_name_debounce',
                                          Duration(seconds: 1), () {
                                        inventorySearchBloc.add(
                                            InventorySearchFetch(
                                                name: value,
                                                productsInCart:
                                                    state.productsInCart,
                                                choice: state.selectedChoice,
                                                searchDetailModel:
                                                    state.searchDetailModel,
                                                isFavouriteScreen: false,
                                                favoriteItems: fbdm
                                                    .FavoriteBrandDetailModel(),
                                                isOfferScreen: false));
                                      });
                                      searchNameInfield = value;
                                    }
                                  });
                                },
                                icon: Icon(
                                  Icons.qr_code_scanner_outlined,
                                  color: ColorSystem.primary,
                                )),*/
                          ),
                        ),
                      )
                    ],
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      InkWell(
                        onTap: () {
                          inventorySearchBloc.add(
                            OnClearFilters(
                              searchDetailModel: state.searchDetailModel,
                              buildOnTap: true,
                              isSearchName: _searchController.text.isNotEmpty
                                  ? true
                                  : false,
                              searchName: _searchController.text.isEmpty
                                  ? ""
                                  : _searchController.text,
                              sortBy: !state.sortName.contains(sortByText)
                                  ? true
                                  : false,
                              isFavouriteScreen: false,
                              brandName: '',
                              primaryInstrument: '',
                              brandItems: [],
                              favouriteBrandScreenBloc:
                                  fbsb.FavouriteBrandScreenBloc(
                                favouriteBrandScreenRepository:
                                    FavouriteBrandScreenRepository(),
                              ),
                              favoriteItems: fbdm.FavoriteBrandDetailModel(),
                              productsInCart: state.productsInCart,
                            ),
                          );
                          state.searchDetailModel.first
                                      .lengthOfSelectedFilters >
                                  0
                              ? showMessage(
                                  context: context,
                                  message: 'Filters has been cleared')
                              : null;
                        },
                        child: Text(
                          "Clear Filter",
                          style: TextStyle(
                              fontSize: SizeSystem.size16,
                              fontWeight: FontWeight.w500,
                              color: Colors.blue,
                              fontFamily: kRubik),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        height: AppBar().preferredSize.height,
                        child: Center(
                          child: Row(
                            children: [
                              Expanded(
                                flex: 5,
                                child: InkWell(
                                  onTap: () {
                                    if (state.showDiscount) {
                                      inventorySearchBloc.add(
                                          ChangeShowDiscount(
                                              showDiscount: false));
                                    } else {
                                      inventorySearchBloc.add(
                                          ChangeShowDiscount(
                                              showDiscount: true));
                                    }
                                  },
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Container(
                                          margin: EdgeInsets.only(
                                              right: 20, left: 5),
                                          child: RotationTransition(
                                            turns: state.showDiscount
                                                ? AlwaysStoppedAnimation(
                                                    90 / 360)
                                                : AlwaysStoppedAnimation(
                                                    0 / 360),
                                            child: Icon(
                                              Icons.keyboard_arrow_down_sharp,
                                              color: Colors.black87,
                                            ),
                                          )),
                                      Flexible(
                                        child: Text(
                                          state.sortName,
                                          style: TextStyle(
                                              fontSize: SizeSystem.size18,
                                              fontWeight: FontWeight.w500,
                                              color: state.sortName
                                                      .contains(sortByText)
                                                  ? Colors.black87
                                                  : Colors.red,
                                              fontFamily: kRubik),
                                        ),
                                      ),
                                      SizedBox(width: 20),
                                    ],
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 3,
                                child: Flex(
                                  direction: Axis.horizontal,
                                  children: [
                                    Expanded(
                                      flex: 1,
                                      child: Row(
                                        children: [
                                          Container(
                                            color: Colors.grey.shade300,
                                            width: 1,
                                          ),
                                          Expanded(
                                            child: Center(
                                              child: Stack(
                                                children: [
                                                  IconButton(
                                                    onPressed: () {
                                                      Navigator.of(context)
                                                          .push(
                                                        MaterialPageRoute(
                                                          builder: (context) =>
                                                              BlocProvider
                                                                  .value(
                                                            value:
                                                                inventorySearchBloc,
                                                            child:
                                                                FilterScreen(),
                                                          ),
                                                        ),
                                                      )
                                                          .then((value) {
                                                        if (value) {
                                                          inventorySearchBloc
                                                              .add(
                                                            SearchProductWithFilters(
                                                              searchDetailModel:
                                                                  state
                                                                      .searchDetailModel,
                                                              productsInCart: state
                                                                  .productsInCart,
                                                              filteredListOfRefinements: state
                                                                  .searchDetailModel
                                                                  .first
                                                                  .filteredListOfRefinments!,
                                                              searchNameInfield,
                                                              choice: state
                                                                  .selectedChoice,
                                                              isFavouriteScreen:
                                                                  false,
                                                              favoriteItems:
                                                                  null,
                                                              brandName: '',
                                                              brandItems: [],
                                                              primaryInstrument:
                                                                  '',
                                                              isOfferScreen:
                                                                  false,
                                                            ),
                                                          );
                                                        }
                                                      });
                                                    },
                                                    icon: SvgPicture.asset(
                                                      IconSystem.filterIcon,
                                                      package:
                                                          'gc_customer_app',
                                                    ),
                                                  ),
                                                  Positioned(
                                                    right: 0,
                                                    top: -5,
                                                    child: Card(
                                                      elevation: 2,
                                                      color: Colors.red,
                                                      shadowColor:
                                                          Colors.red.shade100,
                                                      shape: CircleBorder(),
                                                      child: state
                                                                  .searchDetailModel
                                                                  .first
                                                                  .lengthOfSelectedFilters >
                                                              0
                                                          ? Padding(
                                                              padding:
                                                                  EdgeInsets
                                                                      .all(5),
                                                              child: Text(
                                                                state.searchDetailModel.first
                                                                            .lengthOfSelectedFilters >
                                                                        0
                                                                    ? state
                                                                        .searchDetailModel
                                                                        .first
                                                                        .lengthOfSelectedFilters
                                                                        .toString()
                                                                    : '',
                                                                style: TextStyle(
                                                                    fontSize:
                                                                        SizeSystem
                                                                            .size13,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w500,
                                                                    color: Colors
                                                                        .white,
                                                                    fontFamily:
                                                                        kRubik),
                                                              ),
                                                            )
                                                          : Container(),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Expanded(
                                      flex: 1,
                                      child: Row(
                                        children: [
                                          Container(
                                            color: Colors.grey.shade300,
                                            width: 1,
                                          ),
                                          Expanded(
                                            child: Center(
                                              child: IconButton(
                                                  onPressed:
                                                      state.viewType == "List"
                                                          ? () {
                                                              inventorySearchBloc.add(
                                                                  ChangeViewType(
                                                                      view:
                                                                          "Grid"));
                                                            }
                                                          : () {
                                                              inventorySearchBloc.add(
                                                                  ChangeViewType(
                                                                      view:
                                                                          "List"));
                                                            },
                                                  icon: state.viewType == "List"
                                                      ? SvgPicture.asset(
                                                          IconSystem.grid3,
                                                          package:
                                                              'gc_customer_app',
                                                        )
                                                      : SvgPicture.asset(
                                                          IconSystem
                                                              .inventory_lookup,
                                                          package:
                                                              'gc_customer_app',
                                                        )),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                      Divider(
                        height: 1,
                        color: Colors.grey.shade300,
                      )
                    ],
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  state.showDiscount
                      ? Expanded(
                          child: ListView.builder(
                          itemCount: state.options.length,
                          itemBuilder: (context, i) {
                            return Column(
                              children: [
                                ListTile(
                                  onTap: () {
                                    inventorySearchBloc.add(
                                        ChangeSelectedChoice(
                                            choice: state.options[i].title,
                                            searchText: searchNameInfield,
                                            searchDetailModel:
                                                state.searchDetailModel,
                                            productsInCart:
                                                state.productsInCart,
                                            indexOfItem: i,
                                            isFavouriteScreen: false,
                                            favoriteItems:
                                                fbdm.FavoriteBrandDetailModel(),
                                            isOfferScreen: false));
                                  },
                                  contentPadding:
                                      EdgeInsets.symmetric(vertical: 2),
                                  title: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Padding(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 50.0),
                                        child: Text(
                                          state.options[i].title,
                                          style: TextStyle(
                                            color: state.selectedChoice ==
                                                    state.options[i].title
                                                ? Colors.red
                                                : Theme.of(context)
                                                    .primaryColor,
                                            fontWeight: FontWeight.w500,
                                            fontFamily: kRubik,
                                            fontSize: SizeSystem.size18,
                                          ),
                                        ),
                                      ),
                                      state.selectedChoice ==
                                              state.options[i].title
                                          ? Icon(
                                              Icons.check,
                                              color: Colors.red,
                                              size: 35,
                                            )
                                          : Container()
                                    ],
                                  ),
                                ),
                                Divider(
                                  color: ColorSystem.greyDark,
                                )
                              ],
                            );
                          },
                        ))
                      : state.loadingSearch
                          ? Expanded(
                              child: Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    CircularProgressIndicator(
                                      color: Theme.of(context).primaryColor,
                                    )
                                  ],
                                ),
                              ),
                            )
                          : (state.searchDetailModel.isNotEmpty &&
                                  state.searchDetailModel[0].wrapperinstance !=
                                      null &&
                                  state.searchDetailModel[0].wrapperinstance!
                                          .records !=
                                      null &&
                                  state.searchDetailModel[0].wrapperinstance!
                                      .records!.isNotEmpty)
                              ? Expanded(
                                  child: EasyRefresh.builder(
                                    controller: _controller,
                                    footer: BezierFooter(
                                        backgroundColor:
                                            Theme.of(context).primaryColor,
                                        //                  infiniteOffset: state.currentPage*20,
                                        foregroundColor: Colors.white),
                                    header: BezierHeader(
                                        backgroundColor:
                                            Theme.of(context).primaryColor,
                                        foregroundColor: Colors.white),
                                    onRefresh: null,
                                    noMoreRefresh:
                                        state.haveMore ? false : true,
                                    noMoreLoad: state.haveMore
                                        ? false
                                        : true &&
                                            state
                                                    .searchDetailModel
                                                    .first
                                                    .wrapperinstance!
                                                    .navContent!
                                                    .totalERecsNum! >
                                                30,
                                    onLoad: state.haveMore &&
                                            state
                                                    .searchDetailModel
                                                    .first
                                                    .wrapperinstance!
                                                    .navContent!
                                                    .totalERecsNum! >
                                                30
                                        ? () async {
                                            inventorySearchBloc.add(
                                                FetchInventoryPaginationData(
                                                    choice:
                                                        state.selectedChoice,
                                                    currentPage:
                                                        state.currentPage + 1,
                                                    searchDetailModel:
                                                        state.searchDetailModel,
                                                    searchName:
                                                        searchNameInfield));
                                          }
                                        : null,
                                    childBuilder: (BuildContext context,
                                        ScrollPhysics physics) {
                                      if (state.searchDetailModel.first
                                                  .wrapperinstance!.records ==
                                              null ||
                                          state
                                              .searchDetailModel
                                              .first
                                              .wrapperinstance!
                                              .records!
                                              .isEmpty) {
                                        return Container(
                                          width: double.infinity,
                                          padding: EdgeInsets.all(10),
                                          height: size.height * 0.7,
                                          child: Center(
                                              child: NoDataFound(fontSize: 16)),
                                        );
                                      } else {
                                        if (!state.paginationFetching!) {
                                          Future.delayed(Duration.zero, () {
                                            if (state
                                                    .searchDetailModel
                                                    .first
                                                    .wrapperinstance!
                                                    .records!
                                                    .isNotEmpty &&
                                                state.fetchInventoryData!) {
                                              if (mounted) {
                                                _controller.finishLoad();
                                              }
                                            }
                                          });
                                        }
                                        return DynamicHeightGridView(
                                          // itemCount: !state
                                          //     .paginationFetching! &&
                                          //     (state.haveMore &&
                                          //         state.searchDetailModel.first
                                          //             .wrapperinstance!
                                          //             .navContent!
                                          //             .totalERecsNum! > 30)
                                          //     ? state.searchDetailModel.first
                                          //     .wrapperinstance!.records!
                                          //     .length + 1
                                          //     : state.searchDetailModel.first
                                          //     .wrapperinstance!.records!.length,
                                          itemCount: state
                                              .searchDetailModel
                                              .first
                                              .wrapperinstance!
                                              .records!
                                              .length,
                                          physics: physics,
                                          crossAxisSpacing: 10,
                                          crossAxisCount:
                                              state.viewType == "Grid" ? 2 : 1,
                                          mainAxisSpacing:
                                              state.viewType == "Grid" ? 10 : 0,
                                          builder: (ctx, index) {
                                            if (index ==
                                                state
                                                    .searchDetailModel
                                                    .first
                                                    .wrapperinstance!
                                                    .records!
                                                    .length) {
                                              return Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Padding(
                                                    padding:
                                                        EdgeInsets.all(15.0),
                                                    child: Row(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .center,
                                                      mainAxisSize:
                                                          MainAxisSize.min,
                                                      children: [
                                                        Icon(
                                                          Icons
                                                              .arrow_upward_outlined,
                                                          color: Colors.grey,
                                                        ),
                                                        SizedBox(
                                                          width: 15,
                                                        ),
                                                        Text(
                                                          "Pull up to load more",
                                                          style: TextStyle(
                                                              color:
                                                                  Colors.grey),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              );
                                            } else {
                                              if (state.viewType == "Grid") {
                                                return Padding(
                                                  padding: EdgeInsets.only(
                                                      bottom: index ==
                                                              state
                                                                      .searchDetailModel
                                                                      .first
                                                                      .wrapperinstance!
                                                                      .records!
                                                                      .length -
                                                                  1
                                                          ? 10.0
                                                          : 0),
                                                  child: BlocProvider.value(
                                                      value:
                                                          inventorySearchBloc,
                                                      child: GridItem(
                                                          customerInfoModel:
                                                              widget.customer!,
                                                          index: index,
                                                          items: state
                                                              .searchDetailModel[
                                                                  0]
                                                              .wrapperinstance!
                                                              .records![index])),
                                                );
                                              } else {
                                                return BlocProvider.value(
                                                  value: inventorySearchBloc,
                                                  child: ListItem(
                                                      customerInfoModel:
                                                          widget.customer!,
                                                      index: index,
                                                      items: state
                                                          .searchDetailModel
                                                          .first
                                                          .wrapperinstance!
                                                          .records![index]),
                                                );
                                              }
                                            }
                                          },
                                        );
                                      }
                                    },
/*                                      child: Expanded(
                                        child: state.viewType == "Grid"?
                                        DynamicHeightGridView(
                                                itemCount: state.searchDetailModel[0].wrapperinstance!.records!.length,
                                                crossAxisCount: 2,
                                                crossAxisSpacing: 10,
                                                mainAxisSpacing: 10,
                                                builder: (ctx, index) {
                                                  return BlocProvider.value(
                                                      value: inventorySearchBloc,
                                                      child: GridItem(
                                                          customerInfoModel:
                                                              widget.customer!,
                                                          index: index,
                                                          items: state.searchDetailModel[0].wrapperinstance!.records![index]));
                                                },
                                              )
                                            : SingleChildScrollView(
                                              physics: physics,
                                              primary: true,
                                                child: Column(
                                                  children: [
                                                    BlocBuilder<InventorySearchBloc,InventorySearchState>(
                                                      builder: (context, state) {
                                                             if (state.searchDetailModel.first.wrapperinstance!.records == null || state.searchDetailModel.first.wrapperinstance!.records!.isEmpty) {
                                                              return Container(
                                                                width: double.infinity,
                                                                padding: EdgeInsets.all(10),
                                                                height: size.height * 0.2,
                                                                child: Center(child: NoDataFound(fontSize: 16)),
                                                              );
                                                            }
                                                            else{
                                                              Future.delayed( Duration.zero, () {
                                                                      if(state.searchDetailModel.first.wrapperinstance!.records!.isNotEmpty && state.fetchInventoryData!){
                                                                        if(mounted) {
                                                                            _controller.finishLoad();
                                                                        }}
                                                                    });
                                                                 return ListView.separated(
                                                            shrinkWrap: true,
                                                            primary: false,
                                                            physics:NeverScrollableScrollPhysics(),
                                                            itemCount: state.haveMore &&state.searchDetailModel.first.wrapperinstance!.navContent!.totalERecsNum!>30
                                                                ? state.searchDetailModel.first.wrapperinstance!.records!.length +1
                                                                : state.searchDetailModel.first.wrapperinstance!.records!.length,
                                                            separatorBuilder:
                                                                (context, index) {
                                                              if (index ==state.searchDetailModel.first.wrapperinstance!.records!.length ||index ==state.searchDetailModel.first.wrapperinstance!.records!.length -1) {
                                                                return SizedBox.shrink();
                                                                    }
                                                              return Container(
                                                                color: ColorSystem.secondary.withOpacity(0.3),
                                                                height: 0.5,
                                                                padding:
                                                                    EdgeInsets.only(left: 10,right: 20,
                                                                ),
                                                              );
                                                            },
                                                            itemBuilder:(context, index) {
                                                              if (index ==state.searchDetailModel.first.wrapperinstance!.records!.length) {
                                                                return Center(
                                                                    child: Padding(
                                                                  padding:
                                                                      EdgeInsets.all(15.0),
                                                                  child: Row(
                                                                    mainAxisSize:
                                                                        MainAxisSize
                                                                            .min,
                                                                    crossAxisAlignment:
                                                                        CrossAxisAlignment
                                                                            .center,
                                                                    children: [
                                                                      Icon(
                                                                        Icons.arrow_upward_outlined,
                                                                        color: Colors.grey,
                                                                      ),
                                                                      SizedBox(
                                                                        width: 15,
                                                                      ),
                                                                      Text(
                                                                        "Pull up to load more",
                                                                        style: TextStyle(color: Colors.grey),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ));
                                                              }
                                                              return ListItem(
                                                                  customerInfoModel:widget.customer!,
                                                                  items: state.searchDetailModel.first.wrapperinstance!.records![index]);
                                                            });

                                                            }

                                                      },
                                                    )
                                                  ],
                                                ),
                                              )),*/
                                  ),
                                )
                              : Expanded(
                                  child: Center(
                                    child: SingleChildScrollView(
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
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
                                              color: Theme.of(context)
                                                  .primaryColor,
                                              fontWeight: FontWeight.bold,
                                              fontFamily: kRubik,
                                              fontSize: SizeSystem.size20,
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                                )
                ],
              ),
            ),
            bottomNavigationBar: AppBottomNavBar(
                widget.customer,
                null,
                null,
                inventorySearchBloc,
                productDetailBloc,
                zipStoreListBloc,
                true));
      } else if (state.inventorySearchStatus ==
          InventorySearchStatus.failedState) {
        return Scaffold(
          body: InkWell(
            onTap: () {
              Navigator.pop(context);
            },
            child: Container(
              color: Colors.white,
              child: Center(
                  child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
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
              )),
            ),
          ),
        );
      } else {
        return Scaffold(
          body: InkWell(
            onTap: () {
              Navigator.pop(context);
            },
            child: Container(
              color: Colors.white,
              child: Center(
                  child: CircularProgressIndicator(
                color: Theme.of(context).primaryColor,
              )),
            ),
          ),
        );
      }
    });
  }

  openProductDetail(
      {required String customerID,
      required cm.CustomerInfoModel? customer,
      required String? orderID,
      required String? orderLineItemId,
      required List<Records> productsInCart,
      required Records records}) {
    print("records.warranties!.id ${records.warranties!.id}");
    Navigator.push(
            context,
            cuper.CupertinoPageRoute<List<Records>>(
                builder: (context) => ProductDetailPage(
                      customerID: widget.customerID,
                      warranties: records.warranties ?? Warranties(),
                      warrantyId: records.warranties != null
                          ? records.warranties!.id
                          : "",
                      customer: customer,
                      highPrice: records.highPrice,
                      fromInventory: true,
                      orderLineItemId: orderLineItemId,
                      orderId: orderID,
                      productsInCart: productsInCart,
                      skUID: records.childskus!.first.skuENTId ?? "",
                    ),
                settings: RouteSettings(name: "/detail_page")))
        .then((value) {
      if (value != null && value.isNotEmpty) {
        setState(() {
          // inventorySearchBloc.add(UpdateBottomCart(items: value));
        });
      }
    });
  }

  void doNothing(BuildContext context) {}
}
