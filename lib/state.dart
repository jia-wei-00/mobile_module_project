import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:bloc/bloc.dart';
import 'dictionary_api.dart';

class DictionaryCubit extends Cubit<DictionaryState> {
  DictionaryCubit() : super(StateInitial());

  final String _baseUrl =
      "https://api.dictionaryapi.dev/api/v2/entries/en/sing";

  void search(String text) async {
    if (text.isEmpty) {
      emit(StateInitial());
      return;
    }
    emit(StateLoading());

    try {
      final response = await http.get(Uri.parse(_baseUrl.trim()));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body)[0];
        final List<Definition> definitions = [];

        for (final meaning in data['meanings']) {
          final definition = Definition(
            word: data['word'],
            type: meaning['partOfSpeech'] ?? '',
            definition: meaning['definitions'][0]['definition'] ?? '',
            example: meaning['definitions'][0]['example'] ?? '',
            imageUrl: data['thumbnail'] ?? '',
            synonyms:
                List<String>.from(meaning['definitions'][0]['synonyms'] ?? []),
            antonyms:
                List<String>.from(meaning['definitions'][0]['antonyms'] ?? []),
          );
          definitions.add(definition);
        }

        emit(StateLoaded(definitions));
      } else {
        emit(StateError('Request failed with status: ${response.statusCode}'));
      }
    } catch (e) {
      emit(StateError(e.toString()));
    }
  }
}

abstract class DictionaryState {}

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
  final String imageUrl;
  final List<String> synonyms;
  final List<String> antonyms;

  Definition({
    required this.word,
    required this.type,
    required this.definition,
    required this.example,
    required this.imageUrl,
    required this.synonyms,
    required this.antonyms,
  });
}
