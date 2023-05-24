part of 'profile_screen_bloc.dart';

@immutable
abstract class ProfileScreenEvent extends Equatable {
  ProfileScreenEvent();
  @override
  List<Object> get props => [];
}

class LoadData extends ProfileScreenEvent {
  LoadData();

  @override
  List<Object> get props => [];
}
