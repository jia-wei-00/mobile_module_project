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
        late Definition definitions;

        for (int i = 0; i < data.length; i++) {
          // List for Phonetics
          final List<Phonetics> phoneticsList = [];
          for (int j = 0; j < data['phonetics'].length; j++) {
            final phonetics = Phonetics(
              text: data['phonetics'][j]['text'] ?? "",
              audio: data['phonetics'][j]['audio'] ?? "",
            );
            phoneticsList.add(phonetics);
          }

          final List<Meanings> meaningsList = [];
          for (int k = 0; k < data['meanings'].length; k++) {
            // List for Definitions
            final List<Definitions> definitionsList = [];
            for (int l = 0;
                l < data['meanings'][k]['definitions'].length;
                l++) {
              final definitions = Definitions(
                definition:
                    data['meanings'][k]['definitions'][l]['definition'] ?? '',
                example: data['meanings'][k]['definitions'][l]['example'] ?? '',
              );
              definitionsList.add(definitions);
            }

            final meanings = Meanings(
              partOfSpeech: data['meanings'][k]['partOfSpeech'] ?? '',
              definitions: definitionsList,
              synonyms: data['meanings'][k]['synonyms'] ?? [],
              antonyms: data['meanings'][k]['antonyms'] ?? [],
            );
            meaningsList.add(meanings);
          }

          final definition = Definition(
            word: data['word'] ?? '',
            phonetics: phoneticsList,
            meanings: meaningsList,
            sourceUrls: data['sourceUrls'][0] ?? '',
          );

          definitions = definition;
        }

        emit(StateLoaded(definitions));
      } else {
        emit(StateError('Request failed with status: ${response.statusCode}'));
      }
    } catch (e) {
      emit(StateError(e.toString()));
    }
  }

  void setInitial() {
    emit(StateInitial());
  }
}
