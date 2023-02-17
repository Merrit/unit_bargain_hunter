import 'dart:convert';
import 'dart:io';

import 'package:extension_google_sign_in_as_googleapis_auth/extension_google_sign_in_as_googleapis_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/drive/v3.dart';
import 'package:googleapis_auth/auth_io.dart';
import 'package:http/http.dart';
import 'package:http/io_client.dart';

import 'package:url_launcher/url_launcher.dart';

import '../logs/logs.dart';
import '../storage/storage_service.dart';

abstract class GoogleAuthIds {
  static const String linuxClientIdString =
      '489801959946-a4f66p59bl7lbhcdan9qgs0kroplc2b9.apps.googleusercontent.com';
  static const String linuxClientSecret = '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';
  static final ClientId linuxClientId = ClientId(
    linuxClientIdString,
    linuxClientSecret,
  );

  static const String windowsClientIdString = '';
  static const String windowsClientSecret = '';
  static final ClientId windowsClientId = ClientId(
    windowsClientIdString,
    windowsClientSecret,
  );

  static const String androidClientIdString =
      '489801959946-jhunhbd9fogdu0qnh6lh2vse1cg87voo.apps.googleusercontent.com';
  static final ClientId androidClientId = ClientId(androidClientIdString);

  static const String webClientId =
      '489801959946-smgnr4n23vt0ab658jdbf8q1pfefht23.apps.googleusercontent.com';
  static const String webClientSecret = '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';

  static ClientId get clientId {
    if (kIsWeb) {
      return ClientId(webClientId, webClientSecret);
    }

    switch (Platform.operatingSystem) {
      case 'linux':
        return linuxClientId;
      case 'windows':
        return windowsClientId;
      case 'android':
        return androidClientId;
      default:
        return ClientId('', '');
    }
  }
}

class GoogleAuth {
  static final scopes = [DriveApi.driveFileScope];

  Future<AccessCredentials?> signin() async {
    if (kIsWeb || Platform.isAndroid || Platform.isIOS) {
      return await _googleSignInAuth();
    } else {
      return await _googleApisAuth();
    }
  }

  /// Authenticates via the `googleapis_auth` package.
  ///
  /// Supports all platforms, but is not as stable or nice to use as the
  /// `google_sign_in` package.
  Future<AccessCredentials?> _googleApisAuth() async {
    AutoRefreshingAuthClient? client;
    try {
      client = await clientViaUserConsent(
        GoogleAuthIds.clientId,
        scopes,
        launchAuthUrl,
      );
    } catch (e) {
      log.w('Unable to sign in: $e');
    }

    return client?.credentials;
  }

  /// Authenticates via the `google_sign_in` package.
  ///
  /// Supports Android, iOS & Web.
  Future<AccessCredentials?> _googleSignInAuth() async {
    final GoogleSignIn googleSignIn = GoogleSignIn(scopes: scopes);

    try {
      await googleSignIn.signIn();
    } on PlatformException catch (e) {
      log.w('Failed to sign in with google_sign_in', e);
      return null;
    }

    final AuthClient? client;
    try {
      client = await googleSignIn.authenticatedClient();
    } catch (e) {
      log.w('Unable to get AuthClient: $e');
      return null;
    }

    final googleAuth = await googleSignIn.currentUser?.authentication;
    if (googleAuth == null) return null;
    if (googleAuth.accessToken == null) return null;

    return client?.credentials;
  }

  /// google_sign_in doesn't provide us with a refresh token, so this is a
  /// workaround to refresh authentication for platforms that use google_sign_in
  static Future<AuthClient?> refreshAuthClient() async {
    final GoogleSignIn googleSignIn = GoogleSignIn(scopes: scopes);
    final GoogleSignInAccount? googleSignInAccount =
        await googleSignIn.signInSilently();

    if (googleSignInAccount == null) await GoogleAuth().signin();

    final AuthClient? client = await googleSignIn.authenticatedClient();

    return client;
  }

  Future<void> launchAuthUrl(String url) async {
    final authUrl = Uri.parse(url);
    if (await canLaunchUrl(authUrl)) launchUrl(authUrl);
  }

  /// Returns an `AuthClient` that can be used to make authenticated requests.
  Future<AuthClient?> getAuthClient() async {
    final clientId = GoogleAuthIds.clientId;
    final credentials = await StorageService.instance?.getValue(
      'accessCredentials',
    );

    if (credentials == null) return null;

    final accessCredentials = AccessCredentials.fromJson(
      json.decode(credentials),
    );

    AuthClient? client;
    // `google_sign_in` can't get us a refresh token, so.
    if (accessCredentials.refreshToken != null) {
      client = autoRefreshingClient(
        clientId,
        accessCredentials,
        Client(),
      );
    } else {
      client = await GoogleAuth.refreshAuthClient();
    }

    return client;
  }

  Future<void> signOut() async {
    // Specific signout only seems needed for the google_sign_in package.
    if (defaultTargetPlatform != TargetPlatform.android) return;

    final GoogleSignIn googleSignIn = GoogleSignIn(scopes: scopes);

    await googleSignIn.signOut();
  }
}

class GoogleHttpClient extends IOClient {
  final Map<String, String> _headers;

  GoogleHttpClient(this._headers);

  @override
  Future<IOStreamedResponse> send(BaseRequest request) =>
      super.send(request..headers.addAll(_headers));
}
