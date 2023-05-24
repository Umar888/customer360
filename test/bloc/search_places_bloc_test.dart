import 'dart:convert';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gc_customer_app/bloc/search_places/search_places_bloc.dart';
import 'package:gc_customer_app/data/data_sources/search_places/search_places_data_source.dart';
import 'package:gc_customer_app/models/search_places/search_places_model.dart';
import 'package:gc_customer_app/services/networking/endpoints.dart';
import 'package:http/http.dart';
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../util/util.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late SearchPlacesBloc searchPlacesBloc;
  SharedPreferences.setMockInitialValues({
    'agent_email': 'ankit.kumar@guitarcenter.com',
    'agent_id': '0014M00001nv3BwQAI',
    'agent_id_c360': '0014M00001nv3BwQAI',
    'logged_agent_id': '0054M000004UMmEQAW',
    'access_token': '12345',
    'instance_url': '12345',
  });

  late bool successScenario;

  setUp(
    () {
      var searchPlacesDataSource = SearchPlacesDataSource()
        ..httpService.client = MockClient((request) async {
          if (successScenario) {
            if (request.matches(Endpoints.kClientAddress.escape)) {
              print("Success: ${request.url}");
              return Response(
                  json.encode({
                    "autoCompleteAddressList": [
                      {"city": "city"}
                    ]
                  }),
                  200);
            } else {
              print("API call not mocked: ${request.url}");
              return Response(json.encode({}), 205);
            }
          } else {
            print("Failed: ${request.url}");
            return Response("", 205);
          }
        });
      searchPlacesBloc = SearchPlacesBloc();
      searchPlacesBloc.searchPlacesRepository.searchPlacesDataSource = searchPlacesDataSource;
    },
  );

  group(
    'Success Scenarios',
    () {
      setUp(() => successScenario = true);

      blocTest<SearchPlacesBloc, SearchPlacesLoadSuccess>(
        'Search Requested',
        build: () => searchPlacesBloc,
        act: (bloc) => bloc.add(SearchRequested(query: "123")),
        wait: Duration(milliseconds: 1000),
        expect: () => [
          SearchPlacesLoadSuccess(
            search: SearchPlacesListModel(autoCompleteAddressList: []),
            message: "done",
            loadingState: LoadingState.loading,
            isInit: false,
          ),
          SearchPlacesLoadSuccess(
            search: SearchPlacesListModel(autoCompleteAddressList: [AutoCompleteAddressList(city: "city")]),
            message: "done",
            loadingState: LoadingState.notLoading,
            isInit: false,
          ),
        ],
      );

      blocTest<SearchPlacesBloc, SearchPlacesLoadSuccess>(
        'Search Set Initial',
        build: () => searchPlacesBloc,
        act: (bloc) => bloc.add(SearchSetInitial(search: SearchPlacesListModel(autoCompleteAddressList: [AutoCompleteAddressList()]))),
        expect: () => [
          SearchPlacesLoadSuccess(
            search: SearchPlacesListModel(autoCompleteAddressList: []),
            message: "done",
            loadingState: LoadingState.notLoading,
            isInit: true,
          ),
        ],
      );

      blocTest<SearchPlacesBloc, SearchPlacesLoadSuccess>(
        'Empty Message',
        build: () => searchPlacesBloc,
        act: (bloc) => bloc.add(EmptyMessage(search: SearchPlacesListModel(), init: true)),
        expect: () => [
          SearchPlacesLoadSuccess(
            search: SearchPlacesListModel(),
            message: "",
            loadingState: LoadingState.notLoading,
            isInit: true,
          ),
        ],
      );
    },
  );

  group(
    'Failure Scenarios',
    () {
      setUp(() => successScenario = false);

      blocTest<SearchPlacesBloc, SearchPlacesLoadSuccess>(
        'Search Requested Failure',
        build: () => searchPlacesBloc,
        act: (bloc) => bloc.add(SearchRequested(query: "123")),
        wait: Duration(milliseconds: 1000),
        expect: () => [
          SearchPlacesLoadSuccess(
            search: SearchPlacesListModel(autoCompleteAddressList: []),
            message: "done",
            loadingState: LoadingState.loading,
            isInit: false,
          ),
          SearchPlacesLoadSuccess(
            search: SearchPlacesListModel(autoCompleteAddressList: []),
            message: "done",
            loadingState: LoadingState.notLoading,
            isInit: false,
          ),
        ],
      );
    },
  );
}
