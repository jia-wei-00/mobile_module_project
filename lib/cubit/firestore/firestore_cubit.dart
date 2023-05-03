import 'package:bloc/bloc.dart';
import 'package:dictionary_api/cubit/auth/auth_cubit.dart';
import 'package:equatable/equatable.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../components/snackbar.dart';

part './firestore_state.dart';

class FirestoreCubit extends Cubit<FirestoreState> {
  FirestoreCubit() : super(FirestoreInitial());

  final db = FirebaseFirestore.instance;

  Future<void> addFavorite(word, desc, context, user) async {
    try {
      if (user == null) {
        emit(const FirestoreError("User not logged in"));
        return;
      }

      // Create a new document in the "favorites" collection with a unique ID
      final docRef = db.collection("favorites").doc(user.uid);

      DocumentSnapshot doc = await docRef.get();

      final favoriteWord = {
        'word': word,
        'description': desc,
        'createdAt': DateTime.now(),
      };

      if (doc.exists) {
        await docRef.update({
          'favoriteWords': FieldValue.arrayUnion([favoriteWord])
        });
      } else {
        await docRef.set({
          'favoriteWords': [favoriteWord]
        });
      }

      // Emit a new state to indicate that the favorite word has been successfully added
      emit(const FirestoreSuccess("Favorite added successfully!"));

      fetchData(user);
    } catch (error) {
      emit(FirestoreError(error.toString()));
      // snackBar(error.toString(), Colors.red, Colors.white, context);
    }
  }

  Future<void> fetchData(user) async {
    emit(FirestoreLoading());

    try {
      if (user == null) {
        emit(const FirestoreError("User not logged in"));
        return;
      }

      final docRef = db.collection("favorites").doc(user.uid);
      final docSnapshot = await docRef.get();

      if (docSnapshot.exists) {
        final data = docSnapshot.data() as Map<String, dynamic>;
        final favoriteWords =
            List<Map<String, dynamic>>.from(data['favoriteWords']);
        emit(FirestoreFetchSuccess(FavoriteWords(favoriteWords)));
      } else {
        // Document does not exist
        emit(const FirestoreError("Data not exist"));
      }
    } catch (error) {
      emit(FirestoreError(error.toString()));
    }
  }

  Future<void> removeFavorite(word, desc, createdAt, user) async {
    emit(FirestoreLoading());

    try {
      if (user == null) {
        emit(const FirestoreError("User not logged in"));
        return;
      }

      final docRef = db.collection("favorites").doc(user.uid);

      final favoriteWord = {
        'word': word,
        'description': desc,
        'createdAt': createdAt,
      };

      await docRef.update({
        'favoriteWords': FieldValue.arrayRemove([favoriteWord])
      });

      emit(const FirestoreSuccess("Successfully deleted"));

      fetchData(user);
    } catch (error) {
      emit(FirestoreError(error.toString()));
    }
  }
}
