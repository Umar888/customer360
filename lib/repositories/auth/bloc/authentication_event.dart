part of 'authentication_bloc.dart';

abstract class AuthenticationEvent extends Equatable {
  AuthenticationEvent();

  @override
  List<Object> get props => [];
}

class AuthenticationStatusChanged extends AuthenticationEvent {
  AuthenticationStatusChanged(this.status);

  final AuthenticationStatus status;

  @override
  List<Object> get props => [status];
}

class AuthenticationLogoutRequested extends AuthenticationEvent {
  AuthenticationLogoutRequested({this.status = true,required this.context});

  final bool status;
  final BuildContext context;

  @override
  List<Object> get props => [status];}
class UpdateAuthToken extends AuthenticationEvent {}