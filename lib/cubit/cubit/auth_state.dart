part of 'auth_cubit.dart';

@immutable
abstract class AuthState {}

class AuthInitial extends AuthState {}

class AuthLoginState extends AuthState {
  String email;
  String password;

  AuthLoginState(this.email, this.password);
}

class AuthRegisterState extends AuthState {
  String email;
  String password;

  AuthRegisterState(this.email, this.password);
}

class LogoutState extends AuthState {
  LogoutState();
}
