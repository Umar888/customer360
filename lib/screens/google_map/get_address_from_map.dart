import 'dart:async';
import 'dart:developer';
import 'dart:math';
import 'dart:ui' as ui;

import 'package:easy_debounce/easy_debounce.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gc_customer_app/bloc/product_detail_bloc/product_detail_bloc.dart';
import 'package:gc_customer_app/constants/text_strings.dart';
import 'package:gc_customer_app/models/cart_model/tax_model.dart';
import 'package:gc_customer_app/models/product_detail_model/get_zip_code_list.dart';
import 'package:gc_customer_app/primitives/color_system.dart';
import 'package:gc_customer_app/primitives/constants.dart';
import 'package:gc_customer_app/primitives/icon_system.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:label_marker/label_marker.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'components/floating_card.dart';
import 'models/pick_result.dart';
import 'place_picker.dart';

class GetAddressFromMap extends StatefulWidget {
  final double zoom;
  final String? latitude;
  final String? longitude;
  final double radius;
  final Set<Marker> markers;
  final bool? isFullScreen;
  final String? skuENTId;
  final String? productName;
  final bool showUserPosition;
  final String? orderId;
  Items? cartItemInfor;
  GetAddressFromMap(
      {Key? key,
      this.latitude,
      this.longitude,
      required this.zoom,
      required this.radius,
      required this.markers,
      this.isFullScreen,
      this.skuENTId,
      this.productName,
      this.orderId,
      this.cartItemInfor,
      this.showUserPosition = true})
      : super(key: key);

  @override
  _MapState createState() => _MapState();
}

class _MapState extends State<GetAddressFromMap> {
  late GoogleMapController _googleMapController;
  late PickResult selectedPlace;
//  LatLng _initialPosition=LatLng(double.parse(widget.latitude),widget.longitude);
  String currentAddress = "";
  bool showMap = false;
  final StreamController<bool> _isExpandController =
      StreamController<bool>.broadcast()..add(false);
  final StreamController<String> _searchTextController =
      StreamController<String>.broadcast()..add('');
  PanelController _panelController = PanelController();
  late ProductDetailBloc productDetailBloc;
  late Set<Marker> markers;
  late GoogleMapController ggMapController;
  BitmapDescriptor? pinLocationIcon;
  final StreamController<String?> selectedReasonSC =
      StreamController<String?>.broadcast();
  final StreamController<OtherNodeData> selectedNodeSC =
      StreamController<OtherNodeData>.broadcast();
  final StreamController<LatLng> mapPositionSC =
      StreamController<LatLng>.broadcast();
  OtherNodeData? selectedNodeVal;
  StreamSubscription? subStreamListener;
  TextEditingController searchTextTEC = TextEditingController();

  @override
  void initState() {
    if (!kIsWeb)
      FirebaseAnalytics.instance
          .setCurrentScreen(screenName: 'ZipStoreGoogleMapScreen');

    markers = widget.markers;
    productDetailBloc = context.read<ProductDetailBloc>();
    setCustomMapPin();
    subStreamListener = productDetailBloc.stream.listen((event) {
      if (event.productDetailStatus == ProductDetailStatus.successState) {
        if (widget.cartItemInfor?.sourcingReason != null) {
          selectedReasonSC.add(widget.cartItemInfor!.sourcingReason);
          var selectedStore = productDetailBloc
              .state.getZipCodeList[0].otherNodeData!
              .firstWhere(
                  (ond) =>
                      ond.nodeID == widget.cartItemInfor!.reservationLocation,
                  orElse: () => OtherNodeData());
          selectedNodeVal = selectedStore;
          selectedStore.selectedReason = widget.cartItemInfor!.sourcingReason;
          selectedNodeVal!.selectedReason =
              widget.cartItemInfor!.sourcingReason;
          selectedNodeSC.add(selectedNodeVal!);
        }
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    selectedReasonSC.close();
    selectedNodeSC.close();
    subStreamListener?.cancel();
    super.dispose();
  }

  void setCustomMapPin() async {
    final Uint8List markerIcon = await getBytesFromAsset(
        'packages/gc_customer_app/' + IconSystem.warehouse, 120);
    pinLocationIcon = BitmapDescriptor.fromBytes(markerIcon);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<ProductDetailBloc, ProductDetailState>(
          builder: (context, state) {
        if (state.productDetailStatus != ProductDetailStatus.successState &&
            widget.skuENTId != null)
          return Center(child: CircularProgressIndicator());

        if (widget.markers.isEmpty)
          markers.addLabelMarker(LabelMarker(
              label: 'You are here',
              backgroundColor: Colors.blue[900]!,
              textStyle: TextStyle(fontSize: 32),
              markerId: MarkerId('userLocation'),
              icon: BitmapDescriptor.defaultMarkerWithHue(
                  BitmapDescriptor.hueBlue),
              position: LatLng(double.parse(widget.latitude!),
                  double.parse(widget.longitude!))));
        if (widget.skuENTId != null) {
          _loadMarkers(state);
        }

        return StreamBuilder<OtherNodeData>(
            stream: selectedNodeSC.stream,
            initialData: selectedNodeVal,
            builder: (context, snapshot) {
              var selectedOtherNode = snapshot.data;
              return SlidingUpPanel(
                controller: _panelController,
                minHeight: widget.skuENTId != null
                    ? (330 + (selectedOtherNode?.nodeID != null ? 80 : 0))
                    : 0,
                maxHeight: widget.skuENTId != null
                    ? MediaQuery.of(context).size.height
                    : 0,
                onPanelClosed: () {
                  _isExpandController.add(false);
                  productDetailBloc.add(SearchAddressProduct(searchName: ''));
                },
                onPanelOpened: () {
                  _isExpandController.add(true);
                },
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(50),
                  topRight: Radius.circular(50),
                ),
                padding: EdgeInsets.zero,
                panel: widget.skuENTId != null
                    ? _pannelWidget(state, selectedOtherNode)
                    : SizedBox.shrink(),
                body: Stack(
                  children: [
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 50),
                        child: PlacePicker(
                          mapStyle: IconSystem.mapLight,
                          apiKey: mapApiKey,
                          initialPosition: LatLng(
                              double.parse(widget.latitude ?? '36.370928'),
                              double.parse(widget.longitude ?? '-96.236572')),
                          useCurrentLocation: true,
                          desiredLocationAccuracy: LocationAccuracy.high,
                          enableMapTypeButton: true,
                          enableMyLocationButton: true,
                          initialMapType: MapType.normal,
                          resizeToAvoidBottomInset: true,
                          selectInitialPosition: true,
                          usePlaceDetailSearch: true,
                          onMapCreated: (controller) {
                            ggMapController = controller;
                          },
                          onCameraMove: (position) {
                            mapPositionSC.add(position.target);
                          },
                          onTapBack: () {
                            Navigator.pop(context);
                          },
                          onPlacePicked: (result) {
                            selectedPlace = result;
                            print("selectedPlace $selectedPlace");
                            // setState(() {});
                          },
                          automaticallyImplyAppBarLeading: true,
                          selectedPlaceWidgetBuilder:
                              (_, selectedPlace, state, isSearchBarFocused) {
                            debugPrint(
                                "state: $state, isSearchBarFocused: $isSearchBarFocused");
                            return Container(
                              margin: EdgeInsets.only(top: 20),
                            );
                          },
                          needBack: false,
                          zoom: widget.latitude == null ? 4 : widget.zoom,
                          radius: widget.latitude == null ? 0 : widget.radius,
                          markers: markers,
                        ),
                      ),
                    ),
                    if (widget.isFullScreen == true)
                      Align(
                        alignment: Alignment.topLeft,
                        child: SafeArea(
                            child: BackButton(
                                color: Theme.of(context).primaryColor)),
                      )
                  ],
                ),
              );
            });
      }),
    );
  }

  double calculateDistance(lat1, lon1, lat2, lon2) {
    var p = 0.017453292519943295;
    var c = cos;
    var a = 0.5 -
        c((lat2 - lat1) * p) / 2 +
        c(lat1 * p) * c(lat2 * p) * (1 - c((lon2 - lon1) * p)) / 2;
    return 12742 * asin(sqrt(a)) * 0.621371;
  }

  Widget _pannelWidget(
      ProductDetailState state, OtherNodeData? selectedOtherNode) {
    var isShowDefaultItem = true;
    var defaultItems =
        state.getZipCodeList.first.mainNodeData?.map<Widget>((mnd) {
              if ((mnd.nodeStock ?? '').isEmpty) return SizedBox.shrink();
              return ListTile(
                  leading: Text("${mnd.nodeStock}",
                      style: TextStyle(
                          fontSize: 20,
                          overflow: TextOverflow.ellipsis,
                          fontWeight: FontWeight.w500,
                          color: Theme.of(context).primaryColor,
                          fontFamily: kRubik)),
                  title: Text("${mnd.nodeName}",
                      maxLines: 2,
                      style: TextStyle(
                          fontSize: 20,
                          overflow: TextOverflow.ellipsis,
                          fontWeight: FontWeight.w400,
                          color: Theme.of(context).primaryColor,
                          fontFamily: kRubik)));
            }).toList() ??
            [];

    return StreamBuilder<OtherNodeData>(
        stream: selectedNodeSC.stream,
        initialData: selectedNodeVal,
        builder: (context, snapshot) {
          var selectedOtherNodes = snapshot.data;
          return Container(
            child: StreamBuilder<bool>(
                stream: _isExpandController.stream,
                initialData: false,
                builder: (context, snapshot) {
                  var isExpand = snapshot.data ?? false;
                  return SafeArea(
                    bottom: false,
                    top: isExpand,
                    child: Container(
                      child: Column(children: [
                        if (!isExpand)
                          IconButton(
                            icon: Icon(
                              Icons.menu,
                              color: ColorSystem.secondary,
                            ),
                            padding: EdgeInsets.all(0),
                            onPressed: () {
                              _panelController.open();
                            },
                          ),
                        Row(
                          children: [
                            SizedBox(width: 20),
                            Expanded(
                              child: TextFormField(
                                controller: searchTextTEC,
                                autofocus: false,
                                cursorColor: Theme.of(context).primaryColor,
                                style: TextStyle(
                                    fontSize: 24,
                                    overflow: TextOverflow.ellipsis,
                                    fontWeight: FontWeight.w400,
                                    color: Theme.of(context).primaryColor,
                                    fontFamily: kRubik),
                                onChanged: (name) {
                                  // zipStoreListBloc.add(SetOffset(offset: 0));

                                  EasyDebounce.cancelAll();
                                  EasyDebounce.debounce('search_name_debounce',
                                      Duration(seconds: 1), () {
                                    //       zipStoreListBloc.add(ClearOtherNodeData());
                                    // productDetailBloc
                                    //     .add(SearchAddressProduct(searchName: name));
                                    isShowDefaultItem = false;
                                    _searchTextController.add(name);
                                  });
                                },
                                decoration: InputDecoration(
                                  hintText: 'Search Store',
                                  hintStyle: TextStyle(
                                    color: ColorSystem.secondary,
                                    fontSize: 20,
                                  ),
                                  focusedBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(
                                      color: Theme.of(context).primaryColor,
                                      width: 1,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            isExpand
                                ? TextButton(
                                    onPressed: () {
                                      _panelController.close();
                                    },
                                    style: ButtonStyle(
                                        padding: MaterialStateProperty.all(
                                            EdgeInsets.zero)),
                                    child: Text(
                                      'Close',
                                      style: TextStyle(
                                          color:
                                              Theme.of(context).primaryColor),
                                    ))
                                : SizedBox(width: 14),
                          ],
                        ),
                        StreamBuilder<LatLng>(
                            stream: mapPositionSC.stream,
                            builder: (context, snapshot) {
                              var latLng = snapshot.data;
                              return Expanded(
                                  child: StreamBuilder<String>(
                                      stream: _searchTextController.stream,
                                      initialData: '',
                                      builder: (context, snapshot) {
                                        var searchText = snapshot.data ?? '';
                                        List<GetZipCodeList>
                                            getZipCodeListSearch = [
                                          GetZipCodeList(otherStores: [])
                                        ];
                                        getZipCodeListSearch = filterText(
                                            searchText,
                                            getZipCodeListSearch,
                                            state);
                                        isShowDefaultItem =
                                            (!isExpand && searchText.isEmpty);
                                        var itemCount = isShowDefaultItem
                                            ? defaultItems.length
                                            : getZipCodeListSearch.first
                                                    .otherStores?.length ??
                                                0;
                                        if (searchText.isNotEmpty &&
                                            itemCount == 0)
                                          return Container(
                                            margin: EdgeInsets.only(top: 20),
                                            child: Text('Not found'),
                                          );
                                        return ListView.builder(
                                          padding: EdgeInsets.zero,
                                          itemCount: isShowDefaultItem
                                              ? (defaultItems.length +
                                                  (selectedOtherNode?.nodeID !=
                                                          null
                                                      ? 1
                                                      : 0))
                                              : getZipCodeListSearch.first
                                                      .otherStores?.length ??
                                                  0,
                                          itemBuilder: (context, index) {
                                            if (isShowDefaultItem) {
                                              if (index >=
                                                  defaultItems.length) {
                                                return Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              left: 14),
                                                      child: Text(
                                                        'Selected Sourcing Node',
                                                        style: TextStyle(
                                                            fontSize: 14,
                                                            fontWeight:
                                                                FontWeight.w500,
                                                            fontFamily: kRubik),
                                                      ),
                                                    ),
                                                    ListTile(
                                                      leading: Text(
                                                          "${selectedOtherNode?.nodeID}",
                                                          style: TextStyle(
                                                              fontSize: 20,
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w500,
                                                              color: Theme.of(
                                                                      context)
                                                                  .primaryColor,
                                                              fontFamily:
                                                                  kRubik)),
                                                      title: Text(
                                                          "${selectedOtherNode?.nodeCity}",
                                                          maxLines: 2,
                                                          style: TextStyle(
                                                              fontSize: 20,
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w400,
                                                              color: Theme.of(
                                                                      context)
                                                                  .primaryColor,
                                                              fontFamily:
                                                                  kRubik)),
                                                      trailing: Row(
                                                        mainAxisSize:
                                                            MainAxisSize.min,
                                                        children: [
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
                                                          Text(
                                                              selectedOtherNode?.stockLevel ??
                                                                  '0',
                                                              style: TextStyle(
                                                                  fontSize: 20,
                                                                  overflow:
                                                                      TextOverflow
                                                                          .ellipsis,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w400,
                                                                  color: ColorSystem
                                                                      .greyDark,
                                                                  fontFamily:
                                                                      kRubik)),
                                                        ],
                                                      ),
                                                      // onTap: () {
                                                      //   int kcdcIndex = state
                                                      //           .getZipCodeList
                                                      //           .first
                                                      //           .mainNodeData
                                                      //           ?.indexWhere((mnd) =>
                                                      //               mnd.nodeName ==
                                                      //               'KCDC') ??
                                                      //       -1;
                                                      //   if (otherNode
                                                      //               ?.inventorySelection ==
                                                      //           true &&
                                                      //       kcdcIndex >= 0 &&
                                                      //       state.getZipCodeList.first
                                                      //                   .mainNodeData![
                                                      //               kcdcIndex] ==
                                                      //           '0') {
                                                      //     _showSelectReasonDialog(
                                                      //         getZipCodeListSearch.first
                                                      //                 .sourcingReason ??
                                                      //             [],
                                                      //         otherNode!);
                                                      //   }
                                                      //   FocusScope.of(context).unfocus();
                                                      //   ggMapController
                                                      //       .showMarkerInfoWindow(
                                                      //           MarkerId(store.id!));
                                                      //   ggMapController.animateCamera(
                                                      //       CameraUpdate.newLatLng(LatLng(
                                                      //           double.parse(
                                                      //               store.latitudeC ??
                                                      //                   ''),
                                                      //           double.parse(
                                                      //               store.longitudeC ??
                                                      //                   ''))));
                                                      // },
                                                    ),
                                                  ],
                                                );
                                              }
                                              return defaultItems[index];
                                            }
                                            var store = getZipCodeListSearch
                                                .first.otherStores![index];
                                            var otherNode = state.getZipCodeList
                                                .first.otherNodeData
                                                ?.firstWhere(
                                              (ond) =>
                                                  ond.nodeID == store.storeC,
                                              orElse: () => OtherNodeData(
                                                  stockLevel: '0'),
                                            );
                                            var stockLevel =
                                                otherNode?.stockLevel ?? '0';
                                            bool isSelectedReason =
                                                selectedOtherNodes?.nodeID ==
                                                    otherNode?.nodeID;
                                            if (isSelectedReason) {
                                              otherNode!.selectedReason =
                                                  selectedOtherNodes
                                                      ?.selectedReason;
                                            }
                                            bool isSameLat = latLng?.latitude
                                                    .toStringAsFixed(4) ==
                                                double.parse(
                                                        store.latitudeC ?? '0')
                                                    .toStringAsFixed(4);
                                            bool isSameLng = latLng?.longitude
                                                    .toStringAsFixed(4) ==
                                                double.parse(
                                                        store.longitudeC ?? '0')
                                                    .toStringAsFixed(4);
                                            bool isSamePosition = isSameLat &&
                                                isSameLng &&
                                                !isExpand;

                                            return ListTile(
                                              leading: Text("${store.storeC}",
                                                  style: TextStyle(
                                                      fontSize: 20,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      color: Theme.of(context)
                                                          .primaryColor,
                                                      fontFamily: kRubik)),
                                              title: Text("${store.storeCityC}",
                                                  maxLines: 2,
                                                  style: TextStyle(
                                                      fontSize: 20,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      fontWeight:
                                                          FontWeight.w400,
                                                      color: Theme.of(context)
                                                          .primaryColor,
                                                      fontFamily: kRubik)),
                                              trailing: isExpand
                                                  ? Row(
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
                                                        Text(stockLevel,
                                                            style: TextStyle(
                                                                fontSize: 20,
                                                                overflow:
                                                                    TextOverflow
                                                                        .ellipsis,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w400,
                                                                color: otherNode
                                                                            ?.inventorySelection ==
                                                                        true
                                                                    ? ColorSystem
                                                                        .black
                                                                    : ColorSystem
                                                                        .greyDark,
                                                                fontFamily:
                                                                    kRubik)),
                                                      ],
                                                    )
                                                  : (isSamePosition &&
                                                          otherNode
                                                                  ?.inventorySelection ==
                                                              true &&
                                                          double.parse(
                                                                  stockLevel) >
                                                              0 &&
                                                          widget.cartItemInfor !=
                                                              null)
                                                      ? TextButton(
                                                          onPressed: () {
                                                            int kcdcIndex = state
                                                                    .getZipCodeList
                                                                    .first
                                                                    .mainNodeData
                                                                    ?.indexWhere((mnd) =>
                                                                        mnd.nodeName ==
                                                                        'KCDC') ??
                                                                -1;
                                                            if (otherNode?.inventorySelection ==
                                                                    true &&
                                                                kcdcIndex >=
                                                                    0 &&
                                                                state
                                                                        .getZipCodeList
                                                                        .first
                                                                        .mainNodeData![
                                                                            kcdcIndex]
                                                                        .nodeStock ==
                                                                    '0') {
                                                              if (isSelectedReason) {
                                                                unSelectReason(
                                                                    otherNode!);
                                                              } else {
                                                                _showSelectReasonDialog(
                                                                    state
                                                                            .getZipCodeList
                                                                            .first
                                                                            .sourcingReason ??
                                                                        [],
                                                                    otherNode!);
                                                              }
                                                            }
                                                          },
                                                          child: Text('Select'))
                                                      : SvgPicture.asset(
                                                          IconSystem.gotoArrow,
                                                          package:
                                                              'gc_customer_app',
                                                        ),
                                              onTap: () {
                                                int kcdcIndex = state
                                                        .getZipCodeList
                                                        .first
                                                        .mainNodeData
                                                        ?.indexWhere((mnd) =>
                                                            mnd.nodeName ==
                                                            'KCDC') ??
                                                    -1;

                                                if (isExpand) {
                                                  if (otherNode
                                                              ?.inventorySelection ==
                                                          true &&
                                                      kcdcIndex >= 0 &&
                                                      state
                                                              .getZipCodeList
                                                              .first
                                                              .mainNodeData![
                                                                  kcdcIndex]
                                                              .nodeStock ==
                                                          '0') {
                                                    if (isSelectedReason) {
                                                      unSelectReason(
                                                          otherNode!);
                                                    } else {
                                                      _showSelectReasonDialog(
                                                          state
                                                                  .getZipCodeList
                                                                  .first
                                                                  .sourcingReason ??
                                                              [],
                                                          otherNode!);
                                                    }
                                                  }
                                                }

                                                FocusScope.of(context)
                                                    .unfocus();
                                                ggMapController
                                                    .showMarkerInfoWindow(
                                                        MarkerId(store.id!));
                                                ggMapController.animateCamera(
                                                    CameraUpdate.newLatLng(LatLng(
                                                        double.parse(
                                                            store.latitudeC ??
                                                                ''),
                                                        double.parse(
                                                            store.longitudeC ??
                                                                ''))));
                                              },
                                            );
                                          },
                                        );
                                      }));
                            })
                      ]),
                    ),
                  );
                }),
          );
        });
  }

  List<GetZipCodeList> filterText(String searchText,
      List<GetZipCodeList> getZipCodeListSearch, ProductDetailState state) {
    if (searchText.isEmpty) {
      getZipCodeListSearch = state.getZipCodeList;
    } else {
      state.getZipCodeList.first.otherStores?.forEach((os) {
        bool isContainName =
            os.storeCityC?.toLowerCase().contains(searchText.toLowerCase()) ??
                false;
        bool isContainId = os.storeDescriptionC
                ?.toLowerCase()
                .contains(searchText.toLowerCase()) ??
            false;
        bool isContainStockLevel = state.getZipCodeList.first.otherNodeData
                ?.firstWhere(
                  (ond) => ond.nodeID == os.storeC,
                  orElse: () => OtherNodeData(stockLevel: ''),
                )
                .stockLevel
                ?.contains(searchText) ??
            false;
        if (isContainName || isContainStockLevel || isContainId) {
          getZipCodeListSearch.first.otherStores!.add(os);
        }
      });
    }
    return getZipCodeListSearch;
  }

  Future<Uint8List> getBytesFromAsset(String path, int width) async {
    ByteData data = await rootBundle.load(path);
    ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(),
        targetWidth: width);
    ui.FrameInfo fi = await codec.getNextFrame();
    return (await fi.image.toByteData(format: ui.ImageByteFormat.png))!
        .buffer
        .asUint8List();
  }

  Future<void> _showSelectReasonDialog(
      List<String> sourcingReason, OtherNodeData otherNodeData) async {
    if (widget.orderId == null) return;
    if (otherNodeData.selectedReason != null) {
      selectedReasonSC.add(otherNodeData.selectedReason);
    }
    var selectedReason = await showDialog(
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
                      color: Colors.black,
                      fontSize: 19,
                      fontWeight: FontWeight.bold),
                ),
                content: Material(
                  color: Colors.transparent,
                  child: Column(
                    children: [
                      SizedBox(height: 15),
                      DropdownButtonFormField<String>(
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Please select reason";
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                            labelText: 'Select Reason',
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
                      searchTextTEC.clear();
                      _searchTextController.add('');
                      Navigator.of(context).pop(selectedReason);
                    },
                  ),
                  CupertinoDialogAction(
                    child: Text("CANCEL"),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              );
            });
      },
    );
    if (selectedReason != null) {
      productDetailBloc.selectInventoryReason(
          widget.cartItemInfor!.itemId!,
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

  void unSelectReason(OtherNodeData otherNodeData) {
    productDetailBloc.selectInventoryReason(widget.cartItemInfor!.itemId!, 'NA',
        int.parse(otherNodeData.stockLevel ?? '1'), '');
    otherNodeData.selectedReason = null;
    selectedNodeSC.add(OtherNodeData());
    if (widget.cartItemInfor != null) {
      widget.cartItemInfor!.reservationLocation = null;
      widget.cartItemInfor!.reservationLocationStock = otherNodeData.stockLevel;
      widget.cartItemInfor!.sourcingReason = null;
    }
  }

  void _loadMarkers(ProductDetailState state) {
    int kcdcIndex = state.getZipCodeList.first.mainNodeData
            ?.indexWhere((mnd) => mnd.nodeName == 'KCDC') ??
        -1;
    int wcdcIndex = state.getZipCodeList.first.mainNodeData
            ?.indexWhere((mnd) => mnd.nodeName == 'WCDC') ??
        -1;
    if (kcdcIndex >= 0 && pinLocationIcon != null) {
      var kcdcNOde = state.getZipCodeList.first.mainNodeData![kcdcIndex];
      markers.add(Marker(
          markerId: MarkerId('KCDC: ${kcdcNOde.nodeStock ?? '0'}'),
          icon: pinLocationIcon!,
          infoWindow: InfoWindow(
            title: 'KCDC - ${kcdcNOde.nodeStock ?? '0'}',
            snippet: '📍: 4001 N. NORFLEET RD, KANSAS CITY, MO, 64161',
          ),
          position: LatLng(39.167160, -94.425960)));
    }

    if (wcdcIndex >= 0 && pinLocationIcon != null) {
      var wcdcNode = state.getZipCodeList.first.mainNodeData![wcdcIndex];

      markers.add(Marker(
          markerId: MarkerId('WCDC: ${wcdcNode.nodeStock ?? '0'}'),
          icon: pinLocationIcon!,
          infoWindow: InfoWindow(
            title: 'WCDC - ${wcdcNode.nodeStock ?? '0'}',
            snippet:
                '📍: 1508 W. CASMALIA STREET, SUITE 200, RIALTO, CA, 92377',
          ),
          position: LatLng(34.138630, -117.403290)));
    }

    for (int i = 0;
        i < (state.getZipCodeList.first.otherStores?.length ?? 0);
        i++) {
      var otherStore = state.getZipCodeList.first.otherStores![i];
      if (otherStore.latitudeC != 'test') {
        var stockLevel = state.getZipCodeList.first.otherNodeData
            ?.firstWhere((e) => e.nodeID == otherStore.storeC)
            .stockLevel;

        //Check if store location is same as device location. If they are the same, move store tag forward
        bool isSameLocation = widget.latitude != null &&
            double.parse(otherStore.latitudeC ?? '0').toStringAsFixed(4) ==
                double.parse(widget.latitude ?? '0').toStringAsFixed(4) &&
            double.parse(otherStore.longitudeC ?? '0').toStringAsFixed(4) ==
                double.parse(widget.longitude ?? '0').toStringAsFixed(4);
        if (otherStore.latitudeC != null &&
            otherStore.longitudeC != null &&
            isSameLocation) {
          otherStore.latitudeC =
              (double.parse(otherStore.latitudeC!) - 0.001).toString();
        }

        var distance = widget.latitude == null
            ? null
            : calculateDistance(
                double.parse(widget.latitude!),
                double.parse(widget.longitude!),
                double.parse(otherStore.latitudeC ?? '0'),
                double.parse(otherStore.longitudeC ?? '0'));
        markers.addLabelMarker(LabelMarker(
            label: stockLevel ?? '0',
            textStyle: TextStyle(fontSize: 32),
            backgroundColor:
                (stockLevel ?? '0') == '0' ? Colors.red : Colors.green,
            markerId: MarkerId(otherStore.id!),
            infoWindow: InfoWindow(
              title: '${otherStore.storeDescriptionC} - ${stockLevel ?? '0'}',
              snippet:
                  '${distance == null ? '' : 'From your location: ${distance.toStringAsFixed(2)} miles'}\n' +
                      '📍: ${otherStore.storeAddressC!}' +
                      ", " +
                      otherStore.storeCityC! +
                      ", " +
                      otherStore.stateC! +
                      ', ${otherStore.postalCodeC}' +
                      '\n📞: ${otherStore.phoneC}',
            ),
            onTap: () {
              mapPositionSC.add(LatLng(double.parse(otherStore.latitudeC!),
                  double.parse(otherStore.longitudeC!)));
              searchTextTEC.text = otherStore.storeC ?? '';
              _searchTextController.add(searchTextTEC.text);
            },
            icon: BitmapDescriptor.defaultMarkerWithHue(
                BitmapDescriptor.hueGreen),
            position: LatLng(double.parse(otherStore.latitudeC!),
                double.parse(otherStore.longitudeC!))));
      }
    }
  }
}
