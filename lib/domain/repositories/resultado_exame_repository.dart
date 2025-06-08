// lib/domain/repositories/resultado_exame_repository.dart

import 'package:flutter_clinica_medica/infra/local/local_database.dart';
import 'package:flutter_clinica_medica/domain/models/resultado_exame.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class ResultadoExameRepository {
  final LocalDatabase _localDatabase = LocalDatabase();

  Future<Database> get _database async {
    if (_localDatabase.database == null || !_localDatabase.database!.isOpen) {
      await _localDatabase.openDb();
    }
    return _localDatabase.database!;
  }

  Future<int> insertResultadoExame(ResultadoExame resultadoExame) async {
    final db = await _database;
    return await db.insert(
      'ResultadoExame',
      resultadoExame.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<ResultadoExame>> getAllResultadosExames() async {
    final db = await _database;
    final List<Map<String, dynamic>> maps = await db.query('ResultadoExame');
    return List.generate(maps.length, (i) {
      return ResultadoExame.fromMap(maps[i]);
    });
  }

  Future<ResultadoExame?> getResultadoExameById(int id) async {
    final db = await _database;
    final List<Map<String, dynamic>> maps = await db.query(
      'ResultadoExame',
      where: 'idResultado = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return ResultadoExame.fromMap(maps.first);
    }
    return null;
  }

  Future<int> updateResultadoExame(ResultadoExame resultadoExame) async {
    final db = await _database;
    return await db.update(
      'ResultadoExame',
      resultadoExame.toMap(),
      where: 'idResultado = ?',
      whereArgs: [resultadoExame.idResultado],
    );
  }

  Future<int> deleteResultadoExame(int id) async {
    final db = await _database;
    return await db.delete(
      'ResultadoExame',
      where: 'idResultado = ?',
      whereArgs: [id],
    );
  }
}