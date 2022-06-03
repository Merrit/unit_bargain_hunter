#!/bin/bash

# No spaces in project name.
projectName=UnitBargainHunter
projectId=codes.merritt.bargain
executableName=unit_bargain_hunter
repository=unit_bargain_hunter
githubUsername=merrit

# This script is triggered by the json manifest.
# It can also be run manually: flatpak-builder build-dir $projectId.json

# Exit if any command fails
set -e

# Grab Flatpak build files.
cp -r packaging/linux/flatpak/build-flatpak.sh .
cp -r packaging/linux/$projectId.metainfo.xml .
cp -r packaging/linux/$projectId.desktop .
cp -r assets/icon/icon.svg .

# Setup Dart SDK.
wget https://storage.googleapis.com/dart-archive/channels/stable/release/latest/sdk/dartsdk-linux-x64-release.zip
unzip dartsdk-linux-x64-release.zip

# Update AppStream metainfo file.
dart-sdk/bin/dart pub get packaging/linux/updater
dart-sdk/bin/dart run packaging/linux/updater/bin/updater.dart $projectId $repository $githubUsername appstream_only

# Extract portable Flutter build.
mkdir -p $projectName
tar -xf $projectName-Linux-Portable.tar.gz -C $projectName
rm $projectName/PORTABLE

# Copy the portable app to the Flatpak-based location.
cp -r $projectName /app/
chmod +x /app/$projectName/$executableName
mkdir -p /app/bin
ln -s /app/$projectName/$executableName /app/bin/$executableName

# Install the icon.
iconDir=/app/share/icons/hicolor/scalable/apps
mkdir -p $iconDir
cp -r icon.svg $iconDir/$projectId.svg

# Install the desktop file.
desktopFileDir=/app/share/applications
mkdir -p $desktopFileDir
cp -r $projectId.desktop $desktopFileDir/

# Install the AppStream metadata file.
metadataDir=/app/share/metainfo
mkdir -p $metadataDir
cp -r $projectId.metainfo.xml $metadataDir/
