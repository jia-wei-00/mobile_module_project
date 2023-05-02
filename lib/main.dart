import 'package:dictionary_api/cubit/api/api_cubit.dart';
import 'package:dictionary_api/cubit/auth/auth_cubit.dart';
import 'package:dictionary_api/cubit/auth/auth_state.dart';
import 'package:dictionary_api/pages/favorite_page.dart';
import 'package:dictionary_api/pages/home_page.dart';
import 'package:dictionary_api/pages/login_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:salomon_bottom_bar/salomon_bottom_bar.dart';
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
        body: const NavigationPage(),
      ),
    );
  }
}

class NavigationPage extends StatefulWidget {
  const NavigationPage({Key? key}) : super(key: key);

  @override
  _NavigationPageState createState() => _NavigationPageState();
}

class _NavigationPageState extends State<NavigationPage> {
  int _currentIndex = 0;

  final List<Widget> _pages = <Widget>[
    const HomePage(),
    const FavoritePage(),
    const LoginPage(),
  ];

  final List<String> _titles = <String>[
    'Home',
    'Favorite',
    'Profile',
  ];

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            title: Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(_titles[_currentIndex]),
                  state.user != null
                      ? IconButton(
                          icon: const Icon(Icons.logout),
                          onPressed: () {
                            context.read<AuthCubit>().logOut(context);
                          },
                        )
                      : IconButton(
                          icon: const Icon(Icons.login),
                          onPressed: () => setState(() {
                            _currentIndex = 2;
                          }),
                        )
                ],
              ),
            ),
            automaticallyImplyLeading: false,
            backgroundColor: Colors.black,
          ),
          body: _pages[_currentIndex],
          bottomNavigationBar: SalomonBottomBar(
            currentIndex: _currentIndex,
            onTap: (int index) {
              setState(() {
                _currentIndex = index;
              });
            },
            backgroundColor: Colors.black,
            items: [
              /// Home
              SalomonBottomBarItem(
                  icon: const Icon(Icons.home),
                  title: const Text("Home"),
                  selectedColor: Colors.white,
                  unselectedColor: Colors.white),

              /// Likes
              SalomonBottomBarItem(
                  icon: const Icon(Icons.favorite_border),
                  title: const Text("Likes"),
                  selectedColor: Colors.white,
                  unselectedColor: Colors.white),

              /// Profile
              SalomonBottomBarItem(
                  icon: const Icon(Icons.person),
                  title: const Text("Profile"),
                  selectedColor: Colors.white,
                  unselectedColor: Colors.white),
            ],
          ),
        );
      },
    );
  }
}
