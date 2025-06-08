// lib/presentation/consulta/consulta_list_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_clinica_medica/domain/models/consulta.dart';
import 'package:flutter_clinica_medica/domain/repositories/consulta_repository.dart';
import 'package:flutter_clinica_medica/domain/repositories/paciente_repository.dart'; // Para obter nome do paciente
import 'package:flutter_clinica_medica/domain/repositories/profissional_repository.dart'; // Para obter nome do profissional
import 'package:flutter_clinica_medica/presentation/consulta/consulta_form_screen.dart';
import 'package:intl/intl.dart'; // Para formatação de data e hora (adicione ao pubspec.yaml)

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
      // Usaremos o getAllConsultas do repositório que já faz o JOIN
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
                      child: FutureBuilder<List<String>>(
                        // FutureBuilder para carregar nomes de paciente e profissional
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

                          return ListTile(
                            title: Text('Paciente: $pacienteNome'),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Profissional: $profissionalNome'),
                                Text('Data/Hora: ${DateFormat('dd/MM/yyyy HH:mm').format(consulta.dataHora)}'),
                                if (consulta.motivo != null && consulta.motivo!.isNotEmpty)
                                  Text('Motivo: ${consulta.motivo}'),
                              ],
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit, color: Colors.blue),
                                  onPressed: () async {
                                    // Implementar edição futuramente
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('Funcionalidade de edição futura.')),
                                    );
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.red),
                                  onPressed: () => _deleteConsulta(consulta.idConsulta!),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
    );
  }
}