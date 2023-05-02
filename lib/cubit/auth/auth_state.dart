import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthState extends Equatable {
  final User? user;
  final bool loading;

  const AuthState({this.user, this.loading = false});

  AuthState copyWith({User? user, bool? loading}) {
    return AuthState(
      user: user ?? this.user,
      loading: loading ?? this.loading,
    );
  }

  @override
  List<Object?> get props => [user, loading];
}

// class AuthFailed extends AuthState {}
