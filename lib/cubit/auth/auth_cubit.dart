import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:equatable/equatable.dart';

part 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  AuthCubit() : super(AuthInitial()) {
    checkSignin();
  }

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  Future<void> checkSignin() async {
    final User? user = _auth.currentUser;

    if (user != null) {
      emit(AuthSuccess(user));
    }
  }

  Future<void> registerWithEmailAndPassword(
      String email, String password) async {
    emit(AuthLoading());
    try {
      final user = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      emit(AuthSuccess(user.user!));
    } catch (error) {
      emit(AuthFailed(error.toString()));
    }
  }

  Future<void> signIn(String email, String password) async {
    emit(AuthLoading());
    try {
      final user = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      emit(AuthSuccess(user.user!));
    } on FirebaseAuthException catch (e) {
      emit(AuthFailed(e.message.toString()));
    } catch (error) {
      emit(AuthFailed(error.toString()));
    }
  }

  Future<void> googleSignIn() async {
    emit(AuthLoading());

    try {
      final googleAccount = await _googleSignIn.signIn();

      if (googleAccount == null) {
        emit(const AuthFailed("Please login again!"));
        return;
      }

      final googleAuth = await googleAccount.authentication;
      if (googleAuth.accessToken != null && googleAuth.idToken != null) {
        final authResult = await _auth.signInWithCredential(
          GoogleAuthProvider.credential(
              idToken: googleAuth.idToken, accessToken: googleAuth.accessToken),
        );
        emit(AuthSuccess(authResult.user!));
      }
    } on FirebaseAuthException catch (error) {
      emit(AuthFailed(error.message.toString()));
    } catch (error) {
      emit(AuthFailed(error.toString()));
    }
  }

  Future<void> logOut() async {
    emit(AuthLoading());
    try {
      //Sign out firebase
      await FirebaseAuth.instance.signOut();

      //Revoke Google access token
      await _googleSignIn.signOut();

      emit(AuthLogout());
    } catch (error) {
      emit(AuthFailed(error.toString()));
    }
  }
}
