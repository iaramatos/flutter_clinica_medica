import 'dart:io' show Platform; // Importa 'Platform' condicionalmente
import 'package:flutter/foundation.dart' show kIsWeb; // Importa kIsWeb

import 'package:flutter_clinica_medica/infra/local/sql.dart';
import 'package:path/path.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

// Para web, usaremos o sqflite_common_ffi_web, que utiliza IndexedDB
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart'; // Adicione esta linha

class LocalDatabase {
  Database? database;

  Future<void> openDb() async {
    // Verifica se estamos rodando na web
    if (kIsWeb) {
      // Para a web, use a factory de banco de dados baseada em IndexedDB
      databaseFactory = databaseFactoryFfiWeb;
    } else if (Platform.isWindows) {
      /* Inicializa as configurações da biblioteca SQLite para aplicações Desktop */
      sqfliteFfiInit();
      // Altera como o sistema cria o banco de dados na plataforma Desktop
      databaseFactory = databaseFactoryFfi;
    }
    // Você também pode adicionar um else if para Android/iOS se estiver usando sqflite tradicional
    // Se o seu pubspec.yaml tiver 'sqflite', ele já cuidará de Android/iOS automaticamente
    // else {
    //   // Para Android e iOS, o databaseFactory padrão do sqflite funciona
    //   // Nenhuma ação específica é necessária aqui se você tiver 'sqflite' no pubspec.yaml
    // }

    String path;
    if (kIsWeb) {
      // Para web, o path é virtual, o nome do banco de dados é suficiente
      path = "clinica_medica.db";
    } else {
      /* A função getDatabasesPath() recupera o local padrão de instalação
         da aplicação para o banco de dados. A função join, é utilizada para
         concatenar o diretório do banco com o nome do arquivo do banco de dados. */
      path = join(await getDatabasesPath(), "clinica_medica.db");
    }

    /* Cria a conexão com o banco de dados */
    /* O atributo version define a versão atual do banco de dados
       da aplicação. O atributo onCreate é responsável por gerenciar
       a criação das tabelas do banco de dados. */
    database = await openDatabase(
      path,
      onCreate: (db, version) => _createTable(db, version),
      version: 1,
    );
  }

  void _createTable(Database db, int version) {
    db.execute(sqlCreateTable);
  }

  Future<void> closeDatabase() async {
    /* Se a instância da conexão foi criada e a conexão
       está aberta, fecha a conexão com o banco. */
    if (database != null && database!.isOpen) {
      // Fecha a conexão com o banco
      await database!.close();
    }
  }
}