import 'dart:convert';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gc_customer_app/bloc/add_commission_bloc/add_commission_bloc.dart';
import 'package:gc_customer_app/data/data_sources/add_commission_data_source/add_commission_data_source.dart';
import 'package:gc_customer_app/data/reporsitories/add_commission_repository/add_commission_repository.dart';
import 'package:gc_customer_app/models/add_commission_model/create_commission_model.dart';
import 'package:gc_customer_app/models/add_commission_model/search_employee_model.dart';
import 'package:http/http.dart';
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late AddCommissionBloc addCommissionBloc;
  SharedPreferences.setMockInitialValues({
    'agent_email': 'ankit.kumar@guitarcenter.com',
    'agent_id': '0014M00001nv3BwQAI',
    'agent_id_c360': '0014M00001nv3BwQAI',
    'logged_agent_id': '0054M000004UMmEQAW',
  });

  setUp(
    () {
      var addCommissionDataSource = AddCommissionDataSource();
      addCommissionDataSource.httpService.client = MockClient(
        (request) async {
          if (request.url.toString().contains('orderId=')) {
            return Response(
                json.encode({
                  "storeEmployees": [
                    {
                      "Id": "0056C000002YsAFQA0",
                      "Name": "Brian Szczepanski",
                      "UserRoleId": "00E6C000000nABVUA2",
                      "StoreId__c": "101",
                      "EmployeeNumber": "127777",
                    },
                  ],
                  "CommissionList": {
                    "totalCommission": 100,
                    "isEditable": true,
                    "CommissionWrapperList": [
                      {
                        "isEditable": true,
                        "employeeName": "Ankit Kumar",
                        "employeeId": "110085",
                        "employeeCommission": 50
                      },
                      {
                        "isEditable": true,
                        "employeeName": "Brian Szczepanski",
                        "employeeId": "127777",
                        "employeeCommission": 50
                      }
                    ]
                  }
                }),
                200);
          }
          return Response('', 200);
        },
      );
      addCommissionBloc = AddCommissionBloc(
          addCommissionRepository: AddCommissionRepository(
              addCommissionDataSource: addCommissionDataSource));
    },
  );

  group(
    'Add commission flow',
    () {
      blocTest(
        'Load commission',
        build: () => addCommissionBloc,
        act: (bloc) => bloc.add(PageLoad('123')),
        expect: () => [
          AddCommissionState(
              addCommissionStatus: AddCommissionStatus.loadState),
          AddCommissionState(
              addCommissionStatus: AddCommissionStatus.successState,
              currentPercentage: 100.0,
              listSelectedEmployees: CreateCommissionModel.fromJson({
                    "totalCommission": 100,
                    "isEditable": true,
                    "CommissionWrapperList": [
                      {
                        "isEditable": true,
                        "employeeName": "Ankit Kumar",
                        "employeeId": "110085",
                        "employeeCommission": 50
                      },
                      {
                        "isEditable": true,
                        "employeeName": "Brian Szczepanski",
                        "employeeId": "127777",
                        "employeeCommission": 50
                      }
                    ]
                  }).commissionWrapperList ??
                  [],
              listEmployeesSameStore: [
                SearchedEmployeeModel.fromJson(
                  {
                    "Id": "0056C000002YsAFQA0",
                    "Name": "Brian Szczepanski",
                    "UserRoleId": "00E6C000000nABVUA2",
                    "StoreId__c": "101",
                    "EmployeeNumber": "127777",
                  },
                )
              ])
        ],
      );

      blocTest(
        'Add new employee into commission',
        setUp: () {
          addCommissionBloc.state.addCommissionStatus =
              AddCommissionStatus.successState;
          addCommissionBloc.state.listSelectedEmployees =
              CreateCommissionModel.fromJson({
                    "totalCommission": 100,
                    "isEditable": true,
                    "CommissionWrapperList": [
                      {
                        "isEditable": true,
                        "employeeName": "Ankit Kumar",
                        "employeeId": "110085",
                        "employeeCommission": 100
                      },
                    ]
                  }).commissionWrapperList ??
                  [];
          addCommissionBloc.state.listEmployeesSameStore = [
            // SearchedEmployeeModel.fromJson({
            //   "Id": "0056C000002YsAFQA0",
            //   "Name": "Brian Szczepanski",
            //   "UserRoleId": "00E6C000000nABVUA2",
            //   "StoreId__c": "101",
            //   "EmployeeNumber": "127777",
            // })
          ];
        },
        build: () => addCommissionBloc,
        act: (bloc) => bloc.add(ListSelectedEmployeesAdd(
            employee: SearchedEmployeeModel.fromJson({
          "Id": "0056C000002YsAFQA0",
          "Name": "Brian Szczepanski",
          "UserRoleId": "00E6C000000nABVUA2",
          "StoreId__c": "101",
          "EmployeeNumber": "127777",
        }))),
        expect: () => [
          addCommissionBloc.state.copyWith(
              addCommissionStatus: AddCommissionStatus.successState,
              listSelectedEmployees: CreateCommissionModel.fromJson({
                    "totalCommission": 100,
                    "isEditable": true,
                    "CommissionWrapperList": [
                      {
                        "isEditable": true,
                        "employeeName": "Ankit Kumar",
                        "employeeId": "110085",
                        "employeeCommission": 100
                      },
                      {
                        "isEditable": false,
                        "employeeName": "Brian Szczepanski",
                        "employeeId": "127777",
                        "employeeCommission": 0,
                        "Id": "0056C000002YsAFQA0",
                      },
                    ]
                  }).commissionWrapperList ??
                  [])
        ],
      );

      blocTest(
        'Remove employee (different store) out of commission',
        setUp: () {
          addCommissionBloc.state.addCommissionStatus =
              AddCommissionStatus.successState;
          addCommissionBloc.state.listSelectedEmployees =
              CreateCommissionModel.fromJson({
                    "totalCommission": 100,
                    "isEditable": true,
                    "CommissionWrapperList": [
                      {
                        "isEditable": true,
                        "employeeName": "Ankit Kumar",
                        "employeeId": "110085",
                        "employeeCommission": 50
                      },
                      {
                        "isEditable": true,
                        "employeeName": "Brian Szczepanski",
                        "employeeId": "127777",
                        "employeeCommission": 50
                      }
                    ]
                  }).commissionWrapperList ??
                  [];
          addCommissionBloc.state.listEmployeesSameStore = [
            // SearchedEmployeeModel.fromJson({
            //   "Id": "0056C000002YsAFQA0",
            //   "Name": "Brian Szczepanski",
            //   "UserRoleId": "00E6C000000nABVUA2",
            //   "StoreId__c": "101",
            //   "EmployeeNumber": "127777",
            // })
          ];
        },
        build: () => addCommissionBloc,
        act: (bloc) => bloc.add(ListSelectedEmployeesRemove(
            selectedEmployeeModel: CommissionEmployee.fromJson({
          "isEditable": true,
          "employeeName": "Brian Szczepanski",
          "employeeId": "127777",
          "employeeCommission": 50
        }))),
        expect: () => [
          addCommissionBloc.state.copyWith(
              addCommissionStatus: AddCommissionStatus.successState,
              listSelectedEmployees: CreateCommissionModel.fromJson({
                    "totalCommission": 100,
                    "isEditable": true,
                    "CommissionWrapperList": [
                      {
                        "isEditable": true,
                        "employeeName": "Ankit Kumar",
                        "employeeId": "110085",
                        "employeeCommission": 50
                      },
                    ]
                  }).commissionWrapperList ??
                  [])
        ],
      );

      blocTest(
        'Remove employee (same store) out of commission',
        setUp: () {
          addCommissionBloc.storeId = '123';
          addCommissionBloc.state.addCommissionStatus =
              AddCommissionStatus.successState;
          addCommissionBloc.state.listSelectedEmployees =
              CreateCommissionModel.fromJson({
                    "totalCommission": 100,
                    "isEditable": true,
                    "CommissionWrapperList": [
                      {
                        "isEditable": true,
                        "employeeName": "Ankit Kumar",
                        "employeeId": "110085",
                        "employeeCommission": 50
                      },
                      {
                        "Id": "0056C000002YsAFQA0",
                        "isEditable": true,
                        "employeeName": "Brian Szczepanski",
                        "employeeId": "127777",
                        "employeeCommission": 50
                      }
                    ]
                  }).commissionWrapperList ??
                  [];
          addCommissionBloc.state.listEmployeesSameStore = [];
        },
        build: () => addCommissionBloc,
        act: (bloc) => bloc.add(ListSelectedEmployeesRemove(
          selectedEmployeeModel: CommissionEmployee(
              userId: "0056C000002YsAFQA0",
              isEditable: true,
              employeeName: "Brian Szczepanski",
              employeeId: "127777",
              employeeCommission: 50,
              storeId: '123'),
        )),
        expect: () => [
          addCommissionBloc.state.copyWith(
              addCommissionStatus: AddCommissionStatus.successState,
              listSelectedEmployees: CreateCommissionModel.fromJson({
                    "totalCommission": 100,
                    "isEditable": true,
                    "CommissionWrapperList": [
                      {
                        "isEditable": true,
                        "employeeName": "Ankit Kumar",
                        "employeeId": "110085",
                        "employeeCommission": 50
                      },
                    ]
                  }).commissionWrapperList ??
                  [],
              listEmployeesSameStore: [
                SearchedEmployeeModel.fromJson({
                  "Id": "0056C000002YsAFQA0",
                  "Name": "Brian Szczepanski",
                  "UserRoleId": "00E6C000000nABVUA2",
                  "StoreId__c": "123",
                  "EmployeeNumber": "127777",
                })
              ])
        ],
      );
    },
  );
}
