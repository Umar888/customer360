// ignore_for_file: public_member_api_docs, sort_constructors_first
part of 'settings_screen_bloc.dart';

abstract class SettingsScreenState extends Equatable {
  SettingsScreenState();

  @override
  List<Object> get props => [];
}

class SettingsScreenInitial extends SettingsScreenState {}

class LoadSettingChecksProgress extends SettingsScreenState {}

class LoadSettingChecksFailure extends SettingsScreenState {}

class LoadSettingCheckSuccess extends SettingsScreenState {
  final GetSettingsModel? getSettingsModel;
  LoadSettingCheckSuccess({
    required this.getSettingsModel,
  });
  @override
  List<Object> get props => [getSettingsModel!];
}
