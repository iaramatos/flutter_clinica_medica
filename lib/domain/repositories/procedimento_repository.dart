// lib/domain/repositories/procedimento_repository.dart

import 'package:flutter_clinica_medica/infra/local/local_database.dart';
import 'package:flutter_clinica_medica/domain/models/procedimento.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class ProcedimentoRepository {
  final LocalDatabase _localDatabase = LocalDatabase();

  Future<Database> get _database async {
    if (_localDatabase.database == null || !_localDatabase.database!.isOpen) {
      await _localDatabase.openDb();
    }
    return _localDatabase.database!;
  }

  Future<int> insertProcedimento(Procedimento procedimento) async {
    final db = await _database;
    return await db.insert(
      'Procedimento',
      procedimento.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Procedimento>> getAllProcedimentos() async {
    final db = await _database;
    final List<Map<String, dynamic>> maps = await db.query('Procedimento');
    return List.generate(maps.length, (i) {
      return Procedimento.fromMap(maps[i]);
    });
  }

  Future<Procedimento?> getProcedimentoById(int id) async {
    final db = await _database;
    final List<Map<String, dynamic>> maps = await db.query(
      'Procedimento',
      where: 'idProcedimento = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return Procedimento.fromMap(maps.first);
    }
    return null;
  }

  Future<int> updateProcedimento(Procedimento procedimento) async {
    final db = await _database;
    return await db.update(
      'Procedimento',
      procedimento.toMap(),
      where: 'idProcedimento = ?',
      whereArgs: [procedimento.idProcedimento],
    );
  }

  Future<int> deleteProcedimento(int id) async {
    final db = await _database;
    return await db.delete(
      'Procedimento',
      where: 'idProcedimento = ?',
      whereArgs: [id],
    );
  }
}