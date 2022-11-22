import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;
import 'package:logging/logging.dart';
import 'package:pub_semver/pub_semver.dart' as semver;
import 'package:yaml/yaml.dart';
import 'package:http/http.dart' as http;

final _log = Logger('Versions');

/// Check app versions.
class VersionService {
  String _runningVersion = '';

  /// The application's version as read from pubspec.yaml,
  /// in the format of `1.0.0`.
  Future<String> runningVersion() async {
    if (_runningVersion == '') {
      final rawVersion = await _readVersion();
      // Remove the `+xx` that indicates the Android build number.
      _runningVersion = rawVersion.split('+').first;
    }
    return _runningVersion;
  }

  /// Reads the pubspec.yaml included in the assets and extracts
  /// the version string.
  Future<String> _readVersion() async {
    final pubspec = await rootBundle.loadString('pubspec.yaml');
    final yaml = loadYaml(pubspec);
    final rawVersion = yaml['version'] as String;
    return rawVersion;
  }

  Future<bool> updateAvailable() async {
    final current = semver.Version.parse(await runningVersion());
    final latest = semver.Version.parse(await latestVersion());
    return (current < latest) ? true : false;
  }

  String _latestVersion = '';

  /// Checks the latest GitHub tag.
  Future<String> latestVersion() async {
    if (_latestVersion != '') return _latestVersion;
    final uri = Uri.parse(
      'https://api.github.com/repos/merrit/unit_bargain_hunter/releases',
    );
    final response = await http.get(
      uri,
      headers: {'Accept': 'application/vnd.github.v3+json'},
    );
    if (response.statusCode == 200) {
      final json = jsonDecode(response.body) as List;
      final data = json[0] as Map<String, dynamic>;
      final tag = data['tag_name'] as String;
      // Strip the leading `v` and anything trailing.
      // May need to be updated if we starting using postfixes like `beta`.
      _latestVersion = tag.substring(1, 6);
    } else {
      _log.info('Issue getting latest version info from GitHub, '
          'status code: ${response.statusCode}\n');
    }
    return _latestVersion;
  }
}
