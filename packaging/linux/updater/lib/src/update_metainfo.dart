import 'dart:io';

import 'package:intl/intl.dart';
import 'package:xml/xml.dart';

import 'src.dart';

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
