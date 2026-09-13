import 'dart:convert';

import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Device-local AES-256 key stored in the OS keystore / Keychain.
/// Health payloads never leave the device unencrypted.
class EncryptionService {
  EncryptionService({FlutterSecureStorage? storage})
      : _storage = storage ??
            const FlutterSecureStorage(
              aOptions: AndroidOptions(encryptedSharedPreferences: true),
              iOptions: IOSOptions(
                accessibility: KeychainAccessibility.first_unlock_this_device,
              ),
            );

  static const _keyName = 'fitpro_aes_256_key';
  final FlutterSecureStorage _storage;
  encrypt.Key? _cachedKey;

  Future<void> initialize() async {
    await _loadOrCreateKey();
  }

  Future<encrypt.Key> _loadOrCreateKey() async {
    if (_cachedKey != null) return _cachedKey!;
    var stored = await _storage.read(key: _keyName);
    if (stored == null) {
      final generated = encrypt.Key.fromSecureRandom(32);
      stored = generated.base64;
      await _storage.write(key: _keyName, value: stored);
    }
    _cachedKey = encrypt.Key.fromBase64(stored);
    return _cachedKey!;
  }

  String encryptJson(Map<String, dynamic> payload) {
    final key = _cachedKey;
    if (key == null) {
      throw StateError('EncryptionService.initialize() must run first');
    }
    final iv = encrypt.IV.fromSecureRandom(16);
    final encrypter = encrypt.Encrypter(encrypt.AES(key, mode: encrypt.AESMode.cbc));
    final cipher = encrypter.encrypt(jsonEncode(payload), iv: iv);
    return '${iv.base64}:${cipher.base64}';
  }

  Map<String, dynamic> decryptJson(String blob) {
    final key = _cachedKey;
    if (key == null) {
      throw StateError('EncryptionService.initialize() must run first');
    }
    final parts = blob.split(':');
    if (parts.length != 2) {
      throw const FormatException('Malformed encrypted blob');
    }
    final iv = encrypt.IV.fromBase64(parts[0]);
    final encrypter = encrypt.Encrypter(encrypt.AES(key, mode: encrypt.AESMode.cbc));
    final plain = encrypter.decrypt64(parts[1], iv: iv);
    return jsonDecode(plain) as Map<String, dynamic>;
  }
}
