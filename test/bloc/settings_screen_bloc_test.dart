import 'dart:convert';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gc_customer_app/bloc/settings_screen_bloc/settings_screen_bloc.dart';
import 'package:gc_customer_app/data/data_sources/setting_screen_data_source/setting_screen_data_source.dart';
import 'package:gc_customer_app/data/reporsitories/settings_screen_repository/settings_screen_repository.dart';
import 'package:gc_customer_app/models/settings_models/get_setting.dart';
import 'package:http/http.dart';
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../util/util.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late SettingsScreenBloc settingsScreenBloc;
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
      var settingsScreenDataSource = SettingsScreenDataSource()
        ..httpService.client = MockClient((request) async {
          if (successScenario) {
            if (request.matches(r'/services/apexrest/GC_C360_SettingsAPI'.escape)) {
              print("Success: ${request.url}");
              return Response(json.encode({}), 200);
            } else {
              print("API call not mocked: ${request.url}");
              return Response(json.encode({}), 205);
            }
          } else {
            print("Failed: ${request.url}");
            return Response("", 205);
          }
        });
      settingsScreenBloc = SettingsScreenBloc(settingsScreenRepository: SettingsScreenRepository());
      settingsScreenBloc.settingsScreenRepository.settingsScreenDataSource = settingsScreenDataSource;
    },
  );

  group(
    'Success Scenarios',
    () {
      setUp(() => successScenario = true);

      blocTest<SettingsScreenBloc, SettingsScreenState>(
        'Load Settings Checks',
        build: () => settingsScreenBloc,
        act: (bloc) => bloc.add(LoadSettingsChecks()),
        expect: () => [
          LoadSettingCheckSuccess(getSettingsModel: GetSettingsModel.fromJson({})),
        ],
      );

      blocTest<SettingsScreenBloc, SettingsScreenState>(
        'Save Settings',
        build: () => settingsScreenBloc,
        seed: () => LoadSettingCheckSuccess(
            getSettingsModel: GetSettingsModel(
          settings: [
            Settings(
              type: "Type 1",
              isDisabled: false,
              isSaving: false,
              isChecked: true,
              onClickButton: false,
            ),
            Settings(
              type: "Type 2",
              isDisabled: false,
              isSaving: false,
              isChecked: true,
              onClickButton: false,
            ),
          ],
          message: '1',
        )),
        act: (bloc) => bloc.add(SaveSettings(incomingObject: {}, index: 0)),
        expect: () => [
          LoadSettingCheckSuccess(
            getSettingsModel: GetSettingsModel(settings: [
              Settings(
                type: "Type 1",
                isDisabled: false,
                isSaving: false,
                isChecked: true,
                onClickButton: true,
              ),
              Settings(
                type: "Type 2",
                isDisabled: false,
                isSaving: false,
                isChecked: true,
                onClickButton: true,
              ),
            ], message: ''),
          ),
          LoadSettingCheckSuccess(
            getSettingsModel: GetSettingsModel(settings: [
              Settings(
                type: "Type 1",
                isDisabled: false,
                isSaving: false,
                isChecked: true,
                onClickButton: false,
              ),
              Settings(
                type: "Type 2",
                isDisabled: false,
                isSaving: false,
                isChecked: true,
                onClickButton: true,
              ),
            ], message: '1'),
          ),
        ],
      );
    },
  );

  group(
    'Failure Scenarios',
    () {
      setUp(() => successScenario = false);

      blocTest<SettingsScreenBloc, SettingsScreenState>(
        'Load Settings Checks Failure',
        build: () => settingsScreenBloc,
        act: (bloc) => bloc.add(LoadSettingsChecks()),
        expect: () => [
          LoadSettingChecksFailure(),
        ],
      );

      blocTest<SettingsScreenBloc, SettingsScreenState>(
        'Save Settings Failure',
        build: () => settingsScreenBloc,
        seed: () => LoadSettingCheckSuccess(
            getSettingsModel: GetSettingsModel(
              settings: [
                Settings(
                  type: "Type 1",
                  isDisabled: false,
                  isSaving: false,
                  isChecked: true,
                  onClickButton: false,
                ),
                Settings(
                  type: "Type 2",
                  isDisabled: false,
                  isSaving: false,
                  isChecked: true,
                  onClickButton: false,
                ),
              ],
              message: '1',
            )),
        act: (bloc) => bloc.add(SaveSettings(incomingObject: {}, index: 0)),
        expect: () => [
          LoadSettingCheckSuccess(
            getSettingsModel: GetSettingsModel(settings: [
              Settings(
                type: "Type 1",
                isDisabled: false,
                isSaving: true,
                isChecked: true,
                onClickButton: true,
              ),
              Settings(
                type: "Type 2",
                isDisabled: false,
                isSaving: false,
                isChecked: true,
                onClickButton: false,
              ),
            ], message: ''),
          ),
          LoadSettingChecksFailure(),
        ],
      );
    },
  );
}
