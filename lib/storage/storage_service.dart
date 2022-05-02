import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';

import '../core/helpers/helpers.dart';

/// Interfaces with the host OS to store & retrieve data from disk.
class StorageService {
  /// This class is a singleton.
  /// This variable holds the instance once created.
  static StorageService? _instance;

  /// Private singleton constructor.
  StorageService._singleton();

  /// Factory ensures only one instance is ever created.
  factory StorageService() {
    if (_instance != null) return _instance!;
    return StorageService._singleton();
  }

  /// A generic storage pool, anything large should make its own box.
  static const String _generalBox = 'general';

  /// Initialize the storage access.
  /// Needs to be initialized only once, in the `main()` function.
  Future<void> init() async {
    /// On desktop platforms initialize to a specific directory.
    if (platformIsDesktop()) {
      final dir = await getApplicationSupportDirectory();
      // Defaults to ~/.local/share/feeling_finder/storage
      Hive.init(dir.path + '/storage');
    } else {
      // On mobile and web initialize to default location.
      await Hive.initFlutter();
    }
  }

  /// Persist a value to local disk storage.
  Future<void> saveValue({
    required String key,
    required dynamic value,
    String? storageArea,
  }) async {
    final Box _box = await _getBox(storageArea);
    await _box.put(key, value);
  }

  /// Get a value from local disk storage.
  ///
  /// If the [key] doesn't exist, `null` is returned.
  Future<dynamic> getValue(String key, {String? storageArea}) async {
    final Box _box = await _getBox(storageArea);
    return _box.get(key);
  }

  /// Get all values associated with a particlar storage.
  Future<Iterable<dynamic>> getStorageAreaValues(String storageArea) async {
    final Box _box = await _getBox(storageArea);
    return _box.values;
  }

  /// Delete a key from storage.
  Future<void> deleteValue(String key, {String? storageArea}) async {
    final Box _box = await _getBox(storageArea);
    await _box.delete(key);
  }

  /// Get a Hive storage box, either the one associated with
  /// [storageAreaName], or the general storage box.
  Future<Box> _getBox(String? storageAreaName) async {
    return await Hive.openBox(storageAreaName ?? _generalBox);
  }
}
