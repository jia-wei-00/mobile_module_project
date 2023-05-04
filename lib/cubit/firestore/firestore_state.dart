part of 'firestore_cubit.dart';

abstract class FirestoreState extends Equatable {
  const FirestoreState();

  @override
  List<Object> get props => [];
}

class FirestoreInitial extends FirestoreState {}

class FirestoreLoading extends FirestoreState {}

class FirestoreError extends FirestoreState {
  final String errorMessage;

  const FirestoreError(this.errorMessage);
}

class FirestoreSuccess extends FirestoreState {
  final String successMessage;

  const FirestoreSuccess(this.successMessage);
}

class FirestoreFetchSuccess extends FirestoreState {
  final FavoriteWords favoriteWords;

  const FirestoreFetchSuccess(this.favoriteWords);

  // @override
  // List<Object> get props => [favoriteWords];
}

class FavoriteWords {
  final List<Word> words;

  const FavoriteWords(this.words);
}

class Word {
  String? word;
  String? sourceUrls;

  Word({this.word, this.sourceUrls});
}
