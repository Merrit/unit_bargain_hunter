part of 'app_cubit.dart';

class AppState extends Equatable {
  final String runningVersion;
  final String updateVersion;
  final bool updateAvailable;
  final bool showUpdateButton;

  const AppState({
    required this.runningVersion,
    required this.updateVersion,
    required this.updateAvailable,
    required this.showUpdateButton,
  });

  factory AppState.initial() {
    return AppState(
      runningVersion: '',
      updateVersion: '',
      updateAvailable: false,
      showUpdateButton: false,
    );
  }

  @override
  List<Object> get props =>
      [runningVersion, updateVersion, updateAvailable, showUpdateButton];

  AppState copyWith({
    String? runningVersion,
    String? updateVersion,
    bool? updateAvailable,
    bool? showUpdateButton,
  }) {
    return AppState(
      runningVersion: runningVersion ?? this.runningVersion,
      updateVersion: updateVersion ?? this.updateVersion,
      updateAvailable: updateAvailable ?? this.updateAvailable,
      showUpdateButton: showUpdateButton ?? this.showUpdateButton,
    );
  }
}
