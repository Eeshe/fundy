import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive/hive.dart';
import 'dart:math';

class EncryptionService {
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  Future<HiveAesCipher> fetchEncryptionKey() async {
    String? storedKey = await _secureStorage.read(key: "encryption_key");
    if (storedKey == null) {
      final random = Random.secure();
      List<int> generatedKey = List.generate(32, (_) => random.nextInt(256), growable: false);
      storedKey = base64Encode(generatedKey);
      await _secureStorage.write(key: "encryption_key", value: storedKey);

      return HiveAesCipher(generatedKey);
    }
    return HiveAesCipher(base64Decode(storedKey));
  }
}