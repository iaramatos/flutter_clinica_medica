// lib/presentation/home/main_dashboard_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_clinica_medica/presentation/paciente/paciente_list_screen.dart';
import 'package:flutter_clinica_medica/presentation/profissional/profissional_list_screen.dart';
import 'package:flutter_clinica_medica/presentation/consulta/consulta_list_screen.dart';
import 'package:flutter_clinica_medica/presentation/medicamento/medicamento_list_screen.dart';
import 'package:flutter_clinica_medica/presentation/receita/prescricao_form_screen.dart';
import 'package:flutter_clinica_medica/presentation/receita/prescricao_list_screen.dart';
import 'package:flutter_clinica_medica/presentation/financeiro/financeiro_form_screen.dart';
import 'package:flutter_clinica_medica/presentation/exame/exame_list_screen.dart';
import 'package:flutter_clinica_medica/presentation/exame/resultado_exame_form_screen.dart';
import 'package:flutter_clinica_medica/presentation/exame/resultado_exame_list_screen.dart';
import 'package:flutter_clinica_medica/presentation/sala/sala_list_screen.dart';
import 'package:flutter_clinica_medica/presentation/sala/sala_form_screen.dart';

import 'package:flutter_clinica_medica/presentation/contas/conta_receber_list_screen.dart';
import 'package:flutter_clinica_medica/presentation/contas/conta_pagar_list_screen.dart';
import 'package:flutter_clinica_medica/presentation/contas/relatorio_financeiro_screen.dart';
import 'package:flutter_clinica_medica/utils/auth_manager.dart';
import 'package:flutter_clinica_medica/presentation/auth/login_screen.dart';

class MainDashboardScreen extends StatelessWidget {
  const MainDashboardScreen({super.key});

  static const String routeName = '/dashboard';

  @override
  Widget build(BuildContext context) {
    final authManager = AuthManager();
    final currentUser = authManager.currentUser;

    final Map<String, List<String>> permissions = {
      'admin': [
        'pacientes', 'profissionais', 'consultas', 'medicamentos', 'prescricoes',
        'pagamento', 'tipos_exames', 'resultados_exames', 'salas',
        'contas_receber', 'contas_pagar', 'relatorio_financeiro',
      ],
      'medico': [
        'pacientes', 'consultas', 'medicamentos', 'prescricoes', 'resultados_exames',
      ],
      'enfermeiro': [
        'pacientes', 'consultas', 'medicamentos', 'resultados_exames',
      ],
      'recepcionista': [
        'pacientes', 'consultas', 'pagamento', 'salas',
      ],
      'paciente': [
        'consultas', 'resultados_exames',
      ],
    };

    final List<String> allowedModules = permissions[currentUser?.tipo ?? ''] ?? [];

    bool canAccess(String moduleKey) {
      if (currentUser == null) return false;
      return allowedModules.contains(moduleKey);
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Clínica Médica - Dashboard (${currentUser?.username ?? 'Visitante'})'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              authManager.logout();
              Navigator.of(context).pushReplacementNamed(LoginScreen.routeName);
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            _buildSectionTitle(context, 'Módulos Principais'),
            if (canAccess('pacientes'))
              _buildDashboardButton(context, 'Pacientes', PacienteListScreen.routeName, Icons.person),
            if (canAccess('profissionais'))
              _buildDashboardButton(context, 'Profissionais', ProfissionalListScreen.routeName, Icons.medical_services),
            if (canAccess('consultas'))
              _buildDashboardButton(context, 'Consultas (Agenda)', ConsultaListScreen.routeName, Icons.calendar_today),
            
            // Módulos Auxiliares - SÓ EXIBIR A SEÇÃO SE HOUVER ALGO PARA EXIBIR NELA
            if (canAccess('medicamentos') || canAccess('prescricoes') || canAccess('pagamento'))
              const Divider(height: 30),
            if (canAccess('medicamentos') || canAccess('prescricoes') || canAccess('pagamento'))
              _buildSectionTitle(context, 'Módulos Auxiliares'),
            if (canAccess('medicamentos'))
              _buildDashboardButton(context, 'Medicamentos', MedicamentoListScreen.routeName, Icons.medication),
            if (canAccess('prescricoes'))
              _buildDashboardButton(context, 'Prescrições', PrescricaoListScreen.routeName, Icons.receipt),
            if (canAccess('pagamento'))
              _buildDashboardButton(context, 'Registrar Pagamento', FinanceiroFormScreen.routeName, Icons.payment),
            
            // Módulos de Exames - SÓ EXIBIR A SEÇÃO SE HOUVER ALGO PARA EXIBIR NELA
            if (canAccess('tipos_exames') || canAccess('resultados_exames'))
              const Divider(height: 30),
            if (canAccess('tipos_exames') || canAccess('resultados_exames'))
              _buildSectionTitle(context, 'Módulos de Exames'),
            if (canAccess('tipos_exames'))
              _buildDashboardButton(context, 'Tipos de Exames', ExameListScreen.routeName, Icons.science),
            if (canAccess('resultados_exames')) // Tanto médicos quanto pacientes podem ver
              _buildDashboardButton(context, 'Registrar Resultado Exame', ResultadoExameFormScreen.routeName, Icons.assignment),
            if (canAccess('resultados_exames'))
              _buildDashboardButton(context, 'Ver Resultados Exames', ResultadoExameListScreen.routeName, Icons.file_copy),

            // Módulos de Gestão - SÓ EXIBIR A SEÇÃO SE HOUVER ALGO PARA EXIBIR NELA
            if (canAccess('salas'))
              const Divider(height: 30),
            if (canAccess('salas'))
              _buildSectionTitle(context, 'Módulos de Gestão'),
            if (canAccess('salas'))
              _buildDashboardButton(context, 'Salas', SalaListScreen.routeName, Icons.meeting_room),

            // Módulos Financeiros Detalhados - SÓ EXIBIR A SEÇÃO SE HOUVER ALGO PARA EXIBIR NELA
            if (canAccess('contas_receber') || canAccess('contas_pagar') || canAccess('relatorio_financeiro'))
              const Divider(height: 30),
            if (canAccess('contas_receber') || canAccess('contas_pagar') || canAccess('relatorio_financeiro'))
              _buildSectionTitle(context, 'Módulos Financeiros Detalhados'),
            if (canAccess('contas_receber'))
              _buildDashboardButton(context, 'Contas a Receber', ContaReceberListScreen.routeName, Icons.attach_money),
            if (canAccess('contas_pagar'))
              _buildDashboardButton(context, 'Contas a Pagar', ContaPagarListScreen.routeName, Icons.money_off),
            if (canAccess('relatorio_financeiro'))
              _buildDashboardButton(context, 'Relatório Financeiro', RelatorioFinanceiroScreen.routeName, Icons.bar_chart),
          ].whereType<Widget>().toList(), // .whereType<Widget>().toList() é importante para filtrar 'null'
        ),
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.secondary,
        ),
      ),
    );
  }

  Widget _buildDashboardButton(BuildContext context, String title, String route, IconData icon) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: ListTile(
        leading: Icon(icon, size: 30, color: Theme.of(context).colorScheme.primary),
        title: Text(title, style: const TextStyle(fontSize: 18)),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: () {
          Navigator.of(context).pushNamed(route);
        },
      ),
    );
  }
}