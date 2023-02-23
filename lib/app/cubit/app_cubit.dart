import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:helpers/helpers.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../platform/platform.dart';
import '../../storage/storage_service.dart';
import '../../updates/update_service.dart';

part 'app_state.dart';
part 'app_cubit.freezed.dart';

class AppCubit extends Cubit<AppState> {
  /// Service for fetching release notes.
  final ReleaseNotesService _releaseNotesService;

  /// Service for fetching version info.
  final UpdateService _updateService;

  /// Singleton instance.
  static late AppCubit instance;

  AppCubit({
    required ReleaseNotesService releaseNotesService,
    required UpdateService updateService,
  })  : _updateService = updateService,
        _releaseNotesService = releaseNotesService,
        super(AppState.initial()) {
    instance = this;
    _init();
  }

  /// Initializes the cubit.
  ///
  /// Lazy loading is used instead of awaiting on a constructor to avoid
  /// blocking the UI, since none of the data fetched here is critical.
  Future<void> _init() async {
    await _fetchVersionData();
    await _fetchReleaseNotes();
  }

  /// Fetches version data from the update service.
  Future<void> _fetchVersionData() async {
    final versionInfo = await _updateService.getVersionInfo();
    emit(state.copyWith(
      runningVersion: versionInfo.currentVersion,
      updateVersion: versionInfo.latestVersion,
      updateAvailable: versionInfo.updateAvailable,
      showUpdateButton: (Platform.isDesktop && versionInfo.updateAvailable),
    ));
  }

  /// Fetches release notes from the release notes service.
  Future<void> _fetchReleaseNotes() async {
    final String? lastReleaseNotesVersionShown = await StorageService //
        .instance
        ?.getValue('lastReleaseNotesVersionShown');

    if (lastReleaseNotesVersionShown == state.runningVersion) return;

    final releaseNotes = await _releaseNotesService.getReleaseNotes(
      'v${state.runningVersion}',
    );

    if (releaseNotes == null) return;

    emit(state.copyWith(releaseNotes: releaseNotes));
    emit(state.copyWith(releaseNotes: null));

    StorageService.instance?.saveValue(
      key: 'lastReleaseNotesVersionShown',
      value: state.runningVersion,
    );
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
