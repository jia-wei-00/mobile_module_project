import 'package:dictionary_api/cubit/firestore/firestore_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../components/snackbar.dart';
import '../cubit/auth/auth_cubit.dart';

class FavoritePage extends StatefulWidget {
  const FavoritePage({Key? key}) : super(key: key);

  @override
  State<FavoritePage> createState() => _FavoritePageState();
}

class _FavoritePageState extends State<FavoritePage> {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => FirestoreCubit(),
      child: BlocBuilder<FirestoreCubit, FirestoreState>(
        builder: (context, state) {
          return Scaffold(
            body: const FavoriteCard(),
            floatingActionButton:
                BlocBuilder<AuthCubit, AuthState>(builder: (context, state) {
              return state is AuthSuccess
                  ? FloatingActionButton(
                      onPressed: () {
                        context.read<FirestoreCubit>().addFavorite("hello",
                            "greeting to someone", context, state.user);
                      },
                      backgroundColor: Colors.black,
                      child: const Icon(Icons.add),
                    )
                  : const SizedBox.shrink();
            }),
          );
        },
      ),
    );
  }
}

class FavoriteCard extends StatefulWidget {
  const FavoriteCard({Key? key}) : super(key: key);

  @override
  State<FavoriteCard> createState() => _FavoriteCardState();
}

class _FavoriteCardState extends State<FavoriteCard> {
  @override
  void initState() {
    super.initState();
    final authState = BlocProvider.of<AuthCubit>(context).state;

    if (authState is AuthSuccess) {
      final user = authState.user;

      context.read<FirestoreCubit>().fetchData(user);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<FirestoreCubit, FirestoreState>(
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
        builder: (context, state) {
          return state is AuthSuccess
              ? BlocBuilder<FirestoreCubit, FirestoreState>(
                  builder: (context, state) {
                    if (state is FirestoreLoading) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (state is FirestoreError) {
                      return Center(
                        child: Text(
                          state.errorMessage,
                          style: const TextStyle(color: Colors.red),
                        ),
                      );
                    } else if (state is FirestoreFetchSuccess) {
                      return ListView.builder(
                        itemCount: state.favoriteWords.words.length,
                        itemBuilder: (context, index) {
                          final favorite = state.favoriteWords.words[index];
                          final word = favorite['word'];
                          final desc = favorite['description'];
                          final createdAt = favorite['createdAt'];

                          return Card(
                            child: BlocBuilder<AuthCubit, AuthState>(
                              builder: (context, state) {
                                return state is AuthSuccess
                                    ? ListTile(
                                        // leading: const Icon(Icons.album),
                                        title: Text(word),
                                        subtitle: Text(desc),
                                        trailing: IconButton(
                                          icon: const Icon(
                                            Icons.delete_forever_rounded,
                                            color: Colors.red,
                                          ),
                                          onPressed: () => context
                                              .read<FirestoreCubit>()
                                              .removeFavorite(word, desc,
                                                  createdAt, state.user),
                                        ))
                                    : const SizedBox.shrink();
                              },
                            ),
                          );
                        },
                      );
                    } else {
                      return const SizedBox.shrink();
                    }
                  },
                )
              : const Center(
                  child: Text(
                  "Please login to use favorite feature!",
                  style: TextStyle(color: Colors.red),
                ));
        },
      ),
    );
  }
}
