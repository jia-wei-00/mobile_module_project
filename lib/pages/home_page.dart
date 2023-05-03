import 'package:dictionary_api/components/snackbar.dart';
import 'package:dictionary_api/cubit/api/api_cubit.dart';
import 'package:dictionary_api/cubit/auth/auth_cubit.dart';
import 'package:dictionary_api/cubit/firestore/firestore_cubit.dart';
import 'package:dictionary_api/pages/favorite_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
  late User? user;
  // bool isLogedIn = false;

  @override
  void dispose() {
    _cubit.close();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => FirestoreCubit(),
      child: Scaffold(
        body: BlocListener<FirestoreCubit, FirestoreState>(
          listener: (context, state) {
            if (state is FirestoreError) {
              snackBar(
                state.errorMessage, // use the error message from state
                Colors.red,
                Colors.white,
                context,
              );
            }

            if (state is FirestoreSuccess) {
              snackBar(
                state.successMessage, // use the error message from state
                Colors.green,
                Colors.white,
                context,
              );
            }
          },
          child: BlocBuilder<AuthCubit, AuthState>(
            builder: (context, authState) {
              user = authState is AuthSuccess ? authState.user : null;

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
                    child: BlocBuilder<FirestoreCubit, FirestoreState>(
                      builder: (BuildContext context,
                          FirestoreState fireStoreState) {
                        return fireStoreState is! FirestoreLoading
                            ? BlocBuilder<DictionaryCubit, DictionaryState>(
                                bloc: _cubit,
                                builder: (BuildContext context,
                                    DictionaryState state) {
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
                                      itemBuilder:
                                          (BuildContext context, int index) {
                                        var word =
                                            state.definitions[index].word;
                                        var desc =
                                            state.definitions[index].definition;
                                        var example =
                                            state.definitions[index].example;
                                        var type =
                                            state.definitions[index].type;

                                        return Card(
                                          child: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Text(
                                                      word,
                                                      style: const TextStyle(
                                                        fontSize: 20.0,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                    Row(
                                                      children: [
                                                        IconButton(
                                                            onPressed: () {},
                                                            icon: const Icon(
                                                                Icons
                                                                    .volume_up)),
                                                        user != null
                                                            ? BlocBuilder<
                                                                FirestoreCubit,
                                                                FirestoreState>(
                                                                builder:
                                                                    (context,
                                                                        state) {
                                                                  return authState
                                                                          is AuthSuccess
                                                                      ? IconButton(
                                                                          icon:
                                                                              const Icon(Icons.favorite_outline),
                                                                          color:
                                                                              Colors.red,
                                                                          onPressed:
                                                                              () {
                                                                            context.read<FirestoreCubit>().addFavorite(
                                                                                word,
                                                                                desc,
                                                                                context,
                                                                                user);
                                                                          },
                                                                        )
                                                                      : const SizedBox
                                                                          .shrink();
                                                                },
                                                              )
                                                            : const SizedBox
                                                                .shrink()
                                                      ],
                                                    )
                                                  ],
                                                ),
                                                const SizedBox(height: 8.0),
                                                Text(
                                                  type,
                                                  style: const TextStyle(
                                                      fontSize: 15.0,
                                                      fontWeight:
                                                          FontWeight.normal),
                                                ),
                                                Text(
                                                  desc,
                                                  style: const TextStyle(
                                                      fontSize: 16.0),
                                                ),
                                                const SizedBox(height: 8.0),
                                                if (example.isNotEmpty)
                                                  Text(
                                                    'Example: $example',
                                                    style: const TextStyle(
                                                      fontSize: 16.0,
                                                      fontStyle:
                                                          FontStyle.italic,
                                                    ),
                                                  ),
                                                const SizedBox(height: 8.0),
                                                if (state.definitions[index]
                                                    .synonyms.isNotEmpty)
                                                  Text(
                                                    'Synonyms: ${state.definitions[index].synonyms.join(", ")}',
                                                    style: const TextStyle(
                                                        fontSize: 16.0),
                                                  ),
                                                const SizedBox(height: 8.0),
                                                if (state.definitions[index]
                                                    .antonyms.isNotEmpty)
                                                  Text(
                                                    'Antonyms: ${state.definitions[index].antonyms.join(", ")}',
                                                    style: const TextStyle(
                                                        fontSize: 16.0),
                                                  ),
                                                // if (state.definitions[index]
                                                //     .imageUrl.isNotEmpty)
                                                //   Image.network(
                                                //     state.definitions[index]
                                                //         .imageUrl,
                                                //     height: 200.0,
                                                //   ),
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
                                        style:
                                            const TextStyle(color: Colors.red),
                                      ),
                                    );
                                  } else {
                                    return const Center(
                                      child: Text('Unknown state'),
                                    );
                                  }
                                },
                              )
                            : const CircularProgressIndicator();
                      },
                      // );
                      // },
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
