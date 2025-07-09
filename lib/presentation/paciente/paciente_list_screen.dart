// lib/presentation/paciente/paciente_list_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_clinica_medica/domain/models/paciente.dart';
import 'package:flutter_clinica_medica/domain/repositories/paciente_repository.dart';
import 'package:flutter_clinica_medica/presentation/paciente/paciente_form_screen.dart';
import 'package:flutter_clinica_medica/presentation/paciente/paciente_details_screen.dart'; // NOVO IMPORT

class PacienteListScreen extends StatefulWidget {
  const PacienteListScreen({super.key});

  static const String routeName = '/paciente-list';

  @override
  State<PacienteListScreen> createState() => _PacienteListScreenState();
}

class _PacienteListScreenState extends State<PacienteListScreen> {
  final PacienteRepository _pacienteRepository = PacienteRepository();
  List<Paciente> _pacientes = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPacientes();
  }

  Future<void> _loadPacientes() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final pacientes = await _pacienteRepository.getAllPacientes();
      setState(() {
        _pacientes = pacientes;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao carregar pacientes: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _deletePaciente(int id) async {
    try {
      await _pacienteRepository.deletePaciente(id);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Paciente excluído com sucesso!')),
      );
      _loadPacientes();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao excluir paciente: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lista de Pacientes'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadPacientes,
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () async {
              await Navigator.of(context).pushNamed(PacienteFormScreen.routeName);
              _loadPacientes();
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _pacientes.isEmpty
              ? const Center(child: Text('Nenhum paciente cadastrado.'))
              : ListView.builder(
                  itemCount: _pacientes.length,
                  itemBuilder: (context, index) {
                    final paciente = _pacientes[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: ListTile(
                        title: Text(paciente.nome),
                        subtitle: Text('CPF: ${paciente.cpf} - Telefone: ${paciente.telefone ?? 'N/A'}'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.blue),
                              onPressed: () async {
                                await Navigator.of(context).push(MaterialPageRoute(
                                  builder: (context) => PacienteFormScreen(
                                    paciente: paciente,
                                  ),
                                ));
                                _loadPacientes();
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _deletePaciente(paciente.idPaciente!),
                            ),
                          ],
                        ),
                        onTap: () async {
                          // NOVO: Ao clicar no paciente, navega para a tela de detalhes/prontuário
                          await Navigator.of(context).pushNamed(
                            PacienteDetailsScreen.routeName,
                            arguments: paciente.idPaciente,
                          );
                          _loadPacientes(); // Recarrega a lista se houver alterações nos detalhes
                        },
                      ),
                    );
                  },
                ),
    );
  }
}