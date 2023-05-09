import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gif_view/gif_view.dart';
import 'package:light_shooter/pages/home/home_route.dart';
import 'package:light_shooter/pages/login/bloc/login_bloc.dart';
import 'package:light_shooter/shared/bootstrap.dart';
import 'package:light_shooter/shared/theme/game_colors.dart';
import 'package:light_shooter/shared/widgets/game_button.dart';
import 'package:light_shooter/shared/widgets/game_container.dart';
import 'package:light_shooter/shared/widgets/game_textfield.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final GlobalKey<FormState> _form = GlobalKey();
  final TextEditingController _userName = TextEditingController();
  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();
  final TextEditingController _confirmpassowrd = TextEditingController();
  late LoginBloc _bloc;
  @override
  void initState() {
    _bloc = inject();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GameColors.background,
      body: BlocConsumer<LoginBloc, LoginState>(
        bloc: _bloc,
        listener: (context, state) {
          if (state.authorized) {
            HomeRoute.open(context);
          }
          if (state.error.isNotEmpty) {
            _showErrorSnackbar(context, state.error);
          }
        },
        builder: (context, state) {
          return Stack(
            children: [
              Center(
                child: Form(
                  key: _form,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'Light Shooter',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(
                        height: 32,
                      ),
                      GameContainer(
                        constraints: const BoxConstraints(maxWidth: 300),
                        child: AnimatedSize(
                          duration: const Duration(milliseconds: 300),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const SizedBox(height: 16),
                              if (state.signUpMode) ...[
                                GameTextField(
                                  controller: _userName,
                                  hint: 'User name',
                                  enabled: !state.loading,
                                  validator: (value) {
                                    String text = value ?? '';
                                    if (text.isEmpty) {
                                      return 'Field required';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 16),
                              ],
                              GameTextField(
                                controller: _email,
                                hint: 'E-mail',
                                enabled: !state.loading,
                                validator: (value) {
                                  String text = value ?? '';
                                  if (text.isEmpty) {
                                    return 'Field required';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),
                              GameTextField(
                                controller: _password,
                                hint: 'Password',
                                enabled: !state.loading,
                                validator: (value) {
                                  String text = value ?? '';
                                  if (text.isEmpty) {
                                    return 'Field required';
                                  }
                                  return null;
                                },
                              ),
                              if (state.signUpMode) ...[
                                const SizedBox(height: 16),
                                GameTextField(
                                  controller: _confirmpassowrd,
                                  hint: 'Confirm password',
                                  enabled: !state.loading,
                                  validator: (value) {
                                    String text = value ?? '';
                                    if (text.isEmpty) {
                                      return 'Field required';
                                    }
                                    if (_password.text != text) {
                                      return 'The passawords is not the same';
                                    }
                                    return null;
                                  },
                                ),
                              ],
                              const SizedBox(height: 32),
                              GameButton(
                                expanded: true,
                                onPressed: () {
                                  if (state.signUpMode) {
                                    _doSignUp();
                                  } else {
                                    _doSignIn();
                                  }
                                },
                                text: state.signUpMode ? 'Sign up' : 'Sign in',
                                loading: state.loading,
                              ),
                              const SizedBox(height: 16),
                              SizedBox(
                                height: 40,
                                width: double.maxFinite,
                                child: TextButton(
                                  onPressed: () {
                                    _bloc.add(ClickSignUpEvent(
                                        goSignUp: !state.signUpMode));
                                  },
                                  style: const ButtonStyle(
                                    shape: MaterialStatePropertyAll(
                                      StadiumBorder(),
                                    ),
                                  ),
                                  child: Text(
                                    state.signUpMode ? 'Voltar' : 'Sign up',
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Align(
                alignment: Alignment.bottomRight,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      GifView.asset(
                        'assets/bonfire.gif',
                        height: 50,
                        width: 50,
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      const Text(
                        'Buit with Bonfire',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w300,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _doSignUp() {
    if (_form.currentState?.validate() == true) {
      _bloc.add(SignUpEvent(_userName.text, _email.text, _password.text));
    }
  }

  void _doSignIn() {
    if (_form.currentState?.validate() == true) {
      _bloc.add(SignInEvent(_email.text, _password.text));
    }
  }

  void _showErrorSnackbar(BuildContext context, String error) {
    var snackBar = SnackBar(
      backgroundColor: Colors.red,
      content: Text(error),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}
