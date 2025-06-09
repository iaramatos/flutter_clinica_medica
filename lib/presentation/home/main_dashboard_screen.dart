// lib/presentation/home/main_dashboard_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_clinica_medica/presentation/paciente/paciente_list_screen.dart';
import 'package:flutter_clinica_medica/presentation/profissional/profissional_list_screen.dart';
import 'package:flutter_clinica_medica/presentation/consulta/consulta_list_screen.dart';
import 'package:flutter_clinica_medica/presentation/medicamento/medicamento_list_screen.dart';
import 'package:flutter_clinica_medica/presentation/receita/prescricao_form_screen.dart';
import 'package:flutter_clinica_medica/presentation/receita/prescricao_list_screen.dart';
import 'package:flutter_clinica_medica/presentation/financeiro/financeiro_form_screen.dart';
// NOVOS IMPORTS PARA OS MÓDULOS DE EXAMES E SALAS
import 'package:flutter_clinica_medica/presentation/exame/exame_list_screen.dart';
import 'package:flutter_clinica_medica/presentation/exame/resultado_exame_form_screen.dart';
import 'package:flutter_clinica_medica/presentation/exame/resultado_exame_list_screen.dart';
import 'package:flutter_clinica_medica/presentation/sala/sala_list_screen.dart'; // NOVO IMPORT
import 'package:flutter_clinica_medica/presentation/sala/sala_form_screen.dart'; // NOVO IMPORT (se precisar de acesso direto ao form de sala)


class MainDashboardScreen extends StatelessWidget {
  const MainDashboardScreen({super.key});

  static const String routeName = '/dashboard';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Clínica Médica - Dashboard'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            _buildSectionTitle(context, 'Módulos Principais'),
            _buildDashboardButton(context, 'Pacientes', PacienteListScreen.routeName, Icons.person),
            _buildDashboardButton(context, 'Profissionais', ProfissionalListScreen.routeName, Icons.medical_services),
            _buildDashboardButton(context, 'Consultas (Agenda)', ConsultaListScreen.routeName, Icons.calendar_today),
            
            const Divider(height: 30),
            _buildSectionTitle(context, 'Módulos Auxiliares'),
            _buildDashboardButton(context, 'Medicamentos', MedicamentoListScreen.routeName, Icons.medication),
            _buildDashboardButton(context, 'Prescrições', PrescricaoListScreen.routeName, Icons.receipt),
            _buildDashboardButton(context, 'Registrar Pagamento', FinanceiroFormScreen.routeName, Icons.payment),
            
            const Divider(height: 30),
            _buildSectionTitle(context, 'Módulos de Exames'), // NOVA SEÇÃO
            _buildDashboardButton(context, 'Tipos de Exames', ExameListScreen.routeName, Icons.science), // NOVO BOTÃO
            _buildDashboardButton(context, 'Registrar Resultado Exame', ResultadoExameFormScreen.routeName, Icons.assignment), // NOVO BOTÃO
            _buildDashboardButton(context, 'Ver Resultados Exames', ResultadoExameListScreen.routeName, Icons.file_copy), // NOVO BOTÃO

            const Divider(height: 30),
            _buildSectionTitle(context, 'Módulos de Gestão'), // NOVA SEÇÃO
            _buildDashboardButton(context, 'Salas', SalaListScreen.routeName, Icons.meeting_room), // NOVO BOTÃO para Salas
            // _buildDashboardButton(context, 'Adicionar Sala', SalaFormScreen.routeName, Icons.add_box), // Opcional: Se quiser um botão direto para o form de sala
          ],
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