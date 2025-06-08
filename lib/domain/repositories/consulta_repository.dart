// lib/domain/repositories/consulta_repository.dart

import 'package:flutter_clinica_medica/infra/local/local_database.dart';
import 'package:flutter_clinica_medica/domain/models/consulta.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class ConsultaRepository {
  final LocalDatabase _localDatabase = LocalDatabase();

  Future<Database> get _database async {
    if (_localDatabase.database == null || !_localDatabase.database!.isOpen) {
      await _localDatabase.openDb();
    }
    return _localDatabase.database!;
  }

  Future<int> insertConsulta(Consulta consulta) async {
    final db = await _database;
    return await db.insert(
      'Consulta',
      consulta.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Consulta>> getAllConsultas() async {
    final db = await _database;
    // Exemplo de JOIN para pegar dados relacionados (Paciente e Profissional)
    // Para um sistema real, você pode precisar de métodos mais complexos para buscar dados relacionados.
    final List<Map<String, dynamic>> maps = await db.rawQuery('''
      SELECT
        C.*,
        P.nome AS paciente_nome,
        PR.nome AS profissional_nome
      FROM Consulta AS C
      LEFT JOIN Paciente AS P ON C.idPaciente = P.idPaciente
      LEFT JOIN Profissional AS PR ON C.idProfissional = PR.idProfissional
    ''');

    return List.generate(maps.length, (i) {
      // Aqui você pode criar um modelo mais rico se precisar de dados do paciente/profissional diretamente na consulta
      // Por enquanto, apenas retorna a Consulta pura
      return Consulta.fromMap(maps[i]);
    });
  }

  Future<Consulta?> getConsultaById(int id) async {
    final db = await _database;
    final List<Map<String, dynamic>> maps = await db.query(
      'Consulta',
      where: 'idConsulta = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return Consulta.fromMap(maps.first);
    }
    return null;
  }

  Future<int> updateConsulta(Consulta consulta) async {
    final db = await _database;
    return await db.update(
      'Consulta',
      consulta.toMap(),
      where: 'idConsulta = ?',
      whereArgs: [consulta.idConsulta],
    );
  }

  Future<int> deleteConsulta(int id) async {
    final db = await _database;
    return await db.delete(
      'Consulta',
      where: 'idConsulta = ?',
      whereArgs: [id],
    );
  }
}