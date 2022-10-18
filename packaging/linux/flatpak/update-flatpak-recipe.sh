#!/bin/bash

projectId=codes.merritt.bargain
repository=unit_bargain_hunter
githubUsername=merrit

# Update AppStream metadata and Flathub manifest files.
dart pub global activate --source git https://github.com/Merrit/linux_packaging_updater.git
updater $projectId $repository $githubUsername

# Verify AppStream metadata file for Flathub.
flatpak run org.freedesktop.appstream-glib validate packaging/linux/$projectId.metainfo.xml
