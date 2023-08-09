import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:helpers/helpers.dart';
import 'package:logger/logger.dart';
import 'package:path_provider/path_provider.dart';

/// Globally available instance available for easy logging.
late final Logger log;

/// Manages logging for the app.
class LoggingManager {
  /// The file to which logs are saved.
  final File? _logFile;

  /// Singleton instance for easy access.
  static late final LoggingManager instance;

  LoggingManager._(
    this._logFile,
  ) {
    instance = this;
  }

  static Future<LoggingManager> initialize({bool verbose = false}) async {
    if (testing) {
      // Set the logger to a dummy logger during unit tests.
      log = Logger(level: Level.off);
      return LoggingManager._(File(''));
    }

    final List<LogOutput> outputs = [
      ConsoleOutput(),
    ];

    // Create a log file for the current run.
    File? logFile;
    if (!kIsWeb) {
      final dataDir = await getApplicationSupportDirectory();
      logFile = File('${dataDir.path}${Platform.pathSeparator}log.txt');
      if (await logFile.exists()) await logFile.delete();
      await logFile.create();
      outputs.add(FileOutput(file: logFile));
    }

    log = Logger(
      filter: ProductionFilter(),
      level: (verbose) ? Level.trace : Level.warning,
      output: MultiOutput(outputs),
      // Colors false because it outputs ugly escape characters to log file.
      printer: PrefixPrinter(PrettyPrinter(colors: false)),
    );

    log.t('Logger initialized.');

    return LoggingManager._(
      logFile,
    );
  }

  /// Read the logs from this run from the log file.
  Future<String?> getLogs() async => await _logFile?.readAsString();

  /// Close the logger and release resources.
  void close() => log.close();
}
