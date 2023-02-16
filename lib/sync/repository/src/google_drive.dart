import 'dart:io' as io;

import 'package:googleapis/drive/v3.dart';

import '../../../logs/logs.dart';
import '../../sync.dart';

/// Google Drive sync service.
class GoogleDrive implements SyncRepository {
  final DriveApi _driveApi;

  GoogleDrive(this._driveApi);

  @override
  Future<List<int>?> download({required String fileName}) async {
    final fileId = await _getFileId(fileName);

    if (fileId == null) {
      throw SyncException('File does not exist.');
    }

    final Media media;
    try {
      media = await _driveApi.files.get(
        fileId,
        downloadOptions: DownloadOptions.fullMedia,
      ) as Media;
    } on DetailedApiRequestError catch (e) {
      if (e.status == io.HttpStatus.notFound) {
        throw SyncException('File does not exist.');
      }
      return null;
    }

    return media.toBytes();
  }

  @override
  Future<bool> upload({
    required String fileName,
    required List<int> data,
  }) async {
    final fileId = await _getFileId(fileName);

    if (fileId == null) {
      try {
        await _driveApi.files.create(
          File(
            name: fileName,
            mimeType: 'application/json',
          ),
          uploadOptions: ResumableUploadOptions(),
          uploadMedia: Media(
            Stream.value(data),
            data.length,
          ),
        );
      } on DetailedApiRequestError catch (e) {
        if (e.status == io.HttpStatus.conflict) {
          return false;
        }
        rethrow;
      }
    } else {
      try {
        await _driveApi.files.update(
          File(
            name: fileName,
            mimeType: 'application/json',
          ),
          fileId,
          uploadOptions: ResumableUploadOptions(),
          uploadMedia: Media(
            Stream.value(data),
            data.length,
          ),
        );
      } on DetailedApiRequestError catch (e) {
        log.e('Failed to upload file', e);
        return false;
      }
    }

    return true;
  }

  /// Check if a file with the given [name] exists.
  ///
  /// Returns the ID of the file if it exists.
  /// Returns null if the file does not exist.
  Future<String?> _getFileId(String name) async {
    final response = await _driveApi.files.list(
      q: 'name = "$name"',
    );

    if (response.files == null || response.files!.isEmpty) {
      return null;
    }

    return response.files!.first.id;
  }
}

extension MediaHelper on Media {
  /// Convert the [Media] object to bytes.
  Future<List<int>> toBytes() async {
    final bytes = await stream.toList();
    return bytes.expand((element) => element).toList();
  }
}
