import 'package:dictionary_api/pages/home_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import './bloc/dictionary_bloc.dart' as dict;
import 'dictionary_api.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:dictionary_api/components/navigation_bar.dart' as BottomBar;
import 'package:salomon_bottom_bar/salomon_bottom_bar.dart';

import './cubit/auth/auth_cubit.dart';
import './cubit/auth/auth_state.dart';
import './pages/favorite_page.dart';
import './pages/login_page.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AuthCubit(),
      child: MaterialApp(
        title: 'Flutter Demo',
        theme: _buildTheme(Brightness.light),
        home: const NavigationPage(),
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
                  _cubit.search(_searchController.text);
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

ThemeData _buildTheme(brightness) {
  var baseTheme = ThemeData(brightness: brightness);

  return baseTheme.copyWith(
    textTheme: GoogleFonts.poppinsTextTheme(baseTheme.textTheme),
    primaryColor: Colors.black,
    textButtonTheme: TextButtonThemeData(
      style: ButtonStyle(
        foregroundColor: MaterialStateProperty.all<Color>(Colors.black),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.black,
      ),
    ),
    textSelectionTheme: const TextSelectionThemeData(
      cursorColor: Colors.black,
    ),
    inputDecorationTheme: const InputDecorationTheme(
      focusedBorder: UnderlineInputBorder(
        borderSide: BorderSide(width: 2.0, color: Colors.black),
      ),
      labelStyle: TextStyle(
        color: Colors.black,
      ),
    ),
  );
}
