import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../platform/platform.dart';
import '../app_version.dart';

part 'app_state.dart';

/// Globally accessible variable for the [AppCubit].
///
/// There is only ever one cubit, so this eases access.
late AppCubit appCubit;

class AppCubit extends Cubit<AppState> {
  AppCubit() : super(AppState.initial()) {
    appCubit = this;
    _fetchVersionData();
  }

  Future<void> _fetchVersionData() async {
    final versionRepo = AppVersion();
    final runningVersion = await versionRepo.runningVersion();
    final updateAvailable =
        (Platform.isDesktop) ? await versionRepo.updateAvailable() : false;
    final latestVersion =
        (Platform.isDesktop) ? await versionRepo.latestVersion() : '';
    final showUpdateButton = (Platform.isDesktop && updateAvailable);
    emit(state.copyWith(
      runningVersion: runningVersion,
      updateVersion: latestVersion,
      updateAvailable: updateAvailable,
      showUpdateButton: showUpdateButton,
    ));
  }

  Future<void> launchURL(String url) async {
    await canLaunch(url)
        ? await launch(url)
        : throw 'Could not launch url: $url';
  }

  void promptForProUpgrade() {
    emit(state.copyWith(promptForProUpgrade: true));
    emit(state.copyWith(promptForProUpgrade: false));
  }
}
