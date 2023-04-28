import 'package:bloc/bloc.dart';
import 'package:dictionary_api/components/snackbar.dart';
import 'package:meta/meta.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

part 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  AuthCubit() : super(AuthInitial()) {
    if (AuthState is AuthLoginState) {}
    if (AuthState is AuthLoginState) {}
  }

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  Future registerWithEmailAndPassword(
      String email, String password, context) async {
    try {
      final user = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      // emit();
      snackBar("Welcome ${user.additionalUserInfo?.username}", Colors.green,
          Colors.white, context);
    } catch (error) {
      snackBar(error, Colors.red, Colors.white, context);
    }
  }

  Future<void> signInWithEmailAndPassword(
      String email, String password, context) async {
    try {
      final user = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      // emit(user.additionalUserInfo?.username);
      snackBar("Welcome ${user.additionalUserInfo?.username}", Colors.green,
          Colors.white, context);
    } catch (error) {
      snackBar(error, Colors.red, Colors.white, context);
    }
  }

  Future<void> googleSignIn(context) async {
    final googleAccount = await _googleSignIn.signIn();

    if (googleAccount != null) {
      final googleAuth = await googleAccount.authentication;
      if (googleAuth.accessToken != null && googleAuth.idToken != null) {
        try {
          final authResult = await _auth.signInWithCredential(
            GoogleAuthProvider.credential(
                idToken: googleAuth.idToken,
                accessToken: googleAuth.accessToken),
          );
          // emit(authResult.user?.displayName);
          snackBar("Welcome ${authResult.user?.displayName}", Colors.green,
              Colors.white, context);
        } catch (error) {
          snackBar(error, Colors.red, Colors.white, context);
        }
      }
    } else {
      snackBar("Please login again!", Colors.red, Colors.white, context);
    }
  }

  Future logOut(context) async {
    try {
      await _googleSignIn.disconnect();
      await FirebaseAuth.instance.signOut();
      // emit(null);
      snackBar("Successfully logout", Colors.green, Colors.white, context);
    } catch (error) {
      snackBar(error, Colors.red, Colors.white, context);
    }
  }
}
