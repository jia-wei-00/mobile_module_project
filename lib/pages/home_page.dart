import 'package:dictionary_api/cubit/api/api_cubit.dart';
import 'package:dictionary_api/cubit/auth/auth_cubit.dart';
import 'package:dictionary_api/cubit/auth/auth_state.dart';
import 'package:dictionary_api/pages/favorite_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dictionary_api/components/navigation_bar.dart' as BottomBar;

import '../components/font.dart';
import 'login_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
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
    return BlocProvider(
      create: (context) => AuthCubit(),
      child: BlocBuilder<AuthCubit, AuthState>(
        builder: (context, state) {
          return Scaffold(
            body: BlocBuilder<AuthCubit, AuthState>(
              builder: (context, state) {
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
                              _cubit.search(_searchController.text);
                              FocusScope.of(context).unfocus();
                            },
                            icon: const Icon(Icons.search),
                            color: Colors.black,

                            // const Icon(
                            //   Icons.search,
                            //   color: Colors.blue,
                            // ),
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
                                child: Text(
                                    'Enter a word to search for definitions'));
                          } else if (state is StateLoading) {
                            return const Center(
                                child: CircularProgressIndicator());
                          } else if (state is StateLoaded) {
                            return ListView.builder(
                              itemCount: state.definitions.length,
                              itemBuilder: (BuildContext context, int index) {
                                return Card(
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
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
                                          style:
                                              const TextStyle(fontSize: 16.0),
                                        ),
                                        const SizedBox(height: 8.0),
                                        if (state.definitions[index].example
                                            .isNotEmpty)
                                          Text(
                                            'Example: ${state.definitions[index].example}',
                                            style: const TextStyle(
                                              fontSize: 16.0,
                                              fontStyle: FontStyle.italic,
                                            ),
                                          ),
                                        const SizedBox(height: 8.0),
                                        if (state.definitions[index].synonyms
                                            .isNotEmpty)
                                          Text(
                                            'Synonyms: ${state.definitions[index].synonyms.join(", ")}',
                                            style:
                                                const TextStyle(fontSize: 16.0),
                                          ),
                                        const SizedBox(height: 8.0),
                                        if (state.definitions[index].antonyms
                                            .isNotEmpty)
                                          Text(
                                            'Antonyms: ${state.definitions[index].antonyms.join(", ")}',
                                            style:
                                                const TextStyle(fontSize: 16.0),
                                          ),
                                        if (state.definitions[index].imageUrl
                                            .isNotEmpty)
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
              },
            ),
          );
        },
      ),
    );
  }
}
