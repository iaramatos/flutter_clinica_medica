// lib/domain/repositories/prescricao_medicamento_repository.dart

import 'package:flutter_clinica_medica/infra/local/local_database.dart';
import 'package:flutter_clinica_medica/domain/models/prescricao_medicamento.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class PrescricaoMedicamentoRepository {
  final LocalDatabase _localDatabase = LocalDatabase();

  Future<Database> get _database async {
    if (_localDatabase.database == null || !_localDatabase.database!.isOpen) {
      await _localDatabase.openDb();
    }
    return _localDatabase.database!;
  }

  Future<int> insertPrescricaoMedicamento(PrescricaoMedicamento prescricaoMedicamento) async {
    final db = await _database;
    return await db.insert(
      'PrescricaoMedicamento',
      prescricaoMedicamento.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<PrescricaoMedicamento>> getAllPrescricaoMedicamentos() async {
    final db = await _database;
    final List<Map<String, dynamic>> maps = await db.query('PrescricaoMedicamento');
    return List.generate(maps.length, (i) {
      return PrescricaoMedicamento.fromMap(maps[i]);
    });
  }

  Future<PrescricaoMedicamento?> getPrescricaoMedicamentoById(int id) async {
    final db = await _database;
    final List<Map<String, dynamic>> maps = await db.query(
      'PrescricaoMedicamento',
      where: 'idPrescricao = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return PrescricaoMedicamento.fromMap(maps.first);
    }
    return null;
  }

  Future<int> updatePrescricaoMedicamento(PrescricaoMedicamento prescricaoMedicamento) async {
    final db = await _database;
    return await db.update(
      'PrescricaoMedicamento',
      prescricaoMedicamento.toMap(),
      where: 'idPrescricao = ?',
      whereArgs: [prescricaoMedicamento.idPrescricao],
    );
  }

  Future<int> deletePrescricaoMedicamento(int id) async {
    final db = await _database;
    return await db.delete(
      'PrescricaoMedicamento',
      where: 'idPrescricao = ?',
      whereArgs: [id],
    );
  }
}