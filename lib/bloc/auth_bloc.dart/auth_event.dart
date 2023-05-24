part of 'auth_bloc.dart';

abstract class AuthEvent extends Equatable {
  AuthEvent();
}

class Authentication extends AuthEvent {
  Authentication();

  @override
  List<Object?> get props => [];
}

class LogOutEvent extends AuthEvent {
  LogOutEvent();

  @override
  List<Object?> get props => [];
}
