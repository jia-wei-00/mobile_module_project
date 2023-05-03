import 'package:dictionary_api/components/snackbar.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
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
      String email, String password, context) async {
    emit(AuthLoading());
    try {
      final user = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      emit(AuthSuccess(user.user!));
      snackBar(
          "Welcome ${user.user?.email}", Colors.green, Colors.white, context);
    } catch (error) {
      emit(AuthFailed());
      snackBar(error.toString(), Colors.red, Colors.white, context);
    }
  }

  Future<void> signIn(String email, String password, context) async {
    emit(AuthLoading());
    try {
      final user = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      emit(AuthSuccess(user.user!));
      snackBar(
          "Welcome ${user.user?.email}", Colors.green, Colors.white, context);
    } on FirebaseAuthException catch (e) {
      emit(AuthFailed());
      snackBar(e.message.toString(), Colors.red, Colors.white, context);
    } catch (error) {
      emit(AuthFailed());
      snackBar(error.toString(), Colors.red, Colors.white, context);
    }
  }

  Future<void> googleSignIn(context) async {
    emit(AuthLoading());

    try {
      final googleAccount = await _googleSignIn.signIn();

      if (googleAccount == null) {
        emit(AuthFailed());

        snackBar("Please login again!", Colors.red, Colors.white, context);
        return;
      }

      final googleAuth = await googleAccount.authentication;
      if (googleAuth.accessToken != null && googleAuth.idToken != null) {
        final authResult = await _auth.signInWithCredential(
          GoogleAuthProvider.credential(
              idToken: googleAuth.idToken, accessToken: googleAuth.accessToken),
        );
        emit(AuthSuccess(authResult.user!));
        snackBar("Welcome ${authResult.user?.displayName}", Colors.green,
            Colors.white, context);
      }
    } on FirebaseAuthException catch (error) {
      emit(AuthFailed());
      snackBar(error.message.toString(), Colors.red, Colors.white, context);
    } catch (error) {
      emit(AuthFailed());
      snackBar(error.toString(), Colors.red, Colors.white, context);
    }
  }

  Future<void> logOut(context) async {
    emit(AuthLoading());
    try {
      //Sign out firebase
      await FirebaseAuth.instance.signOut();

      //Revoke Google access token
      await _googleSignIn.signOut();
      // await _googleSignIn.disconnect();

      emit(AuthInitial());
      snackBar("Successfully logout", Colors.green, Colors.white, context);
    } catch (error) {
      emit(AuthFailed());

      print('error is: $error');
      snackBar(error.toString(), Colors.red, Colors.white, context);
    }
  }
}
