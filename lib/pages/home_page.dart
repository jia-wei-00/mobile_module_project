import 'package:dictionary_api/cubit/auth/auth_cubit.dart';
import 'package:dictionary_api/cubit/auth/auth_state.dart';
import 'package:dictionary_api/pages/favorite_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dictionary_api/components/navigation_bar.dart' as BottomBar;
import 'package:go_router/go_router.dart';

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
            appBar: AppBar(
              title: Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Home'),
                    state.user != null
                        ? IconButton(
                            icon: const Icon(Icons.logout),
                            onPressed: () {
                              context.read<AuthCubit>().logOut(context);
                            },
                          )
                        : IconButton(
                            icon: const Icon(Icons.login),
                            onPressed: () => context.go('/profile'),
                          )
                  ],
                ),
              ),
              automaticallyImplyLeading: false,
              backgroundColor: Colors.black,
            ),
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
            bottomNavigationBar: BottomBar.NavigationBar(
              currentIndex: _currentIndex,
              onTap: (int index) {
                if (index == 0) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const HomePage()),
                  );
                } else if (index == 1) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const FavoritePage()),
                  );
                } else if (index == 2) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const LoginPage()),
                  );
                }
              },
            ),
          );
        },
      ),
    );
  }
}
