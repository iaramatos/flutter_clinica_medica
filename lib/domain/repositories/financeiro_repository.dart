// lib/domain/repositories/financeiro_repository.dart

import 'package:flutter_clinica_medica/infra/local/local_database.dart';
import 'package:flutter_clinica_medica/domain/models/financeiro.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class FinanceiroRepository {
  final LocalDatabase _localDatabase = LocalDatabase();

  Future<Database> get _database async {
    if (_localDatabase.database == null || !_localDatabase.database!.isOpen) {
      await _localDatabase.openDb();
    }
    return _localDatabase.database!;
  }

  Future<int> insertFinanceiro(Financeiro financeiro) async {
    final db = await _database;
    return await db.insert(
      'Financeiro',
      financeiro.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Financeiro>> getAllFinanceiros() async {
    final db = await _database;
    final List<Map<String, dynamic>> maps = await db.query('Financeiro');
    return List.generate(maps.length, (i) {
      return Financeiro.fromMap(maps[i]);
    });
  }

  Future<Financeiro?> getFinanceiroById(int id) async {
    final db = await _database;
    final List<Map<String, dynamic>> maps = await db.query(
      'Financeiro',
      where: 'idFinanceiro = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return Financeiro.fromMap(maps.first);
    }
    return null;
  }

  Future<int> updateFinanceiro(Financeiro financeiro) async {
    final db = await _database;
    return await db.update(
      'Financeiro',
      financeiro.toMap(),
      where: 'idFinanceiro = ?',
      whereArgs: [financeiro.idFinanceiro],
    );
  }

  Future<int> deleteFinanceiro(int id) async {
    final db = await _database;
    return await db.delete(
      'Financeiro',
      where: 'idFinanceiro = ?',
      whereArgs: [id],
    );
  }
}