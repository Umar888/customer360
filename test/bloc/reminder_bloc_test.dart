import 'dart:convert';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gc_customer_app/bloc/reminder_bloc/reminder_bloc.dart';
import 'package:gc_customer_app/data/data_sources/reminder_screen_data_source/reminder_screen_data_source.dart';
import 'package:gc_customer_app/data/reporsitories/reminder_screen_repository/reminder_screen_repository.dart';
import 'package:gc_customer_app/models/reminder_model.dart';
import 'package:http/http.dart';
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late ReminderBloC reminderBloC;
  late ReminderScreenDataSource reminderScreenDataSource;
  SharedPreferences.setMockInitialValues({
    'agent_email': 'ankit.kumar@guitarcenter.com',
    'agent_id': '0014M00001nv3BwQAI',
    'agent_id_c360': '0014M00001nv3BwQAI',
    'logged_agent_id': '0054M000004UMmEQAW',
  });

  setUp(() {
    reminderScreenDataSource = ReminderScreenDataSource();
    reminderScreenDataSource.httpService.client = MockClient(
      (request) async {
        if (request.method.toLowerCase().contains('post')) {
          return Response(
              json.encode({
                "task": {
                  "Id": "00T6C00000DUozYUAT",
                  "Status": "Open",
                  "Subject": "Email Ankit Kumar - Internal",
                  "WhoId": "0034M00001wCkKWQA0",
                  "ActivityDate": "2022-12-30",
                  "CreatedDate": "2022-12-30T01:20:25.000+0000",
                  "LastModifiedDate": "2022-12-30T01:20:25.000+0000",
                  "Store_Task_Type__c": "Internal",
                  "Email__c": "ankit.kumar@guitarcenter.com",
                  "Phone__c": "323304647",
                  "First_Name__c": "Ankit",
                  "Description": "Note1",
                  "Last_Name__c": "Kumar",
                  "OwnerId": "0054M000004UMmEQAW",
                  "CreatedById": "0056C000003sGZ6QAM",
                  "LastModifiedById": "0056C000003sGZ6QAM",
                  "ModifiedUser__c": "0054M000004UMmEQAW",
                  "Date_Label__c": "Open",
                  "Day_Label__c": null
                }
              }),
              200);
        }
        return Response(
            json.encode({
              "AllOpenTasks": [
                {
                  "Id": "00T6C00000DUozYUAT",
                  "Status": "Open",
                  "Subject": "Call Ankit Kumar - Internal",
                  "WhoId": "0034M00001wCkKWQA0",
                  "ActivityDate": "2022-12-30",
                  "CreatedDate": "2022-12-30T01:20:25.000+0000",
                  "LastModifiedDate": "2022-12-30T01:20:25.000+0000",
                  "Store_Task_Type__c": "Internal",
                  "Email__c": "ankit.kumar@guitarcenter.com",
                  "Phone__c": "323304647",
                  "First_Name__c": "Ankit",
                  "Description": "note1",
                  "Last_Name__c": "Kumar",
                  "OwnerId": "0054M000004UMmEQAW",
                  "CreatedById": "0056C000003sGZ6QAM",
                  "LastModifiedById": "0056C000003sGZ6QAM",
                  "ModifiedUser__c": "0054M000004UMmEQAW",
                  "Date_Label__c": "Open",
                  "Day_Label__c": null
                }
              ]
            }),
            200);
      },
    );
    reminderBloC = ReminderBloC(reminderRepo: ReminderScreenReponsitory());
    reminderBloC.reminderRepo.reminderScreenDataSource =
        reminderScreenDataSource;
  });

  group(
    'Customer Reminder Flow',
    () {
      blocTest(
        'Get Customer Reminders',
        build: () => reminderBloC,
        act: (bloc) => bloc.add(LoadReminders()),
        expect: () => [
          ReminderInitial(
            reminderState: ReminderState.successState,
            reminders: [
              ReminderModel.fromJson({
                "Id": "00T6C00000DUozYUAT",
                "Status": "Open",
                "Subject": "Call Ankit Kumar - Internal",
                "WhoId": "0034M00001wCkKWQA0",
                "ActivityDate": "2022-12-30",
                "CreatedDate": "2022-12-30T01:20:25.000+0000",
                "LastModifiedDate": "2022-12-30T01:20:25.000+0000",
                "Store_Task_Type__c": "Internal",
                "Email__c": "ankit.kumar@guitarcenter.com",
                "Phone__c": "323304647",
                "First_Name__c": "Ankit",
                "Last_Name__c": "Kumar",
                "Description": "note1",
                "OwnerId": "0054M000004UMmEQAW",
                "CreatedById": "0056C000003sGZ6QAM",
                "LastModifiedById": "0056C000003sGZ6QAM",
                "ModifiedUser__c": "0054M000004UMmEQAW",
                "Date_Label__c": "Open",
                "Day_Label__c": null
              })
            ],
            reminderModel: null,
          )
        ],
      );

      blocTest(
        'Add new reminder',
        build: () => reminderBloC,
        act: (bloc) =>
            bloc.add(SaveReminders('Note1', DateTime(2022, 12, 30), 'Email')),
        expect: () => [
          ReminderInitial(reminderState: ReminderState.loadState),
          ReminderInitial(
              reminderState: ReminderState.successState,
              reminderModel: ReminderModel.fromJson({
                "Id": "00T6C00000DUozYUAT",
                "Status": "Open",
                "Subject": "Email Ankit Kumar - Internal",
                "WhoId": "0034M00001wCkKWQA0",
                "ActivityDate": "2022-12-30",
                "CreatedDate": "2022-12-30T01:20:25.000+0000",
                "LastModifiedDate": "2022-12-30T01:20:25.000+0000",
                "Store_Task_Type__c": "Internal",
                "Email__c": "ankit.kumar@guitarcenter.com",
                "Phone__c": "323304647",
                "First_Name__c": "Ankit",
                "Description": "Note1",
                "Last_Name__c": "Kumar",
                "OwnerId": "0054M000004UMmEQAW",
                "CreatedById": "0056C000003sGZ6QAM",
                "LastModifiedById": "0056C000003sGZ6QAM",
                "ModifiedUser__c": "0054M000004UMmEQAW",
                "Date_Label__c": "Open",
                "Day_Label__c": null
              })),
        ],
      );

      blocTest(
        'Edit reminder',
        build: () => reminderBloC,
        act: (bloc) => bloc.add(UpdateReminders(
            'Note1', DateTime(2022, 12, 30), 'Email', '00T6C00000DUozYUAT')),
        expect: () => [
          ReminderInitial(reminderState: ReminderState.loadState),
          ReminderInitial(
              reminderState: ReminderState.successState,
              reminderModel: ReminderModel.fromJson({
                "Id": "00T6C00000DUozYUAT",
                "Status": "Open",
                "Subject": "Email Ankit Kumar - Internal",
                "WhoId": "0034M00001wCkKWQA0",
                "ActivityDate": "2022-12-30",
                "CreatedDate": "2022-12-30T01:20:25.000+0000",
                "LastModifiedDate": "2022-12-30T01:20:25.000+0000",
                "Store_Task_Type__c": "Internal",
                "Email__c": "ankit.kumar@guitarcenter.com",
                "Phone__c": "323304647",
                "First_Name__c": "Ankit",
                "Description": "Note1",
                "Last_Name__c": "Kumar",
                "OwnerId": "0054M000004UMmEQAW",
                "CreatedById": "0056C000003sGZ6QAM",
                "LastModifiedById": "0056C000003sGZ6QAM",
                "ModifiedUser__c": "0054M000004UMmEQAW",
                "Date_Label__c": "Open",
                "Day_Label__c": null
              })),
        ],
      );
    },
  );
}
