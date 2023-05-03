import 'dart:convert';
import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart';
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

        print(data["meanings"]);

        for (int i = 0; i < data['meanings'].length; i++) {
          final meaning = data['meanings'][i];
          final definition = Definition(
            word: data['word'],
            type: meaning['partOfSpeech'] ?? '',
            definition: meaning[definitions] != null &&
                    i + 1 <= meaning[definitions].length
                ? meaning['definitions'][0]['definition'] ?? ''
                : "",
            example: meaning[definitions] != null &&
                    i + 1 <= meaning[definitions].length
                ? meaning['definitions'][0]['example'] ?? ''
                : "",
            audio: data["phonetics"].length > 0 &&
                    i + 1 <= data["phonetics"].length
                ? data["phonetics"][i]["audio"] ?? ''
                : "",
            pronunciation: data["phonetics"].length > 0 &&
                    i + 1 <= data["phonetics"].length
                ? data["phonetics"][i]["text"] ?? ''
                : "",
            // pronunciation: data["phonetics"][0]["text"] ?? "",

            // imageUrl: data['thumbnail'] ?? '',

            synonyms: List<String>.from(meaning['synonyms'] ?? []),
            antonyms: List<String>.from(meaning['antonyms'] ?? []),
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

  void setInitial() {
    emit(StateInitial());
  }
}
