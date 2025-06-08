// lib/main.dart

import 'package:flutter/material.dart';
import 'package:flutter_clinica_medica/infra/local/local_database.dart';
import 'package:flutter_clinica_medica/presentation/consulta/consulta_form_screen.dart';
import 'package:flutter_clinica_medica/presentation/consulta/consulta_list_screen.dart';
// ...

import 'package:flutter_clinica_medica/presentation/paciente/paciente_form_screen.dart';
import 'package:flutter_clinica_medica/presentation/paciente/paciente_list_screen.dart';
import 'package:flutter_clinica_medica/presentation/profissional/profissional_form_screen.dart';
import 'package:flutter_clinica_medica/presentation/profissional/profissional_list_screen.dart';

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
      initialRoute: ConsultaListScreen
          .routeName, // Ou PacienteListScreen.routeName para testar pacientes
      routes: {
        PacienteListScreen.routeName: (context) => const PacienteListScreen(),
        PacienteFormScreen.routeName: (context) => const PacienteFormScreen(),
        ConsultaListScreen.routeName: (context) => const ConsultaListScreen(),
        ConsultaFormScreen.routeName: (context) => const ConsultaFormScreen(),
        ProfissionalListScreen.routeName: (context) =>
            const ProfissionalListScreen(),
        ProfissionalFormScreen.routeName: (context) =>
            const ProfissionalFormScreen(),
      },
    );
  }
}
