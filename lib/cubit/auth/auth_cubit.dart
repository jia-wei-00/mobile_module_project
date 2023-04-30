import 'package:dictionary_api/components/snackbar.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  AuthCubit() : super(const AuthState()) {
    checkSignin();
  }

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  Future<void> checkSignin() async {
    final User? user = _auth.currentUser;

    if (user != null) {
      emit(state.copyWith(user: user));
    }
  }

  Future<void> registerWithEmailAndPassword(
      String email, String password, context) async {
    emit(state.copyWith(loading: true));
    try {
      final user = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      emit(state.copyWith(user: user.user, loading: false));
      snackBar(
          "Welcome ${user.user?.email}", Colors.green, Colors.white, context);
    } catch (error) {
      emit(state.copyWith(loading: false));
      snackBar(error.toString(), Colors.red, Colors.white, context);
    }
  }

  Future<void> signIn(String email, String password, context) async {
    emit(state.copyWith(loading: true));
    try {
      final user = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      emit(state.copyWith(user: user.user, loading: false));

      snackBar(
          "Welcome ${user.user?.email}", Colors.green, Colors.white, context);
    } on FirebaseAuthException catch (e) {
      emit(state.copyWith(loading: false));
      snackBar(e.message.toString(), Colors.red, Colors.white, context);
    } catch (error) {
      emit(state.copyWith(loading: false));
      snackBar(error.toString(), Colors.red, Colors.white, context);
    }
  }

  Future<void> googleSignIn(context) async {
    emit(state.copyWith(loading: true));

    try {
      final googleAccount = await _googleSignIn.signIn();

      if (googleAccount == null) {
        emit(state.copyWith(loading: false));
        snackBar("Please login again!", Colors.red, Colors.white, context);
        return;
      }

      final googleAuth = await googleAccount.authentication;
      if (googleAuth.accessToken != null && googleAuth.idToken != null) {
        final authResult = await _auth.signInWithCredential(
          GoogleAuthProvider.credential(
              idToken: googleAuth.idToken, accessToken: googleAuth.accessToken),
        );
        emit(state.copyWith(user: authResult.user, loading: false));
        snackBar("Welcome ${authResult.user?.displayName}", Colors.green,
            Colors.white, context);
      }
    } on FirebaseAuthException catch (error) {
      emit(state.copyWith(loading: false));
      snackBar(error.message.toString(), Colors.red, Colors.white, context);
    } catch (error) {
      emit(state.copyWith(loading: false));
      snackBar(error.toString(), Colors.red, Colors.white, context);
    }
  }

  Future<void> logOut(context) async {
    emit(state.copyWith(loading: true));
    try {
      //Sign out firebase
      await FirebaseAuth.instance.signOut();

      //Revoke Google access token
      await _googleSignIn.signOut();
      // await _googleSignIn.disconnect();

      emit(const AuthState());
      snackBar("Successfully logout", Colors.green, Colors.white, context);
    } catch (error) {
      emit(state.copyWith(loading: false));
      snackBar(error.toString(), Colors.red, Colors.white, context);
    }
  }
}
