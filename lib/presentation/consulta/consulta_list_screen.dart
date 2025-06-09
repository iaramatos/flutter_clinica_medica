// lib/presentation/consulta/consulta_list_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_clinica_medica/domain/models/consulta.dart';
import 'package:flutter_clinica_medica/domain/repositories/consulta_repository.dart';
import 'package:flutter_clinica_medica/domain/repositories/paciente_repository.dart';
import 'package:flutter_clinica_medica/domain/repositories/profissional_repository.dart';
import 'package:flutter_clinica_medica/presentation/consulta/consulta_form_screen.dart'; // Importar o formulário de consulta
import 'package:flutter_clinica_medica/presentation/financeiro/financeiro_form_screen.dart'; // Importar o formulário financeiro
import 'package:intl/intl.dart';

class ConsultaListScreen extends StatefulWidget {
  const ConsultaListScreen({super.key});

  static const String routeName = '/consulta-list';

  @override
  State<ConsultaListScreen> createState() => _ConsultaListScreenState();
}

class _ConsultaListScreenState extends State<ConsultaListScreen> {
  final ConsultaRepository _consultaRepository = ConsultaRepository();
  final PacienteRepository _pacienteRepository = PacienteRepository();
  final ProfissionalRepository _profissionalRepository = ProfissionalRepository();

  List<Consulta> _consultas = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadConsultas();
  }

  Future<void> _loadConsultas() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final consultas = await _consultaRepository.getAllConsultas();
      setState(() {
        _consultas = consultas;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao carregar consultas: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _deleteConsulta(int id) async {
    try {
      await _consultaRepository.deleteConsulta(id);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Consulta excluída com sucesso!')),
      );
      _loadConsultas();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao excluir consulta: $e')),
      );
    }
  }

  // Função auxiliar para obter o nome do paciente/profissional a partir do ID
  Future<String> _getPacienteNome(int? id) async {
    if (id == null) return 'Paciente Desconhecido';
    final paciente = await _pacienteRepository.getPacienteById(id);
    return paciente?.nome ?? 'Paciente Desconhecido';
  }

  Future<String> _getProfissionalNome(int? id) async {
    if (id == null) return 'Profissional Desconhecido';
    final profissional = await _profissionalRepository.getProfissionalById(id);
    return profissional?.nome ?? 'Profissional Desconhecido';
  }

  // NOVO MÉTODO: Simular envio de lembrete
  Future<void> _sendReminder(Consulta consulta) async {
    final pacienteNome = await _getPacienteNome(consulta.idPaciente);
    final formattedTime = DateFormat('dd/MM/yyyy HH:mm').format(consulta.dataHora);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Lembrete enviado para $pacienteNome sobre a consulta em $formattedTime.'),
        backgroundColor: Colors.orange, // Cor de destaque para o lembrete
        duration: const Duration(seconds: 3),
      ),
    );
    // Em um sistema real, aqui você chamaria um serviço de backend para enviar e-mail/SMS
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Agenda de Consultas'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadConsultas,
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () async {
              await Navigator.of(context).pushNamed(ConsultaFormScreen.routeName);
              _loadConsultas(); // Recarrega a lista ao voltar do formulário
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _consultas.isEmpty
              ? const Center(child: Text('Nenhuma consulta agendada.'))
              : ListView.builder(
                  itemCount: _consultas.length,
                  itemBuilder: (context, index) {
                    final consulta = _consultas[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: ListTile(
                        title: FutureBuilder<List<String>>(
                          future: Future.wait([
                            _getPacienteNome(consulta.idPaciente),
                            _getProfissionalNome(consulta.idProfissional),
                          ]),
                          builder: (context, snapshot) {
                            String pacienteNome = snapshot.data?[0] ?? 'Carregando...';
                            String profissionalNome = snapshot.data?[1] ?? 'Carregando...';

                            if (snapshot.connectionState == ConnectionState.waiting) {
                              pacienteNome = 'Carregando...';
                              profissionalNome = 'Carregando...';
                            } else if (snapshot.hasError) {
                              pacienteNome = 'Erro';
                              profissionalNome = 'Erro';
                            }
                            return Text('Paciente: $pacienteNome\nProfissional: $profissionalNome');
                          },
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Data/Hora: ${DateFormat('dd/MM/yyyy HH:mm').format(consulta.dataHora)}'),
                            if (consulta.motivo != null && consulta.motivo!.isNotEmpty)
                              Text('Motivo: ${consulta.motivo}'),
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Botão de Lembrete
                            IconButton(
                              icon: const Icon(Icons.notifications, color: Colors.orange),
                              onPressed: () => _sendReminder(consulta),
                            ),
                            // Botão de Editar/Reagendar (AGORA FUNCIONA PASSANDO A CONSULTA)
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.blue),
                              onPressed: () async {
                                await Navigator.of(context).push(MaterialPageRoute(
                                  builder: (context) => ConsultaFormScreen(
                                    consulta: consulta, // PASSA A CONSULTA PARA EDIÇÃO/REAGENDAMENTO
                                  ),
                                ));
                                _loadConsultas(); // Recarrega a lista após edição
                              },
                            ),
                            // Botão de Pagamento
                            IconButton(
                              icon: const Icon(Icons.payment, color: Colors.green),
                              onPressed: () async {
                                await Navigator.of(context).push(MaterialPageRoute(
                                  builder: (context) => FinanceiroFormScreen(
                                    idConsulta: consulta.idConsulta,
                                  ),
                                ));
                                _loadConsultas();
                              },
                            ),
                            // Botão de Excluir/Cancelar
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _deleteConsulta(consulta.idConsulta!),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}