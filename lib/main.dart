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
import 'package:flutter_clinica_medica/presentation/sala/sala_form_screen.dart'; // NOVO IMPORT: Form de Sala
import 'package:flutter_clinica_medica/presentation/sala/sala_list_screen.dart'; // NOVO IMPORT: Lista de Sala
import 'package:flutter_clinica_medica/presentation/exame/exame_list_screen.dart'; // NOVO IMPORT: Lista de Tipos de Exame
import 'package:flutter_clinica_medica/presentation/exame/resultado_exame_form_screen.dart'; // NOVO IMPORT: Form de Resultado de Exame
import 'package:flutter_clinica_medica/presentation/exame/resultado_exame_list_screen.dart'; // NOVO IMPORT: Lista de Resultados de Exame

// IMPORTS PARA LOCALIZAÇÃO
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart'; // Mantenha este import, pois ele já é usado para formatação de data

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final LocalDatabase localDatabase = LocalDatabase();
  await localDatabase.openDb();

  print('Banco de dados da clínica aberto com sucesso!');

  // --- CÓDIGO TEMPORÁRIO PARA TESTE DE INSERÇÃO (REMOVER DEPOIS DA IT4/Release 1) ---
  // Mantenha os de paciente e profissional se ainda não tiver dados de teste
  // Remova-os ou comente-os após ter dados suficientes para testar
  /*
  import 'package:flutter_clinica_medica/domain/models/paciente.dart';
  import 'package:flutter_clinica_medica/domain/repositories/paciente_repository.dart';
  import 'package:flutter_clinica_medica/domain/models/profissional.dart';
  import 'package:flutter_clinica_medica/domain/repositories/profissional_repository.dart';
  import 'package:flutter_clinica_medica/domain/models/sala.dart';
  import 'package:flutter_clinica_medica/domain/repositories/sala_repository.dart';
  import 'package:flutter_clinica_medica/domain/models/exame.dart';
  import 'package:flutter_clinica_medica/domain/repositories/exame_repository.dart';


  final pacienteRepo = PacienteRepository();
  final profissionalRepo = ProfissionalRepository();
  final salaRepo = SalaRepository();
  final exameRepo = ExameRepository();

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
        alergias: 'Nenhuma',
        condicoesPreExistentes: 'Asma'
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

    // Inserir Sala de Teste
    final existingSala = await salaRepo.getSalaById(1);
    if (existingSala == null) {
      final testSala = Sala(
        nome: 'Consultório 1',
        tipo: 'Consultório',
        capacidade: 1
      );
      await salaRepo.insertSala(testSala);
      print('Sala de teste inserida com sucesso!');
    } else {
      print('Sala de teste já existe.');
    }

    // Inserir Exame de Teste
    final existingExame = await exameRepo.getExameById(1);
    if (existingExame == null) {
      final testExame = Exame(
        nome: 'Hemograma Completo',
        descricao: 'Exame de sangue para contagem de células.'
      );
      await exameRepo.insertExame(testExame);
      print('Exame de teste inserido com sucesso!');
    } else {
      print('Exame de teste já existe.');
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
      // CONFIGURAÇÕES DE LOCALIZAÇÃO (ESSENCIAL PARA DATE/TIME PICKERS)
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en', ''), // Inglês
        Locale('pt', 'BR'), // Português do Brasil
      ],
      // Rota inicial do aplicativo (Dashboard)
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

        // Rotas de Salas
        SalaListScreen.routeName: (context) => const SalaListScreen(),
        SalaFormScreen.routeName: (context) => const SalaFormScreen(), // Opcional, se precisar de rota direta

        // Rotas de Exames e Resultados de Exames
        ExameListScreen.routeName: (context) => const ExameListScreen(),
        ResultadoExameFormScreen.routeName: (context) => const ResultadoExameFormScreen(),
        ResultadoExameListScreen.routeName: (context) => const ResultadoExameListScreen(),

        // Rota do Dashboard Principal
        MainDashboardScreen.routeName: (context) => const MainDashboardScreen(),
      },
    );
  }
}