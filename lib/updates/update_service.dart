import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';

import '../logs/logs.dart';
import 'updates.dart';

/// Gets inforamation about the current and latest versions of the app.
Future<VersionInfo> getVersionInfo() async {
  final currentVersion = await _getCurrentVersion();
  final latestVersion = await _getLatestVersion();

  return VersionInfo(
    currentVersion: currentVersion,
    latestVersion: latestVersion,
    updateAvailable: latestVersion != null && latestVersion != currentVersion,
  );
}

/// Gets the current version of the app.
Future<String> _getCurrentVersion() async {
  final packageInfo = await PackageInfo.fromPlatform();
  return packageInfo.version;
}

/// Gets the latest version of the app.
Future<String?> _getLatestVersion() async {
  final uri = Uri.parse(
    'https://api.github.com/repos/merrit/unit_bargain_hunter/releases',
  );

  final response = await http.get(
    uri,
    headers: {'Accept': 'application/vnd.github.v3+json'},
  );

  if (response.statusCode == 200) {
    final json = jsonDecode(response.body) as List;
    final data = List<Map>.from(json);
    final tag = data.firstWhere((element) => element['prerelease'] == false);
    final tagName = tag['tag_name'] as String;
    return _parseVersionTag(tagName);
  } else {
    log.w('Issue getting latest version info from GitHub, '
        'status code: ${response.statusCode}\n');
  }

  return null;
}

/// Returns the version number without the leading `v` or any postfix.
///
/// Examples:
/// `v1.2.3` becomes `1.2.3`.
/// `v1.2.3-beta` becomes `1.2.3`.
String _parseVersionTag(String tag) {
  final version = tag.split('v').last.split('-').first;
  return version;
}
