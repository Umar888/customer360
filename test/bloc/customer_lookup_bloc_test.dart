import 'dart:convert';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gc_customer_app/bloc/customer_look_up_bloc/customer_look_up_bloc.dart';
import 'package:gc_customer_app/data/data_sources/customer_look_up_data_source/customer_lookup_data_source.dart';
import 'package:gc_customer_app/data/reporsitories/customer_look_up_repository/customer_lookup_repository.dart';
import 'package:gc_customer_app/models/user_profile_model.dart';
import 'package:http/http.dart';
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late CustomerLookUpBloc customerLookUpBloc;
  late CustomerLookUpDataSource customerLookUpDataSource;
  SharedPreferences.setMockInitialValues({
    'agent_email': 'ankit.kumar@guitarcenter.com',
    'agent_id': '0014M00001nv3BwQAI',
    'agent_id_c360': '0014M00001nv3BwQAI',
    'logged_agent_id': '0054M000004UMmEQAW',
  });

  setUp(() {
    customerLookUpDataSource = CustomerLookUpDataSource();
    customerLookUpDataSource.httpService.client = MockClient(
      (request) async {
        if (request.url.toString().contains('accountEmail__c=')) {
          return Response(
              json.encode({
                "records": [
                  {
                    "Id": "0014M00001nv3BwQAI",
                    "Name": "Ankit Kumar",
                    "FirstName": "Ankit",
                    "LastName": "Kumar",
                    "accountEmail__c": "ankit.kumar@guitarcenter.com",
                    "Brand_Code__c": "GC",
                    "accountPhone__c": "3233046476",
                    "Premium_Purchaser__c": false,
                    "PersonMailingStreet": "187 Teasdale St",
                    "Address_2__c": "APT 103",
                    "PersonMailingCity": "Thousand Oaks",
                    "PersonMailingState": "CA",
                    "PersonMailingPostalCode": "91360-3154",
                    "PersonMailingCountry": "US",
                    "Zip_Last_4__c": "5452",
                    "Last_Transaction_Date__c": "2020-08-06",
                    "Lifetime_Net_Sales_Amount__c": 713.49,
                    "Lifetime_Net_Sales_Transactions__c": 10.0,
                    "Lifetime_Net_Units__c": 8.0,
                    "Primary_Instrument_Category__c": "Guitar",
                    "Net_Sales_Amount_12MO__c": 631.58,
                    "Order_Count_12MO__c": 5.0,
                    "Epsilon_Customer_Brand_Key__c": "GC_1000000000002",
                    "Lessons_Customer__c": false,
                    "Open_Box_Purchaser__c": false,
                    "Loyalty_Customer__c": true,
                    "Used_Purchaser__c": false,
                    "Synchrony_Customer__c": false,
                    "Vintage_Purchaser__c": false
                  }
                ]
              }),
              200);
        }
        return Response(
            json.encode({
              'isSuccess': true,
              'customer': {
                "Id": "0014M00001nv3BwQAI",
                "Name": "Ankit Kumar",
                "FirstName": "Ankit",
                "LastName": "Kumar",
                "accountEmail__c": "ankit.kumar@guitarcenter.com",
                "Brand_Code__c": "GC",
                "accountPhone__c": "3233046476",
                "Premium_Purchaser__c": false,
                "PersonMailingStreet": "187 Teasdale St",
                "Address_2__c": "APT 103",
                "PersonMailingCity": "Thousand Oaks",
                "PersonMailingState": "CA",
                "PersonMailingPostalCode": "91360-3154",
                "PersonMailingCountry": "US",
                "Zip_Last_4__c": "5452",
                "Last_Transaction_Date__c": "2020-08-06",
                "Lifetime_Net_Sales_Amount__c": 713.49,
                "Lifetime_Net_Sales_Transactions__c": 10.0,
                "Lifetime_Net_Units__c": 8.0,
                "Primary_Instrument_Category__c": "Guitar",
                "Net_Sales_Amount_12MO__c": 631.58,
                "Order_Count_12MO__c": 5.0,
                "Epsilon_Customer_Brand_Key__c": "GC_1000000000002",
                "Lessons_Customer__c": false,
                "Open_Box_Purchaser__c": false,
                "Loyalty_Customer__c": true,
                "Used_Purchaser__c": false,
                "Synchrony_Customer__c": false,
                "Vintage_Purchaser__c": false
              }
            }),
            200);
      },
    );
    customerLookUpBloc = CustomerLookUpBloc(CustomerLookUpRepository());
    customerLookUpBloc.customerLookUpRepository.customerLookUpDataSource = customerLookUpDataSource;
  });

  group(
    'Customer lookup',
    () {
      blocTest(
        'Look up data',
        build: () => customerLookUpBloc,
        act: (bloc) => bloc.add(LoadLookUpData('ankit.kumar@guitarcenter.com', SearchType.email)),
        expect: () => [
          CustomerLookUpProgress(),
          CustomerLookUpSuccess(type: SearchType.email, users: [
            UserProfile.fromJson({
              "Id": "0014M00001nv3BwQAI",
              "Name": "Ankit Kumar",
              "FirstName": "Ankit",
              "LastName": "Kumar",
              "accountEmail__c": "ankit.kumar@guitarcenter.com",
              "Brand_Code__c": "GC",
              "accountPhone__c": "3233046476",
              "Premium_Purchaser__c": false,
              "PersonMailingStreet": "187 Teasdale St",
              "Address_2__c": "APT 103",
              "PersonMailingCity": "Thousand Oaks",
              "PersonMailingState": "CA",
              "PersonMailingPostalCode": "91360-3154",
              "PersonMailingCountry": "US",
              "Zip_Last_4__c": "5452",
              "Last_Transaction_Date__c": "2020-08-06",
              "Lifetime_Net_Sales_Amount__c": 713.49,
              "Lifetime_Net_Sales_Transactions__c": 10.0,
              "Lifetime_Net_Units__c": 8.0,
              "Primary_Instrument_Category__c": "Guitar",
              "Net_Sales_Amount_12MO__c": 631.58,
              "Order_Count_12MO__c": 5.0,
              "Epsilon_Customer_Brand_Key__c": "GC_1000000000002",
              "Lessons_Customer__c": false,
              "Open_Box_Purchaser__c": false,
              "Loyalty_Customer__c": true,
              "Used_Purchaser__c": false,
              "Synchrony_Customer__c": false,
              "Vintage_Purchaser__c": false
            })
          ])
        ],
      );

      blocTest(
        'Clear data',
        build: () => customerLookUpBloc,
        act: (bloc) => bloc.add(ClearData()),
        expect: () => [
          CustomerLookUpInitial(),
        ],
      );

      blocTest<CustomerLookUpBloc, CustomerLookUpState>(
        'Save customer',
        build: () => customerLookUpBloc,
        seed: () => SaveCustomerProgress(),
        act: (bloc) => bloc.add(SaveCustomer(
          email: 'ankit.kumar@guitarcenter.com',
          phone: '3233046476',
          firstName: 'Ankit',
          lastName: 'Kumar',
          address: '187 Teasdale St',
          address2: 'APT 103',
          city: 'Thousand Oaks',
          zipCode: '91360-3154',
          state: 'CA',
          proficiencyLevel: '',
          customerLookUpState: customerLookUpBloc.state,
          playFrequency: '',
          playInstruments: '',
        )),
        expect: () => [
          SaveCustomerProgress(
              isShowOptions: true,
              isShowDialog: false,
              isLoading: true,
              message: "done",
              recommendAddress: null,
              enteredAddress: null,
              proficiencies: [],
              frequencies: [],
              instruments: [],
              selectedProficiency: "",
              selectedInstruments: [],
              selectedFrequency: "",
          ),
          SaveCustomerSuccess(UserProfile.fromJson({
            "Id": "0014M00001nv3BwQAI",
            "Name": "Ankit Kumar",
            "FirstName": "Ankit",
            "LastName": "Kumar",
            "accountEmail__c": "ankit.kumar@guitarcenter.com",
            "Brand_Code__c": "GC",
            "accountPhone__c": "3233046476",
            "Premium_Purchaser__c": false,
            "PersonMailingStreet": "187 Teasdale St",
            "Address_2__c": "APT 103",
            "PersonMailingCity": "Thousand Oaks",
            "PersonMailingState": "CA",
            "PersonMailingPostalCode": "91360-3154",
            "PersonMailingCountry": "US",
            "Zip_Last_4__c": "5452",
            "Last_Transaction_Date__c": "2020-08-06",
            "Lifetime_Net_Sales_Amount__c": 713.49,
            "Lifetime_Net_Sales_Transactions__c": 10.0,
            "Lifetime_Net_Units__c": 8.0,
            "Primary_Instrument_Category__c": "Guitar",
            "Net_Sales_Amount_12MO__c": 631.58,
            "Order_Count_12MO__c": 5.0,
            "Epsilon_Customer_Brand_Key__c": "GC_1000000000002",
            "Lessons_Customer__c": false,
            "Open_Box_Purchaser__c": false,
            "Loyalty_Customer__c": true,
            "Used_Purchaser__c": false,
            "Synchrony_Customer__c": false,
            "Vintage_Purchaser__c": false
          })),
        ],
      );
    },
  );
}
