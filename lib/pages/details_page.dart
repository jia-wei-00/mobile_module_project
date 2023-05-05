import 'package:audioplayers/audioplayers.dart';
import 'package:dictionary_api/components/font.dart';
import 'package:dictionary_api/cubit/api/api_cubit.dart';
import 'package:dictionary_api/cubit/auth/auth_cubit.dart';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DetailsPage extends StatefulWidget {
  final String word;
  const DetailsPage(this.word, {Key? key}) : super(key: key);

  @override
  State<DetailsPage> createState() => _DetailsPageState();
}

class _DetailsPageState extends State<DetailsPage> {
  final DictionaryCubit _cubit = DictionaryCubit();
  late User? user;
  final AudioPlayer audioPlayer = AudioPlayer();
  late Source audioUrl;

  @override
  void initState() {
    super.initState();
    // Access the word variable using the widget property
    final String word = widget.word;
    // Use the word variable to perform an API call or other action
    _cubit.search(word);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.word),
        backgroundColor: Colors.black,
      ),
      body: BlocProvider(
        create: (context) => AuthCubit(),
        child: BlocBuilder<AuthCubit, AuthState>(
          builder: (context, authState) {
            user = authState is AuthSuccess ? authState.user : null;

            return Column(
              children: [
                Expanded(
                  child: BlocBuilder<DictionaryCubit, DictionaryState>(
                    bloc: _cubit,
                    builder: (BuildContext context, DictionaryState state) {
                      if (state is StateInitial) {
                        return const Center(
                            child:
                                Text('Enter a word to search for definitions'));
                      } else if (state is StateLoading) {
                        return const Center(child: CircularProgressIndicator());
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
                                                  mediumFont(e.partOfSpeech!,
                                                      italic: true, bold: true),
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            8.0),
                                                    child: mediumFont(
                                                        "Definitions",
                                                        italic: true),
                                                  ),
                                                  ...e.definitions!
                                                      .map(
                                                        (e) => Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                      .only(
                                                                  top: 5.0,
                                                                  bottom: 5.0),
                                                          child: Row(
                                                            children: [
                                                              const Icon(Icons
                                                                  .arrow_right),
                                                              const SizedBox(
                                                                  width: 5.0),
                                                              Expanded(
                                                                  child: Text(e
                                                                      .definition!)),
                                                            ],
                                                          ),
                                                        ),
                                                      )
                                                      .toList(),
                                                  if (e.definitions!
                                                      .where((e) =>
                                                          e.example != null &&
                                                          e.example!.isNotEmpty)
                                                      .isNotEmpty)
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              8.0),
                                                      child: mediumFont(
                                                          "Example",
                                                          italic: true),
                                                    ),
                                                  ...e.definitions!
                                                      .where((e) =>
                                                          e.example != null &&
                                                          e.example!.isNotEmpty)
                                                      .map(
                                                        (e) => Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                      .only(
                                                                  top: 5.0,
                                                                  bottom: 5.0),
                                                          child: Row(
                                                            children: [
                                                              const Icon(Icons
                                                                  .arrow_right),
                                                              const SizedBox(
                                                                  width: 5.0),
                                                              Expanded(
                                                                  child: Text(e
                                                                      .example!)),
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                  if (e.synonyms!
                                                      .where((e) =>
                                                          e != null &&
                                                          e.isNotEmpty)
                                                      .isNotEmpty)
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              8.0),
                                                      child: mediumFont(
                                                          "synonyms",
                                                          italic: true),
                                                    ),
                                                  if (e.synonyms!
                                                      .where((e) =>
                                                          e != null &&
                                                          e.isNotEmpty)
                                                      .isNotEmpty)
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
                                                                      child: smallFont(
                                                                          item,
                                                                          italic:
                                                                              true,
                                                                          bold:
                                                                              true),
                                                                    ),
                                                                  ))
                                                          .toList(),
                                                    ),
                                                  if (e.antonyms!
                                                      .where((e) =>
                                                          e != null && e == "")
                                                      .isNotEmpty)
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              8.0),
                                                      child: mediumFont(
                                                          "antonyms",
                                                          italic: true),
                                                    ),
                                                  if (e.antonyms!
                                                      .where((e) =>
                                                          e != null && e == "")
                                                      .isNotEmpty)
                                                    Wrap(
                                                      children: e.antonyms!
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
      ),
    );
  }
}
