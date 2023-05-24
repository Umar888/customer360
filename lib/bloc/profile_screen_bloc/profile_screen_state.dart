part of 'profile_screen_bloc.dart';

@immutable
abstract class ProfileScreenState extends Equatable {
  @override
  List<Object?> get props => [];
}

class ProfileScreenInitial extends ProfileScreenState {}

class ProfileScreenProgress extends ProfileScreenState {}

class ProfileScreenFailure extends ProfileScreenState {}

class ProfileScreenSuccess extends ProfileScreenState {
  final UserProfile? userProfile;

  ProfileScreenSuccess({this.userProfile});

  @override
  List<Object?> get props => [userProfile];
}
