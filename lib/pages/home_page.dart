import 'package:audioplayers/audioplayers.dart';
import 'package:dictionary_api/components/font.dart';
import 'package:dictionary_api/components/snackbar.dart';
import 'package:dictionary_api/cubit/api/api_cubit.dart';
import 'package:dictionary_api/cubit/auth/auth_cubit.dart';
import 'package:dictionary_api/cubit/firestore/firestore_cubit.dart';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final DictionaryCubit _cubit = DictionaryCubit();
  final _searchController = TextEditingController();
  final AudioPlayer audioPlayer = AudioPlayer();
  late User? user;
  late List<Map<String, dynamic>> words;
  late Source audioUrl;
  bool _isSignedIn = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _cubit.close();
    _searchController.dispose();
    audioPlayer.dispose();
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
                            final searchQuery = _searchController.text;
                            if (searchQuery.isNotEmpty) {
                              _cubit.search(searchQuery);
                            }
                            FocusScope.of(context).unfocus();
                          },
                          icon: const Icon(Icons.search),
                          color: Colors.black,
                        ),
                      ),
                      textInputAction: TextInputAction.search,
                      onSubmitted: (value) {
                        if (value.isNotEmpty) {
                          _cubit.search(value);
                        }
                        FocusScope.of(context).unfocus();
                        context.read<FirestoreCubit>().fetchData(user, true);
                      },
                    ),
                  ),
                  Expanded(
                    child: BlocBuilder<DictionaryCubit, DictionaryState>(
                      bloc: _cubit,
                      builder: (BuildContext context, DictionaryState state) {
                        if (state is StateInitial) {
                          return Center(
                            child: mediumFont(
                                'Enter a word to search for definitions'),
                          );
                        } else if (state is StateLoading) {
                          return const Center(
                              child: CircularProgressIndicator());
                        } else if (state is StateLoaded) {
                          final word = state.definitions.word;
                          final sourceUrls = state.definitions.sourceUrls;

                          return SingleChildScrollView(
                            child: Card(
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          word!,
                                          style: const TextStyle(
                                            fontSize: 20.0,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Row(
                                          children: [
                                            state.definitions.phonetics!
                                                        .isNotEmpty &&
                                                    state
                                                            .definitions
                                                            .phonetics![0]
                                                            .audio !=
                                                        ""
                                                ? IconButton(
                                                    onPressed: () async {
                                                      audioUrl = UrlSource(state
                                                          .definitions
                                                          .phonetics![0]
                                                          .audio!);
                                                      await audioPlayer
                                                          .play(audioUrl);
                                                    },
                                                    icon: const Icon(
                                                        Icons.volume_up),
                                                  )
                                                : const SizedBox.shrink(),
                                            BlocBuilder<FirestoreCubit,
                                                FirestoreState>(
                                              builder: (context, state) {
                                                _isSignedIn =
                                                    authState is AuthSuccess;

                                                return authState is AuthSuccess
                                                    ? state is FirestoreLoading
                                                        ? const CircularProgressIndicator()
                                                        : IconButton(
                                                            icon: state is FirestoreFetchSuccess &&
                                                                    state
                                                                        .favoriteWords
                                                                        .words
                                                                        .any((w) =>
                                                                            w.word ==
                                                                            word)
                                                                ? const Icon(
                                                                    Icons
                                                                        .favorite,
                                                                    color: Colors
                                                                        .red)
                                                                : const Icon(
                                                                    Icons
                                                                        .favorite_outline,
                                                                    color: Colors
                                                                        .red),
                                                            onPressed: () {
                                                              if (_isSignedIn) {
                                                                if (state
                                                                        is FirestoreFetchSuccess &&
                                                                    state
                                                                        .favoriteWords
                                                                        .words
                                                                        .any((w) =>
                                                                            w.word ==
                                                                            word)) {
                                                                  context
                                                                      .read<
                                                                          FirestoreCubit>()
                                                                      .removeFavorite(
                                                                          word,
                                                                          sourceUrls,
                                                                          user);
                                                                } else {
                                                                  context
                                                                      .read<
                                                                          FirestoreCubit>()
                                                                      .addFavorite(
                                                                          word,
                                                                          sourceUrls,
                                                                          user);
                                                                }
                                                              }
                                                            },
                                                          )
                                                    : const SizedBox.shrink();
                                              },
                                            ),
                                          ],
                                        )
                                      ],
                                    ),
                                    const SizedBox(height: 8.0),
                                    if (state.definitions.phonetics != null)
                                      Row(
                                        children: state.definitions.phonetics!
                                            .map((e) => Text(
                                                  e.text!,
                                                  textAlign: TextAlign.left,
                                                ))
                                            .toList(),
                                      ),
                                    if (state.definitions.phonetics != null)
                                      Column(
                                        children: state.definitions.meanings!
                                            .map(
                                              (e) => Padding(
                                                padding: const EdgeInsets.only(
                                                    top: 8.0, bottom: 8.0),
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      e.partOfSpeech!,
                                                      style: const TextStyle(
                                                        fontSize: 14.0,
                                                        fontStyle:
                                                            FontStyle.italic,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                    ...e.definitions!
                                                        .map(
                                                          (e) => Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                        .only(
                                                                    top: 5.0,
                                                                    bottom:
                                                                        5.0),
                                                            child: Row(
                                                              children: [
                                                                const Icon(Icons
                                                                    .arrow_right),
                                                                const SizedBox(
                                                                    width: 5.0),
                                                                Expanded(
                                                                    child: Text(
                                                                        e.definition!)),
                                                              ],
                                                            ),
                                                          ),
                                                        )
                                                        .toList(),
                                                    if (e.synonyms!.isNotEmpty)
                                                      const Padding(
                                                        padding:
                                                            EdgeInsets.all(8.0),
                                                        child: Text(
                                                          "synonyms",
                                                          style: TextStyle(
                                                            fontSize: 14.0,
                                                            fontStyle: FontStyle
                                                                .italic,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                          ),
                                                        ),
                                                      ),
                                                    Wrap(
                                                      children: e.synonyms!
                                                          .map(
                                                              (item) => Padding(
                                                                    padding:
                                                                        const EdgeInsets.all(
                                                                            4.0),
                                                                    child:
                                                                        Container(
                                                                      decoration:
                                                                          BoxDecoration(
                                                                        borderRadius:
                                                                            BorderRadius.circular(4.0),
                                                                        color: Colors
                                                                            .grey[300],
                                                                      ),
                                                                      padding:
                                                                          const EdgeInsets.all(
                                                                              8.0),
                                                                      child:
                                                                          Text(
                                                                        item,
                                                                        style:
                                                                            const TextStyle(
                                                                          fontSize:
                                                                              12.0,
                                                                          fontWeight:
                                                                              FontWeight.bold,
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ))
                                                          .toList(),
                                                    ),
                                                    if (e.synonyms!.isNotEmpty)
                                                      const Padding(
                                                        padding:
                                                            EdgeInsets.all(8.0),
                                                        child: Text(
                                                          "antonyms",
                                                          style: TextStyle(
                                                            fontSize: 14.0,
                                                            fontStyle: FontStyle
                                                                .italic,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                          ),
                                                        ),
                                                      ),
                                                    if (e.synonyms!.isNotEmpty)
                                                      Wrap(
                                                        children: e.antonyms!
                                                            .map(
                                                                (item) =>
                                                                    Padding(
                                                                      padding:
                                                                          const EdgeInsets.all(
                                                                              4.0),
                                                                      child:
                                                                          Container(
                                                                        decoration:
                                                                            BoxDecoration(
                                                                          borderRadius:
                                                                              BorderRadius.circular(4.0),
                                                                          color:
                                                                              Colors.grey[300],
                                                                        ),
                                                                        padding:
                                                                            const EdgeInsets.all(8.0),
                                                                        child:
                                                                            Text(
                                                                          item,
                                                                          style:
                                                                              const TextStyle(
                                                                            fontSize:
                                                                                12.0,
                                                                            fontWeight:
                                                                                FontWeight.bold,
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ))
                                                            .toList(),
                                                      ),
                                                  ],
                                                ),
                                              ),
                                            )
                                            .toList(),
                                      )
                                  ],
                                ),
                              ),
                            ),
                          );
                        } else if (state is StateError) {
                          return const Center(
                            child: Text(
                              'Please try another word',
                              style: TextStyle(color: Colors.red),
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
        ),
      ),
    );
  }
}
