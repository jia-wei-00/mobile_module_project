part of 'api_cubit.dart';

abstract class DictionaryState extends Equatable {
  const DictionaryState();

  @override
  List<Object> get props => [];
}

class StateInitial extends DictionaryState {}

class StateLoading extends DictionaryState {}

class StateLoaded extends DictionaryState {
  final List<Definition> definitions;

  StateLoaded(this.definitions);
}

class StateError extends DictionaryState {
  final String message;

  StateError(this.message);
}

class Definition {
  final String word;
  final String type;
  final String definition;
  final String example;
  final String audio;
  final String pronunciation;
  // final String imageUrl;
  final List<String> synonyms;
  final List<String> antonyms;

  Definition({
    required this.word,
    required this.type,
    required this.definition,
    required this.example,
    required this.audio,
    required this.pronunciation,
    // required this.imageUrl,
    required this.synonyms,
    required this.antonyms,
  });
}
