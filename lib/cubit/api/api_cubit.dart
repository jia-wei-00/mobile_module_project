import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'api_state.dart';

class DictionaryCubit extends Cubit<DictionaryState> {
  DictionaryCubit() : super(StateInitial());

  void search(String text) async {
    final String _baseUrl =
        "https://api.dictionaryapi.dev/api/v2/entries/en/$text";

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
