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
  var _currentIndex = 0;

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
                    Center(
                      child: Text(
                          state.user == null ? "Please login" : "Logged in"),
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
