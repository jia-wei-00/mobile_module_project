import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

part './firestore_state.dart';

class FirestoreCubit extends Cubit<FirestoreState> {
  FirestoreCubit() : super(FirestoreInitial());

  final db = FirebaseFirestore.instance;

  Future<void> addFavorite(word, sourceUrls, user) async {
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
        'sourceUrls': sourceUrls,
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

      fetchData(user, false);
    } catch (error) {
      emit(FirestoreError(error.toString()));
    }
  }

  Future<void> fetchData(User? user, fromFetch) async {
    emit(FirestoreLoading());

    if (!fromFetch) {
      try {
        if (user == null) {
          emit(const FirestoreError("User not logged in"));
          return;
        }

        final docRef = db.collection("favorites").doc(user!.uid);
        final docSnapshot = await docRef.get();

        if (docSnapshot.exists) {
          final data = docSnapshot.data() as Map<String, dynamic>;
          final favoriteWordsData =
              List<Map<String, dynamic>>.from(data['favoriteWords']);
          final favoriteWords = favoriteWordsData
              .map((wordData) => Word(
                    word: wordData['word'],
                    sourceUrls: wordData['sourceUrls'],
                  ))
              .toList();
          emit(FirestoreFetchSuccess(FavoriteWords(favoriteWords)));
        } else {
          emit(const FirestoreError("Data not exist"));
        }
      } catch (error) {
        emit(FirestoreError(error.toString()));
      }
    } else {
      emit(FirestoreInitial());
    }
  }

  Future<void> removeFavorite(word, sourceUrls, user) async {
    emit(FirestoreLoading());

    try {
      if (user == null) {
        emit(const FirestoreError("User not logged in"));
        return;
      }

      final docRef = db.collection("favorites").doc(user.uid);

      final favoriteWord = {
        'word': word,
        'sourceUrls': sourceUrls,
      };

      await docRef.update({
        'favoriteWords': FieldValue.arrayRemove([favoriteWord])
      });

      emit(const FirestoreSuccess("Successfully deleted"));

      fetchData(user, false);
    } catch (error) {
      emit(FirestoreError(error.toString()));
    }
  }
}
