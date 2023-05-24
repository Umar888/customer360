import 'dart:convert';
import 'dart:developer';

import 'package:gc_customer_app/data/data_sources/landing_screen_data_source/landing_screen_data_source.dart';
import 'package:gc_customer_app/models/landing_screen/agent_list.dart';
import 'package:gc_customer_app/models/landing_screen/assigned_agent.dart';
import 'package:gc_customer_app/models/landing_screen/credit_balance.dart';
import 'package:gc_customer_app/models/landing_screen/customer_info_model.dart';
import 'package:gc_customer_app/models/landing_screen/landing_scree_offers_model.dart';
import 'package:gc_customer_app/models/landing_screen/landing_screen_item_availability.dart';
import 'package:gc_customer_app/models/landing_screen/landing_screen_open_orders.dart';
import 'package:gc_customer_app/models/landing_screen/landing_screen_order_history.dart';
import 'package:gc_customer_app/models/landing_screen/landing_screen_recommendation_model.dart';
import 'package:gc_customer_app/models/landing_screen/landing_screen_recommendation_model_buy_again.dart';
import 'package:gc_customer_app/models/landing_screen/landing_screen_reminders.dart' as lrp;
import 'package:gc_customer_app/models/landing_screen/landing_screen_tags_model.dart';
import 'package:gc_customer_app/models/landing_screen/landing_task_model.dart';
import 'package:gc_customer_app/services/networking/http_response.dart';

import '../../../models/user_profile_model.dart';

class LandingScreenRepository {
  LandingScreenDataSource landingScreenDataSource = LandingScreenDataSource();

  Future<CustomerInfoModel> getCustomerInfo(String email) async {
    var response = await landingScreenDataSource.getCustomerProfile(email);
    if (response.data != null && response.status! && response.data['records'] != null && response.data['records'].isNotEmpty) {
      print("phone cccc ${response.data['records'][0]['Phone__c']}");
      return CustomerInfoModel.fromJson(response.data);
    } else {
      return CustomerInfoModel(records: [], totalSize: 0);
    }
  }

  Future<CustomerInfoModel> getCustomerInfoById(String id) async {
    var response = await landingScreenDataSource.getCustomerProfileById(id);
    if (response.data != null && response.status! && response.data['records'] != null && response.data['records'].isNotEmpty) {
      return CustomerInfoModel.fromJson(response.data);
    } else {
      return CustomerInfoModel(records: [], totalSize: 0, done: true);
    }
  }

  Future<HttpResponse> getCustomerSearchById(String appName,String recordId, String loggedinUserId) async {
    return await landingScreenDataSource.getCustomerSearchById(appName, recordId, loggedinUserId);
  }

  Future<List<AggregatedTaskList>> getCustomerTasks(String id) async {
    var responseTasks = await landingScreenDataSource.getCustomerTasks(id);
    List<AggregatedTaskList> myTaskList = [];
    LandingTaskModel taskModel = LandingTaskModel.fromJson(responseTasks.data);
    for (var agentTaskJson in taskModel.aggregatedTaskList!) {
//      if (agentTaskJson.ownerId.toString() == id.toString()) {
      myTaskList.add(agentTaskJson);
//      }
    }
    return myTaskList;
  }

  Future<LandingScreenRecommendationModel> getRecommendation(String type, String id) async {
    var responseTasks = await landingScreenDataSource.getRecommendation("BrowsingHistory", id);

    if (responseTasks.data != null && responseTasks.data["message"].toString().toLowerCase() == "record found.") {
      LandingScreenRecommendationModel landingScreenRecommendationModel = LandingScreenRecommendationModel.fromJson(responseTasks.data);
      return landingScreenRecommendationModel;
    } else {
      return LandingScreenRecommendationModel(status: 401, productBrowsing: []);
    }
  }

  Future<LandingScreenRecommendationModelBuyAgain> getRecommendationBuyAgain(String type, String id) async {
    var responseTasks = await landingScreenDataSource.getRecommendation("BuyAgain", id);
    log(jsonEncode(responseTasks.data));

    if (responseTasks.data != null && responseTasks.data["message"].toString().toLowerCase() == "record found.") {
      LandingScreenRecommendationModelBuyAgain landingScreenRecommendationModel =
          LandingScreenRecommendationModelBuyAgain.fromJson(responseTasks.data);
      return landingScreenRecommendationModel;
    } else {
      return LandingScreenRecommendationModelBuyAgain(productBuyAgain: []);
    }
  }

  Future<lrp.LandingScreenReminders> getReminders(String recordID, String userID) async {
    var responseTasks = await landingScreenDataSource.getReminders(recordID, userID);
    if (responseTasks.data != null && responseTasks.data["AllOpenTasks"] != null) {
      lrp.LandingScreenReminders landingScreenReminders = lrp.LandingScreenReminders.fromJson(responseTasks.data);
      return landingScreenReminders;
    } else {
      return lrp.LandingScreenReminders(allOpenTasks: []);
    }
  }

  Future<LandingScreenOpenOrderModels> getOpenOrders(String recordID) async {
    var responseTasks = await landingScreenDataSource.getOpenOrders(recordID);
    if (responseTasks.data != null && responseTasks.data["OpenOrders"] != null) {
      LandingScreenOpenOrderModels openOrdersLandingScreenModel = LandingScreenOpenOrderModels.fromJson(responseTasks.data);
      return openOrdersLandingScreenModel;
    } else {
      return LandingScreenOpenOrderModels(openOrders: []);
    }
  }

  Future<LandingScreenOrderHistory> getOrderHistory(String recordID) async {
    print("load ing fav");
    var responseTasks = await landingScreenDataSource.getOrderHistory(recordID);
    if (responseTasks.data != null && responseTasks.data["OrderHistory"] != null && responseTasks.data["brands"] != null) {
      LandingScreenOrderHistory openOrdersLandingScreenModel = LandingScreenOrderHistory.fromJson(responseTasks.data);
      return openOrdersLandingScreenModel;
    } else {
      return LandingScreenOrderHistory(orderHistory: [], brands: []);
    }
  }

  // Future<OpenCasesLandingScreenModel> getOpenCases(String recordID) async {
  //   var responseTasks = await landingScreenDataSource.getOpenCases(recordID);
  //   if (responseTasks.data != null && responseTasks.data["records"] != null) {
  //     OpenCasesLandingScreenModel openCasesLandingScreenModel =
  //         OpenCasesLandingScreenModel.fromJson(responseTasks.data);
  //     return openCasesLandingScreenModel;
  //   } else {
  //     return OpenCasesLandingScreenModel(records: []);
  //   }
  // }

  Future<ItemAvailabilityLandingScreenModel> getItemAvailability(String itemSkuID, String userID) async {
    var responseTasks = await landingScreenDataSource.getItemAvailability(itemSkuID, userID);
    if (responseTasks.data != null) {
      ItemAvailabilityLandingScreenModel itemAvailabilityLandingScreenModel = ItemAvailabilityLandingScreenModel.fromJson(responseTasks.data);
      return itemAvailabilityLandingScreenModel;
    } else {
      return ItemAvailabilityLandingScreenModel(outOfStock: false, inStore: false, noInfo: true);
    }
  }

  Future<CustomerTagging> getTags(String recordId) async {
    var responseTasks = await landingScreenDataSource.getTags(recordId);
    log(jsonEncode(responseTasks.data));
    if (responseTasks.data != null && responseTasks.data["customerTagging"] != null) {
      CustomerTagging favoriteBrandsLandingScreen = CustomerTagging.fromJson(responseTasks.data["customerTagging"]);
      return favoriteBrandsLandingScreen;
    } else {
      return CustomerTagging(data: {
        "Lessons_Customer__c": false,
        "Open_Box_Purchaser__c": false,
        "Loyalty_Customer__c": false,
        "Used_Purchaser__c": false,
        "Synchrony_Customer__c": false,
        "Vintage_Purchaser__c": false
      });
    }
  }

  Future<LandingScreenOffersModel> getOffers() async {
    var responseTasks = await landingScreenDataSource.getOffers();
    log(jsonEncode(responseTasks.data));
    if (responseTasks.data != null && responseTasks.data["offers"] != null) {
      LandingScreenOffersModel landingScreenOffersModel = LandingScreenOffersModel.fromJson(responseTasks.data);
      return landingScreenOffersModel;
    } else {
      return LandingScreenOffersModel(offers: []);
    }
  }

  Future<AssignedAgent> getAssignedAgent(String recordId, String loggedInUserId) async {
    var responseTasks = await landingScreenDataSource.getAssignedAgent(recordId, loggedInUserId);
    if (responseTasks.data != null) {
      AssignedAgent agent = AssignedAgent.fromJson(responseTasks.data);
      return agent;
    } else {
      return AssignedAgent(agentStore: null, agentCC: null);
    }
  }

  Future<AssignedAgent> assignAgent(String recordId, String agentID) async {
    var responseTasks = await landingScreenDataSource.assignAgent(recordId, agentID);
    if (responseTasks.data != null) {
      AssignedAgent agent = AssignedAgent.fromJson(responseTasks.data);
      return agent;
    } else {
      return AssignedAgent(agentStore: null, agentCC: null);
    }
  }

  Future<AgentsList> getAgentList(String recordId, String loggedInUserId) async {
    var responseTasks = await landingScreenDataSource.getAgentList(recordId, loggedInUserId);
    if (responseTasks.data != null && responseTasks.data["AgentList"] != null) {
      AgentsList agent = AgentsList.fromJson(responseTasks.data);
      return agent;
    } else {
      return AgentsList(agentList: []);
    }
  }

  Future<CreditBalance?> getCreditBalance(String customerEmail) async {
    var responseTasks = await landingScreenDataSource.getCreditBalance(customerEmail);
    if (responseTasks.data != null && responseTasks.data['CurrentBalance'] != null) {
      return CreditBalance.fromJson(responseTasks.data);
    } else {
      return CreditBalance();
    }
  }
}
