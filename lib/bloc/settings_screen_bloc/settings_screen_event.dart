// ignore_for_file: public_member_api_docs, sort_constructors_first
part of 'settings_screen_bloc.dart';

abstract class SettingsScreenEvent extends Equatable {
  SettingsScreenEvent();

  @override
  List<Object> get props => [];
}

class LoadSettingsChecks extends SettingsScreenEvent {
  @override
  List<Object> get props => [];
}

class SaveSettings extends SettingsScreenEvent {
  final Map incomingObject;
  final int index;
  SaveSettings({
    required this.incomingObject,
    required this.index,
  });
  @override
  List<Object> get props => [incomingObject];
}
