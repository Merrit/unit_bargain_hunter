part of 'app_cubit.dart';

class AppState extends Equatable {
  final String runningVersion;
  final String updateVersion;
  final bool updateAvailable;
  final bool showUpdateButton;

  /// True if a condition has been met requiring the user to be
  /// prompted to purchase the pro upgrade.
  final bool promptForProUpgrade;

  const AppState({
    required this.runningVersion,
    required this.updateVersion,
    required this.updateAvailable,
    required this.showUpdateButton,
    required this.promptForProUpgrade,
  });

  factory AppState.initial() {
    return const AppState(
      runningVersion: '',
      updateVersion: '',
      updateAvailable: false,
      showUpdateButton: false,
      promptForProUpgrade: false,
    );
  }

  AppState copyWith({
    String? runningVersion,
    String? updateVersion,
    bool? updateAvailable,
    bool? showUpdateButton,
    bool? promptForProUpgrade,
  }) {
    return AppState(
      runningVersion: runningVersion ?? this.runningVersion,
      updateVersion: updateVersion ?? this.updateVersion,
      updateAvailable: updateAvailable ?? this.updateAvailable,
      showUpdateButton: showUpdateButton ?? this.showUpdateButton,
      promptForProUpgrade: promptForProUpgrade ?? this.promptForProUpgrade,
    );
  }

  @override
  List<Object> get props {
    return [
      runningVersion,
      updateVersion,
      updateAvailable,
      showUpdateButton,
      promptForProUpgrade,
    ];
  }
}
