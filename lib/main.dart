import 'dart:io';

import 'package:flutter/material.dart';
import 'dart:convert';
import 'state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import './bloc/dictionary_bloc.dart' as dict;
import 'dictionary_api.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dictionary App',
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Dictionary App'),
        ),
        body: const DictionaryScreen(),
      ),
    );
  }
}

class DictionaryScreen extends StatefulWidget {
  const DictionaryScreen({super.key});

  @override
  State<DictionaryScreen> createState() => DictionaryScreenState();
}

class DictionaryScreenState extends State<DictionaryScreen> {
  final DictionaryCubit _cubit = DictionaryCubit();
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _cubit.close();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Enter a word',
              suffixIcon: IconButton(
                onPressed: () {
                  String $word = _searchController.text;
                  _cubit.search($word);
                  FocusScope.of(context).unfocus();
                },
                icon: const Icon(Icons.search),
              ),
            ),
            textInputAction: TextInputAction.search,
            onSubmitted: (value) {
              _cubit.search(value);
              FocusScope.of(context).unfocus();
            },
          ),
        ),
        Expanded(
          child: BlocBuilder<DictionaryCubit, DictionaryState>(
            bloc: _cubit,
            builder: (BuildContext context, DictionaryState state) {
              if (state is StateInitial) {
                return const Center(
                    child: Text('Enter a word to search for definitions'));
              } else if (state is StateLoading) {
                return const Center(child: CircularProgressIndicator());
              } else if (state is StateLoaded) {
                return ListView.builder(
                  itemCount: state.definitions.length,
                  itemBuilder: (BuildContext context, int index) {
                    return Card(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              state.definitions[index].word,
                              style: const TextStyle(
                                fontSize: 20.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8.0),
                            Text(
                              state.definitions[index].definition,
                              style: const TextStyle(fontSize: 16.0),
                            ),
                            const SizedBox(height: 8.0),
                            if (state.definitions[index].example.isNotEmpty)
                              Text(
                                'Example: ${state.definitions[index].example}',
                                style: const TextStyle(
                                  fontSize: 16.0,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            const SizedBox(height: 8.0),
                            if (state.definitions[index].synonyms.isNotEmpty)
                              Text(
                                'Synonyms: ${state.definitions[index].synonyms.join(", ")}',
                                style: const TextStyle(fontSize: 16.0),
                              ),
                            const SizedBox(height: 8.0),
                            if (state.definitions[index].antonyms.isNotEmpty)
                              Text(
                                'Antonyms: ${state.definitions[index].antonyms.join(", ")}',
                                style: const TextStyle(fontSize: 16.0),
                              ),
                            if (state.definitions[index].imageUrl.isNotEmpty)
                              Image.network(
                                state.definitions[index].imageUrl,
                                height: 200.0,
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              } else if (state is StateError) {
                return Center(
                  child: Text(
                    'Error: ${state.message}',
                    style: const TextStyle(color: Colors.red),
                  ),
                );
              } else {
                return const Center(
                  child: Text('Unknown state'),
                );
              }
            },
          ),
        ),
      ],
    );
  }
}
