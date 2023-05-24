import 'dart:convert';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gc_customer_app/bloc/profile_screen_bloc/address_bloc/address_bloc.dart';
import 'package:gc_customer_app/data/data_sources/profile_screen/addresses_data_source.dart';
import 'package:gc_customer_app/data/reporsitories/profile/addresses_repository.dart';
import 'package:gc_customer_app/models/address_models/address_model.dart';
import 'package:gc_customer_app/services/networking/endpoints.dart';
import 'package:http/http.dart';
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';

extension on String {
  String get escape => RegExp.escape(this);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late AddressBloc addressBloc;
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
      var addressDataSource = AddressesDataSource();
      addressDataSource.httpService.client = MockClient((request) async {
        if(successScenario) {
          if (RegExp('${Endpoints.kBaseURL}${Endpoints.kClientAddress}'.escape + r'$').hasMatch(request.url.toString())) {
            print("Success: ${request.url}");
            return Response(
                json.encode({
                  "addressList": [
                    AddressList(isPrimary: true).toJson(),
                  ],
                  "message": "Record found.",
                }),
                200);
          } else if (RegExp('${Endpoints.kBaseURL}${Endpoints.kClientAddress}'.escape + r'\?recordId=.+$').hasMatch(request.url.toString())) {
            print("Success: ${request.url}");
            return Response(
                json.encode({
                  "addressList": [
                    AddressList(isPrimary: true).toJson(),
                  ],
                  "message": "Record found.",
                }),
                200);
          } else if (RegExp('${Endpoints.kBaseURL}${Endpoints.kClientAddress}'.escape + r'\?loggedinUserId=.+$').hasMatch(request.url.toString())) {
            print("Success: ${request.url}");
            return Response(
                json.encode({
                  "addressInfo": {
                    "recommendedAddress": {
                      "isSuccess": true,
                    },
                    "hasDifference": true,
                    "existingAddress": {},
                  },
                  "message": "Record found.",
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
      addressBloc = AddressBloc(AddressesRepository());
      addressBloc.addressRepository.addressesDataSource = addressDataSource;
    },
  );

  group(
    'Success Scenarios',
    () {
      setUp(() => successScenario = true);
      blocTest(
        'Load Addresses Data',
        build: () => addressBloc,
        act: (bloc) => bloc.add(LoadAddressesData()),
        expect: () => [
          isA<AddressProgress>(),
          isA<AddressSuccess>(),
        ],
      );

      blocTest(
        'Save Addresses Data',
        build: () => addressBloc,
        act: (bloc) => bloc.add(SaveAddressesData(
            addressModel: AddressList.fromJson({
              "state": "California",
              "postalCode": "91360-5405",
              "country": "United States",
              "city": "Thousand Oaks",
              "addressLabel": "000003598",
              "address1": "418 Wilbur Rd"
            }),
            isDefault: false)),
        expect: () => [
          isA<AddressProgress>(),
          isA<AddressSuccess>(),
        ],
      );

      blocTest(
        'Verification Address Profile',
        build: () => addressBloc,
        act: (bloc) => bloc.add(
          VerificationAddressProfile(
              addressModel: AddressList.fromJson({
                "state": "California",
                "postalCode": "91360-5405",
                "country": "United States",
                "city": "Thousand Oaks",
                "addressLabel": "000003598",
                "address1": "418 Wilbur Rd"
              }),
              isDefault: false),
        ),
        expect: () => [
          isA<AddressProgress>(),
          // isA<AddressSuccess>(),
        ],
      );
    },
  );

  group(
    'Failure Scenarios',
    () {
      setUp(() => successScenario = false);
      blocTest(
        'Load Addresses Data Failure',
        build: () => addressBloc,
        act: (bloc) => bloc.add(LoadAddressesData()),
        expect: () => [
          isA<AddressProgress>(),
          isA<AddressFailure>(),
          isA<AddressSuccess>(),
        ],
      );

      blocTest(
        'Save Addresses Data Failure',
        build: () => addressBloc,
        act: (bloc) => bloc.add(SaveAddressesData(
            addressModel: AddressList.fromJson({
              "state": "California",
              "postalCode": "91360-5405",
              "country": "United States",
              "city": "Thousand Oaks",
              "addressLabel": "000003598",
              "address1": "418 Wilbur Rd"
            }),
            isDefault: false)),
        expect: () => [
          isA<AddressProgress>(),
        ],
      );

      blocTest(
        'Verification Address Profile Failure',
        build: () => addressBloc,
        act: (bloc) => bloc.add(
          VerificationAddressProfile(
              addressModel: AddressList.fromJson({
                "state": "California",
                "postalCode": "91360-5405",
                "country": "United States",
                "city": "Thousand Oaks",
                "addressLabel": "000003598",
                "address1": "418 Wilbur Rd"
              }),
              isDefault: false),
        ),
        expect: () => [],
      );
    },
  );
}
