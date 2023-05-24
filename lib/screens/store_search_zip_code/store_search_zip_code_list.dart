import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:easy_debounce/easy_debounce.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gc_customer_app/app.dart';
import 'package:gc_customer_app/screens/google_map/get_address_from_map.dart';
import 'package:gc_customer_app/screens/google_map/providers/place_provider.dart';
import 'package:gc_customer_app/utils/get_user_location.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';


import '../../bloc/store_search_zip_code_bloc/store_search_zip_code_bloc.dart';
import '../../models/store_search_zip_code_model/search_store_zip.dart';
import '../../primitives/color_system.dart';
import '../../primitives/constants.dart';
import '../../primitives/icon_system.dart';
import '../../primitives/size_system.dart';
import '../../services/networking/endpoints.dart';
import '../../services/networking/networking_service.dart';

class StoreSearchZipCodeList extends StatefulWidget {
  final String? orderID;

  StoreSearchZipCodeList({Key? key, required this.orderID}) : super(key: key);

  @override
  State<StoreSearchZipCodeList> createState() => _StoreSearchZipCodeListState();
}

class _StoreSearchZipCodeListState extends State<StoreSearchZipCodeList> {
  late Future<void> _futureSearchStoreZip5;
  late Future<void> _futureSearchStoreZip10;
  late Future<void> _futureSearchStoreZip25;
  late Future<void> _futureSearchStoreZip50;
  late Future<void> _futureSearchStoreZip100;
  late Future<void> _futureSearchStoreZip200;
  late Future<void> _futureSearchStoreZip500;
  late StoreSearchZipCodeBloc storeSearchZipCodeBloc;
  TextEditingController zipCodeTEC = TextEditingController();
  StreamSubscription? streamSubscription;
  ScrollController scrollController = ScrollController();
  final StreamController<bool> isLoadingController =
      StreamController<bool>.broadcast();

  @override
  void initState() {
    super.initState();
    // FirebaseAnalytics.instance
    //     .setCurrentScreen(screenName: 'SearchStoreShippingScreen');
    scrollController.addListener(scrollListener);
    storeSearchZipCodeBloc = context.read<StoreSearchZipCodeBloc>();
    storeSearchZipCodeBloc.add(PageLoad());
    _showMapDefault();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<StoreSearchZipCodeBloc, StoreSearchZipCodeState>(
        builder: (context, state) {
      return Scaffold(
        backgroundColor: ColorSystem.white,
        body: Stack(
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height,
              child: Column(
                children: [
                  SizedBox(
                    height: SizeSystem.size20,
                  ),
                  Container(
                    color: Colors.white,
                    child: Padding(
                      padding: EdgeInsets.only(
                        right: 40,
                        left: 20,
                        top: 20,
                        bottom: 20,
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          IconButton(
                            icon: Icon(Icons.arrow_back),
                            iconSize: 28,
                            constraints: BoxConstraints(),
                            padding: EdgeInsets.only(top: 15),
                            color: ColorSystem.greyDark,
                            onPressed: () {
                              Navigator.pop(context);
                            },
                          ),
                          SizedBox(
                            width: SizeSystem.size20,
                          ),
                          Expanded(
                            child: TextFormField(
                              autofocus: false,
                              controller: zipCodeTEC,
                              keyboardType: TextInputType.number,
                              inputFormatters: <TextInputFormatter>[
                                FilteringTextInputFormatter.allow(
                                    RegExp(r"[0-9.]")),
                                TextInputFormatter.withFunction(
                                    (oldValue, newValue) {
                                  try {
                                    final text = newValue.text;
                                    if (text.isNotEmpty) double.parse(text);
                                    return newValue;
                                  } catch (e) {}
                                  return oldValue;
                                }),
                              ],
                              cursorColor: Theme.of(context).primaryColor,
                              style: TextStyle(
                                  fontSize: SizeSystem.size26,
                                  overflow: TextOverflow.ellipsis,
                                  fontWeight: FontWeight.w500,
                                  color: Theme.of(context).primaryColor,
                                  fontFamily: kRubik),
                              onChanged: (name) {
                                storeSearchZipCodeBloc
                                    .add(SetOffset(offset: 0));
                                EasyDebounce.cancelAll();
                                if (name.length >= 3) {
                                  EasyDebounce.debounce('search_name_debounce',
                                      Duration(seconds: 1), () {
                                    storeSearchZipCodeBloc
                                        .add(SetZipCode(zipCode: name));
                                    storeSearchZipCodeBloc.add(GetAddress(
                                        radius: "5",
                                        name: name,
                                        orderId: widget.orderID!));
                                    storeSearchZipCodeBloc.add(GetAddress(
                                        radius: "10",
                                        name: name,
                                        orderId: widget.orderID!));
                                    storeSearchZipCodeBloc.add(GetAddress(
                                        radius: "25",
                                        name: name,
                                        orderId: widget.orderID!));
                                    storeSearchZipCodeBloc.add(GetAddress(
                                        radius: "50",
                                        name: name,
                                        orderId: widget.orderID!));
                                    storeSearchZipCodeBloc.add(GetAddress(
                                        radius: "100",
                                        name: name,
                                        orderId: widget.orderID!));
                                    storeSearchZipCodeBloc.add(GetAddress(
                                        radius: "200",
                                        name: name,
                                        orderId: widget.orderID!));
                                    // storeSearchZipCodeBloc.add(GetAddress(
                                    //     radius: "500",
                                    //     name: name,
                                    //     orderId: widget.orderID!));
                                  });
                                } else {
                                  EasyDebounce.debounce('search_name_debounce',
                                      Duration(seconds: 1), () {
                                    storeSearchZipCodeBloc
                                        .add(SetZipCode(zipCode: name));
                                  });
                                }
                              },
                              decoration: InputDecoration(
                                hintText: 'Enter Zip Code',
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
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          state.zipCode.length < 3
                              ? emptyTile("5")
                              : tile(state.searchStoreZip5, "5", state),
                          state.zipCode.length < 3
                              ? emptyTile("10")
                              : tile(state.searchStoreZip10, "10", state),
                          state.zipCode.length < 3
                              ? emptyTile("25")
                              : tile(state.searchStoreZip25, "25", state),
                          state.zipCode.length < 3
                              ? emptyTile("50")
                              : tile(state.searchStoreZip50, "50", state),
                          state.zipCode.length < 3
                              ? emptyTile("100")
                              : tile(state.searchStoreZip100, "100", state),
                          state.zipCode.length < 3
                              ? emptyTile("200")
                              : tile(state.searchStoreZip200, "200", state),
                          // state.zipCode.length < 3
                          //     ? emptyTile("500")
                          //     : tile(state.searchStoreZip500, "500", state),
                          // SizedBox(
                          //   height: widget.searchDetailModelQuantity.isNotEmpty?MediaQuery.of(context).size.height * 0.325:MediaQuery.of(context).size.height * 0.25,
                          // )
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            StreamBuilder(
              stream: isLoadingController.stream,
              initialData: true,
              builder: (_, snapshot) {
                if (snapshot.data == true)
                  return Center(child: CircularProgressIndicator());
                return SizedBox.shrink();
              },
            ),
          ],
        ),
      );
    });
  }

  Widget tile(
      SearchStoreModel? zipList, String radius, StoreSearchZipCodeState state) {
    return ListTile(
      shape: Border(
        top: BorderSide(color: ColorSystem.greyMild),
      ),
      dense: true,
      contentPadding: EdgeInsets.only(left: 0.0, right: 0.0),
      minVerticalPadding: 0,
      title: Theme(
        data: Theme.of(context).copyWith(
          dividerColor: Colors.transparent,
        ),
        child: ExpansionTile(
            onExpansionChanged: (isExpanded) {
              if (isExpanded && state.zipCode.isNotEmpty) {
                storeSearchZipCodeBloc.add(GetAddress(
                    radius: radius,
                    name: state.zipCode,
                    orderId: widget.orderID!));
              }
            },
            childrenPadding: EdgeInsets.zero,
            controlAffinity: ListTileControlAffinity.leading,
            iconColor: Theme.of(context).primaryColor,
            title: Text(
              '$radius miles',
              style: Theme.of(context).textTheme.headline6,
            ),
            trailing: InkWell(
              onTap: () async {
                if ((zipList?.searchStoreList ?? []).isNotEmpty &&
                    (zipList?.searchStoreListInformation ?? []).isNotEmpty) {
                  storeSearchZipCodeBloc.add(SetMarkers(
                    searchStoreListInformation:
                        zipList!.searchStoreListInformation ?? [],
                    searchStoreList: zipList.searchStoreList,
                    onTapMarker: (storeC) {
                      Navigator.pop(context, [
                        zipList.searchStoreList
                            ?.firstWhere((ssl) => ssl.id == storeC),
                        zipList.searchStoreListInformation!
                            .firstWhere((ei) => ei.storeC == storeC)
                      ]);
                    },
                  ));
                  storeSearchZipCodeBloc
                      .add(SetZoomLevel(radius: double.parse(radius)));
                  _showModalBottomSheet(zipList, radius).then((value) {
                    if (value != null) {
                      Navigator.pop(context, value);
                    }
                  });
                } else {
                  showMessage(context: context,message:"No Addresses Found");
                }
              },
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 1,
                    color: Colors.grey.shade300,
                  ),
                  SvgPicture.asset(
                    IconSystem.mapLable,
                    package: 'gc_customer_app',
                  )
                ],
              ),
            ),
            children: state.zipCode.length < 3
                ? []
                : [
                    state.storeSearchZipCodeStatus ==
                                StoreSearchZipCodeStatus.loadState &&
                            state.currentRadius == radius
                        ? SizedBox(
                            height: MediaQuery.of(context).size.height * 0.2,
                            child: Center(
                              child: CircularProgressIndicator(
                                color: Theme.of(context).primaryColor,
                              ),
                            ),
                          )
                        : (zipList?.searchStoreList ?? []).isNotEmpty
                            ? Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: zipList!.searchStoreList!.map((e) {
                                  return Padding(
                                    padding:
                                        EdgeInsets.only(right: 8.0, left: 50),
                                    child: ListTile(
                                      onTap: () {
                                        Navigator.pop(context, [
                                          e,
                                          zipList.searchStoreListInformation!
                                              .firstWhere(
                                                  (ei) => ei.storeC == e.id)
                                        ]);
                                      },
                                      shape: Border(
                                        top: BorderSide(
                                          color: ColorSystem.greyMild,
                                        ),
                                      ),
                                      // leading: Text("${e.id}",
                                      //     style:TextStyle(
                                      //         fontSize: SizeSystem.size20,
                                      //         overflow: TextOverflow.ellipsis,
                                      //         fontWeight: FontWeight.w500,
                                      //         color: Theme.of(context).primaryColor,
                                      //         fontFamily: kRubik)),
                                      title: Text("${e.name}",
                                          maxLines: 2,
                                          style: TextStyle(
                                              fontSize: SizeSystem.size20,
                                              overflow: TextOverflow.ellipsis,
                                              fontWeight: FontWeight.w400,
                                              color: Theme.of(context)
                                                  .primaryColor,
                                              fontFamily: kRubik)),

                                      subtitle: Padding(
                                        padding: EdgeInsets.only(top: 2.0),
                                        child: Row(
                                          children: [
                                            Text(e.postalCode ?? "",
                                                maxLines: 2,
                                                style: TextStyle(
                                                    fontSize: SizeSystem.size18,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    fontWeight: FontWeight.w400,
                                                    color: ColorSystem.greyDark,
                                                    fontFamily: kRubik)),
                                            e.avaibility != null &&
                                                    e.avaibility!.isNotEmpty
                                                ? Text(
                                                    " (" + e.avaibility! + ")",
                                                    maxLines: 2,
                                                    style: TextStyle(
                                                        fontSize:
                                                            SizeSystem.size18,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                        fontWeight:
                                                            FontWeight.w400,
                                                        color: e.avaibility ==
                                                                '0'
                                                            ? ColorSystem
                                                                .pureRed
                                                            : ColorSystem
                                                                .additionalGreen,
                                                        fontFamily: kRubik))
                                                : SizedBox.shrink(),
                                          ],
                                        ),
                                      ),
                                      trailing: Text(
                                          "${e.distance ?? "0.0"} mil",
                                          style: TextStyle(
                                              fontSize: SizeSystem.size20,
                                              overflow: TextOverflow.ellipsis,
                                              fontWeight: FontWeight.w400,
                                              color: ColorSystem.greyDark,
                                              fontFamily: kRubik)),
                                    ),
                                  );
                                }).toList())
                            : SizedBox(
                                height:
                                    MediaQuery.of(context).size.height * 0.35,
                                child: Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
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
                                  ),
                                ),
                              )
                  ] // Some list of List Tile's or widget of that kind,
            ),
      ),
    );
  }

  Widget emptyTile(String radius) {
    return ListTile(
      shape: Border(
        top: BorderSide(color: ColorSystem.greyMild),
      ),
      dense: true,
      contentPadding: EdgeInsets.only(left: 0.0, right: 0.0),
      minVerticalPadding: 0,
      title: Theme(
        data: Theme.of(context).copyWith(
          dividerColor: Colors.transparent,
        ),
        child: ExpansionTile(
            onExpansionChanged: (isExpanded) {},
            childrenPadding: EdgeInsets.zero,
            controlAffinity: ListTileControlAffinity.leading,
            iconColor: Theme.of(context).primaryColor,
            title: Text(
              '$radius miles',
              style: Theme.of(context).textTheme.headline6,
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 1,
                  color: Colors.grey.shade300,
                ),
                SvgPicture.asset(
                  IconSystem.mapLable,
                  package: 'gc_customer_app',
                )
              ],
            ),
            children: []),
      ),
    );
  }

  void scrollListener() {}
  Widget _closeButton() => InkWell(
        focusColor: Colors.transparent,
        highlightColor: Colors.transparent,
        hoverColor: Colors.transparent,
        splashColor: Colors.transparent,
        onTap: () {
          Navigator.of(context).pop();
        },
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: ColorSystem.white,
            shape: BoxShape.circle,
          ),
          padding: EdgeInsets.all(10),
          margin: EdgeInsets.only(bottom: 24),
          child: Icon(
            Icons.close,
            color: ColorSystem.black,
            size: 28,
          ),
        ),
      );
  @override
  void dispose() {
    streamSubscription?.cancel();
    scrollController.removeListener(scrollListener);
    scrollController.dispose();
    isLoadingController.close();
    super.dispose();
  }

  Future _showModalBottomSheet(SearchStoreModel zipList, String radius,
      [double? lat, double? long]) async {
    var userPosition = await getUserLocation(context);
    if (userPosition?.latitude == 0) return;
    return showModalBottomSheet(
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        context: context,
        builder: (BuildContext context) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _closeButton(),
              Container(
                height: MediaQuery.of(context).size.height * 0.75,
                clipBehavior: Clip.hardEdge,
                decoration: new BoxDecoration(
                  color: Colors.white,
                  borderRadius: new BorderRadius.only(
                    topLeft: Radius.circular(50.0),
                    topRight: Radius.circular(50.0),
                  ),
                ),
                child: StatefulBuilder(builder: (context, bottomState) {
                  return BlocProvider.value(
                    value: storeSearchZipCodeBloc,
                    child: BlocBuilder<StoreSearchZipCodeBloc,
                        StoreSearchZipCodeState>(builder: (context, cartState) {
                      return GetAddressFromMap(
                          latitude: userPosition?.latitude.toString() ??
                              (cartState.markers.isNotEmpty
                                  ? cartState.markers.first.position.latitude
                                      .toString()
                                  : null),
                          longitude: userPosition?.longitude.toString() ??
                              (cartState.markers.isNotEmpty
                                  ? cartState.markers.first.position.longitude
                                      .toString()
                                  : null),
                          markers: cartState.markers.toSet(),
                          zoom: cartState.zoomLevel,
                          showUserPosition: userPosition != null,
                          radius: double.parse(radius));
                    }),
                  );
                }),
              ),
            ],
          );
        }).then((value) {
      storeSearchZipCodeBloc.add(ClearMarkers());
      return value;
    });
  }

  Future<void> _showMapDefault() async {
    isLoadingController.add(true);
    var currentLocation = await getUserLocation(context);
    if (currentLocation == null || currentLocation.latitude == 0) {
      isLoadingController.add(false);
      return;
    }
    var placemarks = await placemarkFromCoordinates(
        currentLocation.latitude, currentLocation.longitude);

    var zipCode = placemarks.first.postalCode ?? '';
    zipCodeTEC.text = zipCode;
    storeSearchZipCodeBloc.add(SetZipCode(zipCode: zipCode));
    storeSearchZipCodeBloc
        .add(GetAddress(radius: "5", name: zipCode, orderId: widget.orderID!));
    storeSearchZipCodeBloc
        .add(GetAddress(radius: "10", name: zipCode, orderId: widget.orderID!));
    storeSearchZipCodeBloc
        .add(GetAddress(radius: "25", name: zipCode, orderId: widget.orderID!));
    storeSearchZipCodeBloc
        .add(GetAddress(radius: "50", name: zipCode, orderId: widget.orderID!));
    storeSearchZipCodeBloc.add(
        GetAddress(radius: "100", name: zipCode, orderId: widget.orderID!));
    storeSearchZipCodeBloc.add(
        GetAddress(radius: "200", name: zipCode, orderId: widget.orderID!));
    storeSearchZipCodeBloc.add(
        GetAddress(radius: "500", name: zipCode, orderId: widget.orderID!));
    bool isShowDefaultMap = false;
    streamSubscription = storeSearchZipCodeBloc.stream.listen((event) {
      if (event.searchStoreZip50 != null && !isShowDefaultMap) {
        isShowDefaultMap = true;
        isLoadingController.add(false);
        storeSearchZipCodeBloc.add(SetMarkers(
            searchStoreListInformation:
                event.searchStoreZip50?.searchStoreListInformation ?? [],
            searchStoreList: event.searchStoreZip50?.searchStoreList ?? [],
            onTapMarker: (storeC) {
              Navigator.pop(context, [
                event.searchStoreZip50?.searchStoreList
                    ?.firstWhere((ssl) => ssl.id == storeC),
                event.searchStoreZip50?.searchStoreListInformation!
                    .firstWhere((ei) => ei.storeC == storeC)
              ]);
            }));
        storeSearchZipCodeBloc.add(SetZoomLevel(radius: double.parse('50')));
        _showModalBottomSheet(event.searchStoreZip50!, '50',
                currentLocation.latitude, currentLocation.longitude)
            .then((value) {
          if (value != null) Navigator.pop(context, value);
        });
      }
    });
  }
}
