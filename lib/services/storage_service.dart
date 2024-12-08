import 'package:hive_flutter/hive_flutter.dart';

class StorageService {
  late Box _box;

  // Initialize Hive and open a box
  Future<void> init() async {
    await Hive.initFlutter();
    _box = await Hive.openBox('storageBox');
  }

  // Set a value (can store any type)
  Future<void> setValue(String key, dynamic value) async {
    await _box.put(key, value);
  }

  // Get a value
  T? getValue<T>(String key) {
    return _box.get(key);
  }

  // Remove a value
  Future<void> remove(String key) async {
    await _box.delete(key);
  }

  // Clear all values
  Future<void> clear() async {
    await _box.clear();
  }

  // Check if a key exists
  bool containsKey(String key) {
    return _box.containsKey(key);
  }

  Future<void> empty() async {
    await _box.clear();
  }
}
