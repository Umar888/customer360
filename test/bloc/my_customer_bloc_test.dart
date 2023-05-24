// ignore_for_file: unused_local_variable

import 'dart:convert';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gc_customer_app/bloc/my_customer_bloc/my_customer_bloc.dart';
import 'package:gc_customer_app/data/reporsitories/my_customer_repository/my_customer_repository.dart';
import 'package:gc_customer_app/models/my_customer/customer_model.dart';
import 'package:gc_customer_app/models/my_customer/employee_my_customer_model.dart';
import 'package:http/http.dart';
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../util/util.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late MyCustomerBloC? myCustomerBloc;
  SharedPreferences.setMockInitialValues({
    'agent_email': 'ankit.kumar@guitarcenter.com',
    'agent_id': '0014M00001nv3BwQAI',
    'agent_id_c360': '0014M00001nv3BwQAI',
    'logged_agent_id': '0054M000004UMmEQAW',
    'access_token': '12345',
    'instance_url': '12345',
  });

  late bool successScenario;
  MyCustomerBloC setUpBloc() {
    var mock = MockClient((request) async {
      if (successScenario) {
        if (request.matches(r'/services/apexrest/MyCustomers_IsManagerApi'.escape)) {
          print("Success: ${request.url}");
          return Response(json.encode({"IsManager": true, "allUsers": true}), 200);
        } else if (request.matches(r'/services/apexrest/MyCustomers_GetUsersForStoreApi'.escape)) {
          print("Success: ${request.url}");
          return Response(
              json.encode({
                "UserList": [{}]
              }),
              200);
        } else if (request.matches(r'/services/apexrest/MyCustomers_GetLoggedInUserNameApi'.escape)) {
          print("Success: ${request.url}");
          return Response(json.encode({"Name": "Joe Doe"}), 200);
        } else if (request.matches(r'/services/apexrest/MyCustomers_GetAllAccountCountApi'.escape)) {
          print("Success: ${request.url}");
          return Response(json.encode({"Count": "5"}), 200);
        } else if (request.matches(r'/services/apexrest/MyCustomers_GetNewAccountCountApi'.escape)) {
          print("Success: ${request.url}");
          return Response(json.encode({"Count": "2"}), 200);
        } else if (request.matches(r'/services/apexrest/MyCustomers_PriorityCountsApi'.escape)) {
          print("Success: ${request.url}");
          return Response(
              json.encode({
                "resp": [{}],
                "MediumCount": 1,
                "LowCount": 2,
                "HighCount": 4
              }),
              200);
        } else if (request.matches(r'/services/apexrest/MyCustomers_ContactedCountsApi'.escape)) {
          print("Success: ${request.url}");
          return Response(
              json.encode({
                "resp": [{}],
                "NotContactedCount": 1,
                "ContactedCount": 2
              }),
              200);
        } else if (request.matches(r'/services/apexrest/MyCustomers_PurchasedCountsApi'.escape)) {
          print("Success: ${request.url}");
          return Response(
              json.encode({
                "resp": [{}],
                "NotPurchasedCount": 1,
                "PurchasedCount": 2
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
    return MyCustomerBloC(MyCustomerRepository()..myCustomerDataSource.httpService.client = mock);
  }

  group(
    'Success Scenarios',
    () {
      setUp(() => successScenario = true);

      blocTest<MyCustomerBloC, MyCustomerState>(
        'Load My Customer Information',
        build: () => myCustomerBloc = setUpBloc(),
        tearDown: () => myCustomerBloc = null,
        act: (bloc) => bloc.add(LoadMyCustomerInformation("", DateTime(2023, 4, 4), DateTime(2023, 4, 5))),
        expect: () => [
          MyCustomerState(isLoading: true, loggedInUserId: "0054M000004UMmEQAW"),
          MyCustomerState(
            isLoading: true,
            isManager: true,
            isShowAllUsers: true,
          ),
          MyCustomerState(
            isLoading: true,
            isManager: true,
            isShowAllUsers: true,
            employees: [EmployeeMyCustomerModel.fromJson({})],
          ),
          MyCustomerState(
            isLoading: true,
            isManager: true,
            isShowAllUsers: true,
            employees: [EmployeeMyCustomerModel.fromJson({})],
            loggedInUserName: "Joe Doe",
          ),
          MyCustomerState(
            isLoading: true,
            isManager: true,
            isShowAllUsers: true,
            employees: [EmployeeMyCustomerModel.fromJson({})],
            loggedInUserName: "Joe Doe",
            allCount: "5",
          ),
          MyCustomerState(
            isLoading: true,
            isManager: true,
            isShowAllUsers: true,
            employees: [EmployeeMyCustomerModel.fromJson({})],
            loggedInUserName: "Joe Doe",
            allCount: "5",
            newCount: "2",
          ),
          MyCustomerState(
            isLoading: true,
            isManager: true,
            isShowAllUsers: true,
            employees: [EmployeeMyCustomerModel.fromJson({})],
            loggedInUserName: "Joe Doe",
            allCount: "5",
            newCount: "2",
            clients: [MyCustomerModel.fromJson({})],
            high: 4,
            medium: 1,
            low: 2,
          ),
          MyCustomerState(
            isLoading: true,
            isManager: true,
            isShowAllUsers: true,
            employees: [EmployeeMyCustomerModel.fromJson({})],
            loggedInUserName: "Joe Doe",
            allCount: "5",
            newCount: "2",
            clients: [MyCustomerModel.fromJson({})],
            high: 4,
            medium: 1,
            low: 2,
            contacteds: [MyCustomerModel.fromJson({})],
            contactedCount: 2,
            notContactedCount: 1,
          ),
          MyCustomerState(
            isLoading: true,
            isManager: true,
            isShowAllUsers: true,
            employees: [EmployeeMyCustomerModel.fromJson({})],
            loggedInUserName: "Joe Doe",
            allCount: "5",
            newCount: "2",
            clients: [MyCustomerModel.fromJson({})],
            high: 4,
            medium: 1,
            low: 2,
            contacteds: [MyCustomerModel.fromJson({})],
            contactedCount: 2,
            notContactedCount: 1,
            purchaseds: [MyCustomerModel.fromJson({})],
            purchasedCount: 2,
            notPurchasedCount: 1,
          ),
          MyCustomerState(
            isManager: true,
            isShowAllUsers: true,
            employees: [EmployeeMyCustomerModel.fromJson({})],
            loggedInUserName: "Joe Doe",
            allCount: "5",
            newCount: "2",
            clients: [MyCustomerModel.fromJson({})],
            high: 4,
            medium: 1,
            low: 2,
            contacteds: [MyCustomerModel.fromJson({})],
            contactedCount: 2,
            notContactedCount: 1,
            purchaseds: [MyCustomerModel.fromJson({})],
            purchasedCount: 2,
            notPurchasedCount: 1,
            isLoading: false,
          ),
        ],
      );

      blocTest<MyCustomerBloC, MyCustomerState>(
        'Load Employee Information',
        build: () => myCustomerBloc = setUpBloc(),
        tearDown: () => myCustomerBloc = null,
        act: (bloc) => bloc.add(LoadEmployeeInformation("", DateTime(2023, 4, 4), DateTime(2023, 4, 5), "123")),
        expect: () => [
          MyCustomerState(isLoading: true),
          MyCustomerState(
            isLoading: true,
            allCount: "5",
          ),
          MyCustomerState(
            isLoading: true,
            allCount: "5",
            newCount: "2",
          ),
          MyCustomerState(
            isLoading: true,
            allCount: "5",
            newCount: "2",
            clients: [MyCustomerModel.fromJson({})],
            high: 4,
            medium: 1,
            low: 2,
          ),
          MyCustomerState(
            isLoading: true,
            allCount: "5",
            newCount: "2",
            clients: [MyCustomerModel.fromJson({})],
            high: 4,
            medium: 1,
            low: 2,
            contacteds: [MyCustomerModel.fromJson({})],
            contactedCount: 2,
            notContactedCount: 1,
          ),
          MyCustomerState(
            isLoading: true,
            allCount: "5",
            newCount: "2",
            clients: [MyCustomerModel.fromJson({})],
            high: 4,
            medium: 1,
            low: 2,
            contacteds: [MyCustomerModel.fromJson({})],
            contactedCount: 2,
            notContactedCount: 1,
            purchaseds: [MyCustomerModel.fromJson({})],
            purchasedCount: 2,
            notPurchasedCount: 1,
          ),
          MyCustomerState(
            allCount: "5",
            newCount: "2",
            clients: [MyCustomerModel.fromJson({})],
            high: 4,
            medium: 1,
            low: 2,
            contacteds: [MyCustomerModel.fromJson({})],
            contactedCount: 2,
            notContactedCount: 1,
            purchaseds: [MyCustomerModel.fromJson({})],
            purchasedCount: 2,
            notPurchasedCount: 1,
            isLoading: false,
          ),
        ],
      );
    },
  );

  group(
    'Failure Scenarios',
    () {
      setUp(() => successScenario = false);
    },
  );
}
