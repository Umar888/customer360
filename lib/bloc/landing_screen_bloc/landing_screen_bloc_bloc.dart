import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:gc_customer_app/data/reporsitories/landing_screen_repository/landing_screen_repository.dart';
import 'package:gc_customer_app/models/activity_class.dart';
import 'package:gc_customer_app/models/landing_screen/assigned_agent.dart';
import 'package:gc_customer_app/models/landing_screen/credit_balance.dart';
import 'package:gc_customer_app/models/landing_screen/customer_info_model.dart';
import 'package:gc_customer_app/models/landing_screen/landing_scree_offers_model.dart';
import 'package:gc_customer_app/models/landing_screen/landing_screen_order_history.dart';
import 'package:gc_customer_app/models/landing_screen/landing_screen_recommendation_model_buy_again.dart';
import 'package:gc_customer_app/models/landing_screen/landing_screen_reminders.dart' as lrp;
import 'package:gc_customer_app/models/landing_screen/landing_screen_tags_model.dart';
import 'package:gc_customer_app/models/landing_screen/landing_task_model.dart';
import 'package:gc_customer_app/services/extensions/string_extension.dart';
import 'package:gc_customer_app/services/storage/shared_preferences_service.dart';

import '../../constants/colors.dart';
import '../../models/landing_screen/agent_list.dart';
import '../../models/landing_screen/landing_screen_item_availability.dart';
import '../../models/landing_screen/landing_screen_open_orders.dart' as open;
import '../../models/landing_screen/landing_screen_recommendation_model.dart';
import '../../models/offers_list_model.dart';
import '../../models/pinned_notes_model.dart';
import '../../primitives/constants.dart';

part 'landing_screen_bloc_event.dart';

part 'landing_screen_bloc_state.dart';

class LandingScreenBloc extends Bloc<LandingScreenBlocEvent, LandingScreenState> {
  LandingScreenRepository landingScreenRepository;

  LandingScreenBloc({required this.landingScreenRepository}) : super(LandingScreenState()) {
    on<AssignAgent>((event, emit) async {
      if (event.isStore) {
        emit(state.copyWith(isAssigningStoreAgent: true));
      } else {
        emit(state.copyWith(isAssigningCCAgent: true));
      }
      AssignedAgent assignedAgent = await assignAgent(event.agentId);
      if (assignedAgent.agentStore != null) {
        emit(state.copyWith(
            assignedAgent: assignedAgent, isAssigningStoreAgent: false, isAssigningCCAgent: false, message: "Agent assigned successfully"));
      } else {
        emit(state.copyWith(
            assignedAgent: state.assignedAgent!.agentStore == null ? assignedAgent : state.assignedAgent!,
            isAssigningStoreAgent: false,
            isAssigningCCAgent: false,
            message: assignedAgent.message));
      }
    });

    on<ClearMessage>((event, emit) {
      emit(state.copyWith(message: ""));
    });

    on<SearchAgentList>((event, emit) async {
      List<AgentList> searchedAgentList = [];

      for (var agent in state.agentList!) {
        if (agent.name != null) {
          var agentName = agent.name!.toLowerCase();
          var searchedNameString = event.searchString.toLowerCase();
          if (agentName.contains(searchedNameString)) {
            var searchedStringList = searchedNameString.split('');
            var nameStringList = agentName.split('');
            for (var i = 0; i < searchedStringList.length; i++) {
              if (nameStringList.elementAt(i) == searchedStringList.elementAt(i)) {
                if (!searchedAgentList.contains(agent)) {
                  searchedAgentList.add(agent);
                }
              }
            }
          }
        }
        // if (agent.employeeNumber != null) {
        //   var agentId = agent.employeeNumber!.toLowerCase();
        //   var searchedIdString = event.searchString.toLowerCase();
        //   if (agentId.contains(searchedIdString)) {
        //     var searchedStringList = searchedIdString.split('');
        //     var nameStringList = agentId.split('');
        //     for (var i = 0; i < searchedStringList.length; i++) {
        //       if (nameStringList.elementAt(i) ==
        //           searchedStringList.elementAt(i)) {
        //         if (searchedAgentList.contains(agent)) {
        //           return;
        //         } else {
        //           searchedAgentList.add(agent);
        //         }
        //       }
        //     }
        //   }
        // }
      }
      emit(state.copyWith(
        gettingAgentsList: false,
        isSearchAgent: true,
        message: "",
        gettingAgentAssigned: false,
        searchedAgentList: searchedAgentList,
      ));
    });

    on<CheckAgent>((event, emit) async {
      AssignedAgent agent = await getAssignedAgent();
      emit(state.copyWith(
        gettingAgentsList: false,
        isSearchAgent: false,
        gettingAgentAssigned: false,
        message: "",
        assignedAgent: agent,
        searchedAgentList: [],
        isAgentAssigned: agent.agentStore == null ? false : true,
      ));
    });

    on<ClearSearchList>((event, emit) async {
      emit(state.copyWith(
        gettingAgentsList: false,
        message: "",
        isSearchAgent: false,
        searchedAgentList: [],
        gettingAgentAssigned: false,
      ));
    });

    on<GetAgentList>((event, emit) async {
      emit(state.copyWith(
        gettingAgentsList: true,
        message: "",
        agentList: [],
        searchedAgentList: [],
        isSearchAgent: false,
        gettingAgentAssigned: false,
      ));

      AgentsList agent = await getAgentList();
      emit(state.copyWith(
        isSearchAgent: false,
        gettingAgentsList: false,
        agentList: agent.agentList,
        gettingAgentAssigned: false,
        message: "",
        searchedAgentList: [],
      ));
    });

    on<GetRecommendedItemStock>((event, emit) async {
      LandingScreenRecommendationModel landingScreenRecommendationModel = state.landingScreenRecommendationModel ?? event.recommendationModel!;
      LandingScreenRecommendationModelBuyAgain landingScreenRecommendationModelBuyAgain =
          state.landingScreenRecommendationModelBuyAgain ?? event.recommendationModelBuyAgain!;
      ItemAvailabilityLandingScreenModel itemAvailabilityLandingScreenModel = await getItemAvailability(event.itemSkuId);

      if (landingScreenRecommendationModel.productBrowsing!.isNotEmpty) {
        if (landingScreenRecommendationModel.productBrowsing!.first.recommendedProductSet!
            .where((element) => element.itemSKU == event.itemSkuId)
            .isNotEmpty) {
          landingScreenRecommendationModel.productBrowsing!.first.recommendedProductSet!
              .firstWhere((element) => element.itemSKU == event.itemSkuId)
              .outOfStock = itemAvailabilityLandingScreenModel.outOfStock;
          landingScreenRecommendationModel.productBrowsing!.first.recommendedProductSet!
              .firstWhere((element) => element.itemSKU == event.itemSkuId)
              .noInfo = itemAvailabilityLandingScreenModel.noInfo;
          landingScreenRecommendationModel.productBrowsing!.first.recommendedProductSet!
              .firstWhere((element) => element.itemSKU == event.itemSkuId)
              .inStore = itemAvailabilityLandingScreenModel.inStore;
        }
      } else if (landingScreenRecommendationModel.productBrowsingOthers!.isNotEmpty &&
          landingScreenRecommendationModel.productBrowsingOthers!.first.recommendedProductSet!
              .where((element) => element.itemSKU == event.itemSkuId)
              .isNotEmpty) {
        landingScreenRecommendationModel.productBrowsingOthers!.first.recommendedProductSet!
            .firstWhere((element) => element.itemSKU == event.itemSkuId)
            .outOfStock = itemAvailabilityLandingScreenModel.outOfStock;
        landingScreenRecommendationModel.productBrowsingOthers!.first.recommendedProductSet!
            .firstWhere((element) => element.itemSKU == event.itemSkuId)
            .noInfo = itemAvailabilityLandingScreenModel.noInfo;
        landingScreenRecommendationModel.productBrowsingOthers!.first.recommendedProductSet!
            .firstWhere((element) => element.itemSKU == event.itemSkuId)
            .inStore = itemAvailabilityLandingScreenModel.inStore;
      } else if (landingScreenRecommendationModelBuyAgain.productBuyAgain!.isNotEmpty &&
          landingScreenRecommendationModelBuyAgain.productBuyAgain!.where((element) => element.itemSKUC == event.itemSkuId).isNotEmpty) {
        landingScreenRecommendationModelBuyAgain.productBuyAgain!.firstWhere((element) => element.itemSKUC == event.itemSkuId).outOfStock =
            itemAvailabilityLandingScreenModel.outOfStock;
        landingScreenRecommendationModelBuyAgain.productBuyAgain!.firstWhere((element) => element.itemSKUC == event.itemSkuId).noInfo =
            itemAvailabilityLandingScreenModel.noInfo;
        landingScreenRecommendationModelBuyAgain.productBuyAgain!.firstWhere((element) => element.itemSKUC == event.itemSkuId).inStore =
            itemAvailabilityLandingScreenModel.inStore;
      }
      emit(state.copyWith(
        isSearchAgent: false,
        gettingAgentsList: false,
        searchedAgentList: [],
        message: "",
      ));
    });

    on<LoadActivity>((event, emit) async {
      // try{
      open.LandingScreenOpenOrderModels openOrdersLandingScreenModel = await getOpenOrder();
      // OpenCasesLandingScreenModel openCasesLandingScreenModel = await getOpenCases();
      LandingScreenRecommendationModel landingScreenRecommendationModel = await getRecommendations();
      emit(state.copyWith(
        openOrder: openOrdersLandingScreenModel.openOrders!.isNotEmpty
            ? ActivityClass(
                typeOfOrder: 'Open Orders',
                numberOfOrders: openOrdersLandingScreenModel.openOrders!
                    .where((element) =>
                        element.gCOrderLineItemsR != null &&
                        element.gCOrderLineItemsR!.records != null &&
                        element.gCOrderLineItemsR!.records!.isNotEmpty)
                    .length
                    .toString(),
                valueOfOrder: openOrdersLandingScreenModel.openOrders!.where((element) => element.gCOrderLineItemsR != null && element.gCOrderLineItemsR!.records != null && element.gCOrderLineItemsR!.records!.isNotEmpty).isNotEmpty
                    ? openOrdersLandingScreenModel.openOrders!
                        .where((element) =>
                            element.gCOrderLineItemsR != null &&
                            element.gCOrderLineItemsR!.records != null &&
                            element.gCOrderLineItemsR!.records!.isNotEmpty)
                        .fold(0, (previous, current) => previous + double.parse(current.totalC!.toString()).toInt())
                        .toDouble()
                        .toStringAsFixed(2)
                    : "0",
                dateoforder: openOrdersLandingScreenModel.openOrders![0].lastModifiedDate
                    .toString()
                    .changeToBritishFormatHalf(openOrdersLandingScreenModel.openOrders![0].lastModifiedDate.toString()),
                itemsOfOrder:
                    openOrdersLandingScreenModel.openOrders!.where((element) => element.gCOrderLineItemsR != null && element.gCOrderLineItemsR!.records != null && element.gCOrderLineItemsR!.records!.isNotEmpty).isNotEmpty
                        ? openOrdersLandingScreenModel.openOrders!
                            .where((element) =>
                                element.gCOrderLineItemsR != null &&
                                element.gCOrderLineItemsR!.records != null &&
                                element.gCOrderLineItemsR!.records!.isNotEmpty)
                            .fold(0, (previous, current) => previous + current.gCOrderLineItemsR!.totalSize!.toInt())
                            .toString()
                        : "0")
            : ActivityClass(typeOfOrder: 'Open Orders', numberOfOrders: "0", valueOfOrder: "0.00", dateoforder: DateTime.now().toString().changeToBritishFormatHalf(DateTime.now().toString()), itemsOfOrder: "0"),
        openCases: ActivityClass(
            typeOfOrder: 'Open Cases',
            numberOfOrders: "0",
            valueOfOrder: "0.00",
            dateoforder: DateTime.now().toString().changeToBritishFormatHalf(DateTime.now().toString()),
            itemsOfOrder: "0"),
        browsingHistory: landingScreenRecommendationModel.productBrowsing != null && landingScreenRecommendationModel.productBrowsing!.isNotEmpty
            ? ActivityClass(
                typeOfOrder: 'Browsing History',
                numberOfOrders: (landingScreenRecommendationModel.productBrowsing![0].recommendedProductSet!.length).toString(),
                valueOfOrder: (landingScreenRecommendationModel.productBrowsing![0].recommendedProductSet!
                    .fold(0.0, (previous, current) => previous + current.salePrice!)).toStringAsFixed(2),
                dateoforder: DateTime.now().toString().changeToBritishFormatHalf(DateTime.now().toString()),
                itemsOfOrder: (landingScreenRecommendationModel.productBrowsing![0].recommendedProductSet!.length).toString())
            : ActivityClass(
                typeOfOrder: 'Browsing History',
                numberOfOrders: "0",
                valueOfOrder: "0.00",
                dateoforder: DateTime.now().toString().changeToBritishFormatHalf(DateTime.now().toString()),
                itemsOfOrder: "0"),
        gettingAgentsList: false,
        landingScreenRecommendationModel: landingScreenRecommendationModel,
        isSearchAgent: false,
        gettingActivity: false,
        message: "",
        searchedAgentList: [],
      ));
      // }
      //       catch(e){
      //     log("errroroor $e");
      //       }
    });

    on<LoadFavoriteBrands>((event, emit) async {
      LandingScreenOrderHistory favoriteBrandsLandingScreen = await getOrderHistory();

      emit(state.copyWith(
        favoriteBrandsLandingScreen: favoriteBrandsLandingScreen.brands,
        orderHistoryLandingScreen: favoriteBrandsLandingScreen.orderHistory,
        gettingAgentsList: false,
        isSearchAgent: false,
        searchedAgentList: [],
        gettingFavorites: false,
        message: "",
      ));
    });

    on<LoadOffers>((event, emit) async {
      LandingScreenOffersModel landingScreenOffersModel = await getOffers();
      emit(state.copyWith(
        landingScreenOffersModel: landingScreenOffersModel,
        gettingOffers: false,
        message: "",
      ));
    });

    on<PinnedNotesChange>((event, emit) async {
      List<PinnedNotes> p = state.pinnedNotesList ?? [];
      List<PinnedNotes> new_p = [];

      for (int k = 0; k < p.length; k++) {
        if (k == event.index) {
          new_p.add(PinnedNotes(
            textOfNote: p[k].textOfNote,
            authorOfNote: p[k].authorOfNote,
            isLess: p[k].isLess! ? false : true,
            dateOfNote: p[k].dateOfNote,
            backgroundColor: p[k].backgroundColor,
          ));
        } else {
          new_p.add(PinnedNotes(
            textOfNote: p[k].textOfNote,
            authorOfNote: p[k].authorOfNote,
            isLess: p[k].isLess,
            dateOfNote: p[k].dateOfNote,
            backgroundColor: p[k].backgroundColor,
          ));
        }
      }
      emit(state.copyWith(
        pinnedNotesList: List.from(new_p),
        isSearchAgent: false,
        gettingAgentsList: false,
        message: "",
        searchedAgentList: [],
      ));
    });

    on<ReloadReminders>((event, emit) async {
      CustomerTagging customerTagging = await getTags();

      lrp.LandingScreenReminders landingScreenReminders = await getReminders();
      emit(state.copyWith(
        landingScreenReminders: landingScreenReminders,
        tags: customerTagging.data,
      ));
    });

    on<ReloadTasks>((event, emit) async {
      print("reloading");
      List<AggregatedTaskList> taskModel = await getCustomerTasks();
      emit(state.copyWith(
        taskModel: taskModel,
      ));
    });

    on<RemoveCustomer>((event, emit) async {
      emit(state.copyWith(customerInfoModel: CustomerInfoModel(records: [Records(id: null)]), message: ""));
    });

    on<LoadData>((event, emit) async {
      print("yex we loadin");
      emit(state.copyWith(landingScreenStatus: LandingScreenStatus.initial, message: ""));
      CustomerInfoModel customerInfoModel = await getCustomerInfo(event.appName);
      if (customerInfoModel != null && customerInfoModel.records != null && customerInfoModel.records!.isNotEmpty) {
        if (kIsWeb) {
          emit(state.copyWith(
            gettingAgentsList: true,
            isSearchAgent: false,
            gettingOffers: true,
            agentList: [],
            message: "",
            searchedAgentList: [],
            landingScreenStatus: LandingScreenStatus.success,
            customerInfoModel: customerInfoModel,
            gettingActivity: true,
            gettingFavorites: true,
            gettingAgentAssigned: true,
            isAgentAssigned: false,
          ));
        }
        // LandingScreenRecommendationModel landingScreenRecommendationModel =
        //     await getRecommendations();
        // LandingScreenRecommendationModelBuyAgain
        //     landingScreenRecommendationModelBuyAgain =
        //     await getRecommendationsBuyAgain();

        final List<OffersList> offersList = [];
        final List<PinnedNotes> pinnedNotesList = [];
        pinnedNotesList.add(PinnedNotes(
            textOfNote:
                'Jessica  is a gutiar geerk, and loves acoustic n,c vcvbjJessica  is a gutiar geerk, and loves acoustic n,c vcvbjJessica  is a gutiar geerk, and loves acoustic n,c vcvbjJessica  is a gutiar geerk, and loves acoustic n,c vcvbjJessica  is a gutiar geerk, and loves acoustic n,c vcvbj',
            authorOfNote: 'john Doe',
            dateOfNote: 'Aug 20, 2022',
            isLess: true,
            backgroundColor: AppColors.skyblueHex));
        pinnedNotesList.add(PinnedNotes(
            textOfNote:
                'Jessica  is a gutiar geerk, and loves acoustic n,c vcvbjJessica  is a gutiar geerk, and loves acoustic n,c vcvbjJessica  is a gutiar geerk, and loves acoustic n,c vcvbjJessica  is a gutiar geerk, and loves acoustic n,c vcvbjJessica  is a gutiar geerk, and loves acoustic n,c vcvbj',
            authorOfNote: 'john Doe',
            isLess: true,
            dateOfNote: 'Aug 20, 2022',
            backgroundColor: AppColors.yellowNotes));
        emit(state.copyWith(
          offerList: offersList,
          // landingScreenRecommendationModelBuyAgain:
          //     landingScreenRecommendationModelBuyAgain,
          // landingScreenRecommendationModel: landingScreenRecommendationModel,
          pinnedNotesList: pinnedNotesList,
          // landingScreenReminders: landingScreenReminders,
          gettingAgentsList: true,
          isSearchAgent: false,
          gettingOffers: true,
          agentList: [],
          message: "",
          searchedAgentList: [],
          landingScreenStatus: LandingScreenStatus.success,
          customerInfoModel: customerInfoModel,
          // taskModel: taskModel,
          gettingActivity: true,
          gettingFavorites: true,
          gettingAgentAssigned: true,
          isAgentAssigned: false,
        ));
      } else {
        emit(state.copyWith(
          gettingAgentsList: true,
          isSearchAgent: false,
          gettingOffers: true,
          tags: {},
          agentList: [],
          message: "",
          searchedAgentList: [],
          landingScreenStatus: customerInfoModel.done! ? LandingScreenStatus.success : LandingScreenStatus.failure,
          customerInfoModel: customerInfoModel,
          taskModel: [],
          gettingActivity: true,
          gettingFavorites: true,
          gettingAgentAssigned: true,
          isAgentAssigned: false,
        ));
      }
    });
  }

  Future<CustomerInfoModel> getCustomerInfo(String appName) async {
    String message = "";

    var id = await SharedPreferenceService().getValue(agentId);
    var loggedinUserId = await SharedPreferenceService().getValue(loggedInAgentId);

    print("this is agent id $id");
    late CustomerInfoModel response;
    if (id.isNotEmpty) {
      response = await landingScreenRepository.getCustomerInfoById(id);
      await landingScreenRepository.getCustomerSearchById(appName, id, loggedinUserId);

      if (response.records!.isEmpty) {
        message = "User not found";
      } else {
        if (response.records![0].id != null) {
          SharedPreferenceService().setKey(key: agentId, value: response.records![0].id!);
        }
        if (response.records![0].accountEmailC != null) {
          SharedPreferenceService().setKey(key: agentEmail, value: response.records![0].accountEmailC!);
        } else if (response.records![0].emailC != null) {
          SharedPreferenceService().setKey(key: agentEmail, value: response.records![0].emailC!);
        } else if (response.records![0].personEmail != null) {
          SharedPreferenceService().setKey(key: agentEmail, value: response.records![0].personEmail!);
        }
        if (response.records![0].name != null) {
          SharedPreferenceService().setKey(key: savedAgentName, value: response.records![0].name!);
        }
        if (response.records![0].accountEmailC != null) {
          SharedPreferenceService().setKey(key: agentEmail, value: response.records![0].accountEmailC!);
        } else if (response.records![0].emailC != null) {
          SharedPreferenceService().setKey(key: agentEmail, value: response.records![0].emailC!);
        } else if (response.records![0].personEmail != null) {
          SharedPreferenceService().setKey(key: agentEmail, value: response.records![0].personEmail!);
        }
      }
    } else {
      if (kIsWeb) return CustomerInfoModel(records: [], done: false);
      return CustomerInfoModel(records: [Records(id: null)], done: false);
    }
    return response;
  }

  Future<List<AggregatedTaskList>> getCustomerTasks() async {
    String id = await SharedPreferenceService().getValue(agentId);
    final response = await landingScreenRepository.getCustomerTasks(id);
    return response;
  }

  Future<LandingScreenRecommendationModel> getRecommendations() async {
    String id = await SharedPreferenceService().getValue(agentId);
    final response = await landingScreenRepository.getRecommendation("BrowsingHistory", id);
    return response;
  }

  Future<LandingScreenRecommendationModelBuyAgain> getRecommendationsBuyAgain() async {
    String id = await SharedPreferenceService().getValue(agentId);
    final response = await landingScreenRepository.getRecommendationBuyAgain("BuyAgain", id);
    return response;
  }

  Future<lrp.LandingScreenReminders> getReminders() async {
    String id = await SharedPreferenceService().getValue(agentId);
    String loggedInAgent = await SharedPreferenceService().getValue(loggedInAgentId);
    print("loggedInAgent => $loggedInAgent");
    final response = await landingScreenRepository.getReminders(id, loggedInAgent);
    return response;
  }

  Future<AssignedAgent> getAssignedAgent() async {
    String id = await SharedPreferenceService().getValue(agentId);
    String loggedInAgent = await SharedPreferenceService().getValue(loggedInAgentId);
    print("checking assigned agent");
    final response = await landingScreenRepository.getAssignedAgent(id, loggedInAgent);
    return response;
  }

  Future<AssignedAgent> assignAgent(String agentsId) async {
    String id = await SharedPreferenceService().getValue(agentId);
    final response = await landingScreenRepository.assignAgent(id, agentsId);
    return response;
  }

  Future<AgentsList> getAgentList() async {
    String id = await SharedPreferenceService().getValue(agentId);
    String loggedInAgent = await SharedPreferenceService().getValue(loggedInAgentId);

    final response = await landingScreenRepository.getAgentList(id, loggedInAgent);
    return response;
  }

  Future<open.LandingScreenOpenOrderModels> getOpenOrder() async {
    String id = await SharedPreferenceService().getValue(agentId);
    final response = await landingScreenRepository.getOpenOrders(id);
    return response;
  }

  // Future<OpenCasesLandingScreenModel> getOpenCases() async {
  //   var id = await SharedPreferenceService().getValue(agentId);
  //   final response = await landingScreenRepository.getOpenCases(id);
  //   return response;
  // }

  Future<CustomerTagging> getTags([String? otherUserId]) async {
    String id = await SharedPreferenceService().getValue(agentId);
    final response = await landingScreenRepository.getTags(id);
    return response;
  }

  Future<ItemAvailabilityLandingScreenModel> getItemAvailability(String itemSkuId) async {
    var loggedInUserId = await SharedPreferenceService().getValue(loggedInAgentId);
    final response = await landingScreenRepository.getItemAvailability(itemSkuId, loggedInUserId);
    return response;
  }

  Future<LandingScreenOrderHistory> getOrderHistory() async {
    String id = await SharedPreferenceService().getValue(agentId);
    final response = await landingScreenRepository.getOrderHistory(id);
    return response;
  }

  Future<LandingScreenOffersModel> getOffers() async {
    final response = await landingScreenRepository.getOffers();
    return response;
  }
}
