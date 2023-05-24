import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:gc_customer_app/models/cart_model/cart_detail_model.dart';
import 'package:gc_customer_app/models/product_detail_model/get_zip_code_list.dart';
import 'package:gc_customer_app/models/common_models/records_class_model.dart'
    as asm;

part 'zip_store_list_state.dart';
part 'zip_store_list_event.dart';

class ZipStoreListBloc extends Bloc<ZipStoreListEvent, ZipStoreListState> {
  ZipStoreListBloc() : super(ZipStoreListState()) {
    on<PageLoad>((event, emit) async {
      emit(state.copyWith(zipStoreListStatus: ZipStoreListStatus.loadState));

      double maxExtent = event.productsInCart.isNotEmpty ? 0.325 : 0.25;
      double minExtent = event.productsInCart.isNotEmpty ? 0.325 : 0.25;
      double initialExtent = minExtent;

      emit(state.copyWith(
          zipStoreListStatus: ZipStoreListStatus.successState,
          initialExtent: initialExtent,
          minExtent: minExtent,
          maxExtent: maxExtent,
          productsInCart: event.productsInCart,
          zipCode: "",
          currentRecord: [event.records],
          getZipCodeListSearch: event.getZipCodeListSearch,
          getZipCodeList: event.getZipCodeList));
    });

    on<SetZipCode>((event, emit) {
      emit(state.copyWith(zipCode: event.zipCode));
    });

    on<SetOffset>((event, emit) {
      emit(state.copyWith(offset: event.offset));
    });

    on<ChangeInitialExtent>((event, emit) {
      emit(state.copyWith(initialExtent: event.initialExtent));
    });

    on<ChangeIsExpanded>((event, emit) {
      emit(state.copyWith(isExpanded: event.isExpanded));
    });

    on<ClearOtherNodeData>((event, emit) {
      List<GetZipCodeList> getZipCodeListSearch = state.getZipCodeListSearch;
      getZipCodeListSearch[0].otherNodeData!.clear();
      emit(state.copyWith(
        getZipCodeListSearch: getZipCodeListSearch,
      ));
    });

    on<AddOtherNodeData>((event, emit) {
      List<GetZipCodeList> getZipCodeListSearch = state.getZipCodeListSearch;
      List<GetZipCodeList> getZipCodeList = state.getZipCodeList;
      getZipCodeListSearch.first.otherNodeData = getZipCodeList
          .first.otherNodeData!
          .where((element) =>
              element.label!.toLowerCase().contains(event.name.toLowerCase()))
          .toList();

      //     for (var p in getZipCodeList[0].otherNodeData!) {
      //   if (p.label!.toLowerCase().contains(event.name.toLowerCase())) {
      //     getZipCodeListSearch[0].otherNodeData!.add(p);
      //   }
      // }
      emit(state.copyWith(
        getZipCodeListSearch: getZipCodeListSearch,
        getZipCodeList: getZipCodeList,
      ));
    });

    on<UpdateBottomCartWithItems>((event, emit) async {
      List<Items> orderDetailModel = [];
      List<asm.Records> orderRecords = event.records;
      orderDetailModel = event.items;
      for (asm.Records p in orderRecords) {
        if (orderDetailModel
            .where((element) => element.itemId == p.oliRecId)
            .isNotEmpty) {
          p.quantity = orderDetailModel
              .firstWhere((element) => element.itemId == p.oliRecId)
              .quantity!
              .toInt()
              .toString();
        }
      }

      emit(state.copyWith(
        productsInCart: orderRecords,
      ));
    });
  }
}
