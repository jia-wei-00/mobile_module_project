part of 'api_cubit.dart';

abstract class DictionaryState extends Equatable {
  const DictionaryState();

  @override
  List<Object> get props => [];
}

class StateInitial extends DictionaryState {}

class StateLoading extends DictionaryState {}

class StateLoaded extends DictionaryState {
  final Definition definitions;

  StateLoaded(this.definitions);
}

class StateError extends DictionaryState {
  final String message;

  StateError(this.message);
}

class Definition {
  String? word;
  List<Phonetics>? phonetics;
  List<Meanings>? meanings;
  String? sourceUrls;

  Definition({this.word, this.phonetics, this.meanings, this.sourceUrls});
}

class Phonetics {
  String? text;
  String? audio;

  Phonetics({this.text, this.audio});
}

class Meanings {
  String? partOfSpeech;
  List<Definitions>? definitions;
  List<dynamic>? synonyms;
  List<dynamic>? antonyms;

  Meanings({this.partOfSpeech, this.definitions, this.synonyms, this.antonyms});
}

class Definitions {
  String? definition;
  String? example;

  Definitions({this.definition, this.example});
}
