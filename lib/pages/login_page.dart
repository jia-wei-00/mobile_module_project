import 'package:dictionary_api/pages/home_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_signin_button/flutter_signin_button.dart';

import '../cubit/auth/auth_cubit.dart';
import '../components/font.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool signUp = false;

  @override
  Widget build(BuildContext context) {
    final emailController = TextEditingController();
    final passwordController = TextEditingController();

    return Scaffold(
      body: BlocBuilder<AuthCubit, AuthState>(
        builder: (context, state) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Image.asset('assets/images/logo.png',
                        width: 200, height: 200),
                  ),
                  TextField(
                    controller: emailController,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: passwordController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'Password',
                    ),
                  ),
                  const SizedBox(height: 16),
                  state is AuthLoading
                      ? const Padding(
                          padding: EdgeInsets.all(10.0),
                          child: CircularProgressIndicator(),
                        )
                      : Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Column(
                            children: [
                              ElevatedButton(
                                onPressed: () {
                                  final email = emailController.text.trim();
                                  final password =
                                      passwordController.text.trim();
                                  !signUp
                                      ? context
                                          .read<AuthCubit>()
                                          .signIn(email, password)
                                      : context
                                          .read<AuthCubit>()
                                          .registerWithEmailAndPassword(
                                              email, password);
                                },
                                child: signUp
                                    ? mediumFont('Register', italic: true)
                                    : mediumFont('Sign In', italic: true),
                              ),
                              const SizedBox(height: 16),
                              TextButton(
                                onPressed: () {
                                  setState(() {
                                    signUp = !signUp;
                                  });
                                },
                                child: !signUp
                                    ? const Text(
                                        'Don\'t have an account? Register')
                                    : const Text('Have an account? Sign In'),
                              ),
                              SignInButton(
                                Buttons.Google,
                                onPressed: () {
                                  context.read<AuthCubit>().googleSignIn();
                                },
                              ),
                            ],
                          ),
                        )
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
