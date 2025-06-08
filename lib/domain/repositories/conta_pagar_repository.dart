// lib/domain/repositories/conta_pagar_repository.dart

import 'package:flutter_clinica_medica/infra/local/local_database.dart';
import 'package:flutter_clinica_medica/domain/models/conta_pagar.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class ContaPagarRepository {
  final LocalDatabase _localDatabase = LocalDatabase();

  Future<Database> get _database async {
    if (_localDatabase.database == null || !_localDatabase.database!.isOpen) {
      await _localDatabase.openDb();
    }
    return _localDatabase.database!;
  }

  Future<int> insertContaPagar(ContaPagar contaPagar) async {
    final db = await _database;
    return await db.insert(
      'ContaPagar',
      contaPagar.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<ContaPagar>> getAllContasPagar() async {
    final db = await _database;
    final List<Map<String, dynamic>> maps = await db.query('ContaPagar');
    return List.generate(maps.length, (i) {
      return ContaPagar.fromMap(maps[i]);
    });
  }

  Future<ContaPagar?> getContaPagarById(int id) async {
    final db = await _database;
    final List<Map<String, dynamic>> maps = await db.query(
      'ContaPagar',
      where: 'idConta = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return ContaPagar.fromMap(maps.first);
    }
    return null;
  }

  Future<int> updateContaPagar(ContaPagar contaPagar) async {
    final db = await _database;
    return await db.update(
      'ContaPagar',
      contaPagar.toMap(),
      where: 'idConta = ?',
      whereArgs: [contaPagar.idConta],
    );
  }

  Future<int> deleteContaPagar(int id) async {
    final db = await _database;
    return await db.delete(
      'ContaPagar',
      where: 'idConta = ?',
      whereArgs: [id],
    );
  }
}