import 'dart:convert';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gc_customer_app/bloc/profile_screen_bloc/address_bloc/address_bloc.dart';
import 'package:gc_customer_app/data/data_sources/profile_screen/addresses_data_source.dart';
import 'package:gc_customer_app/data/reporsitories/profile/addresses_repository.dart';
import 'package:gc_customer_app/models/address_models/address_model.dart';
import 'package:http/http.dart';
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late AddressBloc addressBloc;
  SharedPreferences.setMockInitialValues({
    'agent_email': 'ankit.kumar@guitarcenter.com',
    'agent_id': '0014M00001nv3BwQAI',
    'agent_id_c360': '0014M00001nv3BwQAI',
    'logged_agent_id': '0054M000004UMmEQAW',
  });

  setUp(
    () {
      var addressDataSource = AddressesDataSource();
      addressDataSource.httpService.client = MockClient(
        (request) async {
          if (request.method.toLowerCase().contains('get')) {
            return Response(
                json.encode({
                  "addressList": [
                    {
                      "state": "California",
                      "postalCode": "91360-3154",
                      "isPrimary": true,
                      "country": "United States",
                      "contactPointAddressId": "",
                      "city": "Thousand Oaks",
                      "addressLabel": "Test Home#1",
                      "address1": "187 Teasdale St"
                    },
                  ]
                }),
                200);
          } else {
            var body = jsonDecode(request.body);
            return Response(
                json.encode({
                  "addressList": [
                    {
                      "state": body['state'],
                      "postalCode": body['postalCode'],
                      "isPrimary": body['isDefault'],
                      "country": body['country'],
                      "contactPointAddressId": body['contactPointAddressId'],
                      "city": body['city'],
                      "addressLabel": body['addressLabel'],
                      "address1": body['address1'],
                    },
                    {
                      "state": "California",
                      "postalCode": "91360-3154",
                      "isPrimary": true,
                      "country": "United States",
                      "contactPointAddressId": "",
                      "city": "Thousand Oaks",
                      "addressLabel": "Test Home#1",
                      "address1": "187 Teasdale St"
                    },
                  ]
                }),
                200);
          }
        },
      );
      addressBloc = AddressBloc(AddressesRepository());
      addressBloc.addressRepository.addressesDataSource = addressDataSource;
    },
  );

  group(
    'Get and add new address',
    () {
      blocTest(
        'Get addresses',
        build: () => addressBloc,
        act: (bloc) => bloc.add(LoadAddressesData()),
        expect: () => [
          AddressProgress(),
          AddressSuccess(addresses: [
            AddressList.fromJson({
              "state": "California",
              "postalCode": "91360-3154",
              "isPrimary": true,
              "country": "United States",
              "contactPointAddressId": "",
              "city": "Thousand Oaks",
              "addressLabel": "Test Home#1",
              "address1": "187 Teasdale St"
            })
          ]),
        ],
      );

      blocTest(
        'Add new address',
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
        expect: () {
          return [AddressProgress(), isA<AddressSuccess>()];
        },
      );
    },
  );
}
