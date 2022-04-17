#!/bin/bash

projectId=codes.merritt.bargain
repository=unit_bargain_hunter
githubUsername=merrit

# Update manifest and AppStream metadata files.
dart run update_flatpak_recipe/bin/update.dart $projectId $repository $githubUsername

# Verify AppStream metadata file.
appstream-util validate $projectId.metainfo.xml
