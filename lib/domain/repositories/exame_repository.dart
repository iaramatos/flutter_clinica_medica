// lib/domain/repositories/exame_repository.dart

import 'package:flutter_clinica_medica/infra/local/local_database.dart';
import 'package:flutter_clinica_medica/domain/models/exame.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class ExameRepository {
  final LocalDatabase _localDatabase = LocalDatabase();

  Future<Database> get _database async {
    if (_localDatabase.database == null || !_localDatabase.database!.isOpen) {
      await _localDatabase.openDb();
    }
    return _localDatabase.database!;
  }

  Future<int> insertExame(Exame exame) async {
    final db = await _database;
    return await db.insert(
      'Exame',
      exame.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Exame>> getAllExames() async {
    final db = await _database;
    final List<Map<String, dynamic>> maps = await db.query('Exame');
    return List.generate(maps.length, (i) {
      return Exame.fromMap(maps[i]);
    });
  }

  Future<Exame?> getExameById(int id) async {
    final db = await _database;
    final List<Map<String, dynamic>> maps = await db.query(
      'Exame',
      where: 'idExame = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return Exame.fromMap(maps.first);
    }
    return null;
  }

  Future<int> updateExame(Exame exame) async {
    final db = await _database;
    return await db.update(
      'Exame',
      exame.toMap(),
      where: 'idExame = ?',
      whereArgs: [exame.idExame],
    );
  }

  Future<int> deleteExame(int id) async {
    final db = await _database;
    return await db.delete(
      'Exame',
      where: 'idExame = ?',
      whereArgs: [id],
    );
  }
}