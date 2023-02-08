import 'dart:convert';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:googleapis_auth/googleapis_auth.dart';

import '../../storage/storage_service.dart';
import '../google_auth.dart';

part 'authentication_state.dart';

class AuthenticationCubit extends Cubit<AuthenticationState> {
  final GoogleAuth _googleAuth;
  final StorageService _storageService;

  static late AuthenticationCubit instance;

  AuthenticationCubit._(
    this._googleAuth,
    this._storageService, {
    required AuthenticationState initialState,
  }) : super(initialState) {
    instance = this;
  }

  static Future<AuthenticationCubit> initialize({
    required GoogleAuth googleAuth,
    required StorageService storageService,
  }) async {
    final String? savedCredentials = await storageService.getValue(
      'accessCredentials',
    );

    AccessCredentials? credentials;
    if (savedCredentials != null) {
      credentials = AccessCredentials.fromJson(jsonDecode(savedCredentials));
    }

    return AuthenticationCubit._(
      googleAuth,
      storageService,
      initialState: AuthenticationState(
        accessCredentials: credentials,
        signedIn: (credentials != null),
        waitingForUserToSignIn: false,
      ),
    );
  }

  Future<void> signIn() async {
    assert(!state.signedIn);

    emit(state.copyWith(waitingForUserToSignIn: true));

    final accessCredentials = await _googleAuth.signin();
    if (accessCredentials == null) return;

    emit(state.copyWith(
      accessCredentials: accessCredentials,
      signedIn: true,
      waitingForUserToSignIn: false,
    ));

    await _storageService.saveValue(
      key: 'accessCredentials',
      value: jsonEncode(accessCredentials.toJson()),
    );
  }

  /// Cancel the sign in process.
  Future<void> cancelSignIn() async {
    emit(state.copyWith(signedIn: false, waitingForUserToSignIn: false));
  }

  Future<void> signOut() async {
    await _googleAuth.signOut();
    await _storageService.deleteValue('accessCredentials');

    emit(state.copyWith(
      accessCredentials: null,
      signedIn: false,
    ));
  }
}
