// lib/main.dart

import 'package:flutter/material.dart';
import 'package:flutter_clinica_medica/infra/local/local_database.dart'; // CORRIGIDO O NOME DO PACOTE

void main() async {
  // Garante que o Flutter esteja inicializado antes de operações assíncronas.
  WidgetsFlutterBinding.ensureInitialized();

  final LocalDatabase localDatabase = LocalDatabase();
  await localDatabase.openDb(); // Abre o banco de dados

  // Opcional: Adicione um print para confirmar que o banco de dados foi aberto.
  print('Banco de dados da clínica aberto com sucesso!');

  runApp(
      const ClinicaMedicaApp()); // Alterado o nome da classe principal para ser mais descritivo
}

class ClinicaMedicaApp extends StatelessWidget {
  // Renomeado de MainApp para ClinicaMedicaApp
  const ClinicaMedicaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sistema de Gestão de Clínica Médica', // Título para o aplicativo
      debugShowCheckedModeBanner: false, // Oculta a faixa de "Debug"
      theme: ThemeData(
        primarySwatch: Colors.blue, // Cor primária (exemplo)
        colorScheme:
            ColorScheme.fromSeed(seedColor: Colors.blue), // Esquema de cores
        useMaterial3: true,
      ),
      home:
          const HomeScreenClinica(), // Define uma tela inicial simples para começar
      // As rotas antigas foram removidas. Você definirá novas rotas para cada módulo da clínica.
      // routes : routes, // Remover esta linha
    );
  }
}

// Uma tela de exemplo simples para garantir que o aplicativo inicie e exiba algo
class HomeScreenClinica extends StatelessWidget {
  const HomeScreenClinica({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bem-vindo à Clínica Médica'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const <Widget>[
            Text(
              'Sistema de Gestão de Clínica Médica',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),
            Text(
              'A base está configurada! Agora, vamos construir os módulos do seu sistema (Prontuários, Agendamentos, etc.).',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
            // Aqui você pode adicionar botões ou navegação para as primeiras telas dos seus módulos.
          ],
        ),
      ),
    );
  }
}
