import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:light_shooter/server_conection/server_client.dart';
import 'package:light_shooter/server_conection/websocket_client.dart';

part 'login_event.dart';
part 'login_state.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  final ServerClient _client;
  final WebsocketClient _websocketClient;
  LoginBloc(this._client, this._websocketClient) : super(const LoginState()) {
    on<SignInEvent>(_onSignInEvent);
    on<SignUpEvent>(_onSignUpEvent);
    on<ClickSignUpEvent>(_onClickSignUpEvent);
  }

  FutureOr<void> _onSignInEvent(
    SignInEvent event,
    Emitter<LoginState> emit,
  ) async {
    emit(state.copyWith(loading: true));
    await _client
        .signInEmail(email: event.email, password: event.password)
        .then((value) async {
      _websocketClient.init(value);
      emit(state.copyWith(authorized: true, loading: false));
    }).catchError((e) {
      emit(state.copyWith(error: e.message, loading: false));
    });
  }

  FutureOr<void> _onClickSignUpEvent(
    ClickSignUpEvent event,
    Emitter<LoginState> emit,
  ) {
    emit(state.copyWith(signUpMode: event.goSignUp));
  }

  FutureOr<void> _onSignUpEvent(
    SignUpEvent event,
    Emitter<LoginState> emit,
  ) async {
    emit(state.copyWith(loading: true));
    await _client
        .signInEmail(
      username: event.username,
      email: event.email,
      password: event.password,
      create: true,
    )
        .then((value) async {
      _websocketClient.init(value);
      emit(state.copyWith(authorized: true, loading: false));
    }).catchError((e) {
      emit(state.copyWith(error: e.message, loading: false));
    });
  }
}
