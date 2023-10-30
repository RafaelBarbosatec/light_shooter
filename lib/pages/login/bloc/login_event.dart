part of 'login_bloc.dart';

@immutable
abstract class LoginEvent {}

class SignInEvent extends LoginEvent {
  final String email;
  final String password;

  SignInEvent(this.email, this.password);
}

class SignUpEvent extends LoginEvent {
  final String username;
  final String email;
  final String password;

  SignUpEvent(this.username, this.email, this.password);
}

class ClickSignUpEvent extends LoginEvent {
  final bool goSignUp;

  ClickSignUpEvent({this.goSignUp = true});
}
