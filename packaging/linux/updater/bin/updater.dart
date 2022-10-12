import 'dart:io';

import 'package:updater/src/src.dart';

Future<void> main(List<String> arguments) async {
  projectId = arguments[0];
  repository = arguments[1];
  user = arguments[2];

  final githubInfo = await GitHubInfo.fetch(
    projectId: projectId,
    repository: repository,
    user: user,
  );

  if (githubInfo.linuxAssetName == null) {
    throw Exception('Asset not found.');
  }

  await updateManifest(projectId, githubInfo);
  updateMetainfo(projectId, githubInfo);
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
