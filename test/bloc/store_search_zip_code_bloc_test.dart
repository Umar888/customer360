import 'dart:convert';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gc_customer_app/bloc/store_search_zip_code_bloc/store_search_zip_code_bloc.dart';
import 'package:gc_customer_app/data/data_sources/store_search_zip_code_data_source/store_search_zip_code_data_source.dart';
import 'package:gc_customer_app/data/reporsitories/store_search_zip_code_reporsitory/store_search_zip_code_repository.dart';
import 'package:gc_customer_app/models/store_search_zip_code_model/search_store_zip.dart';
import 'package:gc_customer_app/services/networking/endpoints.dart';
import 'package:http/http.dart';
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../util/util.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late StoreSearchZipCodeBloc? storeSearchZipCodeBloc;
  SharedPreferences.setMockInitialValues({
    'agent_email': 'ankit.kumar@guitarcenter.com',
    'agent_id': '0014M00001nv3BwQAI',
    'agent_id_c360': '0014M00001nv3BwQAI',
    'logged_agent_id': '0054M000004UMmEQAW',
    'access_token': '12345',
    'instance_url': '12345',
  });

  StoreSearchZipCodeBloc setUpBloc() {
    var storeSearchZipCodeDataSource = StoreSearchZipCodeDataSource()
      ..httpService.client = MockClient((request) async {
        if (request.matches(Endpoints.kStoreZipAddress.escape)) {
          print("Success: ${request.url}");
          return Response(json.encode({}), 200);
        } else {
          print("API call not mocked: ${request.url}");
          return Response(json.encode({}), 205);
        }
      });
    return StoreSearchZipCodeBloc(
        storeSearchZipCodeRepository: StoreSearchZipCodeRepository(storeSearchZipCodeDataSource: storeSearchZipCodeDataSource));
  }

  blocTest<StoreSearchZipCodeBloc, StoreSearchZipCodeState>(
    'Page Load',
    setUp: () => storeSearchZipCodeBloc = setUpBloc(),
    tearDown: () => storeSearchZipCodeBloc = null,
    build: () => storeSearchZipCodeBloc!,
    act: (bloc) => bloc.add(PageLoad()),
    expect: () => [
      storeSearchZipCodeBloc!.state.copyWith(
        storeSearchZipCodeStatus: StoreSearchZipCodeStatus.successState,
        initialExtent: 0.325,
        zipCode: "",
      )
    ],
  );

  blocTest<StoreSearchZipCodeBloc, StoreSearchZipCodeState>(
    'Set Offset',
    setUp: () => storeSearchZipCodeBloc = setUpBloc(),
    tearDown: () => storeSearchZipCodeBloc = null,
    build: () => storeSearchZipCodeBloc!,
    act: (bloc) => bloc.add(SetOffset(offset: 2)),
    expect: () => [storeSearchZipCodeBloc!.state.copyWith(offset: 2)],
  );

  blocTest<StoreSearchZipCodeBloc, StoreSearchZipCodeState>(
    'Clear Markers',
    setUp: () => storeSearchZipCodeBloc = setUpBloc(),
    tearDown: () => storeSearchZipCodeBloc = null,
    build: () => storeSearchZipCodeBloc!,
    act: (bloc) => bloc.add(ClearMarkers()),
    expect: () => [storeSearchZipCodeBloc!.state.copyWith(markers: [])],
  );

  blocTest<StoreSearchZipCodeBloc, StoreSearchZipCodeState>(
    'Set Zoom Level',
    setUp: () => storeSearchZipCodeBloc = setUpBloc(),
    tearDown: () => storeSearchZipCodeBloc = null,
    build: () => storeSearchZipCodeBloc!,
    act: (bloc) => bloc.add(SetZoomLevel(radius: 2.5)),
    expect: () => [
      storeSearchZipCodeBloc!.state.copyWith(zoomLevel: 12.84310940439148),
    ],
  );

  blocTest<StoreSearchZipCodeBloc, StoreSearchZipCodeState>(
    'Set Markers',
    setUp: () => storeSearchZipCodeBloc = setUpBloc(),
    tearDown: () => storeSearchZipCodeBloc = null,
    build: () => storeSearchZipCodeBloc!,
    act: (bloc) => bloc.add(SetMarkers(
      searchStoreListInformation: [],
      searchStoreList: [],
    )),
    expect: () => [
      storeSearchZipCodeBloc!.state.copyWith(markers: []),
    ],
  );

  blocTest<StoreSearchZipCodeBloc, StoreSearchZipCodeState>(
    'Set Zip Code',
    setUp: () => storeSearchZipCodeBloc = setUpBloc(),
    tearDown: () => storeSearchZipCodeBloc = null,
    build: () => storeSearchZipCodeBloc!,
    act: (bloc) => bloc.add(SetZipCode(zipCode: "123-456")),
    expect: () => [
      storeSearchZipCodeBloc!.state.copyWith(zipCode: "123-456"),
    ],
  );

  group(
    'Get Address',
    () {
      blocTest<StoreSearchZipCodeBloc, StoreSearchZipCodeState>(
        'with radius 5',
        setUp: () => storeSearchZipCodeBloc = setUpBloc(),
        tearDown: () => storeSearchZipCodeBloc = null,
        build: () => storeSearchZipCodeBloc!,
        act: (bloc) => bloc.add(GetAddress(radius: "5", name: "Dummy", orderId: "123")),
        expect: () => [
          StoreSearchZipCodeState().copyWith(storeSearchZipCodeStatus: StoreSearchZipCodeStatus.loadState, currentRadius: "5"),
          storeSearchZipCodeBloc!.state.copyWith(
            currentRadius: "",
            searchStoreZip5: SearchStoreModel.fromJson({}),
            storeSearchZipCodeStatus: StoreSearchZipCodeStatus.successState,
          ),
        ],
      );

      blocTest<StoreSearchZipCodeBloc, StoreSearchZipCodeState>(
        'with radius 10',
        setUp: () => storeSearchZipCodeBloc = setUpBloc(),
        tearDown: () => storeSearchZipCodeBloc = null,
        build: () => storeSearchZipCodeBloc!,
        act: (bloc) => bloc.add(GetAddress(radius: "10", name: "Dummy", orderId: "123")),
        expect: () => [
          StoreSearchZipCodeState().copyWith(storeSearchZipCodeStatus: StoreSearchZipCodeStatus.loadState, currentRadius: "10"),
          storeSearchZipCodeBloc!.state.copyWith(
            currentRadius: "",
            searchStoreZip10: SearchStoreModel.fromJson({}),
            storeSearchZipCodeStatus: StoreSearchZipCodeStatus.successState,
          ),
        ],
      );

      blocTest<StoreSearchZipCodeBloc, StoreSearchZipCodeState>(
        'with radius 25',
        setUp: () => storeSearchZipCodeBloc = setUpBloc(),
        tearDown: () => storeSearchZipCodeBloc = null,
        build: () => storeSearchZipCodeBloc!,
        act: (bloc) => bloc.add(GetAddress(radius: "25", name: "Dummy", orderId: "123")),
        expect: () => [
          StoreSearchZipCodeState().copyWith(storeSearchZipCodeStatus: StoreSearchZipCodeStatus.loadState, currentRadius: "25"),
          storeSearchZipCodeBloc!.state.copyWith(
            currentRadius: "",
            searchStoreZip25: SearchStoreModel.fromJson({}),
            storeSearchZipCodeStatus: StoreSearchZipCodeStatus.successState,
          ),
        ],
      );

      blocTest<StoreSearchZipCodeBloc, StoreSearchZipCodeState>(
        'with radius 50',
        setUp: () => storeSearchZipCodeBloc = setUpBloc(),
        tearDown: () => storeSearchZipCodeBloc = null,
        build: () => storeSearchZipCodeBloc!,
        act: (bloc) => bloc.add(GetAddress(radius: "50", name: "Dummy", orderId: "123")),
        expect: () => [
          StoreSearchZipCodeState().copyWith(storeSearchZipCodeStatus: StoreSearchZipCodeStatus.loadState, currentRadius: "50"),
          storeSearchZipCodeBloc!.state.copyWith(
            currentRadius: "",
            searchStoreZip50: SearchStoreModel.fromJson({}),
            storeSearchZipCodeStatus: StoreSearchZipCodeStatus.successState,
          ),
        ],
      );

      blocTest<StoreSearchZipCodeBloc, StoreSearchZipCodeState>(
        'with radius 100',
        setUp: () => storeSearchZipCodeBloc = setUpBloc(),
        tearDown: () => storeSearchZipCodeBloc = null,
        build: () => storeSearchZipCodeBloc!,
        act: (bloc) => bloc.add(GetAddress(radius: "100", name: "Dummy", orderId: "123")),
        expect: () => [
          StoreSearchZipCodeState().copyWith(storeSearchZipCodeStatus: StoreSearchZipCodeStatus.loadState, currentRadius: "100"),
          storeSearchZipCodeBloc!.state.copyWith(
            currentRadius: "",
            searchStoreZip100: SearchStoreModel.fromJson({}),
            storeSearchZipCodeStatus: StoreSearchZipCodeStatus.successState,
          ),
        ],
      );

      blocTest<StoreSearchZipCodeBloc, StoreSearchZipCodeState>(
        'with radius 200',
        setUp: () => storeSearchZipCodeBloc = setUpBloc(),
        tearDown: () => storeSearchZipCodeBloc = null,
        build: () => storeSearchZipCodeBloc!,
        act: (bloc) => bloc.add(GetAddress(radius: "200", name: "Dummy", orderId: "123")),
        expect: () => [
          StoreSearchZipCodeState().copyWith(storeSearchZipCodeStatus: StoreSearchZipCodeStatus.loadState, currentRadius: "200"),
          storeSearchZipCodeBloc!.state.copyWith(
            currentRadius: "",
            searchStoreZip200: SearchStoreModel.fromJson({}),
            storeSearchZipCodeStatus: StoreSearchZipCodeStatus.successState,
          ),
        ],
      );

      blocTest<StoreSearchZipCodeBloc, StoreSearchZipCodeState>(
        'with radius 500',
        setUp: () => storeSearchZipCodeBloc = setUpBloc(),
        tearDown: () => storeSearchZipCodeBloc = null,
        build: () => storeSearchZipCodeBloc!,
        act: (bloc) => bloc.add(GetAddress(radius: "500", name: "Dummy", orderId: "123")),
        expect: () => [
          StoreSearchZipCodeState().copyWith(storeSearchZipCodeStatus: StoreSearchZipCodeStatus.loadState, currentRadius: "500"),
          storeSearchZipCodeBloc!.state.copyWith(
            currentRadius: "",
            searchStoreZip500: SearchStoreModel.fromJson({}),
            storeSearchZipCodeStatus: StoreSearchZipCodeStatus.successState,
          ),
        ],
      );
    },
  );
}
