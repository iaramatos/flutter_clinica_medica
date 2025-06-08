// lib/domain/repositories/medicamento_repository.dart

import 'package:flutter_clinica_medica/infra/local/local_database.dart';
import 'package:flutter_clinica_medica/domain/models/medicamento.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class MedicamentoRepository {
  final LocalDatabase _localDatabase = LocalDatabase();

  Future<Database> get _database async {
    if (_localDatabase.database == null || !_localDatabase.database!.isOpen) {
      await _localDatabase.openDb();
    }
    return _localDatabase.database!;
  }

  Future<int> insertMedicamento(Medicamento medicamento) async {
    final db = await _database;
    return await db.insert(
      'Medicamento',
      medicamento.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Medicamento>> getAllMedicamentos() async {
    final db = await _database;
    final List<Map<String, dynamic>> maps = await db.query('Medicamento');
    return List.generate(maps.length, (i) {
      return Medicamento.fromMap(maps[i]);
    });
  }

  Future<Medicamento?> getMedicamentoById(int id) async {
    final db = await _database;
    final List<Map<String, dynamic>> maps = await db.query(
      'Medicamento',
      where: 'idMedicamento = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return Medicamento.fromMap(maps.first);
    }
    return null;
  }

  Future<int> updateMedicamento(Medicamento medicamento) async {
    final db = await _database;
    return await db.update(
      'Medicamento',
      medicamento.toMap(),
      where: 'idMedicamento = ?',
      whereArgs: [medicamento.idMedicamento],
    );
  }

  Future<int> deleteMedicamento(int id) async {
    final db = await _database;
    return await db.delete(
      'Medicamento',
      where: 'idMedicamento = ?',
      whereArgs: [id],
    );
  }
}