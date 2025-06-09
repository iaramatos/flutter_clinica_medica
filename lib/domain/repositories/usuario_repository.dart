// lib/domain/repositories/usuario_repository.dart

import 'package:flutter_clinica_medica/infra/local/local_database.dart';
import 'package:flutter_clinica_medica/domain/models/usuario.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class UsuarioRepository {
  final LocalDatabase _localDatabase = LocalDatabase();

  Future<Database> get _database async {
    if (_localDatabase.database == null || !_localDatabase.database!.isOpen) {
      await _localDatabase.openDb();
    }
    return _localDatabase.database!;
  }

  Future<int> insertUsuario(Usuario usuario) async {
    final db = await _database;
    return await db.insert(
      'Usuario',
      usuario.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Usuario>> getAllUsuarios() async {
    final db = await _database;
    final List<Map<String, dynamic>> maps = await db.query('Usuario');
    return List.generate(maps.length, (i) {
      return Usuario.fromMap(maps[i]);
    });
  }

  Future<Usuario?> getUsuarioById(int id) async {
    final db = await _database;
    final List<Map<String, dynamic>> maps = await db.query(
      'Usuario',
      where: 'idUsuario = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return Usuario.fromMap(maps.first);
    }
    return null;
  }

  // Método para buscar usuário por username (para login)
  Future<Usuario?> getUsuarioByUsername(String username) async {
    final db = await _database;
    final List<Map<String, dynamic>> maps = await db.query(
      'Usuario',
      where: 'username = ?',
      whereArgs: [username],
    );
    if (maps.isNotEmpty) {
      return Usuario.fromMap(maps.first);
    }
    return null;
  }

  Future<int> updateUsuario(Usuario usuario) async {
    final db = await _database;
    return await db.update(
      'Usuario',
      usuario.toMap(),
      where: 'idUsuario = ?',
      whereArgs: [usuario.idUsuario],
    );
  }

  Future<int> deleteUsuario(int id) async {
    final db = await _database;
    return await db.delete(
      'Usuario',
      where: 'idUsuario = ?',
      whereArgs: [id],
    );
  }
}