import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../platform/platform.dart';
import '../version_service.dart';

part 'app_state.dart';

class AppCubit extends Cubit<AppState> {
  /// Singleton instance.
  static late AppCubit instance;

  AppCubit(VersionService appVersionService) : super(AppState.initial()) {
    instance = this;
    _fetchVersionData(appVersionService);
  }

  Future<void> _fetchVersionData(VersionService versionRepo) async {
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
    final uri = Uri.parse(url);
    await canLaunchUrl(uri)
        ? await launchUrl(uri)
        : throw 'Could not launch url: $url';
  }

  void promptForProUpgrade() {
    emit(state.copyWith(promptForProUpgrade: true));
    emit(state.copyWith(promptForProUpgrade: false));
  }
}
