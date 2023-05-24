import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:gc_customer_app/data/reporsitories/settings_screen_repository/settings_screen_repository.dart';
import 'package:gc_customer_app/models/settings_models/get_setting.dart';
import 'package:gc_customer_app/primitives/constants.dart';
import 'package:gc_customer_app/services/networking/http_response.dart';
import 'package:gc_customer_app/services/storage/shared_preferences_service.dart';

part 'settings_screen_event.dart';
part 'settings_screen_state.dart';

class SettingsScreenBloc
    extends Bloc<SettingsScreenEvent, SettingsScreenState> {
  SettingsScreenRepository settingsScreenRepository;
  SettingsScreenBloc({required this.settingsScreenRepository})
      : super(SettingsScreenInitial()) {
    on<LoadSettingsChecks>((event, emit) async {
      LoadSettingChecksProgress();
      HttpResponse response = await getSettingsCheckList();
      if (response.data != null && response.status == true) {
        GetSettingsModel getSettingsModel =
            GetSettingsModel.fromJson(response.data);
        emit(
          LoadSettingCheckSuccess(getSettingsModel: getSettingsModel),
        );
      } else {
        emit(LoadSettingChecksFailure());
      }
    });
    on<SaveSettings>((event, emit) async {
      var previousState = state as LoadSettingCheckSuccess;
      List<Settings> incomingListOfSettings =
          previousState.getSettingsModel!.settings;
      for (int k = 0; k < incomingListOfSettings.length; k++) {
        if (k == event.index) {
          incomingListOfSettings[event.index] = Settings(
            type: incomingListOfSettings[k].type,
            isDisabled: incomingListOfSettings[k].isDisabled,
            isSaving: true,
            isChecked: incomingListOfSettings[k].isChecked,
            onClickButton: true,
          );
        } else {
          Settings(
            type: incomingListOfSettings[k].type,
            isDisabled: incomingListOfSettings[k].isDisabled,
            isSaving: false,
            isChecked: incomingListOfSettings[k].isChecked,
            onClickButton: incomingListOfSettings[k].onClickButton = false,
          );
        }
      }
      emit(
        LoadSettingCheckSuccess(
            getSettingsModel: GetSettingsModel(
                settings: incomingListOfSettings, message: '')),
      );
      HttpResponse response =
          await saveSettings(incomingObject: event.incomingObject);

      if (response.data != null) {
        for (int k = 0; k < incomingListOfSettings.length; k++) {
          if (k == event.index) {
            incomingListOfSettings[event.index] = Settings(
              type: incomingListOfSettings[k].type,
              isDisabled: incomingListOfSettings[k].isDisabled,
              isSaving: false,
              isChecked: incomingListOfSettings[k].isChecked,
              onClickButton: true,
            );
          } else {
            Settings(
              type: incomingListOfSettings[k].type,
              isDisabled: incomingListOfSettings[k].isDisabled,
              isSaving: false,
              isChecked: incomingListOfSettings[k].isChecked,
              onClickButton: incomingListOfSettings[k].onClickButton = true,
            );
          }
        }

        // incomingListOfSettings[event.index] = Settings(
        //   type: incomingListOfSettings[event.index].type,
        //   isDisabled: incomingListOfSettings[event.index].isDisabled,
        //   isSaving: false,
        //   isChecked: incomingListOfSettings[event.index].isChecked,
        //   onClickButton: true,
        // );
        emit(
          LoadSettingCheckSuccess(
              getSettingsModel: previousState.getSettingsModel),
        );
      } else {
        emit(LoadSettingChecksFailure());
      }
    });
  }

  Future<HttpResponse> getSettingsCheckList() async {
    var id = await SharedPreferenceService().getValue(agentId);
    final response =
        await settingsScreenRepository.getSettingsScreenChecks(id);
    return response;
  }

  Future<HttpResponse> saveSettings({required Map incomingObject}) async {
    var id = await SharedPreferenceService().getValue(agentId);
    final response = await settingsScreenRepository
        .saveSettingsBackend(recordID: id, latestCheckValue: incomingObject);
    return response;
  }
}
