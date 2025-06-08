// lib/main.dart

import 'package:flutter/material.dart';
import 'package:flutter_clinica_medica/infra/local/local_database.dart';
import 'package:flutter_clinica_medica/presentation/paciente/paciente_form_screen.dart';
import 'package:flutter_clinica_medica/presentation/paciente/paciente_list_screen.dart';
import 'package:flutter_clinica_medica/presentation/profissional/profissional_form_screen.dart';
import 'package:flutter_clinica_medica/presentation/profissional/profissional_list_screen.dart';
import 'package:flutter_clinica_medica/presentation/consulta/consulta_form_screen.dart';
import 'package:flutter_clinica_medica/presentation/consulta/consulta_list_screen.dart';
import 'package:flutter_clinica_medica/presentation/medicamento/medicamento_form_screen.dart';
import 'package:flutter_clinica_medica/presentation/medicamento/medicamento_list_screen.dart';
import 'package:flutter_clinica_medica/presentation/receita/prescricao_form_screen.dart';
import 'package:flutter_clinica_medica/presentation/receita/prescricao_list_screen.dart';
import 'package:flutter_clinica_medica/presentation/financeiro/financeiro_form_screen.dart';
import 'package:flutter_clinica_medica/presentation/home/main_dashboard_screen.dart';

// ADICIONE ESTES DOIS IMPORTS PARA LOCALIZAÇÃO
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart'; // Mantenha este import, pois ele já é usado para formatação de data

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); 

  final LocalDatabase localDatabase = LocalDatabase(); 
  await localDatabase.openDb(); 

  print('Banco de dados da clínica aberto com sucesso!'); 

  // --- CÓDIGO TEMPORÁRIO PARA TESTE DE INSERÇÃO (REMOVER DEPOIS DA IT4) ---
  // Mantenha os de paciente e profissional se ainda não tiver dados de teste
  // Remova-os ou comente-os após ter dados suficientes para testar
  // Exemplo de como você poderia inserir dados de teste se necessário:
  /*
  import 'package:flutter_clinica_medica/domain/models/paciente.dart';
  import 'package:flutter_clinica_medica/domain/repositories/paciente_repository.dart';
  import 'package:flutter_clinica_medica/domain/models/profissional.dart';
  import 'package:flutter_clinica_medica/domain/repositories/profissional_repository.dart';

  final pacienteRepo = PacienteRepository();
  final profissionalRepo = ProfissionalRepository();
  try {
    // Inserir Paciente de Teste
    final existingPaciente = await pacienteRepo.getPacienteById(1);
    if (existingPaciente == null) {
      final testPaciente = Paciente(
        nome: 'Paciente Teste Maria Silva',
        cpf: '111.111.111-11',
        dataNascimento: DateTime(1990, 5, 15),
        telefone: '999999999',
        email: 'maria.silva@email.com',
        endereco: 'Rua A, 123',
        convenio: 'Particular',
      );
      await pacienteRepo.insertPaciente(testPaciente);
      print('Paciente de teste inserido com sucesso!');
    } else {
      print('Paciente de teste já existe.');
    }

    // Inserir Profissional de Teste
    final existingProfissional = await profissionalRepo.getProfissionalById(1);
    if (existingProfissional == null) {
      final testProfissional = Profissional(
        nome: 'Profissional Teste Dr. João',
        especialidade: 'Clínico Geral',
        registro: 'CRM/XX 12345',
        email: 'joao@clinica.com',
        telefone: '987654321',
        tipoUsuario: 'medico',
      );
      await profissionalRepo.insertProfissional(testProfissional);
      print('Profissional de teste inserido com sucesso!');
    } else {
      print('Profissional de teste já existe.');
    }
  } catch (e) {
    print('Erro durante inserção de dados de teste: $e');
  }
  */
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
      // --- ADICIONE ESTAS LINHAS AQUI PARA LOCALIZAÇÃO ---
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate, // Necessário para iOS-style widgets
      ],
      supportedLocales: const [
        Locale('en', ''), // Inglês
        Locale('pt', 'BR'), // Português do Brasil
      ],
      // --- FIM DAS LINHAS A SEREM ADICIONADAS ---
      initialRoute: MainDashboardScreen.routeName,
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

        // Rotas de Medicamento e Prescrição
        MedicamentoListScreen.routeName: (context) => const MedicamentoListScreen(),
        MedicamentoFormScreen.routeName: (context) => const MedicamentoFormScreen(),
        PrescricaoFormScreen.routeName: (context) => const PrescricaoFormScreen(),
        PrescricaoListScreen.routeName: (context) => const PrescricaoListScreen(),

        // Rotas Financeiras
        FinanceiroFormScreen.routeName: (context) => const FinanceiroFormScreen(),

        // Rota do Dashboard Principal
        MainDashboardScreen.routeName: (context) => const MainDashboardScreen(),
      },
    );
  }
}