// lib/utils/password_util.dart

import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';

class PasswordUtil {
  // Gera um salt aleatório
  static String generateSalt() {
    final random = Random.secure();
    final saltBytes = List<int>.generate(16, (_) => random.nextInt(256));
    return base64Encode(saltBytes);
  }

  // Gera o hash da senha usando SHA-256 e um salt
  static String hashPassword(String password, String salt) {
    final key = utf8.encode(password + salt);
    final bytes = sha256.convert(key).bytes;
    return base64Encode(bytes);
  }

  // Verifica se a senha fornecida corresponde ao hash armazenado
  static bool verifyPassword(String password, String storedHash, String storedSalt) {
    final hashedPassword = hashPassword(password, storedSalt);
    return hashedPassword == storedHash;
  }
}