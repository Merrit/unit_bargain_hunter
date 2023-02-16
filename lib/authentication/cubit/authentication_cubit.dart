import 'dart:convert';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:googleapis_auth/googleapis_auth.dart';

import '../../storage/storage_service.dart';
import '../../sync/sync.dart';
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
      final authClient = await googleAuth.getAuthClient();
      if (authClient != null) {
        final syncRepository = await SyncRepository.initialize(authClient);
        await SyncService.initialize(
          storageService: storageService,
          syncRepository: syncRepository,
        );
      }
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

  Future<bool> signIn() async {
    assert(!state.signedIn);

    emit(state.copyWith(waitingForUserToSignIn: true));

    final accessCredentials = await _googleAuth.signin();
    if (accessCredentials == null) return false;

    emit(state.copyWith(
      accessCredentials: accessCredentials,
      signedIn: true,
      waitingForUserToSignIn: false,
    ));

    await _storageService.saveValue(
      key: 'accessCredentials',
      value: jsonEncode(accessCredentials.toJson()),
    );

    return await _initSyncService();
  }

  /// Initialize the sync service once the user has signed in.
  ///
  /// Returns `true` if the sync service was initialized successfully.
  /// Returns `false` if the user is not signed in.
  Future<bool> _initSyncService() async {
    final authClient = await _googleAuth.getAuthClient();
    if (authClient == null) return false;

    final syncRepository = await SyncRepository.initialize(authClient);
    await SyncService.initialize(
      storageService: _storageService,
      syncRepository: syncRepository,
    );

    return true;
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
