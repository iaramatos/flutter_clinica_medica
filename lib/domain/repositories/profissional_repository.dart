// lib/domain/repositories/profissional_repository.dart

import 'package:flutter_clinica_medica/infra/local/local_database.dart';
import 'package:flutter_clinica_medica/domain/models/profissional.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class ProfissionalRepository {
  final LocalDatabase _localDatabase = LocalDatabase();

  Future<Database> get _database async {
    if (_localDatabase.database == null || !_localDatabase.database!.isOpen) {
      await _localDatabase.openDb();
    }
    return _localDatabase.database!;
  }

  Future<int> insertProfissional(Profissional profissional) async {
    final db = await _database;
    return await db.insert(
      'Profissional',
      profissional.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Profissional>> getAllProfissionais() async {
    final db = await _database;
    final List<Map<String, dynamic>> maps = await db.query('Profissional');
    return List.generate(maps.length, (i) {
      return Profissional.fromMap(maps[i]);
    });
  }

  Future<Profissional?> getProfissionalById(int id) async {
    final db = await _database;
    final List<Map<String, dynamic>> maps = await db.query(
      'Profissional',
      where: 'idProfissional = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return Profissional.fromMap(maps.first);
    }
    return null;
  }

  Future<int> updateProfissional(Profissional profissional) async {
    final db = await _database;
    return await db.update(
      'Profissional',
      profissional.toMap(),
      where: 'idProfissional = ?',
      whereArgs: [profissional.idProfissional],
    );
  }

  Future<int> deleteProfissional(int id) async {
    final db = await _database;
    return await db.delete(
      'Profissional',
      where: 'idProfissional = ?',
      whereArgs: [id],
    );
  }
}