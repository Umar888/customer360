import 'dart:convert';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gc_customer_app/bloc/approval_process_bloc/approval_process_bloc.dart';
import 'package:gc_customer_app/data/data_sources/approval_process_data_source/approval_process_data_source.dart';
import 'package:gc_customer_app/data/reporsitories/approval_process_repository/approval_process_repository.dart';
import 'package:gc_customer_app/models/approval_model.dart';
import 'package:http/http.dart';
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late ApprovalProcessBloC approvalProcessBloC;
  SharedPreferences.setMockInitialValues({
    'agent_email': 'ankit.kumar@guitarcenter.com',
    'agent_id': '0014M00001nv3BwQAI',
    'agent_id_c360': '0014M00001nv3BwQAI',
    'logged_agent_id': '0054M000004UMmEQAW',
  });

  setUp(
    () {
      var approvalProcessDataSource = ApprovalProcesssDataSource();
      approvalProcessDataSource.httpService.client =
          MockClient((request) async {
        if (!request.url.toString().contains('recordType=')) {
          return Response(
              json.encode({
                "ShippingOverrideApprovals": [
                  {
                    "ShippingAndHandling": 15.89,
                    "ShippingAdjustment": 15.0,
                    "ShipmentOverrideReason": "Special Handling (102)",
                    "RejectUrl":
                        "https://gcinc--tracuat.sandbox.my.salesforce.com/services/apexrest/GC_C360_ApprovalProcessAPI?recordId=a1O6C000001BB5fUAG&recordType=ShippingApproval&action=Reject",
                    "RecordId": "a1O6C000001BB5fUAG",
                    "OrderNumber": "GCSFU0000014260",
                    "LastModifiedDate": "2022-12-26T12:09:12.000Z",
                    "CreatedDate": "2022-12-26T12:08:13.000Z",
                    "ApproveUrl":
                        "https://gcinc--tracuat.sandbox.my.salesforce.com/services/apexrest/GC_C360_ApprovalProcessAPI?recordId=a1O6C000001BB5fUAG&recordType=ShippingApproval&action=Approve",
                    "ApprovalRequest": "Initiated"
                  },
                  {
                    "ShippingAndHandling": 26.12,
                    "ShippingAdjustment": 25.0,
                    "ShipmentOverrideReason": "Oversize Charge (101)",
                    "RejectUrl":
                        "https://gcinc--tracuat.sandbox.my.salesforce.com/services/apexrest/GC_C360_ApprovalProcessAPI?recordId=a1O6C000001BB5kUAG&recordType=ShippingApproval&action=Reject",
                    "RecordId": "a1O6C000001BB5kUAG",
                    "OrderNumber": "GCSFU0000014261",
                    "LastModifiedDate": "2022-12-26T12:11:41.000Z",
                    "CreatedDate": "2022-12-26T12:09:23.000Z",
                    "ApproveUrl":
                        "https://gcinc--tracuat.sandbox.my.salesforce.com/services/apexrest/GC_C360_ApprovalProcessAPI?recordId=a1O6C000001BB5kUAG&recordType=ShippingApproval&action=Approve",
                    "ApprovalRequest": "Initiated"
                  },
                ]
              }),
              200);
        } else if (request.url.toString().contains('action=Approve')) {
          return Response(
              json.encode({
                "approveStatus": {
                  "message": "Success",
                  "isSuccess": true,
                  "action": "Approve",
                }
              }),
              200);
        } else {
          return Response(
              json.encode({
                "approveStatus": {
                  "message": "Success",
                  "isSuccess": true,
                  "action": "Reject",
                }
              }),
              200);
        }
      });
      approvalProcessBloC = ApprovalProcessBloC(ApprovalProcesssRepository());
      approvalProcessBloC.approvalProcesssRepository
          .approvalProcesssDataSource = approvalProcessDataSource;
    },
  );

  group(
    "Success Scenarios",
    () {
      blocTest(
        "Load Approval List",
        setUp: () {},
        build: () => approvalProcessBloC,
        wait: Duration(milliseconds: 500),
        act: (bloc) => bloc.add(LoadApprovalProcess()),
        expect: () => [
          ApprovalProcessProgress(),
            ApprovalProcessSuccess(approvalModels: [
              ApprovalModel.fromJson({
                "ShippingAndHandling": 15.89,
                "ShippingAdjustment": 15.0,
                "ShipmentOverrideReason": "Special Handling (102)",
                "RejectUrl":
                    "https://gcinc--tracuat.sandbox.my.salesforce.com/services/apexrest/GC_C360_ApprovalProcessAPI?recordId=a1O6C000001BB5fUAG&recordType=ShippingApproval&action=Reject",
                "RecordId": "a1O6C000001BB5fUAG",
                "OrderNumber": "GCSFU0000014260",
                "LastModifiedDate": "2022-12-26T12:09:12.000Z",
                "CreatedDate": "2022-12-26T12:08:13.000Z",
                "ApproveUrl":
                    "https://gcinc--tracuat.sandbox.my.salesforce.com/services/apexrest/GC_C360_ApprovalProcessAPI?recordId=a1O6C000001BB5fUAG&recordType=ShippingApproval&action=Approve",
                "ApprovalRequest": "Initiated"
              }),
              ApprovalModel.fromJson({
                "ShippingAndHandling": 26.12,
                "ShippingAdjustment": 25.0,
                "ShipmentOverrideReason": "Oversize Charge (101)",
                "RejectUrl":
                    "https://gcinc--tracuat.sandbox.my.salesforce.com/services/apexrest/GC_C360_ApprovalProcessAPI?recordId=a1O6C000001BB5kUAG&recordType=ShippingApproval&action=Reject",
                "RecordId": "a1O6C000001BB5kUAG",
                "OrderNumber": "GCSFU0000014261",
                "LastModifiedDate": "2022-12-26T12:11:41.000Z",
                "CreatedDate": "2022-12-26T12:09:23.000Z",
                "ApproveUrl":
                    "https://gcinc--tracuat.sandbox.my.salesforce.com/services/apexrest/GC_C360_ApprovalProcessAPI?recordId=a1O6C000001BB5kUAG&recordType=ShippingApproval&action=Approve",
                "ApprovalRequest": "Initiated"
              }),
            ])
          ],
      );

      blocTest(
        'Approve Request',
        setUp: () {
          approvalProcessBloC.emit(ApprovalProcessSuccess(approvalModels: [
            ApprovalModel.fromJson({
              "ShippingAndHandling": 26.12,
              "ShippingAdjustment": 25.0,
              "ShipmentOverrideReason": "Oversize Charge (101)",
              "RejectUrl":
                  "https://gcinc--tracuat.sandbox.my.salesforce.com/services/apexrest/GC_C360_ApprovalProcessAPI?recordId=a1O6C000001BB5kABC&recordType=ShippingApproval&action=Reject",
              "RecordId": "a1O6C000001BB5kABC",
              "OrderNumber": "GCSFU00000123",
              "LastModifiedDate": "2022-12-26T12:11:41.000Z",
              "CreatedDate": "2022-12-26T12:09:23.000Z",
              "ApproveUrl":
                  "https://gcinc--tracuat.sandbox.my.salesforce.com/services/apexrest/GC_C360_ApprovalProcessAPI?recordId=a1O6C000001BB5kABC&recordType=ShippingApproval&action=Approve",
              "ApprovalRequest": "Initiated"
            })
          ]));
        },
        wait: Duration(seconds: 1),
        build: () => approvalProcessBloC,
        act: (bloc) => [
          approvalProcessBloC.add(ApproveApprovalProcess(
            'a1O6C000001BB5kABC',
            orderId: 'GCSFU00000123',
          )),
        ],
        expect: () => [
          ApprovalProcessProgress(),
          isA<ApprovalProcessSuccess>(),
          isA<ApprovalProcessSuccess>(),
        ],
      );

      blocTest(
        'Reject Request',
        setUp: () {
          approvalProcessBloC.emit(ApprovalProcessSuccess(approvalModels: [
            ApprovalModel.fromJson({
              "ShippingAndHandling": 26.12,
              "ShippingAdjustment": 25.0,
              "ShipmentOverrideReason": "Oversize Charge (101)",
              "RejectUrl":
                  "https://gcinc--tracuat.sandbox.my.salesforce.com/services/apexrest/GC_C360_ApprovalProcessAPI?recordId=a1O6C000001BB5kABC&recordType=ShippingApproval&action=Reject",
              "RecordId": "a1O6C000001BB5kABC",
              "OrderNumber": "GCSFU00000123",
              "LastModifiedDate": "2022-12-26T12:11:41.000Z",
              "CreatedDate": "2022-12-26T12:09:23.000Z",
              "ApproveUrl":
                  "https://gcinc--tracuat.sandbox.my.salesforce.com/services/apexrest/GC_C360_ApprovalProcessAPI?recordId=a1O6C000001BB5kABC&recordType=ShippingApproval&action=Approve",
              "ApprovalRequest": "Initiated"
            })
          ]));
        },
        wait: Duration(seconds: 1),
        build: () => approvalProcessBloC,
        act: (bloc) => [
          approvalProcessBloC.add(RejectApprovalProcesss(
            'a1O6C000001BB5kABC',
            orderId: 'GCSFU00000123',
          )),
        ],
        expect: () => [
          ApprovalProcessProgress(),
          isA<ApprovalProcessSuccess>(),
          isA<ApprovalProcessSuccess>(),
        ],
      );
    },
  );
}
