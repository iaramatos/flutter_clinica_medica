// lib/main.dart

import 'package:flutter/material.dart';
import 'package:flutter_clinica_medica/infra/local/local_database.dart';
import 'package:flutter_clinica_medica/presentation/paciente/paciente_form_screen.dart';
import 'package:flutter_clinica_medica/presentation/paciente/paciente_list_screen.dart';
import 'package:flutter_clinica_medica/presentation/consulta/consulta_form_screen.dart';
import 'package:flutter_clinica_medica/presentation/consulta/consulta_list_screen.dart';
import 'package:flutter_clinica_medica/presentation/profissional/profissional_form_screen.dart';
import 'package:flutter_clinica_medica/presentation/profissional/profissional_list_screen.dart';
// IMPORTS DA IT. 3 EXISTENTES
import 'package:flutter_clinica_medica/presentation/medicamento/medicamento_form_screen.dart';
import 'package:flutter_clinica_medica/presentation/medicamento/medicamento_list_screen.dart';
import 'package:flutter_clinica_medica/presentation/receita/prescricao_form_screen.dart';
import 'package:flutter_clinica_medica/presentation/financeiro/financeiro_form_screen.dart';
import 'package:flutter_clinica_medica/presentation/home/iteration3_menu_screen.dart';
// NOVO IMPORT PARA A LISTAGEM DE PRESCRIÇÃO
import 'package:flutter_clinica_medica/presentation/receita/prescricao_list_screen.dart'; 


void main() async {
  WidgetsFlutterBinding.ensureInitialized(); 

  final LocalDatabase localDatabase = LocalDatabase(); 
  await localDatabase.openDb(); 

  print('Banco de dados da clínica aberto com sucesso!'); 

  // --- CÓDIGO TEMPORÁRIO PARA TESTE DE INSERÇÃO (REMOVER DEPOIS!) ---
  // Mantenha os de paciente e profissional se ainda não tiver dados de teste
  // Remova-os ou comente-os após ter dados suficientes para testar
  // ... (código para inserir Paciente e Profissional de teste)
  // --- FIM DO CÓDIGO TEMPORÁRIO ---

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
      initialRoute: Iteration3MenuScreen.routeName, // Mantém o menu da Iteração 3 como inicial
      routes: {
        // Rotas de Paciente
        PacienteListScreen.routeName: (context) => const PacienteListScreen(),
        PacienteFormScreen.routeName: (context) => const PacienteFormScreen(),

        // Rotas de Profissional
        ProfissionalListScreen.routeName: (context) => const ProfissionalListScreen(),
        ProfissionalFormScreen.routeName: (context) => const ProfissionalFormScreen(),

        // Rotas de Consulta
        ConsultaListScreen.routeName: (context) => const ConsultaListScreen(),
        ConsultaFormScreen.routeName: (context) => const ConsultaFormScreen(),

        // ROTAS DA ITERAÇÃO 3
        MedicamentoListScreen.routeName: (context) => const MedicamentoListScreen(),
        MedicamentoFormScreen.routeName: (context) => const MedicamentoFormScreen(),
        PrescricaoFormScreen.routeName: (context) => const PrescricaoFormScreen(),
        FinanceiroFormScreen.routeName: (context) => const FinanceiroFormScreen(),
        Iteration3MenuScreen.routeName: (context) => const Iteration3MenuScreen(),

        // NOVA ROTA: LISTAGEM DE PRESCRIÇÕES
        PrescricaoListScreen.routeName: (context) => const PrescricaoListScreen(),
      },
    );
  }
}