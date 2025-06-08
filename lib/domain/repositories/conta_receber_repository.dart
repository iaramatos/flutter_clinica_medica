// lib/domain/repositories/conta_receber_repository.dart

import 'package:flutter_clinica_medica/infra/local/local_database.dart';
import 'package:flutter_clinica_medica/domain/models/conta_receber.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class ContaReceberRepository {
  final LocalDatabase _localDatabase = LocalDatabase();

  Future<Database> get _database async {
    if (_localDatabase.database == null || !_localDatabase.database!.isOpen) {
      await _localDatabase.openDb();
    }
    return _localDatabase.database!;
  }

  Future<int> insertContaReceber(ContaReceber contaReceber) async {
    final db = await _database;
    return await db.insert(
      'ContaReceber',
      contaReceber.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<ContaReceber>> getAllContasReceber() async {
    final db = await _database;
    final List<Map<String, dynamic>> maps = await db.query('ContaReceber');
    return List.generate(maps.length, (i) {
      return ContaReceber.fromMap(maps[i]);
    });
  }

  Future<ContaReceber?> getContaReceberById(int id) async {
    final db = await _database;
    final List<Map<String, dynamic>> maps = await db.query(
      'ContaReceber',
      where: 'idConta = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return ContaReceber.fromMap(maps.first);
    }
    return null;
  }

  Future<int> updateContaReceber(ContaReceber contaReceber) async {
    final db = await _database;
    return await db.update(
      'ContaReceber',
      contaReceber.toMap(),
      where: 'idConta = ?',
      whereArgs: [contaReceber.idConta],
    );
  }

  Future<int> deleteContaReceber(int id) async {
    final db = await _database;
    return await db.delete(
      'ContaReceber',
      where: 'idConta = ?',
      whereArgs: [id],
    );
  }
}