// lib/domain/repositories/receita_repository.dart

import 'package:flutter_clinica_medica/infra/local/local_database.dart';
import 'package:flutter_clinica_medica/domain/models/receita.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class ReceitaRepository {
  final LocalDatabase _localDatabase = LocalDatabase();

  Future<Database> get _database async {
    if (_localDatabase.database == null || !_localDatabase.database!.isOpen) {
      await _localDatabase.openDb();
    }
    return _localDatabase.database!;
  }

  Future<int> insertReceita(Receita receita) async {
    final db = await _database;
    return await db.insert(
      'Receita',
      receita.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Receita>> getAllReceitas() async {
    final db = await _database;
    final List<Map<String, dynamic>> maps = await db.query('Receita');
    return List.generate(maps.length, (i) {
      return Receita.fromMap(maps[i]);
    });
  }

  Future<Receita?> getReceitaById(int id) async {
    final db = await _database;
    final List<Map<String, dynamic>> maps = await db.query(
      'Receita',
      where: 'idReceita = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return Receita.fromMap(maps.first);
    }
    return null;
  }

  Future<int> updateReceita(Receita receita) async {
    final db = await _database;
    return await db.update(
      'Receita',
      receita.toMap(),
      where: 'idReceita = ?',
      whereArgs: [receita.idReceita],
    );
  }

  Future<int> deleteReceita(int id) async {
    final db = await _database;
    return await db.delete(
      'Receita',
      where: 'idReceita = ?',
      whereArgs: [id],
    );
  }
}