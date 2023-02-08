part of 'authentication_cubit.dart';

class AuthenticationState extends Equatable {
  final AccessCredentials? accessCredentials;
  final bool signedIn;
  final bool waitingForUserToSignIn;

  const AuthenticationState({
    required this.accessCredentials,
    required this.signedIn,
    required this.waitingForUserToSignIn,
  });

  @override
  List<Object?> get props => [
        accessCredentials,
        signedIn,
        waitingForUserToSignIn,
      ];

  AuthenticationState copyWith({
    AccessCredentials? accessCredentials,
    bool? signedIn,
    bool? waitingForUserToSignIn,
  }) {
    return AuthenticationState(
      accessCredentials: accessCredentials ?? this.accessCredentials,
      signedIn: signedIn ?? this.signedIn,
      waitingForUserToSignIn:
          waitingForUserToSignIn ?? this.waitingForUserToSignIn,
    );
  }
}
