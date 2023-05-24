import 'dart:async';
import 'dart:collection';

import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gc_customer_app/bloc/favourite_brand_screen_bloc/favourite_brand_screen_bloc.dart';
import 'package:gc_customer_app/data/data_sources/cart_data_source/cart_data_source.dart';
import 'package:gc_customer_app/data/reporsitories/cart_reporsitory/cart_repository.dart';
import 'package:gc_customer_app/data/reporsitories/favourite_brand-screen_repository/favourite_brand_screen_repository.dart';
import 'package:gc_customer_app/data/reporsitories/inventory_search_reporsitory/inventory_search_repository.dart';
import 'package:gc_customer_app/models/cart_model/cart_warranties_model.dart';
import 'package:gc_customer_app/models/favorite_brands_model/favorite_brand_detail_model.dart' as fbdm;
import 'package:gc_customer_app/models/inventory_search/add_search_model.dart';
import 'package:gc_customer_app/models/inventory_search/cart_model.dart';
import 'package:gc_customer_app/models/landing_screen/landing_screen_order_history.dart';
import 'package:gc_customer_app/primitives/constants.dart';
import 'package:gc_customer_app/services/storage/shared_preferences_service.dart';

import '../../models/common_models/facet.dart';
import '../../models/common_models/records_class_model.dart';
import '../../models/common_models/refinement_model.dart';
import '../../models/inventory_search/create_cart_model.dart';
import '../../models/inventory_search/options_model_for_filters.dart';
import '../../models/inventory_search/update_cart_model.dart';

part 'inventory_search_event.dart';

part 'inventory_search_state.dart';

class InventorySearchBloc extends Bloc<InventorySearchEvent, InventorySearchState> {
  InventorySearchRepository inventorySearchRepository;
  FavouriteBrandScreenRepository favouriteBrandScreenRepository;
  CartRepository cartRepository = CartRepository(cartDataSource: CartDataSource());

  InventorySearchBloc({required this.inventorySearchRepository, required this.favouriteBrandScreenRepository}) : super(InventorySearchState()) {
    Future<bool> getFiltersAddToModel(
        dynamic event, List<Refinement>? filteredListOfRefinments, String sortedByVal, List<AddSearchModel>? mainSearchDetailModel) async {
      final responseJson = await inventorySearchRepository.getDataBySorting(
        event.searchText!,
        filteredListOfRefinments!.isNotEmpty ? filteredListOfRefinments[filteredListOfRefinments.length - 1].id! : '',
        sortedByVal,
        filteredListOfRefinments,
      );
      mainSearchDetailModel!.clear();
      mainSearchDetailModel.add(AddSearchModel.fromJson(responseJson.data));
      return true;
    }

    void addingSelectedFilterToFact(
        List<Facet>? expansionTileList, List<AddSearchModel>? mainSearchDetailModel, List<Refinement>? filteredListOfRefinments) {
      // adding selected Filters in filteredListOfRefinments
      expansionTileList = mainSearchDetailModel!.first.wrapperinstance!.facet;
      for (var i = 0; i < expansionTileList!.length; i++) {
        if (expansionTileList[i].selectedRefinement!.isNotEmpty) {
          for (var j = 0; j < expansionTileList[i].selectedRefinement!.length; j++) {
            filteredListOfRefinments!.add(expansionTileList[i].selectedRefinement![j]);
          }
        }
      }
    }

    Future<fbdm.FavoriteBrandDetailModel> getRecordDetail(String brandName, String instrumentName) async {
      var id = await SharedPreferenceService().getValue(agentId);
      final response = await favouriteBrandScreenRepository.getRecordDetail(id, brandName, instrumentName);
      return response;
    }

    void filtersFunctionality(
        List<AddSearchModel>? mainSearchDetailModel, List<Refinement>? filteredListOfRefinments, List<Facet>? expansionTileList) {
      //  Filters List
      mainSearchDetailModel!.first.lengthOfSelectedFilters = filteredListOfRefinments!.length;
      for (var i = 0; i < filteredListOfRefinments.length; i++) {
        for (var j = 0; j < mainSearchDetailModel.first.wrapperinstance!.facet!.length; j++) {
          if (mainSearchDetailModel.first.wrapperinstance!.facet![j].dimensionId == filteredListOfRefinments[i].dimensionId) {
            mainSearchDetailModel.first.wrapperinstance!.facet![j].selectedRefinement!.add(filteredListOfRefinments[i]);
            mainSearchDetailModel.first.wrapperinstance!.facet![j].refinement!.insert(0, filteredListOfRefinments[i]);
            mainSearchDetailModel.first.wrapperinstance!.facet![j].refinement!.toSet().toList();
          } else {}
        }
      }
      // collect selected facet to add refinments if they are not returned by the list.
      List<Facet>? selectedFacets = [];
      for (var i = 0; i < expansionTileList!.length; i++) {
        if (expansionTileList[i].selectedRefinement!.isNotEmpty) {
          selectedFacets.add(Facet(
              refinement: expansionTileList[i].refinement,
              rank: expansionTileList[i].rank,
              multiSelect: expansionTileList[i].multiSelect,
              displayName: expansionTileList[i].displayName,
              dimensionId: expansionTileList[i].dimensionId,
              dimensionName: expansionTileList[i].displayName,
              isExpand: expansionTileList[i].isExpand,
              selectedRefinement: expansionTileList[i].selectedRefinement));
        }
      }
      for (var i = 0; i < selectedFacets.length; i++) {
        selectedFacets[i].refinement!.removeWhere((element) => element.onPressed == false);
      }
      // add that facets to the mainSearchDetailModel that are not returned by the data
      mainSearchDetailModel.first.wrapperinstance!.facet!.insertAll(
          0,
          selectedFacets.where((selectedFilter) =>
              mainSearchDetailModel.first.wrapperinstance!.facet!.every((newList) => newList.dimensionId != selectedFilter.dimensionId)));
      print(filteredListOfRefinments);
      print(selectedFacets);
    }

    void addProductInCart(dynamic event, List<AddSearchModel>? mainSearchDetailModel) {
      // cart functionality
      if (event.productsInCart.isNotEmpty) {
        for (var cartIndex = 0; cartIndex < mainSearchDetailModel!.first.wrapperinstance!.records!.length; cartIndex++) {
          for (var j = 0; j < event.productsInCart.length; j++) {
            if (event.productsInCart[j].productId == mainSearchDetailModel.first.wrapperinstance!.records![cartIndex].productId ||
                event.productsInCart[j].childskus!.first.skuENTId! ==
                    mainSearchDetailModel.first.wrapperinstance!.records![cartIndex].childskus!.first.skuENTId!) {
              mainSearchDetailModel.first.wrapperinstance!.records![cartIndex].quantity = event.productsInCart[j].quantity;
              mainSearchDetailModel.first.wrapperinstance!.records![cartIndex].oliRecId = event.productsInCart[j].oliRecId;
            }
          }
        }
      }
    }

    on<PageLoad>((event, emit) async {
      emit(state.copyWith(inventorySearchStatus: InventorySearchStatus.loadState));
      List<AddSearchModel> searchDetailModel = [];
      searchDetailModel.clear();
      final responseJson = await inventorySearchRepository.fetchSearchedData(event.name, event.offset);
      searchDetailModel.add(AddSearchModel.fromJson(responseJson.data));
      print("state.productsInCart ${state.productsInCart.length}");
      //if (event.isFirstTime!) {
      facetList = searchDetailModel.first.wrapperinstance!.facet;
      // }

      if (state.productsInCart.isNotEmpty) {
        for (int k = 0; k < searchDetailModel[0].wrapperinstance!.records!.length; k++) {
          if (state.productsInCart
              .where((element) =>
                  element.productId == searchDetailModel[0].wrapperinstance!.records![k].productId ||
                  element.childskus!.first.skuENTId == searchDetailModel[0].wrapperinstance!.records![k].childskus!.first.skuENTId)
              .isNotEmpty) {
            Records records = state.productsInCart.firstWhere((element) =>
                element.productId == searchDetailModel[0].wrapperinstance!.records![k].productId ||
                element.childskus!.first.skuENTId == searchDetailModel[0].wrapperinstance!.records![k].childskus!.first.skuENTId);
            searchDetailModel[0].wrapperinstance!.records![k].quantity = records.quantity;
            searchDetailModel[0].wrapperinstance!.records![k].oliRecId = records.oliRecId;
          }
        }
      }
      searchDetailModel.first.wrapperinstance!.facet = facetList;
      emit(state.copyWith(
          searchDetailModel: searchDetailModel,
          fetchInventoryData: state.fetchInventoryData ?? true,
          inventorySearchStatus: InventorySearchStatus.successState,
          searchString: event.name,
          sortName: sortByText,
          currentPage: 1,
          haveMore: true,
          showDiscount: false,
          selectedChoice: '',
          offset: event.offset));
    });

    on<FetchInventoryPaginationData>((event, emit) async {
      // emit(state.copyWith(loadingSearch: true));
      emit(state.copyWith(
        paginationFetching: true,
        message: "done",
      ));
      List<AddSearchModel>? mainSearchDetailModel = event.searchDetailModel;
      List<Facet>? expansionTileList = [];

      expansionTileList = mainSearchDetailModel!.first.wrapperinstance!.facet;
      List<AddSearchModel> searchDetailModel = [];
      searchDetailModel.clear();

      List<Refinement>? filteredListOfRefinments = mainSearchDetailModel.first.filteredListOfRefinments!;

      String sortedByVal;
      // mark  selected filters in a model
      for (var i = 0; i < expansionTileList!.length; i++) {
        if (expansionTileList[i].selectedRefinement!.isNotEmpty) {
          for (var j = 0; j < expansionTileList[i].selectedRefinement!.length; j++) {
            filteredListOfRefinments.add(expansionTileList[i].selectedRefinement![j]);
          }
        }
      }
      sortedByVal = event.choice;
      switch (sortedByVal) {
        case 'Best Match':
          sortedByVal = 'bM';
          break;
        case 'Top Seller':
          sortedByVal = 'bS';
          break;
        case 'Customer Ratings':
          sortedByVal = 'oR';
          break;
        case 'Price: High to Low':
          sortedByVal = 'pHL';
          break;
        case 'Price: Low to High':
          sortedByVal = 'pLH';
          break;
        case 'Newest First':
          sortedByVal = 'cD';
          break;
        case 'BeBrand A-Z':
          sortedByVal = 'bN';
          break;
        default:
          sortedByVal = '';
      }
      final responseJson = await inventorySearchRepository.fetchPaginationData(
          searchName: state.searchString,
          selectedId: filteredListOfRefinments.isEmpty ? '' : filteredListOfRefinments[filteredListOfRefinments.length - 1].id!,
          sortByVal: sortedByVal,
          filteredListOfRefinements: state.searchDetailModel.first.filteredListOfRefinments,
          pageSize: '30',
          currentPage: event.currentPage);
      searchDetailModel.add(AddSearchModel.fromJson(responseJson.data));

      // add incoming data to the exixting list
      if (searchDetailModel.first.wrapperinstance!.records!.isNotEmpty) {
        List<Records>? listWithAllData = [];
        listWithAllData = [...mainSearchDetailModel.first.wrapperinstance!.records!, ...searchDetailModel.first.wrapperinstance!.records!];
        print('Fetched pagination in Inventory search');
        if (event.currentPage == 2) {
          mainSearchDetailModel.first.wrapperinstance!.records = listWithAllData;
          if (searchDetailModel.first.wrapperinstance!.records!.isNotEmpty) {
            emit(state.copyWith(
              searchDetailModel: mainSearchDetailModel,
              currentPage: state.currentPage + 1,
              haveMore: true,
              paginationFetching: false,
              message: "done",
            ));
          } else {
            emit(state.copyWith(
              searchDetailModel: mainSearchDetailModel,
              // currentPage: state.currentPage+1,
              haveMore: false,
              paginationFetching: false,
              message: "done",
            ));
          }
        } else if (event.currentPage > 2) {
          mainSearchDetailModel.first.wrapperinstance!.records = listWithAllData;
          emit(state.copyWith(
            searchDetailModel: mainSearchDetailModel,
            currentPage: state.currentPage + 1,
            haveMore: true,
            paginationFetching: false,
            message: "done",
          ));
        } else {
          emit(state.copyWith(
            searchDetailModel: mainSearchDetailModel,
            // currentPage: state.currentPage+1,
            haveMore: false,
            paginationFetching: false,
            message: "done",
          ));
        }
      } else {
        emit(state.copyWith(
          searchDetailModel: mainSearchDetailModel,
          // currentPage: state.currentPage+1,
          haveMore: false,
          paginationFetching: false,
          message: "done",
        ));
      }
    });

    on<GetWarranties>((event, emit) async {
      try {
        emit(state.copyWith(isUpdating: true, updateID: event.productId, message: "done"));

        emit(state.copyWith(fetchWarranties: true, updateID: event.productId));
        WarrantiesModel response = await inventorySearchRepository.getWarranties(event.skuEntId);
        print("response.length ${response.warranties!.length}");
        if (response.warranties!.isEmpty) {
          emit(state.copyWith(
              warrantiesModel: [],
              fetchWarranties: false,
              isUpdating: false,
              updateID: "",
              warrantiesRecord: [event.records],
              showDialog: true,
              message: "done"));
        } else {
          emit(state.copyWith(
              warrantiesModel: response.warranties,
              fetchWarranties: false,
              isUpdating: false,
              updateID: "",
              warrantiesRecord: [event.records],
              showDialog: true,
              message: "done"));
        }
      } catch (e) {
        emit(state.copyWith(warrantiesModel: [], warrantiesRecord: [], isUpdating: false, updateID: "", fetchWarranties: false, message: "done"));
      }
    });

    on<ClearWarranties>((event, emit) async {
      emit(state.copyWith(fetchWarranties: false, warrantiesModel: [], warrantiesRecord: []));
    });

    on<ChangeShowDialog>((event, emit) async {
      emit(state.copyWith(showDialog: event.value));
    });

    on<InventorySearchFetch>((event, emit) async {
      emit(state.copyWith(loadingSearch: true));
      List<AddSearchModel>? mainSearchDetailModel = event.searchDetailModel;
      String sortedByVal;
      List<Refinement>? filteredListOfRefinments = event.searchDetailModel.first.filteredListOfRefinments;
      List<Facet>? expansionTileList = [];
      // show number of selected filters
      expansionTileList = event.searchDetailModel.first.wrapperinstance!.facet;
      // adding selected Filters in filteredListOfRefinments
      for (var i = 0; i < expansionTileList!.length; i++) {
        if (expansionTileList[i].selectedRefinement!.isNotEmpty) {
          for (var j = 0; j < expansionTileList[i].selectedRefinement!.length; j++) {
            filteredListOfRefinments!.add(expansionTileList[i].selectedRefinement![j]);
          }
        }
      }
      // show number of selected filters
      // searchDetailModel.first.wrapperinstance!.facet = expansionTileList;
      sortedByVal = event.choice;
      switch (sortedByVal) {
        case 'Best Match':
          sortedByVal = 'bM';
          break;
        case 'Top Seller':
          sortedByVal = 'bS';
          break;
        case 'Customer Ratings':
          sortedByVal = 'oR';
          break;
        case 'Price: High to Low':
          sortedByVal = 'pHL';
          break;
        case 'Price: Low to High':
          sortedByVal = 'pLH';
          break;
        case 'Newest First':
          sortedByVal = 'cD';
          break;
        case 'BeBrand A-Z':
          sortedByVal = 'bN';
          break;
        default:
          sortedByVal = '';
      }
      final responseJson = await inventorySearchRepository.fetchDataBySearchName(
        searchName: event.name,
        selectedId: filteredListOfRefinments!.isNotEmpty ? filteredListOfRefinments[filteredListOfRefinments.length - 1].id! : '',
        sortedByVal: sortedByVal,
        filteredListOfRefinements: filteredListOfRefinments,
      );
      mainSearchDetailModel.clear();
      mainSearchDetailModel.add(AddSearchModel.fromJson(responseJson.data));
      if (event.isFavouriteScreen) {
        event.favoriteItems.wrapperinstance!.records = mainSearchDetailModel.first.wrapperinstance!.records;
        print(event.favoriteItems.wrapperinstance!.records);
        for (var i = 0; i < event.favoriteItems.wrapperinstance!.records!.length; i++) {
          event.favoriteItems.wrapperinstance!.records![i].quantity = mainSearchDetailModel.first.wrapperinstance!.records![i].quantity;
        }
      }
      //  else if (event.isOfferScreen) {
      //   mainSearchDetailModel.first.listOfOfferForFilters =
      //       mainSearchDetailModel.first.wrapperinstance!.records;
      // }
      mainSearchDetailModel.first.lengthOfSelectedFilters = filteredListOfRefinments.length;
      mainSearchDetailModel.first.lengthOfSelectedFilters = event.searchDetailModel.first.lengthOfSelectedFilters;
      // mapping already selected Filters in a
      filtersFunctionality(mainSearchDetailModel, filteredListOfRefinments, expansionTileList);
      // Cart functionality
      addProductInCart(event, mainSearchDetailModel);
      emit(state.copyWith(
          searchDetailModel: mainSearchDetailModel,
          loadingSearch: false,
          currentPage: 1,
          haveMore: true,
          inventorySearchStatus: InventorySearchStatus.successState,
          searchString: event.name));
    });

    on<ChangeViewType>((event, emit) async {
      emit(state.copyWith(viewType: event.view));
    });

    on<SetCart>((event, emit) async {
      List<AddSearchModel> addSearch = state.searchDetailModel;
      if (addSearch.isNotEmpty && event.records.isNotEmpty) {
        for (final k in addSearch[0].wrapperinstance!.records!) {
          if (event.records.where((element) => element.childskus!.first.skuENTId! == k.childskus!.first.skuENTId!).isNotEmpty) {
            k.quantity = event.records.firstWhere((element) => element.childskus!.first.skuENTId! == k.childskus!.first.skuENTId!).quantity;
          }
        }
      }
      else if (addSearch.isNotEmpty && event.records.isEmpty) {
        for (final k in addSearch[0].wrapperinstance!.records!) {
          k.quantity = "0";
        }
      }
      emit(state.copyWith(
        orderId: event.orderId,
        message: "done",
        itemOfCart: event.itemOfCart,
        productsInCart: event.records,
        searchDetailModel: addSearch,
      ));
    });

    on<UpdateIsFirst>((event, emit) async {
      emit(state.copyWith(isFirst: event.value));
    });

    on<AddToCart>((event, emit) async {
      Records e = event.records;
      List<AddSearchModel> addSearch = state.searchDetailModel;
      if (addSearch.isNotEmpty &&
          addSearch[0].wrapperinstance!.records!.where((element) => element.childskus!.first.skuENTId == e.childskus!.first.skuENTId).isNotEmpty) {
        addSearch[0].wrapperinstance!.records!.firstWhere((element) => element.childskus!.first.skuENTId == e.childskus!.first.skuENTId).warranties =
            event.warranties;
      }

      e.warranties = event.warranties;
      if (event.quantity == -1) {
        emit(state.copyWith(message: "", isUpdating: true, updateID: event.productId, updateSKUID: event.skUid));
        if (double.parse(e.quantity!) == 0 || e.oliRecId == null || e.oliRecId!.isEmpty) {
          final responseJson = await inventorySearchRepository.addToCartAndCreateOrder(event.records, event.customerID, event.orderID);
          if (responseJson != null && responseJson.data != null) {
            AddToCartAndCreateOrder addToCartAndCreateOrder = AddToCartAndCreateOrder.fromJson(responseJson.data);
            print('Create order');
            print(addToCartAndCreateOrder.orderId);
            List<Records> productsInCart = [];
            List<ItemsOfCart> itemOfCart = [];
            if (addToCartAndCreateOrder.orderId != null) {
              productsInCart.add(e);
              e.quantity = (double.parse(e.quantity!) + 1).toString();
              e.oliRecId = addToCartAndCreateOrder.oliRecId!;

              String orderId = addToCartAndCreateOrder.orderId!;
//                  String orderNumber = addToCartAndCreateOrder.!;
              itemOfCart.add(ItemsOfCart(
                  itemQuantity: e.quantity.toString(),
                  itemId: e.childskus!.first.skuENTId.toString(),
                  itemName: e.productName!,
                  itemProCoverage: (e.warranties!.price ?? 0.0).toString(),
                  itemPrice: e.childskus!.first.skuPrice!));
              String orderLineItemId = addToCartAndCreateOrder.oliRecId!;
              productsInCart = LinkedHashSet<Records>.from(productsInCart).toList();
              itemOfCart = LinkedHashSet<ItemsOfCart>.from(itemOfCart).toList();
              List<AddSearchModel> addSearch = state.searchDetailModel;
              if (addSearch.isNotEmpty &&
                  addSearch[0].wrapperinstance!.records!.isNotEmpty &&
                  addSearch[0]
                      .wrapperinstance!
                      .records!
                      .where((element) => element.childskus!.first.skuENTId == e.childskus!.first.skuENTId)
                      .isNotEmpty) {
                addSearch[0]
                    .wrapperinstance!
                    .records!
                    .firstWhere((element) => element.childskus!.first.skuENTId == e.childskus!.first.skuENTId)
                    .quantity = e.quantity;
                addSearch[0]
                    .wrapperinstance!
                    .records!
                    .firstWhere((element) => element.childskus!.first.skuENTId == e.childskus!.first.skuENTId)
                    .warranties = event.warranties;
              }
              emit(state.copyWith(
                  orderId: orderId,
                  searchDetailModel: addSearch,
                  isUpdating: false,
                  itemOfCart: [...state.itemOfCart, ...itemOfCart],
                  updateID: "",
                  updateSKUID: "",
                  orderLineItemId: orderLineItemId,
                  message: "done",
                  productsInCart: [...state.productsInCart, ...productsInCart]));

              if (event.ifWarranties) {
                await cartRepository.updateWarranties(event.warranties, addToCartAndCreateOrder.oliRecId!);
              }
            } else {
              e.isCartAdding = false;
              itemOfCart = LinkedHashSet<ItemsOfCart>.from(itemOfCart).toList();
              productsInCart = LinkedHashSet<Records>.from(productsInCart).toList();
              emit(state.copyWith(
                isUpdating: false,
                updateID: "",
                updateSKUID: "",
                message: "Cannot create order. Check your network connection!",
              ));
            }
          } else {
            List<Records> productsInCart = [];
            List<ItemsOfCart> itemOfCart = [];
            e.isCartAdding = false;
            itemOfCart = LinkedHashSet<ItemsOfCart>.from(itemOfCart).toList();
            productsInCart = LinkedHashSet<Records>.from(productsInCart).toList();
            emit(state.copyWith(
              isUpdating: false,
              updateID: "",
              updateSKUID: "",
              message: "Cannot create order. Check your network connection!",
            ));
          }
        } else {
          final responseJson =
              await inventorySearchRepository.updateCartAdd(event.records, event.customerID, event.orderID, (double.parse(e.quantity!) + 1).toInt());

          UpdateCart updateCart = UpdateCart.fromJson(responseJson.data);
          e.quantity = (double.parse(e.quantity!) + 1).toString();
          List<ItemsOfCart> itemOfCart = [...state.itemOfCart];
          for (ItemsOfCart i in itemOfCart) {
            print("lopizo ${i.itemId}");
            print("lopizo-r ${e.childskus!.first.skuENTId}");
          }
          if (itemOfCart.isNotEmpty && itemOfCart.where((element) => element.itemId == e.childskus!.first.skuENTId).isNotEmpty) {
            itemOfCart.firstWhere((element) => element.itemId == e.childskus!.first.skuENTId).itemQuantity = (double.parse(e.quantity!)).toString();
          } else {
            itemOfCart.add(ItemsOfCart(
                itemQuantity: e.quantity.toString(),
                itemId: e.childskus!.first.skuENTId.toString(),
                itemName: e.productName!,
                itemProCoverage: (e.warranties!.price ?? 0.0).toString(),
                itemPrice: e.childskus!.first.skuPrice!));
            itemOfCart = LinkedHashSet<ItemsOfCart>.from(itemOfCart).toList();
          }
          if (addSearch.isNotEmpty &&
              addSearch[0].wrapperinstance!.records!.isNotEmpty &&
              addSearch[0]
                  .wrapperinstance!
                  .records!
                  .where((element) => element.childskus!.first.skuENTId == e.childskus!.first.skuENTId)
                  .isNotEmpty) {
            addSearch[0]
                .wrapperinstance!
                .records!
                .firstWhere((element) => element.childskus!.first.skuENTId == e.childskus!.first.skuENTId)
                .quantity = e.quantity;
            addSearch[0]
                .wrapperinstance!
                .records!
                .firstWhere((element) => element.childskus!.first.skuENTId == e.childskus!.first.skuENTId)
                .warranties = event.warranties;
          }

          if (updateCart.message!.isNotEmpty) {
            emit(state.copyWith(
                message: updateCart.message ?? "",
                isUpdating: false,
                updateID: "",
                updateSKUID: "",
                searchDetailModel: addSearch,
                productsInCart: LinkedHashSet<Records>.from(state.productsInCart).toList(),
                itemOfCart: LinkedHashSet<ItemsOfCart>.from(itemOfCart).toList()));
          } else {
            emit(state.copyWith(
              isUpdating: false,
              updateID: "",
              updateSKUID: "",
              message: "Cannot update cart. Check your network connection!",
            ));
          }
        }
      } else {
        emit(state.copyWith(
          message: "",
          isUpdating: true,
          updateID: event.productId,
          updateSKUID: event.skUid,
        ));
        if (double.parse(e.quantity!) == 0) {
          final responseJson = await inventorySearchRepository.addToCartAndCreateOrder(event.records, event.customerID, event.orderID);
          if (responseJson != null) {
            AddToCartAndCreateOrder addToCartAndCreateOrder = AddToCartAndCreateOrder.fromJson(responseJson.data);
            List<Records> productsInCart = [];
            List<ItemsOfCart> itemOfCart = [];
            if (addToCartAndCreateOrder.orderId != null) {
              productsInCart.add(e);
              e.quantity = (event.quantity).toString();
              e.oliRecId = addToCartAndCreateOrder.oliRecId!;

              String orderId = addToCartAndCreateOrder.orderId!;
              itemOfCart.add(ItemsOfCart(
                  itemQuantity: e.quantity.toString(),
                  itemId: e.childskus!.first.skuENTId.toString(),
                  itemName: e.productName!,
                  itemProCoverage: (e.warranties!.price ?? 0.0).toString(),
                  itemPrice: e.childskus!.first.skuPrice!));
              String orderLineItemId = addToCartAndCreateOrder.oliRecId!;
              productsInCart = LinkedHashSet<Records>.from(productsInCart).toList();
              itemOfCart = LinkedHashSet<ItemsOfCart>.from(itemOfCart).toList();
              List<AddSearchModel> addSearch = state.searchDetailModel;
              if (addSearch.isNotEmpty &&
                  addSearch[0].wrapperinstance!.records!.isNotEmpty &&
                  addSearch[0]
                      .wrapperinstance!
                      .records!
                      .where((element) => element.childskus!.first.skuENTId == e.childskus!.first.skuENTId)
                      .isNotEmpty) {
                addSearch[0]
                    .wrapperinstance!
                    .records!
                    .firstWhere((element) => element.childskus!.first.skuENTId == e.childskus!.first.skuENTId)
                    .quantity = e.quantity;
              }
              emit(state.copyWith(
                  orderId: orderId,
                  searchDetailModel: addSearch,
                  isUpdating: false,
                  itemOfCart: [...state.itemOfCart, ...itemOfCart],
                  updateID: "",
                  updateSKUID: "",
                  orderLineItemId: orderLineItemId,
                  message: "done",
                  productsInCart: [...state.productsInCart, ...productsInCart]));

              if (event.ifWarranties) {
                await cartRepository.updateWarranties(event.warranties, addToCartAndCreateOrder.oliRecId!);
              }
            } else {
              e.isCartAdding = false;
              itemOfCart = LinkedHashSet<ItemsOfCart>.from(itemOfCart).toList();
              productsInCart = LinkedHashSet<Records>.from(productsInCart).toList();
              emit(state.copyWith(
                isUpdating: false,
                updateID: "",
                updateSKUID: "",
                message: "Cannot create order. Check your network connection!",
              ));
            }
          } else {
            List<Records> productsInCart = [];
            List<ItemsOfCart> itemOfCart = [];
            e.isCartAdding = false;
            itemOfCart = LinkedHashSet<ItemsOfCart>.from(itemOfCart).toList();
            productsInCart = LinkedHashSet<Records>.from(productsInCart).toList();
            emit(state.copyWith(
              isUpdating: false,
              updateID: "",
              updateSKUID: "",
              message: "Cannot create order. Check your network connection!",
            ));
          }
        } else {
          final responseJson =
              await inventorySearchRepository.updateCartAdd(event.records, event.customerID, event.orderID, (event.quantity).toInt());
          UpdateCart updateCart = UpdateCart.fromJson(responseJson.data);
          e.quantity = (event.quantity).toString();
          List<ItemsOfCart> itemOfCart = [...state.itemOfCart];
          for (ItemsOfCart i in itemOfCart) {
            print("lopizo ${i.itemId}");
            print("lopizo-r ${e.childskus!.first.skuENTId}");
          }

          if (itemOfCart.isNotEmpty) {
            itemOfCart.firstWhere((element) => element.itemId == e.childskus!.first.skuENTId).itemQuantity = (double.parse(e.quantity!)).toString();
          } else {
            itemOfCart.add(ItemsOfCart(
                itemQuantity: e.quantity.toString(),
                itemId: e.childskus!.first.skuENTId.toString(),
                itemName: e.productName!,
                itemProCoverage: (e.warranties!.price ?? 0.0).toString(),
                itemPrice: e.childskus!.first.skuPrice!));
            itemOfCart = LinkedHashSet<ItemsOfCart>.from(itemOfCart).toList();
          }
          List<AddSearchModel> addSearch = state.searchDetailModel;
          if (addSearch.isNotEmpty &&
              addSearch[0].wrapperinstance!.records!.isNotEmpty &&
              addSearch[0]
                  .wrapperinstance!
                  .records!
                  .where((element) => element.childskus!.first.skuENTId == e.childskus!.first.skuENTId)
                  .isNotEmpty) {
            addSearch[0]
                .wrapperinstance!
                .records!
                .firstWhere((element) => element.childskus!.first.skuENTId == e.childskus!.first.skuENTId)
                .quantity = e.quantity;
          }

          if (updateCart.message!.isNotEmpty) {
            emit(state.copyWith(
                message: updateCart.message ?? "",
                isUpdating: false,
                updateID: "",
                searchDetailModel: addSearch,
                productsInCart: LinkedHashSet<Records>.from(state.productsInCart).toList(),
                itemOfCart: LinkedHashSet<ItemsOfCart>.from(itemOfCart).toList()));
          } else {
            emit(state.copyWith(
              isUpdating: false,
              updateID: "",
              updateSKUID: "",
              message: "Cannot update cart. Check your network connection!",
            ));
          }
        }
      }
      if (event.fromFavorite) {
        event.favouriteBrandScreenBloc.add(RefreshList());
      }
    });

    on<UpdateBottomCart>((event, emit) async {
      emit(state.copyWith(productsInCart: event.items));
    });

    on<FetchEligibility>((event, emit) async {
      List<AddSearchModel> addSearchModel = state.searchDetailModel;
      List<Records> records = addSearchModel.first.wrapperinstance!.records ?? [];
      records[event.index].fetchingEligibility = true;
      records[event.index].mainNodeData = [];
      records[event.index].moreInfo = [];
      addSearchModel.first.wrapperinstance!.records = records;

      emit(state.copyWith(searchDetailModel: addSearchModel, message: "done"));
      var id = await SharedPreferenceService().getValue(loggedInAgentId);
      final elegResponseJson = await inventorySearchRepository.getItemEligibility(records[event.index].childskus!.first.skuENTId!, id);
      records[event.index].fetchingEligibility = false;
      records[event.index].mainNodeData = elegResponseJson.mainNodeData ?? [];
      records[event.index].moreInfo = elegResponseJson.moreInfo ?? [];
      addSearchModel.first.wrapperinstance!.records = records;
      emit(state.copyWith(searchDetailModel: addSearchModel, message: "done"));
    });

    on<UpdateBottomCartWithItems>((event, emit) async {
      List<BrandItems> orderDetailModel = [];
      List<Records> orderRecords = event.records;
      orderDetailModel = event.items;
      for (Records p in orderRecords) {
        if (orderDetailModel.where((element) => element.itemID == p.oliRecId).isNotEmpty) {
          p.quantity = orderDetailModel.firstWhere((element) => element.itemID == p.oliRecId).quantity!.toString();
        }
      }

      emit(state.copyWith(
        productsInCart: orderRecords,
      ));
    });

    on<RemoveFromCart>((event, emit) async {
      List<AddSearchModel> addSearch = state.searchDetailModel;
//      if(addSearch.isNotEmpty) {
      // if (event.customerID == null || event.customerID.isEmpty) {
      //   emit(state.copyWith(
      //       message: "Customer is not available for order"
      //   ));
      // }
      // else {
      try {
        Records e = event.records;
        // if (event.customerID.isNotEmpty) {
        if (event.quantity == -1) {
          emit(state.copyWith(isUpdating: true, updateID: event.productId, message: "", searchDetailModel: state.searchDetailModel));
          if (double.parse(e.quantity!) > 0) {
            if (double.parse(e.quantity!) > 1) {
              final responseJson = await inventorySearchRepository.updateCartAdd(
                  event.records, event.customerID, event.orderID, (event.quantity == -1 ? double.parse(e.quantity!) - 1 : event.quantity).toInt());
              UpdateCart updateCart = UpdateCart.fromJson(responseJson.data);
              e.quantity = (event.quantity == -1 ? double.parse(e.quantity!) - 1 : event.quantity).toString();
              List<ItemsOfCart> itemOfCart = state.itemOfCart;

              itemOfCart.firstWhere((element) => element.itemId == e.childskus!.first.skuENTId).itemQuantity = (double.parse(e.quantity!)).toString();
              List<AddSearchModel> addSearch = state.searchDetailModel;
              if (addSearch.isNotEmpty &&
                  addSearch[0].wrapperinstance!.records!.isNotEmpty &&
                  addSearch[0]
                      .wrapperinstance!
                      .records!
                      .where((element) => element.childskus!.first.skuENTId == e.childskus!.first.skuENTId)
                      .isNotEmpty) {
                addSearch[0]
                    .wrapperinstance!
                    .records!
                    .firstWhere((element) => element.childskus!.first.skuENTId == e.childskus!.first.skuENTId)
                    .quantity = e.quantity;
              }

              if (updateCart.message!.isNotEmpty) {
                emit(state.copyWith(
                    isUpdating: false,
                    searchDetailModel: addSearch,
                    updateID: "",
                    message: updateCart.message ?? "",
                    productsInCart: LinkedHashSet<Records>.from(state.productsInCart).toList(),
                    itemOfCart: LinkedHashSet<ItemsOfCart>.from(itemOfCart).toList()));
              } else {
                emit(state.copyWith(
                  message: "Cannot update cart. Check your network connection!",
                ));
              }
            } else {
              List<AddSearchModel> addSearch = state.searchDetailModel;

              if (addSearch.isNotEmpty &&
                  addSearch[0]
                      .wrapperinstance!
                      .records!
                      .where((element) => element.childskus!.first.skuENTId == e.childskus!.first.skuENTId)
                      .isNotEmpty) {
                addSearch[0]
                    .wrapperinstance!
                    .records!
                    .firstWhere((element) => element.childskus!.first.skuENTId == e.childskus!.first.skuENTId)
                    .warranties = Warranties(price: 0.0);
              }

              final responseJson = await inventorySearchRepository.updateCartDelete(
                  event.records, event.customerID, event.orderID, (double.parse(e.quantity!) - 1).toInt());
              //  print(jsonEncode(responseJson.data));
              UpdateCart updateCart = UpdateCart.fromJson(responseJson.data);
              e.quantity = (double.parse(e.quantity!) - 1).toString();
              state.productsInCart.remove(state.productsInCart
                  .firstWhere((element) => element.productId == e.productId || element.childskus!.first.skuENTId! == e.childskus!.first.skuENTId!));
              List<ItemsOfCart> itemOfCart = state.itemOfCart;
              itemOfCart.firstWhere((element) => element.itemId == e.childskus!.first.skuENTId).itemQuantity = (double.parse(e.quantity!)).toString();
              itemOfCart.remove(itemOfCart.firstWhere((element) => element.itemId == e.childskus!.first.skuENTId));
              if (addSearch.isNotEmpty &&
                  addSearch[0].wrapperinstance!.records!.isNotEmpty &&
                  addSearch[0]
                      .wrapperinstance!
                      .records!
                      .where((element) => element.childskus!.first.skuENTId == e.childskus!.first.skuENTId)
                      .isNotEmpty) {
                addSearch[0]
                    .wrapperinstance!
                    .records!
                    .firstWhere((element) => element.childskus!.first.skuENTId == e.childskus!.first.skuENTId)
                    .quantity = e.quantity;
              }

              emit(state.copyWith(
                  isUpdating: false,
                  searchDetailModel: addSearch,
                  updateID: "",
                  message: updateCart.message ?? "",
                  itemOfCart: LinkedHashSet<ItemsOfCart>.from(itemOfCart).toList(),
                  productsInCart: LinkedHashSet<Records>.from(state.productsInCart).toList()));
            }
          }
        } else if (event.quantity == -2) {
          List<AddSearchModel> addSearch = state.searchDetailModel;
          if (addSearch.isNotEmpty &&
              addSearch[0].wrapperinstance!.records!.isNotEmpty &&
              addSearch[0]
                  .wrapperinstance!
                  .records!
                  .where((element) => element.childskus!.first.skuENTId == e.childskus!.first.skuENTId)
                  .isNotEmpty) {
            addSearch[0]
                .wrapperinstance!
                .records!
                .firstWhere((element) => element.childskus!.first.skuENTId == e.childskus!.first.skuENTId)
                .quantity = "0";
          }
          emit(state.copyWith(
              isUpdating: false,
              updateID: "",
              searchDetailModel: addSearch,
              message: "Cart Cleared Successfully",
              itemOfCart: [],
              productsInCart: []));
        } else if (event.quantity == 0) {
          emit(state.copyWith(isUpdating: true, updateID: event.productId, message: "", searchDetailModel: state.searchDetailModel));
          final responseJson = await inventorySearchRepository.updateCartDelete(event.records, event.customerID, event.orderID, 0);
          //  print(jsonEncode(responseJson.data));
          UpdateCart updateCart = UpdateCart.fromJson(responseJson.data);
          e.quantity = "0";
          state.productsInCart.remove(state.productsInCart.firstWhere((element) => element.productId == e.productId));
          List<ItemsOfCart> itemOfCart = state.itemOfCart;

          itemOfCart.firstWhere((element) => element.itemId == e.childskus!.first.skuENTId).itemQuantity = "0";
          itemOfCart.remove(itemOfCart.firstWhere((element) => element.itemId == e.childskus!.first.skuENTId));
          List<AddSearchModel> addSearch = state.searchDetailModel;
          if (addSearch.isNotEmpty &&
              addSearch[0].wrapperinstance!.records!.isNotEmpty &&
              addSearch[0]
                  .wrapperinstance!
                  .records!
                  .where((element) => element.childskus!.first.skuENTId == e.childskus!.first.skuENTId)
                  .isNotEmpty) {
            addSearch[0]
                .wrapperinstance!
                .records!
                .firstWhere((element) => element.childskus!.first.skuENTId == e.childskus!.first.skuENTId)
                .quantity = e.quantity;
          }

          emit(state.copyWith(
              isUpdating: false,
              searchDetailModel: addSearch,
              updateID: "",
              message: updateCart.message ?? "",
              itemOfCart: LinkedHashSet<ItemsOfCart>.from(itemOfCart).toList(),
              productsInCart: LinkedHashSet<Records>.from(state.productsInCart).toList()));
        } else {
          emit(state.copyWith(isUpdating: true, updateID: event.productId, message: "", searchDetailModel: state.searchDetailModel));
          if (double.parse(e.quantity!) > 0) {
            if (double.parse(e.quantity!) > 1) {
              final responseJson =
                  await inventorySearchRepository.updateCartAdd(event.records, event.customerID, event.orderID, (event.quantity).toInt());
              UpdateCart updateCart = UpdateCart.fromJson(responseJson.data);
              e.quantity = (event.quantity).toString();
              List<ItemsOfCart> itemOfCart = state.itemOfCart;

              itemOfCart.firstWhere((element) => element.itemId == e.childskus!.first.skuENTId).itemQuantity = (double.parse(e.quantity!)).toString();
              List<AddSearchModel> addSearch = state.searchDetailModel;
              if (addSearch.isNotEmpty &&
                  addSearch[0].wrapperinstance!.records!.isNotEmpty &&
                  addSearch[0]
                      .wrapperinstance!
                      .records!
                      .where((element) => element.childskus!.first.skuENTId == e.childskus!.first.skuENTId)
                      .isNotEmpty) {
                addSearch[0]
                    .wrapperinstance!
                    .records!
                    .firstWhere((element) => element.childskus!.first.skuENTId == e.childskus!.first.skuENTId)
                    .quantity = e.quantity;
              }

              if (updateCart.message!.isNotEmpty) {
                emit(state.copyWith(
                    isUpdating: false,
                    searchDetailModel: addSearch,
                    updateID: "",
                    message: updateCart.message ?? "",
                    productsInCart: LinkedHashSet<Records>.from(state.productsInCart).toList(),
                    itemOfCart: LinkedHashSet<ItemsOfCart>.from(itemOfCart).toList()));
              } else {
                emit(state.copyWith(
                  message: "Cannot update cart. Check your network connection!",
                ));
              }
            } else {
              final responseJson =
                  await inventorySearchRepository.updateCartDelete(event.records, event.customerID, event.orderID, (event.quantity).toInt());
              //  print(jsonEncode(responseJson.data));
              UpdateCart updateCart = UpdateCart.fromJson(responseJson.data);
              e.quantity = (event.quantity).toString();
              state.productsInCart.remove(state.productsInCart.firstWhere((element) => element.productId == e.productId));
              List<ItemsOfCart> itemOfCart = state.itemOfCart;

              itemOfCart.firstWhere((element) => element.itemId == e.childskus!.first.skuENTId).itemQuantity = (double.parse(e.quantity!)).toString();
              itemOfCart.remove(itemOfCart.firstWhere((element) => element.itemId == e.childskus!.first.skuENTId));
              List<AddSearchModel> addSearch = state.searchDetailModel;
              if (addSearch.isNotEmpty &&
                  addSearch[0].wrapperinstance!.records!.isNotEmpty &&
                  addSearch[0]
                      .wrapperinstance!
                      .records!
                      .where((element) => element.childskus!.first.skuENTId == e.childskus!.first.skuENTId)
                      .isNotEmpty) {
                addSearch[0]
                    .wrapperinstance!
                    .records!
                    .firstWhere((element) => element.childskus!.first.skuENTId == e.childskus!.first.skuENTId)
                    .quantity = e.quantity;
              }

              emit(state.copyWith(
                  isUpdating: false,
                  searchDetailModel: addSearch,
                  updateID: "",
                  message: updateCart.message ?? "",
                  itemOfCart: LinkedHashSet<ItemsOfCart>.from(itemOfCart).toList(),
                  productsInCart: LinkedHashSet<Records>.from(state.productsInCart).toList()));
            }
          }
        }
        // }
        if (event.fromFavorite) {
          event.favouriteBrandScreenBloc.add(RefreshList());
        }
      } catch (e) {
        print("ye error he $e");
      }
      // }
    });

    on<ChangeShowDiscount>((event, emit) async {
      emit(state.copyWith(showDiscount: event.showDiscount));
    });

    on<ChangeSelectedChoice>((event, emit) async {
      List<AddSearchModel>? mainSearchDetailModel = event.searchDetailModel;
      List<Facet>? expansionTileList = [];
      String sortedByVal;
      List<Refinement>? filteredListOfRefinments = mainSearchDetailModel!.first.filteredListOfRefinments!;
      String? sortName;
      expansionTileList = mainSearchDetailModel.first.wrapperinstance!.facet;
      if (state.options[event.indexOfItem!].onPressed == true) {
        state.options[event.indexOfItem!].onPressed = false;
        sortName = sortByText;
        emit(state.copyWith(
            loadingSearch: true,
            showDiscount: false,
            selectedChoice: '',
            currentPage: 1,
            haveMore: true,
            sortName: sortByText,
            options: state.options));
        // adding selected Filters in filteredListOfRefinments
        addingSelectedFilterToFact(expansionTileList, mainSearchDetailModel, filteredListOfRefinments);
        await getFiltersAddToModel(event, filteredListOfRefinments, '', mainSearchDetailModel).then((value) {
          if (event.isFavouriteScreen) {
            event.favoriteItems.wrapperinstance!.records = mainSearchDetailModel.first.wrapperinstance!.records;
            addProductInCart(event, mainSearchDetailModel);
          }
          // else if (event.isOfferScreen) {
          //   mainSearchDetailModel.first.listOfOfferForFilters =
          //       mainSearchDetailModel.first.wrapperinstance!.records;
          // }
          mainSearchDetailModel.first.lengthOfSelectedFilters = filteredListOfRefinments.length;
          addProductInCart(event, mainSearchDetailModel);
          filtersFunctionality(mainSearchDetailModel, filteredListOfRefinments, expansionTileList);
          emit(state.copyWith(
            searchDetailModel: mainSearchDetailModel,
            loadingSearch: false,
            currentPage: 1,
            options: state.options,
            inventorySearchStatus: InventorySearchStatus.successState,
          ));
        });
      } else {
        state.options.forEach((element) {
          element.onPressed = false;
        });
        state.options[event.indexOfItem!].onPressed = true;
        sortName = state.options.firstWhere((element) => element.onPressed == true).title;
        emit(state.copyWith(selectedChoice: event.choice, sortName: sortName));
        sortedByVal = event.choice;
        switch (sortedByVal) {
          case 'Best Match':
            sortedByVal = 'bM';
            break;
          case 'Top Seller':
            sortedByVal = 'bS';
            break;
          case 'Customer Ratings':
            sortedByVal = 'oR';
            break;
          case 'Price: High to Low':
            sortedByVal = 'pHL';
            break;
          case 'Price: Low to High':
            sortedByVal = 'pLH';
            break;
          case 'Newest First':
            sortedByVal = 'cD';
            break;
          case 'BeBrand A-Z':
            sortedByVal = 'bN';
            break;
          default:
            sortedByVal = '';
        }
        if (event.choice.isNotEmpty) {
          if (event.isOfferScreen && event.searchDetailModel!.first.lengthOfSelectedFilters == 0 && searchNameInOffersScreen.isEmpty) {
            mainSearchDetailModel.first.listOfOfferForFilters = [];
            addProductInCart(event, mainSearchDetailModel);
            emit(state.copyWith(
                showDiscount: false, selectedChoice: event.choice, currentPage: 1, haveMore: true, sortName: event.choice, options: state.options));
          } else {
            emit(state.copyWith(
                loadingSearch: true,
                showDiscount: false,
                selectedChoice: event.choice,
                currentPage: 1,
                haveMore: true,
                sortName: event.choice,
                options: state.options));
            // adding selected Filters in filteredListOfRefinments
            addingSelectedFilterToFact(expansionTileList, mainSearchDetailModel, filteredListOfRefinments);
            await getFiltersAddToModel(event, filteredListOfRefinments, sortedByVal, mainSearchDetailModel).then((value) {
              addProductInCart(event, mainSearchDetailModel);
              filtersFunctionality(mainSearchDetailModel, filteredListOfRefinments, expansionTileList);
              emit(state.copyWith(
                searchDetailModel: mainSearchDetailModel,
                loadingSearch: false,
                currentPage: 1,
                haveMore: true,
                options: state.options,
                inventorySearchStatus: InventorySearchStatus.successState,
              ));
            });
            if (event.isFavouriteScreen) {
              event.favoriteItems.wrapperinstance!.records = mainSearchDetailModel.first.wrapperinstance!.records;
              addProductInCart(event, mainSearchDetailModel);
            }
            // else if (event.isOfferScreen) {
            //   mainSearchDetailModel.first.listOfOfferForFilters =
            //       mainSearchDetailModel.first.wrapperinstance!.records;
            // }
            mainSearchDetailModel.first.lengthOfSelectedFilters = filteredListOfRefinments.length;
          }
        } else {
          emit(state.copyWith(
            selectedChoice: event.choice,
            sortName: sortName,
            currentPage: 1,
            haveMore: true,
            showDiscount: false,
            options: state.options,
          ));
        }
      }
    });

    on<ChangeSelectedSort>((event, emit) async {
      emit(state.copyWith(selectedSort: event.sort));
    });

    on<UpdateScale>((event, emit) async {
      emit(state.copyWith(scale: event.prevScale * event.zoom));
    });

    on<CommitScale>((event, emit) async {
      emit(state.copyWith(prevScale: event.scale));
    });

    on<UpdatePosition>((event, emit) async {
      emit(state.copyWith(position: event.newPosition));
    });

    on<ChangeSelectedDiscount>((event, emit) async {
      emit(state.copyWith(selectedDiscount: event.discount));
    });

    on<AddOptions>((event, emit) async {
      emit(state.copyWith(
        options: [
          OptionsModel(
            title: "Best Match",
            onPressed: false,
          ),
          OptionsModel(
            title: "Top Seller",
            onPressed: false,
          ),
          OptionsModel(
            title: "Customer Ratings",
            onPressed: false,
          ),
          OptionsModel(
            title: "Price: High to Low",
            onPressed: false,
          ),
          OptionsModel(
            title: "Price: Low to High",
            onPressed: false,
          ),
          OptionsModel(
            title: "Newest First",
            onPressed: false,
          ),
          OptionsModel(
            title: "Brand A-Z",
            onPressed: false,
          ),
        ],
      ));
    });

    on<AddFilters>((event, emit) async {
      List<AddSearchModel>? mainSearchDetailModel = state.searchDetailModel;
      List<Facet> facetList = mainSearchDetailModel.first.wrapperinstance!.facet!;

      if (facetList[event.parentIndex].multiSelect == 'false') {
        for (var i = 0; i < facetList[event.parentIndex].refinement!.length; i++) {
          if (i == event.childIndex) {
            facetList[event.parentIndex].refinement![event.childIndex].onPressed =
                !facetList[event.parentIndex].refinement![event.childIndex].onPressed!;
            if (facetList[event.parentIndex].refinement![event.childIndex].onPressed!) {
              facetList[event.parentIndex].selectedRefinement!.add(facetList[event.parentIndex].refinement![event.childIndex]);
            } else {
              facetList[event.parentIndex].selectedRefinement!.remove(facetList[event.parentIndex].refinement![event.childIndex]);
            }
          } else {
            facetList[event.parentIndex].refinement![i].onPressed = false;

            facetList[event.parentIndex].selectedRefinement!.remove(facetList[event.parentIndex].refinement![i]);
          }
        }
      } else {
        facetList[event.parentIndex].refinement![event.childIndex].onPressed = !facetList[event.parentIndex].refinement![event.childIndex].onPressed!;
        if (facetList[event.parentIndex].refinement![event.childIndex].onPressed!) {
          facetList[event.parentIndex].selectedRefinement!.add(facetList[event.parentIndex].refinement![event.childIndex]);
        } else {
          facetList[event.parentIndex].selectedRefinement!.remove(facetList[event.parentIndex].refinement![event.childIndex]);
        }
      }

      emit(state.copyWith(searchDetailModel: mainSearchDetailModel, message: "done"));
    });

    on<OnExpandMainTile>((event, emit) async {
      List<AddSearchModel>? mainSearchDetailModel = [];

      print(event.searchDetailModel);
      mainSearchDetailModel = event.searchDetailModel;
      for (var i = 0; i < event.searchDetailModel!.first.wrapperinstance!.facet!.length; i++) {
        if (i == event.index) {
          event.searchDetailModel!.first.wrapperinstance!.facet![i].isExpand = !event.searchDetailModel!.first.wrapperinstance!.facet![i].isExpand!;
        } else {
          event.searchDetailModel!.first.wrapperinstance!.facet![i].isExpand = false;
        }
      }

      emit(state.copyWith(searchDetailModel: mainSearchDetailModel, message: "zebon"));
    });

    on<EmptyMessage>((event, emit) async {
      emit(state.copyWith(message: ""));
    });

    on<DoneMessage>((event, emit) async {
      emit(state.copyWith(message: "done"));
    });

    on<OnClearFilters>((event, emit) async {
      List<AddSearchModel>? mainSearchDetailModel = event.searchDetailModel;
      List<Facet> listOfFacets = mainSearchDetailModel!.first.wrapperinstance!.facet!;
      List<Refinement>? filteredListOfRefinments = mainSearchDetailModel.first.filteredListOfRefinments!;
      String sortedByVal;
      sortedByVal = state.sortName;
      // check if sorted by value is selected
      switch (sortedByVal) {
        case 'Best Match':
          sortedByVal = 'bM';
          break;
        case 'Top Seller':
          sortedByVal = 'bS';
          break;
        case 'Customer Ratings':
          sortedByVal = 'oR';
          break;
        case 'Price: High to Low':
          sortedByVal = 'pHL';
          break;
        case 'Price: Low to High':
          sortedByVal = 'pLH';
          break;
        case 'Newest First':
          sortedByVal = 'cD';
          break;
        case 'BeBrand A-Z':
          sortedByVal = 'bN';
          break;
        default:
          sortedByVal = '';
      }
      for (var i = 0; i < mainSearchDetailModel.first.wrapperinstance!.facet!.length; i++) {
        for (var j = 0; j < listOfFacets[i].refinement!.length; j++) {
          listOfFacets[i].refinement![j].onPressed = false;
          listOfFacets[i].isExpand = false;
          listOfFacets[i].selectedRefinement!.clear();
        }
      }
      if (!event.isFavouriteScreen! && event.buildOnTap && mainSearchDetailModel.first.lengthOfSelectedFilters > 0) {
        emit(state.copyWith(
          loadingSearch: true,
        ));
        final responseJson = await inventorySearchRepository.applyFilters(
            searchName: event.searchName!,
            selectedId: filteredListOfRefinments.isEmpty ? '' : filteredListOfRefinments[filteredListOfRefinments.length - 1].id!,
            filteredListOfRefinements: filteredListOfRefinments,
            sortedByVal: sortedByVal);
        mainSearchDetailModel.clear();
        mainSearchDetailModel.add(AddSearchModel.fromJson(responseJson.data));
        emit(state.copyWith(
          loadingSearch: false,
        ));
      } else if (event.isFavouriteScreen! && event.buildOnTap && mainSearchDetailModel.first.lengthOfSelectedFilters > 0) {
        emit(state.copyWith(
          loadingSearch: true,
        ));
        final responseJson = await inventorySearchRepository.applyFilters(
            searchName: event.searchName!,
            selectedId: filteredListOfRefinments.isEmpty ? '' : filteredListOfRefinments[filteredListOfRefinments.length - 1].id!,
            filteredListOfRefinements: filteredListOfRefinments,
            sortedByVal: sortedByVal);
        mainSearchDetailModel.clear();
        mainSearchDetailModel.add(AddSearchModel.fromJson(responseJson.data));
        event.favoriteItems!.wrapperinstance!.records = mainSearchDetailModel.first.wrapperinstance!.records;
        emit(state.copyWith(
          loadingSearch: false,
        ));
      }
      mainSearchDetailModel.first.lengthOfSelectedFilters = 0;
      addProductInCart(event, mainSearchDetailModel);
      emit(state.copyWith(
          searchDetailModel: mainSearchDetailModel,
          message: "Done",
          loadingSearch: false,
          currentPage: 1,
          haveMore: true,
          options: state.options,
          sortName: state.sortName));
    });

    on<SearchProductWithFilters>((event, emit) async {
      List<AddSearchModel>? mainSearchDetailModel = event.searchDetailModel;

      List<Facet>? expansionTileList = [];
      String sortedByVal;
      sortedByVal = event.choice;
      // check if sorted by value is selected
      switch (sortedByVal) {
        case 'Best Match':
          sortedByVal = 'bM';
          break;
        case 'Top Seller':
          sortedByVal = 'bS';
          break;
        case 'Customer Ratings':
          sortedByVal = 'oR';
          break;
        case 'Price: High to Low':
          sortedByVal = 'pHL';
          break;
        case 'Price: Low to High':
          sortedByVal = 'pLH';
          break;
        case 'Newest First':
          sortedByVal = 'cD';
          break;
        case 'BeBrand A-Z':
          sortedByVal = 'bN';
          break;
        default:
          sortedByVal = '';
      }
      expansionTileList = mainSearchDetailModel!.first.wrapperinstance!.facet;
      List<Refinement>? filteredListOfRefinments = mainSearchDetailModel.first.filteredListOfRefinments!;
      // mark  selected filters in a model
      for (var i = 0; i < expansionTileList!.length; i++) {
        if (expansionTileList[i].selectedRefinement!.isNotEmpty) {
          for (var j = 0; j < expansionTileList[i].selectedRefinement!.length; j++) {
            filteredListOfRefinments.add(expansionTileList[i].selectedRefinement![j]);
          }
        }
      }
      emit(state.copyWith(loadingSearch: true, showDiscount: false));
      if (event.isFavouriteScreen! || event.isOfferScreen!) {
        // if its favourite screen then apply filters accordingly
        final responseJson = await inventorySearchRepository.applyFilters(
            searchName: event.searText,
            selectedId: filteredListOfRefinments.isEmpty ? '' : filteredListOfRefinments[filteredListOfRefinments.length - 1].id!,
            filteredListOfRefinements: event.filteredListOfRefinements,
            sortedByVal: sortedByVal);
        mainSearchDetailModel.clear();
        mainSearchDetailModel.add(AddSearchModel.fromJson(responseJson.data));
      } else {
        // apply filters for inventory
        final responseJson = await inventorySearchRepository.applyFilters(
            searchName: event.searText,
            selectedId: filteredListOfRefinments.isEmpty ? '' : filteredListOfRefinments[filteredListOfRefinments.length - 1].id!,
            filteredListOfRefinements: event.filteredListOfRefinements,
            sortedByVal: sortedByVal);
        mainSearchDetailModel.clear();
        mainSearchDetailModel.add(AddSearchModel.fromJson(responseJson.data));
      }
      // filters for favourite Brand screen
      if (event.isFavouriteScreen!) {
        event.favoriteItems!.wrapperinstance!.records = mainSearchDetailModel.first.wrapperinstance!.records;
        for (var i = 0; i < event.favoriteItems!.wrapperinstance!.records!.length; i++) {
          event.favoriteItems!.wrapperinstance!.records![i].quantity = mainSearchDetailModel.first.wrapperinstance!.records![i].quantity;
        }
      } else if (event.isOfferScreen! && filteredListOfRefinments.isNotEmpty) {
        mainSearchDetailModel.first.listOfOfferForFilters = mainSearchDetailModel.first.wrapperinstance!.records;
      } else if (event.isFavouriteScreen! && filteredListOfRefinments.isEmpty && sortedByVal.isEmpty) {
        event.favoriteItems!.wrapperinstance!.records = [];
        fbdm.FavoriteBrandDetailModel favoriteBrandDetailModel = await getRecordDetail(event.brandName!, event.primaryInstrument!);
        event.favoriteItems!.wrapperinstance!.records = favoriteBrandDetailModel.wrapperinstance!.records;
        for (var i = 0; i < event.favoriteItems!.wrapperinstance!.records!.length; i++) {
          event.favoriteItems!.wrapperinstance!.records![i].quantity = mainSearchDetailModel.first.wrapperinstance!.records![i].quantity;
        }
      }
      mainSearchDetailModel.first.lengthOfSelectedFilters = filteredListOfRefinments.length;
      // mapping already selected Filters
      for (var i = 0; i < filteredListOfRefinments.length; i++) {
        for (var j = 0; j < mainSearchDetailModel.first.wrapperinstance!.facet!.length; j++) {
          if (mainSearchDetailModel.first.wrapperinstance!.facet![j].dimensionId == filteredListOfRefinments[i].dimensionId) {
            mainSearchDetailModel.first.wrapperinstance!.facet![j].selectedRefinement!.add(filteredListOfRefinments[i]);
            mainSearchDetailModel.first.wrapperinstance!.facet![j].refinement!.insert(0, filteredListOfRefinments[i]);
            mainSearchDetailModel.first.wrapperinstance!.facet![j].refinement!.toSet().toList();
          } else {}
        }
      }
      // collect selected facet to add refinments if they are not returned by the list.
      List<Facet>? selectedFacets = [];
      for (var i = 0; i < expansionTileList.length; i++) {
        if (expansionTileList[i].selectedRefinement!.isNotEmpty) {
          selectedFacets.add(Facet(
              refinement: expansionTileList[i].refinement,
              rank: expansionTileList[i].rank,
              multiSelect: expansionTileList[i].multiSelect,
              displayName: expansionTileList[i].displayName,
              dimensionId: expansionTileList[i].dimensionId,
              dimensionName: expansionTileList[i].displayName,
              isExpand: expansionTileList[i].isExpand,
              selectedRefinement: expansionTileList[i].selectedRefinement));
        }
      }
      for (var i = 0; i < selectedFacets.length; i++) {
        selectedFacets[i].refinement!.removeWhere((element) => element.onPressed == false);
      }
      print(selectedFacets);
      // add that facets to the mainSearchDetailModel that are not returned by the data
      mainSearchDetailModel.first.wrapperinstance!.facet!.insertAll(
          0,
          selectedFacets.where((selectedFilter) =>
              mainSearchDetailModel.first.wrapperinstance!.facet!.every((newList) => newList.dimensionId != selectedFilter.dimensionId)));
      // Cart functionality
      addProductInCart(event, mainSearchDetailModel);
      mainSearchDetailModel.first.lengthOfSelectedFilters = event.searchDetailModel!.first.lengthOfSelectedFilters;
      //  responseStream.add(true);
      emit(state.copyWith(
          searchDetailModel: mainSearchDetailModel,
          loadingSearch: false,
          inventorySearchStatus: InventorySearchStatus.successState,
          currentPage: 1,
          haveMore: true));
    });
  }
}
