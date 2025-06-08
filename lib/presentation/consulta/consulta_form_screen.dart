// lib/presentation/consulta/consulta_form_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_clinica_medica/domain/models/consulta.dart';
import 'package:flutter_clinica_medica/domain/models/paciente.dart'; // Para selecionar pacientes
import 'package:flutter_clinica_medica/domain/models/profissional.dart'; // Para selecionar profissionais
import 'package:flutter_clinica_medica/domain/models/sala.dart'; // Para selecionar salas (futuramente)
import 'package:flutter_clinica_medica/domain/repositories/consulta_repository.dart';
import 'package:flutter_clinica_medica/domain/repositories/paciente_repository.dart';
import 'package:flutter_clinica_medica/domain/repositories/profissional_repository.dart';

class ConsultaFormScreen extends StatefulWidget {
  const ConsultaFormScreen({super.key});

  static const String routeName = '/consulta-form';

  @override
  State<ConsultaFormScreen> createState() => _ConsultaFormScreenState();
}

class _ConsultaFormScreenState extends State<ConsultaFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _dataHoraController = TextEditingController();
  final _motivoController = TextEditingController();
  final _diagnosticoController = TextEditingController();

  Paciente? _selectedPaciente;
  Profissional? _selectedProfissional;

  List<Paciente> _pacientes = [];
  List<Profissional> _profissionais = [];
  bool _isLoadingDropdowns = true;

  final ConsultaRepository _consultaRepository = ConsultaRepository();
  final PacienteRepository _pacienteRepository = PacienteRepository();
  final ProfissionalRepository _profissionalRepository = ProfissionalRepository();

  @override
  void initState() {
    super.initState();
    _loadDropdownData();
  }

  Future<void> _loadDropdownData() async {
    try {
      final pacientes = await _pacienteRepository.getAllPacientes();
      final profissionais = await _profissionalRepository.getAllProfissionais();
      setState(() {
        _pacientes = pacientes;
        _profissionais = profissionais;
        _isLoadingDropdowns = false;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao carregar dados de seleção: $e')),
      );
      setState(() {
        _isLoadingDropdowns = false;
      });
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );
      if (pickedTime != null) {
        setState(() {
          final DateTime finalDateTime = DateTime(
            picked.year,
            picked.month,
            picked.day,
            pickedTime.hour,
            pickedTime.minute,
          );
          _dataHoraController.text = finalDateTime.toIso8601String().substring(0, 16); // Formato YYYY-MM-DDTHH:MM
        });
      }
    }
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedPaciente == null || _selectedProfissional == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Por favor, selecione o Paciente e o Profissional.')),
        );
        return;
      }

      final consulta = Consulta(
        dataHora: DateTime.parse(_dataHoraController.text),
        motivo: _motivoController.text.isNotEmpty ? _motivoController.text : null,
        diagnostico: _diagnosticoController.text.isNotEmpty ? _diagnosticoController.text : null,
        idPaciente: _selectedPaciente!.idPaciente,
        idProfissional: _selectedProfissional!.idProfissional,
        // idSala e idReceita serão tratados em iterações futuras
        idSala: null, // Temporariamente nulo
        idReceita: null, // Temporariamente nulo
      );

      try {
        await _consultaRepository.insertConsulta(consulta);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Consulta agendada com sucesso!')),
        );
        _clearForm();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao agendar consulta: $e')),
        );
      }
    }
  }

  void _clearForm() {
    _dataHoraController.clear();
    _motivoController.clear();
    _diagnosticoController.clear();
    setState(() {
      _selectedPaciente = null;
      _selectedProfissional = null;
    });
  }

  @override
  void dispose() {
    _dataHoraController.dispose();
    _motivoController.dispose();
    _diagnosticoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Agendar Consulta'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: _isLoadingDropdowns
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: ListView(
                  children: [
                    // Campo de seleção de Paciente
                    DropdownButtonFormField<Paciente>(
                      value: _selectedPaciente,
                      decoration: const InputDecoration(labelText: 'Paciente'),
                      items: _pacientes.map((paciente) {
                        return DropdownMenuItem(
                          value: paciente,
                          child: Text(paciente.nome),
                        );
                      }).toList(),
                      onChanged: (Paciente? newValue) {
                        setState(() {
                          _selectedPaciente = newValue;
                        });
                      },
                      validator: (value) {
                        if (value == null) {
                          return 'Selecione o paciente';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 10),

                    // Campo de seleção de Profissional
                    DropdownButtonFormField<Profissional>(
                      value: _selectedProfissional,
                      decoration: const InputDecoration(labelText: 'Profissional'),
                      items: _profissionais.map((profissional) {
                        return DropdownMenuItem(
                          value: profissional,
                          child: Text(profissional.nome),
                        );
                      }).toList(),
                      onChanged: (Profissional? newValue) {
                        setState(() {
                          _selectedProfissional = newValue;
                        });
                      },
                      validator: (value) {
                        if (value == null) {
                          return 'Selecione o profissional';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 10),

                    // Campo de Data e Hora
                    TextFormField(
                      controller: _dataHoraController,
                      decoration: InputDecoration(
                        labelText: 'Data e Hora da Consulta (YYYY-MM-DDTHH:MM)',
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.calendar_today),
                          onPressed: () => _selectDate(context),
                        ),
                      ),
                      readOnly: true, // Para forçar o uso do seletor de data/hora
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor, insira a data e hora da consulta';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 10),

                    TextFormField(
                      controller: _motivoController,
                      decoration: const InputDecoration(labelText: 'Motivo da Consulta'),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 10),

                    TextFormField(
                      controller: _diagnosticoController,
                      decoration: const InputDecoration(labelText: 'Diagnóstico (opcional)'),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 20),

                    ElevatedButton(
                      onPressed: _submitForm,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                      ),
                      child: const Text('Agendar Consulta'),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}