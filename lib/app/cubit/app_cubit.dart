import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../platform/platform.dart';
import '../../updates/update_service.dart';

part 'app_state.dart';

class AppCubit extends Cubit<AppState> {
  /// Singleton instance.
  static late AppCubit instance;

  AppCubit() : super(AppState.initial()) {
    instance = this;
    _fetchVersionData();
  }

  Future<void> _fetchVersionData() async {
    final versionInfo = await getVersionInfo();
    emit(state.copyWith(
      runningVersion: versionInfo.currentVersion,
      updateVersion: versionInfo.latestVersion,
      updateAvailable: versionInfo.updateAvailable,
      showUpdateButton: (Platform.isDesktop && versionInfo.updateAvailable),
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
