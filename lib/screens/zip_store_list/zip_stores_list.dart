import 'dart:async';
import 'dart:math';

import 'package:easy_debounce/easy_debounce.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gc_customer_app/app.dart';
import 'package:gc_customer_app/bloc/inventory_search_bloc/inventory_search_bloc.dart'
    as isb;
import 'package:gc_customer_app/bloc/product_detail_bloc/product_detail_bloc.dart'
    as pdb;
import 'package:gc_customer_app/bloc/zip_store_list_bloc/zip_store_list_bloc.dart';
import 'package:gc_customer_app/models/cart_model/tax_model.dart';
import 'package:gc_customer_app/models/landing_screen/customer_info_model.dart';
import 'package:gc_customer_app/models/product_detail_model/get_zip_code_list.dart';
import 'package:gc_customer_app/primitives/color_system.dart';
import 'package:gc_customer_app/primitives/constants.dart';
import 'package:gc_customer_app/primitives/icon_system.dart';

import 'package:gc_customer_app/models/common_models/records_class_model.dart'
    as asm;
import 'package:gc_customer_app/screens/google_map/get_address_from_map.dart';
import 'package:gc_customer_app/utils/get_user_location.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:label_marker/label_marker.dart';

import 'package:permission_handler/permission_handler.dart';

class ZipStoresList extends StatefulWidget {
  final String customerID;
  final CustomerInfoModel? customer;
  final String? orderID;
  final String? orderLineItemId;
  List<GetZipCodeList> getZipCodeListSearch;
  List<GetZipCodeList> getZipCodeList;
  final List<asm.Records> productsInCart;
  final asm.Records records;
  Items? cartItemInfor;

  ZipStoresList(
      {Key? key,
      required this.orderLineItemId,
      required this.getZipCodeList,
      required this.records,
      required this.getZipCodeListSearch,
      required this.orderID,
      required this.customerID,
      this.customer,
      required this.productsInCart,
      this.cartItemInfor})
      : super(key: key);

  @override
  State<ZipStoresList> createState() => _ZipStoresListState();
}

class _ZipStoresListState extends State<ZipStoresList> {
  late BuildContext draggableSheetContext;
  late ZipStoreListBloc zipStoreListBloc;
  ScrollController scrollController = ScrollController();
  late isb.InventorySearchBloc inventorySearchBloc;
  late pdb.ProductDetailBloc productDetailBloc;
  final StreamController<String?> selectedReasonSC =
      StreamController<String?>.broadcast();
  final StreamController<OtherNodeData> selectedNodeSC =
      StreamController<OtherNodeData>.broadcast();
  OtherNodeData? selectedNodeValue;

  @override
  void initState() {
    super.initState();
    // FirebaseAnalytics.instance.setCurrentScreen(screenName: 'ZipStoreScreen');
    zipStoreListBloc = context.read<ZipStoreListBloc>();
    inventorySearchBloc = context.read<isb.InventorySearchBloc>();
    productDetailBloc = context.read<pdb.ProductDetailBloc>();

    scrollController.addListener(scrollListener);
    zipStoreListBloc.add(PageLoad(
        getZipCodeListSearch: widget.getZipCodeListSearch,
        getZipCodeList: widget.getZipCodeList,
        productsInCart: widget.productsInCart,
        records: widget.records));
    print(widget.cartItemInfor?.toJson());
    print(widget.cartItemInfor?.sourcingReason);
    if ((widget.cartItemInfor?.sourcingReason ?? '').isNotEmpty &&
        widget.cartItemInfor!.reservationLocation != 'NA') {
      selectedReasonSC.add(widget.cartItemInfor!.sourcingReason);
      print(widget.cartItemInfor!.reservationLocation);
      var selectedStore = widget.getZipCodeList[0].otherNodeData!.firstWhere(
          (ond) => ond.nodeID == widget.cartItemInfor!.reservationLocation);
      selectedNodeValue = selectedStore;
      selectedStore.selectedReason = widget.cartItemInfor!.sourcingReason;
      selectedNodeValue!.selectedReason = widget.cartItemInfor!.sourcingReason;
      selectedNodeSC.add(selectedNodeValue!);
    }
  }

  @override
  void dispose() {
    selectedReasonSC.close();
    selectedNodeSC.close();
    scrollController.removeListener(scrollListener);
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ZipStoreListBloc, ZipStoreListState>(
        builder: (context, state) {
      if (state.zipStoreListStatus == ZipStoreListStatus.successState) {
        return Scaffold(
          body: (state.getZipCodeList.isNotEmpty &&
                  state.getZipCodeList[0].otherNodeData!.isNotEmpty)
              ? StreamBuilder<OtherNodeData?>(
                  stream: selectedNodeSC.stream,
                  initialData: selectedNodeValue,
                  builder: (context, snapshot) {
                    var selectedOtherNode = snapshot.data;
                    return Stack(
                      children: [
                        SizedBox(
                          height: MediaQuery.of(context).size.height,
                          child: Column(
                            children: [
                              SafeArea(
                                child: Container(
                                  color: Colors.white,
                                  child: Padding(
                                    padding: EdgeInsets.only(
                                      // right: 30,
                                      left: 10,
                                    ),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        IconButton(
                                          icon: Icon(Icons.arrow_back),
                                          iconSize: 28,
                                          constraints: BoxConstraints(),
                                          padding: EdgeInsets.only(top: 15),
                                          color: ColorSystem.greyDark,
                                          onPressed: () {
                                            Navigator.pop(
                                                context, state.productsInCart);
                                          },
                                        ),
                                        SizedBox(width: 20),
                                        Expanded(
                                          child: TextFormField(
                                            autofocus: false,
                                            cursorColor:
                                                Theme.of(context).primaryColor,
                                            style: TextStyle(
                                                fontSize: 24,
                                                overflow: TextOverflow.ellipsis,
                                                fontWeight: FontWeight.w400,
                                                color: Theme.of(context)
                                                    .primaryColor,
                                                fontFamily: kRubik),
                                            onChanged: (name) {
                                              zipStoreListBloc.add(
                                                  SetZipCode(zipCode: name));

                                              if (name.isEmpty) {
                                                zipStoreListBloc
                                                    .add(ClearOtherNodeData());
                                              } else {
                                                // zipStoreListBloc.add(SetOffset(offset: 0));

                                                EasyDebounce.cancelAll();
                                                EasyDebounce.debounce(
                                                    'search_name_debounce',
                                                    Duration(seconds: 0), () {
                                                  //                                              zipStoreListBloc.add(ClearOtherNodeData());
                                                  zipStoreListBloc.add(
                                                      AddOtherNodeData(
                                                          name: name));
                                                  setState(() {});
                                                });
                                              }
                                            },
                                            decoration: InputDecoration(
                                              hintText: 'Search',
                                              hintStyle: TextStyle(
                                                color: ColorSystem.secondary,
                                                fontSize: 20,
                                              ),
                                              focusedBorder:
                                                  UnderlineInputBorder(
                                                borderSide: BorderSide(
                                                  color: Theme.of(context)
                                                      .primaryColor,
                                                  width: 1,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        InkWell(
                                          onTap: () => _showMapBottomSheet(
                                              context, state),
                                          child: Container(
                                              child: SvgPicture.asset(
                                            IconSystem.mapLable,
                                            package: 'gc_customer_app',
                                          )),
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: SingleChildScrollView(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: state.zipCode.isEmpty
                                              ? state.getZipCodeList[0]
                                                  .otherNodeData!
                                                  .map((e) {
                                                  bool isSelectedReason =
                                                      selectedOtherNode
                                                              ?.nodeID ==
                                                          e.nodeID;

                                                  return ListTile(
                                                    shape: Border(
                                                      top: BorderSide(
                                                        color: ColorSystem
                                                            .greyMild,
                                                      ),
                                                    ),
                                                    leading: Text("${e.nodeID}",
                                                        style: TextStyle(
                                                            fontSize: 20,
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                            fontWeight:
                                                                FontWeight.w500,
                                                            color: Theme.of(
                                                                    context)
                                                                .primaryColor,
                                                            fontFamily:
                                                                kRubik)),
                                                    title: Text("${e.nodeCity}",
                                                        maxLines: 2,
                                                        style: TextStyle(
                                                            fontSize: 20,
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                            fontWeight:
                                                                FontWeight.w400,
                                                            color: Theme.of(
                                                                    context)
                                                                .primaryColor,
                                                            fontFamily:
                                                                kRubik)),
                                                    trailing: Row(
                                                      mainAxisSize:
                                                          MainAxisSize.min,
                                                      children: [
                                                        if (isSelectedReason)
                                                          Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                        .only(
                                                                    right: 14),
                                                            child: Icon(
                                                                Icons.check,
                                                                color: ColorSystem
                                                                    .additionalGreen),
                                                          ),
                                                        Text(e.stockLevel!,
                                                            style: TextStyle(
                                                                fontSize: 20,
                                                                overflow:
                                                                    TextOverflow
                                                                        .ellipsis,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w400,
                                                                color: e.inventorySelection ==
                                                                        true
                                                                    ? ColorSystem
                                                                        .black
                                                                    : ColorSystem
                                                                        .greyDark,
                                                                fontFamily:
                                                                    kRubik)),
                                                      ],
                                                    ),
                                                    onTap: () {
                                                      print(
                                                          '----1 $isSelectedReason');
                                                      if (isSelectedReason) {
                                                        unSelectReason(e);
                                                      } else {
                                                        _onTapStoreItem(
                                                            state, e);
                                                      }
                                                    },
                                                  );
                                                }).toList()
                                              : state.getZipCodeListSearch[0]
                                                      .otherNodeData!.isEmpty
                                                  ? [
                                                      SizedBox(
                                                        height: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .height /
                                                            1.5,
                                                        child: Center(
                                                          child: Column(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .center,
                                                            children: [
                                                              SvgPicture.asset(
                                                                IconSystem
                                                                    .noDataFound,
                                                                package:
                                                                    'gc_customer_app',
                                                              ),
                                                              SizedBox(
                                                                height: 24,
                                                              ),
                                                              Text(
                                                                'NO DATA FOUND!',
                                                                style:
                                                                    TextStyle(
                                                                  color: ColorSystem
                                                                      .primary,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  fontFamily:
                                                                      kRubik,
                                                                  fontSize: 20,
                                                                ),
                                                              )
                                                            ],
                                                          ),
                                                        ),
                                                      )
                                                    ]
                                                  : state
                                                      .getZipCodeListSearch[0]
                                                      .otherNodeData!
                                                      .map((e) {
                                                      bool isSelectedReason =
                                                          selectedOtherNode
                                                                  ?.nodeID ==
                                                              e.nodeID;
                                                      return ListTile(
                                                        shape: Border(
                                                          top: BorderSide(
                                                            color: ColorSystem
                                                                .greyMild,
                                                          ),
                                                        ),
                                                        leading: Text(
                                                            "${e.nodeID}",
                                                            style: TextStyle(
                                                                fontSize: 20,
                                                                overflow:
                                                                    TextOverflow
                                                                        .ellipsis,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w500,
                                                                color:
                                                                    ColorSystem
                                                                        .primary,
                                                                fontFamily:
                                                                    kRubik)),
                                                        title: Text(
                                                            "${e.nodeCity}",
                                                            maxLines: 2,
                                                            style: TextStyle(
                                                                fontSize: 20,
                                                                overflow:
                                                                    TextOverflow
                                                                        .ellipsis,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w400,
                                                                color:
                                                                    ColorSystem
                                                                        .primary,
                                                                fontFamily:
                                                                    kRubik)),
                                                        trailing: Row(
                                                          mainAxisSize:
                                                              MainAxisSize.min,
                                                          children: [
                                                            if (isSelectedReason)
                                                              Padding(
                                                                padding:
                                                                    const EdgeInsets
                                                                            .only(
                                                                        right:
                                                                            14),
                                                                child: Icon(
                                                                    Icons.check,
                                                                    color: ColorSystem
                                                                        .additionalGreen),
                                                              ),
                                                            Text(e.stockLevel!,
                                                                style: TextStyle(
                                                                    fontSize:
                                                                        20,
                                                                    overflow:
                                                                        TextOverflow
                                                                            .ellipsis,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w400,
                                                                    color: e.inventorySelection ==
                                                                            true
                                                                        ? ColorSystem
                                                                            .black
                                                                        : ColorSystem
                                                                            .greyDark,
                                                                    fontFamily:
                                                                        kRubik)),
                                                          ],
                                                        ),
                                                        onTap: () {
                                                          if (isSelectedReason) {
                                                            unSelectReason(e);
                                                          } else {
                                                            _onTapStoreItem(
                                                                state, e);
                                                          }
                                                        },
                                                      );
                                                    }).toList()),
                                      SizedBox(
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .height *
                                              0.375)
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Align(
                          alignment: Alignment.bottomCenter,
                          child: DraggableScrollableActuator(
                            child: DraggableScrollableSheet(
                              key: Key(state.initialExtent.toString()),
                              minChildSize: 0.325 +
                                  (selectedOtherNode != null ? 0.07 : 0),
                              maxChildSize: 0.325 +
                                  (selectedOtherNode != null ? 0.07 : 0),
                              snap: true,
                              initialChildSize: 0.325 +
                                  (selectedOtherNode != null ? 0.07 : 0),
                              builder: (context, controller) {
                                return _draggableScrollableSheetBuilder(context,
                                    controller, state, selectedOtherNode);
                              },
                            ),
                          ),
                        ),
                      ],
                    );
                  })
              : SizedBox(
                  height: MediaQuery.of(context).size.height,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SvgPicture.asset(
                          IconSystem.noDataFound,
                          package: 'gc_customer_app',
                        ),
                        SizedBox(
                          height: 24,
                        ),
                        Text(
                          'NO DATA FOUND!',
                          style: TextStyle(
                            color: Theme.of(context).primaryColor,
                            fontWeight: FontWeight.bold,
                            fontFamily: kRubik,
                            fontSize: 20,
                          ),
                        )
                      ],
                    ),
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

  Widget _draggableScrollableSheetBuilder(
      BuildContext context,
      ScrollController scrollController,
      ZipStoreListState zipStoreListState,
      OtherNodeData? selectedOtherNode) {
    draggableSheetContext = context;

    return Material(
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(50),
        topRight: Radius.circular(50),
      ),
      elevation: 0,
      color: ColorSystem.greyMild,
      borderOnForeground: true,
      type: MaterialType.card,
      clipBehavior: Clip.hardEdge,
      child: SingleChildScrollView(
        controller: scrollController,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 30.0),
          child: Column(
            children: [
              SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(widget.records.productName!,
                        maxLines: 3,
                        style: TextStyle(
                            fontSize: 22,
                            overflow: TextOverflow.ellipsis,
                            fontWeight: FontWeight.w500,
                            color: Theme.of(context).primaryColor,
                            fontFamily: kRubik)),
                  ),
                ],
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Global:",
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w400,
                        color: Theme.of(context).primaryColor,
                        fontFamily: kRubik),
                  ),
                  Text(
                    "${zipStoreListState.getZipCodeList.first.mainNodeData!.where((element) => element.nodeName == "Global").isNotEmpty ? zipStoreListState.getZipCodeList.first.mainNodeData!.firstWhere((element) => element.nodeName == "Global").nodeStock : ""}",
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w400,
                        color: Theme.of(context).primaryColor,
                        fontFamily: kRubik),
                  ),
                ],
              ),
              SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "WCDC:",
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w400,
                        color: Theme.of(context).primaryColor,
                        fontFamily: kRubik),
                  ),
                  Text(
                    "${zipStoreListState.getZipCodeList.first.mainNodeData!.where((element) => element.nodeName == "WCDC").isNotEmpty ? zipStoreListState.getZipCodeList.first.mainNodeData!.firstWhere((element) => element.nodeName == "WCDC").nodeStock : ""}",
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w400,
                        color: Theme.of(context).primaryColor,
                        fontFamily: kRubik),
                  ),
                ],
              ),
              SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "KCDC:",
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w400,
                        color: Theme.of(context).primaryColor,
                        fontFamily: kRubik),
                  ),
                  Text(
                    "${zipStoreListState.getZipCodeList.first.mainNodeData!.where((element) => element.nodeName == "KCDC").isNotEmpty ? zipStoreListState.getZipCodeList.first.mainNodeData!.firstWhere((element) => element.nodeName == "KCDC").nodeStock : ""}",
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w400,
                        color: Theme.of(context).primaryColor,
                        fontFamily: kRubik),
                  ),
                ],
              ),
              SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Store:",
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w400,
                        color: Theme.of(context).primaryColor,
                        fontFamily: kRubik),
                  ),
                  Text(
                    "${zipStoreListState.getZipCodeList.first.mainNodeData!.where((element) => element.nodeName == "Store").isNotEmpty ? zipStoreListState.getZipCodeList.first.mainNodeData!.firstWhere((element) => element.nodeName == "Store").nodeStock : ""}",
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w400,
                        color: Theme.of(context).primaryColor,
                        fontFamily: kRubik),
                  ),
                ],
              ),
              if (selectedOtherNode != null && selectedOtherNode.nodeID != null)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Text(
                        'Selected Sourcing Node',
                        style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            fontFamily: kRubik),
                      ),
                    ),
                    Row(
                      children: [
                        Row(
                          children: [
                            Text(
                              "${selectedOtherNode.nodeID}",
                              style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w400,
                                  color: Theme.of(context).primaryColor,
                                  fontFamily: kRubik),
                            ),
                            SizedBox(width: 12),
                            Text(
                              "${selectedOtherNode.nodeCity}",
                              style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w400,
                                  color: Theme.of(context).primaryColor,
                                  fontFamily: kRubik),
                            ),
                          ],
                        ),
                        Spacer(),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(right: 14),
                              child: Icon(Icons.check,
                                  color: ColorSystem.additionalGreen),
                            ),
                            Text(selectedOtherNode.stockLevel!,
                                style: TextStyle(
                                    fontSize: 20,
                                    overflow: TextOverflow.ellipsis,
                                    fontWeight: FontWeight.w400,
                                    color: ColorSystem.primary,
                                    fontFamily: kRubik)),
                          ],
                        ),
                      ],
                    )
                  ],
                ),
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  void scrollListener() {
//     var maxExtent = scrollController.position.maxScrollExtent;
//     var loadingPosition = maxExtent - (maxExtent * 0.4);
//     if (scrollController.position.extentAfter < loadingPosition &&
//         !isLoadingData) {
//       offset = offset + 10;
//       setState(() {
// //        futureCustomers = getCustomer(offset);
//       });
//     }
  }

  _showMapBottomSheet(BuildContext context, ZipStoreListState state) async {
    if ((state.getZipCodeList.first.otherStores ?? []).isNotEmpty) {
      Set<Marker> markers = {};
      // Permission.location.isRestricted
      var currentLocation = await getUserLocation(context);
      if (currentLocation?.latitude == 0) return;
      if (currentLocation != null)
        markers.addLabelMarker(LabelMarker(
            label: 'You are here',
            backgroundColor: Colors.blue[900]!,
            textStyle: TextStyle(fontSize: 32),
            markerId: MarkerId('userLocation'),
            icon:
                BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
            position:
                LatLng(currentLocation.latitude, currentLocation.longitude)));
      for (int i = 0; i < state.getZipCodeList.first.otherStores!.length; i++) {
        var otherStore = state.getZipCodeList.first.otherStores![i];
        var stockLevel = state.getZipCodeList.first.otherNodeData
            ?.firstWhere((e) => e.nodeID == otherStore.storeC)
            .stockLevel;
        var distance = currentLocation == null
            ? 0
            : calculateDistance(
                currentLocation.latitude,
                currentLocation.longitude,
                double.parse(otherStore.latitudeC ?? '0'),
                double.parse(otherStore.longitudeC ?? '0'));

        //Check if store location is same as device location. If they are the same, move store tag forward
        bool isSameLocation =
            double.parse(otherStore.latitudeC ?? '0').toStringAsFixed(4) ==
                    currentLocation?.latitude.toStringAsFixed(4) &&
                double.parse(otherStore.longitudeC ?? '0').toStringAsFixed(4) ==
                    currentLocation?.longitude.toStringAsFixed(4);
        if (otherStore.latitudeC != null &&
            otherStore.longitudeC != null &&
            isSameLocation) {
          otherStore.latitudeC =
              (double.parse(otherStore.latitudeC!) - 0.001).toString();
        }

        if (distance <= 200)
          markers.addLabelMarker(LabelMarker(
              label: stockLevel ?? '0',
              textStyle: TextStyle(fontSize: 32),
              backgroundColor:
                  (stockLevel ?? '0') == '0' ? Colors.red : Colors.green,
              markerId: MarkerId(otherStore.id!),
              infoWindow: InfoWindow(
                title: '${otherStore.storeDescriptionC} - ${stockLevel ?? '0'}',
                snippet:
                    '${currentLocation == null ? '' : 'From your location: ${distance.toStringAsFixed(2)} miles\n'}' +
                        '📍: ${otherStore.storeAddressC!}' +
                        ", " +
                        otherStore.storeCityC! +
                        ", " +
                        otherStore.stateC! +
                        ', ${otherStore.postalCodeC}' +
                        '\n📞: ${otherStore.phoneC}',
              ),
              icon: BitmapDescriptor.defaultMarkerWithHue(
                  BitmapDescriptor.hueGreen),
              position: LatLng(double.parse(otherStore.latitudeC!),
                  double.parse(otherStore.longitudeC!))));
      }

      Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => GetAddressFromMap(
              latitude: currentLocation?.latitude.toString(),
              longitude: currentLocation?.longitude.toString(),
              markers: markers,
              zoom: 7,
              radius: double.parse('200'),
              isFullScreen: true,
            ),
          ));
    } else {
      showMessage(context: context, message: "No Addresses Found");
    }
  }

  double calculateDistance(lat1, lon1, lat2, lon2) {
    var p = 0.017453292519943295;
    var c = cos;
    var a = 0.5 -
        c((lat2 - lat1) * p) / 2 +
        c(lat1 * p) * c(lat2 * p) * (1 - c((lon2 - lon1) * p)) / 2;
    return 12742 * asin(sqrt(a)) * 0.621371;
  }

  Future<void> _showSelectReasonDialog(
      List<String> sourcingReason, OtherNodeData otherNodeData) async {
    if (widget.orderID == null) return;
    if (otherNodeData.selectedReason != null) {
      selectedReasonSC.add(otherNodeData.selectedReason);
    }
    var selectedReason = await showCupertinoDialog(
      barrierDismissible: true,
      context: context,
      builder: (BuildContext dialogContext) {
        return StreamBuilder<String?>(
            stream: selectedReasonSC.stream,
            initialData: otherNodeData.selectedReason,
            builder: (context, snapshot) {
              var selectedReason = snapshot.data;
              return CupertinoAlertDialog(
                title: Text(
                  "Selected Sourcing Node\n${otherNodeData.nodeID}",
                  style: TextStyle(
                      color: Colors.black87,
                      fontSize: 19,
                      fontWeight: FontWeight.bold),
                ),
                content: Material(
                  color: Colors.transparent,
                  child: Column(
                    children: [
                      SizedBox(height: 15),
                      // Divider(color: Colors.black54, height: 1),
                      // SizedBox(height: 10),
                      DropdownButtonFormField<String>(
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Please select reason";
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                            // labelText: 'Select Reason',
                            hintText: 'Reason',
                            alignLabelWithHint: true,
                            constraints: BoxConstraints(),
                            contentPadding: EdgeInsets.symmetric(
                                vertical: 0, horizontal: 0),
                            labelStyle: TextStyle(
                              color: ColorSystem.greyDark,
                              fontSize: 16,
                            ),
                            helperStyle: TextStyle(
                              color: ColorSystem.greyDark,
                              fontSize: 16,
                            ),
                            errorStyle: TextStyle(
                                color: ColorSystem.lavender3,
                                fontWeight: FontWeight.w400),
                            errorBorder: UnderlineInputBorder(
                              borderSide: BorderSide(
                                color: ColorSystem.lavender3,
                                width: 1,
                              ),
                            ),
                            focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(
                                color: ColorSystem.greyDark,
                                width: 1,
                              ),
                            )),
                        hint: Text(
                            (selectedReason ?? '').isEmpty
                                ? "Select Reason"
                                : selectedReason!,
                            style: TextStyle(
                                color: Theme.of(context).primaryColor)),
                        icon: Padding(
                          padding: EdgeInsets.only(right: 2.0),
                          child: Icon(Icons.expand_more_outlined,
                              color: Theme.of(context).primaryColor),
                        ),
                        isExpanded: true,
                        isDense: true,
                        items: sourcingReason.map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(
                              value,
                              style: TextStyle(
                                  color: Theme.of(context).primaryColor),
                            ),
                          );
                        }).toList(),
                        onChanged: (val) async {
                          selectedReasonSC.add(val);
                        },
                      ),
                    ],
                  ),
                ),
                actions: [
                  CupertinoDialogAction(
                    child: Text("OK"),
                    onPressed: () {
                      Navigator.of(dialogContext).pop(selectedReason);
                    },
                  ),
                  CupertinoDialogAction(
                    child: Text("CANCEL"),
                    onPressed: () {
                      Navigator.of(dialogContext).pop();
                    },
                  ),
                ],
              );
            });
      },
    );
    if (selectedReason != null) {
      productDetailBloc.selectInventoryReason(
          widget.orderLineItemId!,
          otherNodeData.nodeID ?? '',
          int.parse(otherNodeData.stockLevel ?? '1'),
          selectedReason);
      otherNodeData.selectedReason = selectedReason;
      selectedNodeSC.add(otherNodeData);
      if (widget.cartItemInfor != null) {
        widget.cartItemInfor!.reservationLocation = otherNodeData.nodeID;
        widget.cartItemInfor!.reservationLocationStock =
            otherNodeData.stockLevel;
        widget.cartItemInfor!.sourcingReason = selectedReason;
      }
    }
  }

  void _onTapStoreItem(ZipStoreListState state, OtherNodeData e) {
    int kcdcIndex = state.getZipCodeList.first.mainNodeData
            ?.indexWhere((mnd) => mnd.nodeName == 'KCDC') ??
        -1;
    if (e.inventorySelection == true &&
        kcdcIndex >= 0 &&
        state.getZipCodeList.first.mainNodeData![kcdcIndex].nodeStock == '0') {
      _showSelectReasonDialog(
          state.getZipCodeList.first.sourcingReason ?? [], e);
    }
  }

  void unSelectReason(OtherNodeData otherNodeData) {
    productDetailBloc.selectInventoryReason(widget.orderLineItemId!, 'NA',
        int.parse(otherNodeData.stockLevel ?? '1'), '');
    otherNodeData.selectedReason = null;
    selectedNodeSC.add(OtherNodeData());
    if (widget.cartItemInfor != null) {
      widget.cartItemInfor!.reservationLocation = null;
      widget.cartItemInfor!.reservationLocationStock = otherNodeData.stockLevel;
      widget.cartItemInfor!.sourcingReason = null;
    }
  }
}
