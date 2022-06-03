import 'dart:io';

import 'package:intl/intl.dart';
import 'package:updater/src/src.dart';
import 'package:xml/xml.dart';

Future<void> main(List<String> arguments) async {
  projectId = arguments[0];
  repository = arguments[1];
  user = arguments[2];
  if (arguments.length > 3) {
    target = arguments[3];
  }

  final githubInfo = await GitHubInfo.fetch(
    projectId: projectId,
    repository: repository,
    user: user,
  );

  if (githubInfo.linuxAssetName == null) {
    throw Exception('Asset not found.');
  }

  updateMetainfo(projectId, githubInfo);
  if (target == 'appstream_only') {
    exit(0);
  }

  await updateManifest(projectId, githubInfo);
}

/// Update the $projectId.json manifest file with the necessary info from
/// the latest release: tag / version and sha256 of the linux asset.
Future<void> updateManifest(String projectId, GitHubInfo githubInfo) async {
  File manifestFile = File('$projectId.json');
  bool exists = await manifestFile.exists();
  if (!exists) {
    // If run by the flathub builder, the files will all be in the same dir.
    // Otherwise we check the dir above for the manifest.
    manifestFile = File('flatpak/$projectId.json');
  }
  String manifestJson = manifestFile.readAsStringSync();

  final manifest = Manifest.fromJson(manifestJson);

  manifest.modules?.first.sources = <Source>[
    Source(
      type: 'file',
      url: githubInfo.linuxAssetName?.browserDownloadUrl,
      sha256: await githubInfo.linuxAssetHash(),
    ),
    Source(
      type: 'git',
      url: githubInfo.repo.cloneUrl,
      tag: githubInfo.latestRelease.tagName,
    ),
    Source(
      type: 'file',
      path: '$projectId.metainfo.xml',
    ),
  ];

  manifestJson = manifest.toJson();
  manifestFile.writeAsStringSync(manifestJson);
}

/// Update the $projectId.metainfo.xml file with the
/// date and version of the new release.
void updateMetainfo(String projectId, GitHubInfo githubInfo) {
  final metainfoFile = File('$projectId.metainfo.xml');
  final metainfo = XmlDocument.parse(metainfoFile.readAsStringSync());

  final publishDate = githubInfo.latestRelease.publishedAt;
  final date = DateFormat('yyyy-MM-dd').format(publishDate!);

  metainfo.findAllElements('release').first.replace(
        XmlElement(XmlName('release'), [
          XmlAttribute(
            XmlName('version'),
            githubInfo.latestRelease.tagName!.substring(1),
          ),
          XmlAttribute(
            XmlName('date'),
            date,
          ),
        ]),
      );

  metainfoFile.writeAsStringSync(metainfo.toXmlString(pretty: true));
}
