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
import 'package:flutter_clinica_medica/presentation/sala/sala_form_screen.dart';
import 'package:flutter_clinica_medica/presentation/sala/sala_list_screen.dart';
import 'package:flutter_clinica_medica/presentation/exame/exame_list_screen.dart';
import 'package:flutter_clinica_medica/presentation/exame/resultado_exame_form_screen.dart';
import 'package:flutter_clinica_medica/presentation/exame/resultado_exame_list_screen.dart';

// IMPORTS PARA A IT. 7 - CONTAS E RELATÓRIOS
import 'package:flutter_clinica_medica/presentation/contas/conta_receber_form_screen.dart';
import 'package:flutter_clinica_medica/presentation/contas/conta_receber_list_screen.dart';
import 'package:flutter_clinica_medica/presentation/contas/conta_pagar_form_screen.dart';
import 'package:flutter_clinica_medica/presentation/contas/conta_pagar_list_screen.dart';
import 'package:flutter_clinica_medica/presentation/contas/relatorio_financeiro_screen.dart';

// NOVOS IMPORTS PARA AUTENTICAÇÃO (ITERAÇÃO 8)
import 'package:flutter_clinica_medica/presentation/auth/login_screen.dart';
import 'package:flutter_clinica_medica/presentation/auth/register_screen.dart';

// IMPORTS PARA LOCALIZAÇÃO
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final LocalDatabase localDatabase = LocalDatabase();
  await localDatabase.openDb();

  print('Banco de dados da clínica aberto com sucesso!');

  // --- CÓDIGO TEMPORÁRIO PARA TESTE DE INSERÇÃO (REMOVER DEPOIS!) ---
  // Este bloco é para inserir um usuário admin automaticamente na primeira vez que o DB for criado.
  // REMOVA OU COMENTE ESTE BLOCO APÓS TESTAR E TER SEU USUÁRIO ADMIN CADASTRADO.
  /*
  import 'package:flutter_clinica_medica/domain/models/usuario.dart';
  import 'package:flutter_clinica_medica/domain/repositories/usuario_repository.dart';
  import 'package:flutter_clinica_medica/utils/password_util.dart';

  final usuarioRepo = UsuarioRepository();
  try {
    final existingAdmin = await usuarioRepo.getUsuarioByUsername('admin');
    if (existingAdmin == null) {
      final salt = PasswordUtil.generateSalt();
      final hashedPassword = PasswordUtil.hashPassword('admin123', salt); // Senha padrão para o admin
      final adminUser = Usuario(
        username: 'admin',
        passwordHash: hashedPassword,
        salt: salt,
        email: 'admin@clinica.com',
        tipo: 'admin',
      );
      await usuarioRepo.insertUsuario(adminUser);
      print('Usuário admin de teste criado!');
    } else {
      print('Usuário admin de teste já existe.');
    }
  } catch (e) {
    print('Erro durante inserção de usuário admin de teste: $e');
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
      // Rota inicial do aplicativo (AGORA INICIA NA TELA DE LOGIN)
      initialRoute: LoginScreen.routeName, // AQUI ESTÁ A MUDANÇA PRINCIPAL
      routes: {
        // Rotas de Autenticação (NOVAS)
        LoginScreen.routeName: (context) => const LoginScreen(),
        RegisterScreen.routeName: (context) => const RegisterScreen(),

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
        ContaReceberListScreen.routeName: (context) => const ContaReceberListScreen(),
        ContaReceberFormScreen.routeName: (context) => const ContaReceberFormScreen(),
        ContaPagarListScreen.routeName: (context) => const ContaPagarListScreen(),
        ContaPagarFormScreen.routeName: (context) => const ContaPagarFormScreen(),
        RelatorioFinanceiroScreen.routeName: (context) => const RelatorioFinanceiroScreen(),

        // Rotas de Salas
        SalaListScreen.routeName: (context) => const SalaListScreen(),
        SalaFormScreen.routeName: (context) => const SalaFormScreen(),

        // Rotas de Exames e Resultados de Exames
        ExameListScreen.routeName: (context) => const ExameListScreen(),
        ResultadoExameFormScreen.routeName: (context) => const ResultadoExameFormScreen(),
        ResultadoExameListScreen.routeName: (context) => const ResultadoExameListScreen(),

        // Rota do Dashboard Principal (acessado após login)
        MainDashboardScreen.routeName: (context) => const MainDashboardScreen(),
      },
    );
  }
}