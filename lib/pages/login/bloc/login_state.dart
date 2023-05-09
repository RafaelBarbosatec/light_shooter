// ignore_for_file: public_member_api_docs, sort_constructors_first
part of 'login_bloc.dart';

@immutable
class LoginState {
  final bool loading;
  final bool authorized;
  final String error;
  final bool signUpMode;

  const LoginState({
    this.loading = false,
    this.authorized = false,
    this.error = '',
    this.signUpMode = false,
  });

  LoginState copyWith({
    bool? loading,
    bool? authorized,
    String? error,
    bool? signUpMode,
  }) {
    return LoginState(
      loading: loading ?? this.loading,
      signUpMode: signUpMode ?? this.signUpMode,
      authorized: authorized ?? false,
      error: error ?? '',
    );
  }
}
