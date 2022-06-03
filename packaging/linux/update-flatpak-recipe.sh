#!/bin/bash

projectId=codes.merritt.bargain
repository=unit_bargain_hunter
githubUsername=merrit

# Update manifest and AppStream metadata files.
dart run updater/bin/updater.dart $projectId $repository $githubUsername

# Verify AppStream metadata file.
flatpak run org.freedesktop.appstream-glib validate $projectId.metainfo.xml
