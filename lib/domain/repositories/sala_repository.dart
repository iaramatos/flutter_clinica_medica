// lib/domain/repositories/sala_repository.dart

import 'package:flutter_clinica_medica/infra/local/local_database.dart';
import 'package:flutter_clinica_medica/domain/models/sala.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class SalaRepository {
  final LocalDatabase _localDatabase = LocalDatabase();

  Future<Database> get _database async {
    if (_localDatabase.database == null || !_localDatabase.database!.isOpen) {
      await _localDatabase.openDb();
    }
    return _localDatabase.database!;
  }

  Future<int> insertSala(Sala sala) async {
    final db = await _database;
    return await db.insert(
      'Sala',
      sala.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Sala>> getAllSalas() async {
    final db = await _database;
    final List<Map<String, dynamic>> maps = await db.query('Sala');
    return List.generate(maps.length, (i) {
      return Sala.fromMap(maps[i]);
    });
  }

  Future<Sala?> getSalaById(int id) async {
    final db = await _database;
    final List<Map<String, dynamic>> maps = await db.query(
      'Sala',
      where: 'idSala = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return Sala.fromMap(maps.first);
    }
    return null;
  }

  Future<int> updateSala(Sala sala) async {
    final db = await _database;
    return await db.update(
      'Sala',
      sala.toMap(),
      where: 'idSala = ?',
      whereArgs: [sala.idSala],
    );
  }

  Future<int> deleteSala(int id) async {
    final db = await _database;
    return await db.delete(
      'Sala',
      where: 'idSala = ?',
      whereArgs: [id],
    );
  }
}