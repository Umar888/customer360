import 'dart:convert';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gc_customer_app/bloc/landing_screen_bloc/landing_screen_bloc_bloc.dart';
import 'package:gc_customer_app/constants/colors.dart';
import 'package:gc_customer_app/data/data_sources/landing_screen_data_source/landing_screen_data_source.dart';
import 'package:gc_customer_app/data/reporsitories/landing_screen_repository/landing_screen_repository.dart';
import 'package:gc_customer_app/models/activity_class.dart';
import 'package:gc_customer_app/models/landing_screen/agent_list.dart';
import 'package:gc_customer_app/models/landing_screen/assigned_agent.dart';
import 'package:gc_customer_app/models/landing_screen/customer_info_model.dart';
import 'package:gc_customer_app/models/landing_screen/landing_scree_offers_model.dart';
import 'package:gc_customer_app/models/landing_screen/landing_screen_recommendation_model.dart';
import 'package:gc_customer_app/models/landing_screen/landing_screen_recommendation_model_buy_again.dart';
import 'package:gc_customer_app/models/landing_screen/landing_screen_reminders.dart';
import 'package:gc_customer_app/models/pinned_notes_model.dart';
import 'package:gc_customer_app/services/extensions/string_extension.dart';
import 'package:gc_customer_app/services/networking/endpoints.dart';
import 'package:http/http.dart';
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../util/util.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late LandingScreenBloc landingScreenBloc;
  SharedPreferences.setMockInitialValues({
    'agent_email': 'ankit.kumar@guitarcenter.com',
    'agent_id': '0014M00001nv3BwQAI',
    'agent_id_c360': '0014M00001nv3BwQAI',
    'logged_agent_id': '0054M000004UMmEQAW',
    'access_token': '12345',
    'instance_url': '12345',
  });

  late bool successScenario;
  final Map<String, dynamic> dummyAssignedAgentJson = {
    "message": "",
    "AgentStore": <String, dynamic>{},
    "AgentCC": <String, dynamic>{},
  };

  final dummyAssignedAgent = AssignedAgent.fromJson(dummyAssignedAgentJson);

  setUp(
    () {
      var landingScreenDataSource = LandingScreenDataSource();
      landingScreenDataSource.httpService.client = MockClient((request) async {
        if (successScenario) {
          if (request.matches(Endpoints.kAssignAgent.escape + r'$')) {
            print("Success: ${request.url}");
            return Response(json.encode(dummyAssignedAgentJson), 200);
          } else if (request.matches(Endpoints.kAssignedAgent.escape + r'.+&recordType=Agent$')) {
            print("Success: ${request.url}");
            return Response(json.encode(dummyAssignedAgentJson), 200);
          } else if (request.matches(Endpoints.kAssignedAgent.escape + r'.+&recordType=AgentList$')) {
            print("Success: ${request.url}");
            return Response(
                json.encode({
                  "AgentList": [{}],
                  "message": "done",
                }),
                200);
          } else if (request.matches(Endpoints.kItemAvailability.escape)) {
            print("Success: ${request.url}");
            return Response(json.encode({}), 200);
          } else if (request.matches(Endpoints.kOpenOrders.escape)) {
            print("Success: ${request.url}");
            return Response(json.encode({"OpenOrders": []}), 200);
          } else if (request.matches(Endpoints.lRecommendation.escape)) {
            print("Success: ${request.url}");
            return Response(json.encode({"message": "record found."}), 200);
          } else if (request.matches(Endpoints.kOrderHistory.escape)) {
            print("Success: ${request.url}");
            return Response(json.encode({"OrderHistory": [], "brands": []}), 200);
          } else if (request.matches(Endpoints.kOffers.escape)) {
            print("Success: ${request.url}");
            return Response(json.encode({"offers": []}), 200);
          } else if (request.matches(Endpoints.kTags.escape)) {
            print("Success: ${request.url}");
            return Response(json.encode({"customerTagging": {}}), 200);
          } else if (request.matches(Endpoints.kReminders.escape)) {
            print("Success: ${request.url}");
            return Response(json.encode({"AllOpenTasks": []}), 200);
          } else if (request.matches(Endpoints.kCustomerTasks.escape)) {
            print("Success: ${request.url}");
            return Response(json.encode({"AggregatedTaskList": []}), 200);
          } else if (request.matches(Endpoints.kCustomerSearch.escape)) {
            print("Success: ${request.url}");
            return Response(json.encode({}), 200);
          } else if (request.matches(r'.*Synchrony_Customer__c,Vintage_Purchaser__c from account where Id=.+ LIMIT 1$')) {
            print("Success: ${request.url}");
            return Response(
                json.encode({
                  "records": [
                    {"Id": ""}
                  ]
                }),
                200);
          } else {
            print("API call not mocked: ${request.url}");
            return Response(json.encode({}), 205);
          }
        } else {
          print("Failed: ${request.url}");
          return Response(json.encode({}), 205);
        }
      });
      landingScreenBloc = LandingScreenBloc(landingScreenRepository: LandingScreenRepository());
      landingScreenBloc.landingScreenRepository.landingScreenDataSource = landingScreenDataSource;
    },
  );

  group(
    'Failure Scenarios',
    () {
      setUp(() => successScenario = false);

      blocTest<LandingScreenBloc, LandingScreenState>(
        'Assign Agent Failure',
        build: () => landingScreenBloc,
        seed: () => LandingScreenState(assignedAgent: dummyAssignedAgent),
        act: (bloc) => bloc.add(AssignAgent(
          agentId: "123",
          index: 0,
          isStore: true,
        )),
        expect: () => [
          LandingScreenState(
            assignedAgent: dummyAssignedAgent,
            isAssigningStoreAgent: true,
          ),
          LandingScreenState(
            assignedAgent: dummyAssignedAgent,
            isAssigningStoreAgent: false,
          ),
        ],
      );

      blocTest<LandingScreenBloc, LandingScreenState>(
        'Load Data Failure',
        build: () => landingScreenBloc,
        act: (bloc) => bloc.add(LoadData()),
        expect: () => [
          LandingScreenState(
            landingScreenStatus: LandingScreenStatus.initial,
            message: "",
          ),
          LandingScreenState(
            gettingAgentsList: true,
            isSearchAgent: false,
            gettingOffers: true,
            tags: {},
            agentList: [],
            message: "",
            searchedAgentList: [],
            landingScreenStatus: LandingScreenStatus.success,
            customerInfoModel: CustomerInfoModel(records: [], totalSize: 0, done: true),
            taskModel: [],
            gettingActivity: true,
            gettingFavorites: true,
            gettingAgentAssigned: true,
            isAgentAssigned: false,
          ),
        ],
      );
    },
  );

  group(
    'Success Scenarios',
    () {
      setUp(() => successScenario = true);

      blocTest<LandingScreenBloc, LandingScreenState>(
        'Assign Agent',
        build: () => landingScreenBloc,
        seed: () => LandingScreenState(assignedAgent: dummyAssignedAgent),
        act: (bloc) => bloc.add(AssignAgent(
          agentId: "123",
          index: 0,
          isStore: true,
        )),
        expect: () => [
          LandingScreenState(
            assignedAgent: dummyAssignedAgent,
            isAssigningStoreAgent: true,
          ),
          LandingScreenState(
            assignedAgent: dummyAssignedAgent,
            isAssigningStoreAgent: false,
            message: "Agent assigned successfully",
          ),
        ],
      );

      blocTest<LandingScreenBloc, LandingScreenState>(
        'Clear Message',
        build: () => landingScreenBloc,
        act: (bloc) => bloc.add(ClearMessage()),
        expect: () => [
          LandingScreenState(message: ""),
        ],
      );

      blocTest<LandingScreenBloc, LandingScreenState>(
        'Search Agent List',
        build: () => landingScreenBloc,
        seed: () => LandingScreenState(agentList: [AgentList(name: "Joe Doe")]),
        act: (bloc) => bloc.add(SearchAgentList(searchString: "abc")),
        expect: () => [
          LandingScreenState(
            agentList: [AgentList(name: "Joe Doe")],
            gettingAgentsList: false,
            isSearchAgent: true,
            message: "",
            gettingAgentAssigned: false,
            searchedAgentList: [],
          ),
        ],
      );

      blocTest<LandingScreenBloc, LandingScreenState>(
        'Check Agent',
        build: () => landingScreenBloc,
        act: (bloc) => bloc.add(CheckAgent()),
        expect: () => [
          LandingScreenState(
            gettingAgentsList: false,
            isSearchAgent: false,
            gettingAgentAssigned: false,
            message: "",
            assignedAgent: dummyAssignedAgent,
            searchedAgentList: [],
            isAgentAssigned: true,
          ),
        ],
      );

      blocTest<LandingScreenBloc, LandingScreenState>(
        'Clear Search List',
        build: () => landingScreenBloc,
        act: (bloc) => bloc.add(ClearSearchList()),
        expect: () => [
          LandingScreenState(
            gettingAgentsList: false,
            message: "",
            isSearchAgent: false,
            searchedAgentList: [],
            gettingAgentAssigned: false,
          ),
        ],
      );

      blocTest<LandingScreenBloc, LandingScreenState>(
        'Get Agent List',
        build: () => landingScreenBloc,
        act: (bloc) => bloc.add(GetAgentList()),
        expect: () => [
          LandingScreenState(
            gettingAgentsList: true,
            message: "",
            agentList: [],
            searchedAgentList: [],
            isSearchAgent: false,
            gettingAgentAssigned: false,
          ),
          LandingScreenState(
            isSearchAgent: false,
            gettingAgentsList: false,
            agentList: [AgentList.fromJson({})],
            gettingAgentAssigned: false,
            message: "",
            searchedAgentList: [],
          ),
        ],
      );

      blocTest<LandingScreenBloc, LandingScreenState>(
        'Get Recommended Item Stock',
        build: () => landingScreenBloc,
        act: (bloc) => bloc.add(GetRecommendedItemStock(
          itemSkuId: "",
          gettingFavorites: false,
          gettingActivity: false,
          recommendationModelBuyAgain: LandingScreenRecommendationModelBuyAgain(productBuyAgain: []),
          recommendationModel: LandingScreenRecommendationModel(productBrowsing: [], productBrowsingOthers: []),
        )),
        expect: () => [
          LandingScreenState(
            isSearchAgent: false,
            gettingAgentsList: false,
            searchedAgentList: [],
            message: "",
          ),
        ],
      );

      blocTest<LandingScreenBloc, LandingScreenState>(
        'Load Activity',
        build: () => landingScreenBloc,
        act: (bloc) => bloc.add(LoadActivity()),
        expect: () => [
          LandingScreenState(
            openOrder: ActivityClass(
                typeOfOrder: 'Open Orders',
                numberOfOrders: "0",
                valueOfOrder: "0.00",
                dateoforder: DateTime.now().toString().changeToBritishFormatHalf(DateTime.now().toString()),
                itemsOfOrder: "0"),
            openCases: ActivityClass(
                typeOfOrder: 'Open Cases',
                numberOfOrders: "0",
                valueOfOrder: "0.00",
                dateoforder: DateTime.now().toString().changeToBritishFormatHalf(DateTime.now().toString()),
                itemsOfOrder: "0"),
            browsingHistory: ActivityClass(
                typeOfOrder: 'Browsing History',
                numberOfOrders: "0",
                valueOfOrder: "0.00",
                dateoforder: DateTime.now().toString().changeToBritishFormatHalf(DateTime.now().toString()),
                itemsOfOrder: "0"),
            gettingAgentsList: false,
            landingScreenRecommendationModel: LandingScreenRecommendationModel(
              productBrowsingOthers: [],
              productBrowsing: [],
              message: "record found.",
              status: 200,
            ),
            isSearchAgent: false,
            gettingActivity: false,
            message: "",
            searchedAgentList: [],
          ),
        ],
      );

      blocTest<LandingScreenBloc, LandingScreenState>(
        'Load Favorite Brands',
        build: () => landingScreenBloc,
        act: (bloc) => bloc.add(LoadFavoriteBrands()),
        expect: () => [
          LandingScreenState(
            favoriteBrandsLandingScreen: [],
            orderHistoryLandingScreen: [],
            gettingAgentsList: false,
            isSearchAgent: false,
            searchedAgentList: [],
            gettingFavorites: false,
            message: "",
          ),
        ],
      );

      blocTest<LandingScreenBloc, LandingScreenState>(
        'Load Offers',
        build: () => landingScreenBloc,
        act: (bloc) => bloc.add(LoadOffers()),
        expect: () => [
          LandingScreenState(
            landingScreenOffersModel: LandingScreenOffersModel(offers: []),
            gettingOffers: false,
            message: "",
          ),
        ],
      );

      blocTest<LandingScreenBloc, LandingScreenState>(
        'Pinned Notes Change',
        build: () => landingScreenBloc,
        act: (bloc) => bloc.add(PinnedNotesChange(index: 0)),
        expect: () => [
          LandingScreenState(
            pinnedNotesList: [],
            isSearchAgent: false,
            gettingAgentsList: false,
            message: "",
            searchedAgentList: [],
          ),
        ],
      );

      blocTest<LandingScreenBloc, LandingScreenState>(
        'Reload Reminders',
        build: () => landingScreenBloc,
        act: (bloc) => bloc.add(ReloadReminders()),
        expect: () => [
          LandingScreenState(
            landingScreenReminders: LandingScreenReminders(allOpenTasks: []),
            tags: {},
          ),
        ],
      );

      blocTest<LandingScreenBloc, LandingScreenState>(
        'Reload Tasks',
        build: () => landingScreenBloc,
        act: (bloc) => bloc.add(ReloadTasks()),
        expect: () => [
          LandingScreenState(taskModel: []),
        ],
      );

      blocTest<LandingScreenBloc, LandingScreenState>(
        'Remove Customer',
        build: () => landingScreenBloc,
        act: (bloc) => bloc.add(RemoveCustomer()),
        expect: () => [
          LandingScreenState(
            customerInfoModel: CustomerInfoModel(records: [Records(id: null)]),
            message: "",
          ),
        ],
      );

      blocTest<LandingScreenBloc, LandingScreenState>(
        'Load Data',
        build: () => landingScreenBloc,
        act: (bloc) => bloc.add(LoadData()),
        expect: () => [
          LandingScreenState(
            landingScreenStatus: LandingScreenStatus.initial,
            message: "",
          ),
          LandingScreenState(
            pinnedNotesList: [
              PinnedNotes(
                  textOfNote:
                      'Jessica  is a gutiar geerk, and loves acoustic n,c vcvbjJessica  is a gutiar geerk, and loves acoustic n,c vcvbjJessica  is a gutiar geerk, and loves acoustic n,c vcvbjJessica  is a gutiar geerk, and loves acoustic n,c vcvbjJessica  is a gutiar geerk, and loves acoustic n,c vcvbj',
                  authorOfNote: 'john Doe',
                  dateOfNote: 'Aug 20, 2022',
                  isLess: true,
                  backgroundColor: AppColors.skyblueHex),
              PinnedNotes(
                  textOfNote:
                      'Jessica  is a gutiar geerk, and loves acoustic n,c vcvbjJessica  is a gutiar geerk, and loves acoustic n,c vcvbjJessica  is a gutiar geerk, and loves acoustic n,c vcvbjJessica  is a gutiar geerk, and loves acoustic n,c vcvbjJessica  is a gutiar geerk, and loves acoustic n,c vcvbj',
                  authorOfNote: 'john Doe',
                  isLess: true,
                  dateOfNote: 'Aug 20, 2022',
                  backgroundColor: AppColors.yellowNotes),
            ],
            gettingAgentsList: true,
            isSearchAgent: false,
            gettingOffers: true,
            agentList: [],
            message: "",
            searchedAgentList: [],
            landingScreenStatus: LandingScreenStatus.success,
            customerInfoModel: CustomerInfoModel(records: [Records(id: "")]),
            gettingActivity: true,
            gettingFavorites: true,
            gettingAgentAssigned: true,
            isAgentAssigned: false,
          ),
        ],
      );
    },
  );
}
