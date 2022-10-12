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

  final String releaseNotes = githubInfo.latestRelease.body ?? '';
  final releaseNotesIterable = releaseNotes.split('\n');

  metainfo.findAllElements('release').first.replace(
        XmlElement(
          XmlName('release'),
          [
            XmlAttribute(
              XmlName('version'),
              githubInfo.latestRelease.tagName!.substring(1),
            ),
            XmlAttribute(
              XmlName('date'),
              date,
            ),
          ],
          [
            XmlElement(
              XmlName('description'),
              [],
              [
                for (var item in releaseNotesIterable)
                  XmlElement(
                    XmlName('p'),
                    [],
                    [XmlText(item)],
                  ),
                // XmlText(releaseNotes),
              ],
            ),
          ],
        ),
      );

  metainfoFile.writeAsStringSync(metainfo.toXmlString(pretty: true));
}
