// lib/main.dart

import 'package:flutter/material.dart';
import 'package:flutter_clinica_medica/infra/local/local_database.dart';
import 'package:flutter_clinica_medica/presentation/paciente/paciente_form_screen.dart'; // NOVO IMPORT: Tela de formulário de paciente
import 'package:flutter_clinica_medica/presentation/paciente/paciente_list_screen.dart'; // NOVO IMPORT: Tela de listagem de paciente

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); 

  final LocalDatabase localDatabase = LocalDatabase(); 
  await localDatabase.openDb(); 

  print('Banco de dados da clínica aberto com sucesso!'); 

  runApp(const ClinicaMedicaApp());
}

class ClinicaMedicaApp extends StatelessWidget {
  const ClinicaMedicaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sistema de Gestão de Clínica Médica',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      initialRoute: PacienteListScreen.routeName, 
      routes: {
        // Configura as rotas nomeadas para as telas de paciente
        PacienteListScreen.routeName: (context) => const PacienteListScreen(),
        PacienteFormScreen.routeName: (context) => const PacienteFormScreen(),
        // Você adicionará outras rotas aqui conforme desenvolver mais módulos
      },
    );
  }
}
