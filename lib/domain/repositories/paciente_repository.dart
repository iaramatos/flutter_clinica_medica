// lib/domain/repositories/paciente_repository.dart

import 'package:flutter_clinica_medica/infra/local/local_database.dart';
import 'package:flutter_clinica_medica/domain/models/paciente.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class PacienteRepository {
  final LocalDatabase _localDatabase = LocalDatabase();

  Future<Database> get _database async {
    if (_localDatabase.database == null || !_localDatabase.database!.isOpen) {
      await _localDatabase.openDb();
    }
    return _localDatabase.database!;
  }

  Future<int> insertPaciente(Paciente paciente) async {
    final db = await _database;
    return await db.insert(
      'Paciente',
      paciente.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Paciente>> getAllPacientes() async {
    final db = await _database;
    final List<Map<String, dynamic>> maps = await db.query('Paciente');
    return List.generate(maps.length, (i) {
      return Paciente.fromMap(maps[i]);
    });
  }

  Future<Paciente?> getPacienteById(int id) async {
    final db = await _database;
    final List<Map<String, dynamic>> maps = await db.query(
      'Paciente',
      where: 'idPaciente = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return Paciente.fromMap(maps.first);
    }
    return null;
  }

  Future<int> updatePaciente(Paciente paciente) async {
    final db = await _database;
    return await db.update(
      'Paciente',
      paciente.toMap(),
      where: 'idPaciente = ?',
      whereArgs: [paciente.idPaciente],
    );
  }

  Future<int> deletePaciente(int id) async {
    final db = await _database;
    return await db.delete(
      'Paciente',
      where: 'idPaciente = ?',
      whereArgs: [id],
    );
  }
}