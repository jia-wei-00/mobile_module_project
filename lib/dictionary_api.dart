import 'dart:convert';
import 'package:http/http.dart' as http;

// List<dynamic> meaningList = data['meanings'];
// List<dynamic> definitionList = meaningList[0]['definitions'];
// Map<String, dynamic> definitionMap = definitionList[0];
// String def = definitionMap['definition'];
// String def = definitionMap['example'];
// String def = definitionMap['synonyms'];
// String def = definitionMap['antonyms'];

class Meanings {
  final String? partOfSpeech;
  final List<Definitions>? definitions;
  final List<dynamic>? synonyms;
  final List<dynamic>? antonyms;

  Meanings({
    this.partOfSpeech,
    this.definitions,
    this.synonyms,
    this.antonyms,
  });

  Meanings.fromJson(Map<String, dynamic> json)
      : partOfSpeech = json['partOfSpeech'] as String?,
        definitions = (json['definitions'] as List?)
            ?.map(
                (dynamic e) => Definitions.fromJson(e as Map<String, dynamic>))
            .toList(),
        synonyms = json['synonyms'] as List<dynamic>?,
        antonyms = json['antonyms'] as List<dynamic>?;
}

class Definitions {
  final String? definition;
  final List<String>? example;
  final List<String>? synonyms;
  final List<String>? antonyms;

  Definitions(
    $word, {
    this.definition,
    this.example,
    this.synonyms,
    this.antonyms,
    required word,
  });

  Definitions.fromJson(Map<String, dynamic> json)
      : definition = json['definition'] as String?,
        example = (json['example'] as List?)
            ?.map((dynamic e) => e as String)
            .toList(),
        synonyms = (json['synonyms'] as List?)
            ?.map((dynamic e) => e as String)
            .toList(),
        antonyms = (json['antonyms'] as List?)
            ?.map((dynamic e) => e as String)
            .toList();

  Map<String, dynamic> toJson() => {
        'definition': definition,
        'example': example,
        'synonyms': synonyms,
        'antonyms': antonyms,
      };
}

class DictionaryApi {
  final String _baseUrl =
      'https://api.dictionaryapi.dev/api/v2/entries/en/sing';
  late final String _languageCode;
  late final String _word;

  DictionaryApi({required String languageCode, required String word}) {
    _languageCode = languageCode;
    _word = word;
  }

  Future<List<Definitions>> getDefinitions() async {
    final url = '$_baseUrl/$_languageCode/$_word';
    final response = await _getResponse(url);
    if (response.statusCode == 200) {
      final List<dynamic> jsonList = json.decode(response.body);
      final List<Definitions> definitionsList = jsonList
          .map((dynamic e) => Definitions.fromJson(e as Map<String, dynamic>))
          .toList();
      return definitionsList;
    } else {
      throw Exception('Failed to load definitions');
    }
  }

  Future<http.Response> _getResponse(String url) async {
    final response = await http.get(Uri.parse(url));
    return response;
  }
}
