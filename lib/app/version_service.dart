import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:pub_semver/pub_semver.dart' as semver;
import 'package:yaml/yaml.dart';
import 'package:http/http.dart' as http;

import '../logs/logs.dart';

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

  String _latest = '';

  /// Gets the latest version from the GitHub tag.
  Future<String> latestVersion() async {
    if (_latest != '') return _latest;
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
      _latest = parseVersionTag(tagName);
    } else {
      log.w('Issue getting latest version info from GitHub, '
          'status code: ${response.statusCode}\n');
    }
    return _latest;
  }

  /// Returns the version number without the leading `v` or any postfix.
  ///
  /// Examples:
  /// `v1.2.3` becomes `1.2.3`.
  /// `v1.2.3-beta` becomes `1.2.3`.
  @visibleForTesting
  String parseVersionTag(String tag) {
    final version = tag.split('v').last.split('-').first;
    return version;
  }
}
