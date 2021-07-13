import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:unit_bargain_hunter/infrastructure/platform/platform.dart';
import 'package:unit_bargain_hunter/infrastructure/versions/versions.dart';
import 'package:url_launcher/url_launcher.dart';

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
    final versionRepo = Versions();
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
}
