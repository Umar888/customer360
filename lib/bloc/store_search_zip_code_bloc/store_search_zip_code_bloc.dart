import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:gc_customer_app/primitives/constants.dart';
import 'package:gc_customer_app/services/storage/shared_preferences_service.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../data/reporsitories/store_search_zip_code_reporsitory/store_search_zip_code_repository.dart';
import '../../models/cart_model/cart_detail_model.dart';
import '../../models/common_models/records_class_model.dart';
import '../../models/inventory_search/add_search_model.dart';
import '../../models/store_search_zip_code_model/search_store_zip.dart';

part 'store_search_zip_code_state.dart';
part 'store_search_zip_code_event.dart';

class StoreSearchZipCodeBloc
    extends Bloc<StoreSearchZipCodeEvent, StoreSearchZipCodeState> {
  StoreSearchZipCodeRepository storeSearchZipCodeRepository;

  StoreSearchZipCodeBloc({required this.storeSearchZipCodeRepository})
      : super(StoreSearchZipCodeState()) {
    on<PageLoad>((event, emit) async {
      emit(state.copyWith(
        storeSearchZipCodeStatus: StoreSearchZipCodeStatus.successState,
        initialExtent: state.minExtent,
        zipCode: "",
      ));
    });

    on<SetOffset>((event, emit) {
      emit(state.copyWith(offset: event.offset));
    });
    on<ClearMarkers>((event, emit) {
      emit(state.copyWith(markers: []));
    });

    on<SetZoomLevel>((event, emit) {
      double radius = event.radius;
      double zoomLevel = state.zoomLevel;
      if (radius > 0) {
        double radiusElevated = (radius * 1000) + ((radius * 1000) / 2);
        double scale = radiusElevated / 500;
        zoomLevel = (16 - (log(scale) / log(2))).toDouble();
      } else {
        zoomLevel = double.parse(zoomLevel.toStringAsFixed(2));
      }
      emit(state.copyWith(zoomLevel: zoomLevel - 0.25));
    });
    on<SetMarkers>((event, emit) {
      List<Marker> markers = [];
      for (int i = 0; i < event.searchStoreListInformation.length; i++) {
        var store = event.searchStoreListInformation[i];
        markers.add(Marker(
            markerId: MarkerId(event.searchStoreListInformation[i].id!),
            infoWindow: InfoWindow(
              title: '${store.storeDescriptionC}',
              snippet: '📍: ${store.storeAddressC ?? ''}' +
                  ", ${store.storeCityC ?? ''}, ${store.stateC ?? ''}" +
                  ', ${store.postalCodeC}' +
                  '\n📞: ${store.phoneC}',
              onTap: () {
                if (event.onTapMarker != null)
                  event.onTapMarker!(store.storeC ?? '');
              },
            ),
            icon: BitmapDescriptor.defaultMarkerWithHue(
                event.searchStoreList?[i].avaibility == '0'
                    ? BitmapDescriptor.hueRed
                    : BitmapDescriptor.hueGreen),
            position: LatLng(
                double.parse(event.searchStoreListInformation[i].latitudeC!),
                double.parse(
                    event.searchStoreListInformation[i].longitudeC!))));
      }
      emit(state.copyWith(markers: markers));
    });

    on<SetZipCode>((event, emit) {
      emit(state.copyWith(zipCode: event.zipCode));
    });

    on<GetAddress>((event, emit) async {
      emit(state.copyWith(
          storeSearchZipCodeStatus: StoreSearchZipCodeStatus.loadState,
          currentRadius: event.radius));
      List<SearchStoreList>? searchStoreZip = [];
      var loggedInUserId =
          await SharedPreferenceService().getValue(loggedInAgentId);
      var response = await storeSearchZipCodeRepository.getAddress(
          event.name, event.radius, loggedInUserId, event.orderId);

      if (event.radius == "5") {
        emit(state.copyWith(
            currentRadius: "",
            searchStoreZip5: SearchStoreModel.fromJson(response.data),
            storeSearchZipCodeStatus: StoreSearchZipCodeStatus.successState));
      } else if (event.radius == "10") {
        emit(state.copyWith(
            currentRadius: "",
            searchStoreZip10: SearchStoreModel.fromJson(response.data),
            storeSearchZipCodeStatus: StoreSearchZipCodeStatus.successState));
      } else if (event.radius == "25") {
        emit(state.copyWith(
            currentRadius: "",
            searchStoreZip25: SearchStoreModel.fromJson(response.data),
            storeSearchZipCodeStatus: StoreSearchZipCodeStatus.successState));
      } else if (event.radius == "50") {
        emit(state.copyWith(
            currentRadius: "",
            searchStoreZip50: SearchStoreModel.fromJson(response.data),
            storeSearchZipCodeStatus: StoreSearchZipCodeStatus.successState));
      } else if (event.radius == "100") {
        emit(state.copyWith(
            currentRadius: "",
            searchStoreZip100: SearchStoreModel.fromJson(response.data),
            storeSearchZipCodeStatus: StoreSearchZipCodeStatus.successState));
      } else if (event.radius == "200") {
        emit(state.copyWith(
            currentRadius: "",
            searchStoreZip200: SearchStoreModel.fromJson(response.data),
            storeSearchZipCodeStatus: StoreSearchZipCodeStatus.successState));
      } else if (event.radius == "500") {
        emit(state.copyWith(
            currentRadius: "",
            searchStoreZip500: SearchStoreModel.fromJson(response.data),
            storeSearchZipCodeStatus: StoreSearchZipCodeStatus.successState));
      }
    });
  }
}
