import 'dart:convert';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gc_customer_app/bloc/cart_bloc/add_customer_bloc/add_customer_bloc.dart';
import 'package:gc_customer_app/bloc/cart_bloc/cart_bloc.dart';
import 'package:gc_customer_app/data/data_sources/cart_data_source/cart_data_source.dart';
import 'package:gc_customer_app/data/reporsitories/cart_reporsitory/cart_repository.dart';
import 'package:gc_customer_app/models/user_profile_model.dart';
import 'package:gc_customer_app/services/networking/endpoints.dart';
import 'package:http/http.dart';
import 'package:http/testing.dart';
import 'package:mockito/mockito.dart';
import 'package:shared_preferences/shared_preferences.dart';

extension on String {
  String get escape => RegExp.escape(this);
}

class MockCartBloc extends Mock implements CartBloc {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late AddCustomerBloc addCustomerBloc;
  SharedPreferences.setMockInitialValues({
    'agent_email': 'ankit.kumar@guitarcenter.com',
    'agent_id': '0014M00001nv3BwQAI',
    'agent_id_c360': '0014M00001nv3BwQAI',
    'logged_agent_id': '0054M000004UMmEQAW',
    'access_token': '12345',
    'instance_url': '12345',
  });

  late bool successScenario;
  late UserProfile dummyUserProfile;
  setUp(
    () {
      dummyUserProfile = UserProfile(
        id: "123",
        accountEmailC: "joe.doe@mail.com",
        name: "Joe Doe",
        phone: "123456789",
        lastTransactionDateC: DateTime.now(),
      );

      var cartDataSource = CartDataSource();
      cartDataSource.httpService.client = MockClient((request) async {
        if (successScenario) {
          if (RegExp('${Endpoints.kBaseURL}${Endpoints.kClientCustomer}'.escape + r'\?loggedinUserId=.+&recordType=ProficiencyLevel$')
              .hasMatch(request.url.toString())) {
            print("Success: ${request.url}");
            return Response(
                json.encode({
                  "ProficiencyLevel": ["1", "2", "3"]
                }),
                200);
          } else if (RegExp('${Endpoints.kBaseURL}${Endpoints.kClientCustomer}'.escape + r'\?loggedinUserId=.+&recordType=PreferredInstrument')
              .hasMatch(request.url.toString())) {
            print("Success: ${request.url}");
            return Response(
                json.encode({
                  "PreferredInstrument": ["4", "5", "6"]
                }),
                200);
          } else if (RegExp('${Endpoints.kBaseURL}${Endpoints.kClientCustomer}'.escape + r'\?loggedinUserId=.+&recordType=PlayFrequency')
              .hasMatch(request.url.toString())) {
            print("Success: ${request.url}");
            return Response(
                json.encode({
                  "PlayFrequency": ["7", "8", "9"]
                }),
                200);
          } else if (RegExp('${Endpoints.kBaseURL}${Endpoints.kClientAddress}'.escape + r"\?recordType=RecommendedAddress.+$")
              .hasMatch(request.url.toString())) {
            print("Success: ${request.url}");
            return Response(
                json.encode({
                  "message": "record found.",
                  "addressInfo": {
                    "recommendedAddress": {
                      "state": "California",
                      "postalcode": "91360-5405",
                      "isSuccess": true,
                      "isShipping": true,
                      "isBilling": false,
                      "country": "United States",
                      "city": "Thousand Oaks",
                      "addressline2": "",
                      "addressline1": "418 E Wilbur Rd"
                    },
                    "hasDifference": true,
                    "existingAddress": {
                      "state": "California",
                      "postalcode": "91360-5405",
                      "isSuccess": null,
                      "isShipping": true,
                      "isBilling": false,
                      "country": "United States",
                      "city": "Thousand Oaks",
                      "addressline2": "",
                      "addressline1": "418 Wilbur Rd",
                    },
                  },
                }),
                200);
          } else if (RegExp('${Endpoints.kBaseURL}${Endpoints.kClientCustomer}'.escape + r'$').hasMatch(request.url.toString())) {
            print("Success: ${request.url}");
            return Response(
                json.encode({
                  "isSuccess": true,
                  "customer": dummyUserProfile,
                }),
                200);
          } else if (RegExp('${Endpoints.kBaseURL}'.escape + r'.+from%20account%20where%20.+$').hasMatch(request.url.toString())) {
            print("Success1: ${request.url}");
            return Response(
                json.encode({
                  "records": [dummyUserProfile.toJson()]
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
      addCustomerBloc = AddCustomerBloc(CartRepository(cartDataSource: cartDataSource));
    },
  );

  group(
    'Success Scenarios',
    () {
      setUp(() => successScenario = true);

      blocTest<AddCustomerBloc, AddCustomerState>(
        'Fetch User Options',
        build: () => addCustomerBloc,
        act: (bloc) => bloc.add(FetchUserOptions()),
        expect: () => [
          AddCustomerState(
            proficiencies: ["1", "2", "3"],
            instruments: ["4", "5", "6"],
            frequencies: ["7", "8", "9"],
          ),
        ],
      );

      blocTest<AddCustomerBloc, AddCustomerState>(
        'Select Proficiency Level',
        build: () => addCustomerBloc,
        act: (bloc) => bloc.add(SelectProficiencyLevel("1")),
        expect: () => [
          AddCustomerState(selectedProficiency: "1", message: "done"),
        ],
      );

      blocTest<AddCustomerBloc, AddCustomerState>(
        'Select Play Frequency',
        build: () => addCustomerBloc,
        act: (bloc) => bloc.add(SelectPlayFrequency("1")),
        expect: () => [
          AddCustomerState(selectedFrequency: "1", message: "done"),
        ],
      );

      blocTest<AddCustomerBloc, AddCustomerState>(
        'Select Preferred Instrument',
        build: () => addCustomerBloc,
        act: (bloc) => bloc.add(SelectPreferredInstrument("1")),
        expect: () => [
          AddCustomerState(selectedInstruments: ["1"], message: "done"),
        ],
      );

      blocTest<AddCustomerBloc, AddCustomerState>(
        'Remove Preferred Instrument',
        build: () => addCustomerBloc,
        act: (bloc) => bloc.add(RemovePreferredInstrument("1")),
        expect: () => [
          AddCustomerState(selectedInstruments: [], message: "done"),
        ],
      );

      blocTest<AddCustomerBloc, AddCustomerState>(
        'Update Show Options (false)',
        build: () => addCustomerBloc,
        act: (bloc) => bloc.add(UpdateShowOptions(false)),
        expect: () => [
          AddCustomerState(showOption: false),
        ],
      );

      blocTest<AddCustomerBloc, AddCustomerState>(
        'Update Show Options (true)',
        build: () => addCustomerBloc,
        act: (bloc) => bloc.add(UpdateShowOptions(true)),
        expect: () => [
          AddCustomerState(showOption: true),
        ],
      );

      blocTest<AddCustomerBloc, AddCustomerState>(
        'Load Form Key',
        build: () => addCustomerBloc,
        act: (bloc) => bloc.add(LoadFormKey()),
        expect: () => [
          isA<AddCustomerState>(),
        ],
      );

      blocTest<AddCustomerBloc, AddCustomerState>(
        'Change Customer Type (email)',
        build: () => addCustomerBloc,
        act: (bloc) => bloc.add(ChangeCustomerType(true)),
        expect: () => [
          AddCustomerState(addCustomerType: AddCustomerType.email),
        ],
      );

      blocTest<AddCustomerBloc, AddCustomerState>(
        'Change Customer Type (phone)',
        build: () => addCustomerBloc,
        act: (bloc) => bloc.add(ChangeCustomerType(false)),
        expect: () => [
          AddCustomerState(addCustomerType: AddCustomerType.phone),
        ],
      );

      blocTest<AddCustomerBloc, AddCustomerState>(
        'Hide Recommended Dialog Add Customer',
        build: () => addCustomerBloc,
        act: (bloc) => bloc.add(HideRecommendedDialogAddCustomer()),
        expect: () => [
          AddCustomerState(showRecommendedDialog: false),
        ],
      );

      blocTest<AddCustomerBloc, AddCustomerState>(
        'Get Recommended Addresses Add Customer',
        build: () => addCustomerBloc,
        act: (bloc) => bloc.add(GetRecommendedAddressesAddCustomer(
          address1: "418 Wilbur Rd",
          address2: "",
          city: "Thousand Oaks",
          state: "California",
          postalCode: "91360-5405",
          country: "United States",
          isShipping: true,
          isBilling: false,
          currentFName: "Joe",
          currentLName: "Doe",
          currentEmail: "joe.doe@mail.com",
          currentPhone: "123456789",
          cartBloc: MockCartBloc(),
        )),
        expect: () => [
          AddCustomerState(saveCustomerStatus: SaveCustomerStatus.saving),
          AddCustomerState(
            recommendedAddress: "",
            recommendedAddressLine1: "",
            saveCustomerStatus: SaveCustomerStatus.saving,
            recommendedAddressLine2: "",
            recommendedAddressLineCity: "",
            recommendedAddressLineCountry: "",
            recommendedAddressLineState: "",
            recommendedAddressLineZipCode: "",
            showRecommendedDialog: false,
            message: "done",
            orderAddress: "",
            currentFName: "Joe",
            currentLName: "Doe",
            currentEmail: "joe.doe@mail.com",
            currentPhone: "123456789",
            currentAddress1: "418 Wilbur Rd",
            currentAddress2: "",
            currentCity: "Thousand Oaks",
            currentState: "California",
            currentZip: "91360-5405",
          ),
          AddCustomerState(
            recommendedAddress: "418 E Wilbur Rd, , Thousand Oaks, California, United States, 91360-5405",
            orderAddress: "418 Wilbur Rd, , Thousand Oaks, California, United States, 91360-5405",
            showRecommendedDialog: true,
            recommendedAddressLine1: "418 E Wilbur Rd",
            recommendedAddressLine2: "",
            recommendedAddressLineCity: "Thousand Oaks",
            saveCustomerStatus: SaveCustomerStatus.notSaving,
            message: "done",
            recommendedAddressLineCountry: "United States",
            recommendedAddressLineState: "California",
            recommendedAddressLineZipCode: "91360-5405",
            currentFName: "Joe",
            currentLName: "Doe",
            currentEmail: "joe.doe@mail.com",
            currentPhone: "123456789",
            currentAddress1: "418 Wilbur Rd",
            currentAddress2: "",
            currentCity: "Thousand Oaks",
            currentState: "California",
            currentZip: "91360-5405",
          ),
        ],
      );

      blocTest<AddCustomerBloc, AddCustomerState>(
        'Clear Recommended Addresses Add Customer',
        build: () => addCustomerBloc,
        act: (bloc) => bloc.add(ClearRecommendedAddressesAddCustomer()),
        expect: () => [
          AddCustomerState(
            recommendedAddress: "",
            orderAddress: "",
            recommendedAddressLine1: "",
            recommendedAddressLine2: "",
            recommendedAddressLineCity: "",
            recommendedAddressLineCountry: "",
            recommendedAddressLineState: "",
            recommendedAddressLineZipCode: "",
          ),
        ],
      );

      blocTest<AddCustomerBloc, AddCustomerState>(
        'Load Look Up Data (email)',
        build: () => addCustomerBloc,
        act: (bloc) => bloc.add(LoadLookUpData("", SearchType.email)),
        wait: Duration(milliseconds: 500),
        expect: () => [
          AddCustomerState(customerLookUpStatus: CustomerLookUpStatus.loading),
          AddCustomerState(
            customerLookUpStatus: CustomerLookUpStatus.success,
            users: [dummyUserProfile],
            addCustomerType: AddCustomerType.email,
            message: "done",
          ),
        ],
      );

      blocTest<AddCustomerBloc, AddCustomerState>(
        'Load Look Up Data (phone)',
        build: () => addCustomerBloc,
        act: (bloc) => bloc.add(LoadLookUpData("", SearchType.phone)),
        wait: Duration(milliseconds: 500),
        expect: () => [
          AddCustomerState(customerLookUpStatus: CustomerLookUpStatus.loading),
          AddCustomerState(
            customerLookUpStatus: CustomerLookUpStatus.success,
            users: [dummyUserProfile],
            addCustomerType: AddCustomerType.phone,
          ),
        ],
      );

      blocTest<AddCustomerBloc, AddCustomerState>(
        'Clear Message',
        build: () => addCustomerBloc,
        act: (bloc) => bloc.add(ClearMessage()),
        expect: () => [
          AddCustomerState(message: "", saveCustomerStatus: SaveCustomerStatus.notSaving),
        ],
      );

      blocTest<AddCustomerBloc, AddCustomerState>(
        'Reset Data',
        build: () => addCustomerBloc,
        act: (bloc) => bloc.add(ResetData()),
        expect: () => [
          AddCustomerState(customerLookUpStatus: CustomerLookUpStatus.initial, message: "done"),
        ],
      );

      blocTest<AddCustomerBloc, AddCustomerState>(
        'Clear Message',
        build: () => addCustomerBloc,
        act: (bloc) => bloc.add(ClearMessage()),
        expect: () => [
          AddCustomerState(message: "", saveCustomerStatus: SaveCustomerStatus.notSaving),
        ],
      );

      blocTest<AddCustomerBloc, AddCustomerState>(
        'Select User',
        build: () => addCustomerBloc,
        seed: () => AddCustomerState(users: [dummyUserProfile]),
        act: (bloc) => bloc.add(SelectUser(index: 0, orderId: "123", cartBloc: MockCartBloc(), function: () {})),
        expect: () => [
          AddCustomerState(users: [dummyUserProfile], message: "done"),
        ],
      );

      blocTest<AddCustomerBloc, AddCustomerState>(
        'Save Customer',
        build: () => addCustomerBloc,
        act: (bloc) => bloc.add(SaveCustomer(
          email: "joe.doe@mail.com",
          index: 0,
          cartBloc: MockCartBloc(),
          orderId: "123",
          phone: "123456789",
          firstName: "Joe",
          lastName: "Doe",
          address1: "Address 1",
          address2: "",
          city: "City",
          zipCode: "1234-567",
          state: "State",
        )),
        expect: () => [
          AddCustomerState(
            currentFName: "Joe",
            currentLName: "Doe",
            currentEmail: "joe.doe@mail.com",
            currentPhone: "123456789",
            currentAddress1: "Address 1",
            currentAddress2: "",
            currentCity: "City",
            currentState: "State",
            currentZip: "1234-567",
            saveCustomerStatus: SaveCustomerStatus.saving,
          ),
          AddCustomerState(
            currentFName: "Joe",
            currentLName: "Doe",
            currentEmail: "joe.doe@mail.com",
            currentPhone: "123456789",
            currentAddress1: "Address 1",
            currentAddress2: "",
            currentCity: "City",
            currentState: "State",
            currentZip: "1234-567",
            saveCustomerStatus: SaveCustomerStatus.notSaving,
            customerLookUpStatus: CustomerLookUpStatus.success,
            message: "done",
            users: [dummyUserProfile],
            newCustomerAdded: true,
          ),
        ],
      );
    },
  );

  group(
    'Failure Scenarios',
    () {
      setUp(() => successScenario = false);

      blocTest<AddCustomerBloc, AddCustomerState>(
        'Get Recommended Addresses Add Customer Failure',
        build: () => addCustomerBloc,
        act: (bloc) => bloc.add(GetRecommendedAddressesAddCustomer(
          address1: "418 Wilbur Rd",
          address2: "",
          city: "Thousand Oaks",
          state: "California",
          postalCode: "91360-5405",
          country: "United States",
          isShipping: true,
          isBilling: false,
          currentFName: "Joe",
          currentLName: "Doe",
          currentEmail: "joe.doe@mail.com",
          currentPhone: "123456789",
          cartBloc: MockCartBloc(),
        )),
        expect: () => [
          AddCustomerState(saveCustomerStatus: SaveCustomerStatus.saving),
          AddCustomerState(
            recommendedAddress: "",
            recommendedAddressLine1: "",
            saveCustomerStatus: SaveCustomerStatus.saving,
            recommendedAddressLine2: "",
            recommendedAddressLineCity: "",
            recommendedAddressLineCountry: "",
            recommendedAddressLineState: "",
            recommendedAddressLineZipCode: "",
            showRecommendedDialog: false,
            message: "done",
            orderAddress: "",
            currentFName: "Joe",
            currentLName: "Doe",
            currentEmail: "joe.doe@mail.com",
            currentPhone: "123456789",
            currentAddress1: "418 Wilbur Rd",
            currentAddress2: "",
            currentCity: "Thousand Oaks",
            currentState: "California",
            currentZip: "91360-5405",
          ),
          AddCustomerState(
            message: "Recommended address not found",
            recommendedAddress: "",
            saveCustomerStatus: SaveCustomerStatus.notSaving,
            orderAddress: "",
            recommendedAddressLine1: "418 Wilbur Rd",
            recommendedAddressLine2: "",
            recommendedAddressLineCity: "Thousand Oaks",
            recommendedAddressLineCountry: "United States",
            recommendedAddressLineState: "California",
            recommendedAddressLineZipCode: "91360-5405",
            showRecommendedDialog: false,
            currentFName: "Joe",
            currentLName: "Doe",
            currentEmail: "joe.doe@mail.com",
            currentPhone: "123456789",
            currentAddress1: "418 Wilbur Rd",
            currentAddress2: "",
            currentCity: "Thousand Oaks",
            currentState: "California",
            currentZip: "91360-5405",
          ),
        ],
      );

      blocTest<AddCustomerBloc, AddCustomerState>(
        'Save Customer Failure',
        build: () => addCustomerBloc,
        act: (bloc) => bloc.add(SaveCustomer(
          email: "joe.doe@mail.com",
          index: 0,
          cartBloc: MockCartBloc(),
          orderId: "123",
          phone: "123456789",
          firstName: "Joe",
          lastName: "Doe",
          address1: "Address 1",
          address2: "",
          city: "City",
          zipCode: "1234-567",
          state: "State",
        )),
        expect: () => [
          AddCustomerState(
            currentFName: "Joe",
            currentLName: "Doe",
            currentEmail: "joe.doe@mail.com",
            currentPhone: "123456789",
            currentAddress1: "Address 1",
            currentAddress2: "",
            currentCity: "City",
            currentState: "State",
            currentZip: "1234-567",
            saveCustomerStatus: SaveCustomerStatus.saving,
          ),
          AddCustomerState(
            currentFName: "Joe",
            currentLName: "Doe",
            currentEmail: "joe.doe@mail.com",
            currentPhone: "123456789",
            currentAddress1: "Address 1",
            currentAddress2: "",
            currentCity: "City",
            currentState: "State",
            currentZip: "1234-567",
            saveCustomerStatus: SaveCustomerStatus.notSaving,
            message: "Cannot create new user",
          ),
        ],
      );
    },
  );
}
