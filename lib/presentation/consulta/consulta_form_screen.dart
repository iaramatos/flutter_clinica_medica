// lib/presentation/consulta/consulta_form_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_clinica_medica/domain/models/consulta.dart';
import 'package:flutter_clinica_medica/domain/models/paciente.dart';
import 'package:flutter_clinica_medica/domain/models/profissional.dart';
import 'package:flutter_clinica_medica/domain/models/sala.dart';
import 'package:flutter_clinica_medica/domain/repositories/consulta_repository.dart';
import 'package:flutter_clinica_medica/domain/repositories/paciente_repository.dart';
import 'package:flutter_clinica_medica/domain/repositories/profissional_repository.dart';
import 'package:flutter_clinica_medica/domain/repositories/sala_repository.dart';
import 'package:intl/intl.dart';

class ConsultaFormScreen extends StatefulWidget {
  final Consulta? consulta;
  const ConsultaFormScreen({super.key, this.consulta});

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
  Sala? _selectedSala;

  List<Paciente> _pacientes = [];
  List<Profissional> _profissionais = [];
  List<Sala> _salas = [];
  bool _isLoadingDropdowns = true;

  final ConsultaRepository _consultaRepository = ConsultaRepository();
  final PacienteRepository _pacienteRepository = PacienteRepository();
  final ProfissionalRepository _profissionalRepository = ProfissionalRepository();
  final SalaRepository _salaRepository = SalaRepository();

  @override
  void initState() {
    super.initState();
    _loadDropdownData();
    if (widget.consulta != null) {
      _dataHoraController.text = DateFormat('dd/MM/yyyy HH:mm').format(widget.consulta!.dataHora);
      _motivoController.text = widget.consulta!.motivo ?? '';
      _diagnosticoController.text = widget.consulta!.diagnostico ?? '';
    }
  }

  Future<void> _loadDropdownData() async {
    try {
      final pacientes = await _pacienteRepository.getAllPacientes();
      final profissionais = await _profissionalRepository.getAllProfissionais();
      final salas = await _salaRepository.getAllSalas();

      setState(() {
        _pacientes = pacientes;
        _profissionais = profissionais;
        _salas = salas;
        _isLoadingDropdowns = false;

        if (widget.consulta != null) {
          _selectedPaciente = pacientes.firstWhere(
            (p) => p.idPaciente == widget.consulta!.idPaciente,
            orElse: () => pacientes.isEmpty ? null as Paciente : pacientes.first,
          );
          _selectedProfissional = profissionais.firstWhere(
            (pr) => pr.idProfissional == widget.consulta!.idProfissional,
            orElse: () => profissionais.isEmpty ? null as Profissional : profissionais.first,
          );
          _selectedSala = salas.firstWhere(
            (s) => s.idSala == widget.consulta!.idSala,
            orElse: () => salas.isEmpty ? null as Sala : salas.first,
          );
        }
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

  Future<void> _selectDataHora(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
      locale: const Locale('pt', 'BR'),
    );
    if (pickedDate != null) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
        builder: (BuildContext context, Widget? child) {
          return MediaQuery(
            data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
            child: child!,
          );
        },
      );
      if (pickedTime != null) {
        setState(() {
          final DateTime finalDateTime = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            pickedTime.hour,
            pickedTime.minute,
          );
          _dataHoraController.text = DateFormat('dd/MM/yyyy HH:mm').format(finalDateTime);
        });
      }
    }
  }

  // Método para verificar conflitos de agendamento (RN02)
  Future<bool> _hasConflict(DateTime dataHora, int profissionalId, int? salaId, int? currentConsultaId) async {
    final allConsultas = await _consultaRepository.getAllConsultas();
    for (var c in allConsultas) {
      if (c.idConsulta != currentConsultaId &&
          c.dataHora.year == dataHora.year &&
          c.dataHora.month == dataHora.month &&
          c.dataHora.day == dataHora.day &&
          c.dataHora.hour == dataHora.hour &&
          c.dataHora.minute == dataHora.minute) {

        // Conflito de Profissional
        if (c.idProfissional == profissionalId) { // CORRIGIDO: profissionalId
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Conflito: Profissional já tem outra consulta neste horário.'), backgroundColor: Colors.red),
            );
            return true;
        }
        // Conflito de Sala
        if (c.idSala == salaId) {
             ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Conflito: Sala já está ocupada neste horário.'), backgroundColor: Colors.red),
            );
            return true;
        }
      }
    }
    return false;
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedPaciente == null || _selectedProfissional == null || _selectedSala == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Por favor, selecione o Paciente, Profissional e a Sala.')),
        );
        return;
      }

      final parsedDataHora = DateFormat('dd/MM/yyyy HH:mm').parse(_dataHoraController.text);

      final hasConflict = await _hasConflict(parsedDataHora, _selectedProfissional!.idProfissional!, _selectedSala!.idSala, widget.consulta?.idConsulta);
      if (hasConflict) {
        return;
      }

      final consulta = Consulta(
        idConsulta: widget.consulta?.idConsulta,
        dataHora: parsedDataHora,
        motivo: _motivoController.text.isNotEmpty ? _motivoController.text : null,
        diagnostico: _diagnosticoController.text.isNotEmpty ? _diagnosticoController.text : null,
        idPaciente: _selectedPaciente!.idPaciente,
        idProfissional: _selectedProfissional!.idProfissional,
        idSala: _selectedSala!.idSala,
        idReceita: null,
      );

      try {
        if (consulta.idConsulta == null) {
          await _consultaRepository.insertConsulta(consulta);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Consulta agendada com sucesso!')),
          );
        } else {
          await _consultaRepository.updateConsulta(consulta);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Consulta atualizada com sucesso!')),
          );
        }
        _clearForm();
        Navigator.of(context).pop();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao agendar consulta: $e')), // Corrigida a sintaxe do SnackBar aqui
        );
      }
    }
  }

  void _clearForm() { // CORRIGIDO: Removido caracteres estranhos
    _dataHoraController.clear();
    _motivoController.clear();
    _diagnosticoController.clear();
    setState(() {
      _selectedPaciente = null;
      _selectedProfissional = null;
      _selectedSala = null;
    });
  }

  @override
  void dispose() { // CORRIGIDO: Removido caracteres estranhos
    _dataHoraController.dispose();
    _motivoController.dispose();
    _diagnosticoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) { // CORRIGIDO: Removido caracteres estranhos
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.consulta == null ? 'Agendar Consulta' : 'Editar Consulta'),
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

                    // NOVO CAMPO: Seleção de Sala
                    DropdownButtonFormField<Sala>(
                      value: _selectedSala,
                      decoration: const InputDecoration(labelText: 'Sala de Atendimento'),
                      items: _salas.map((sala) {
                        return DropdownMenuItem(
                          value: sala,
                          child: Text('${sala.nome ?? 'Sala S/N'} (Tipo: ${sala.tipo ?? 'N/A'})'),
                        );
                      }).toList(),
                      onChanged: (Sala? newValue) {
                        setState(() {
                          _selectedSala = newValue;
                        });
                      },
                      validator: (value) {
                        if (value == null) {
                          return 'Selecione a sala';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 10),

                    // CAMPO DE DATA E HORA (COM PICKER E FORMATO BRASILEIRO)
                    TextFormField(
                      controller: _dataHoraController,
                      decoration: InputDecoration(
                        labelText: 'Data e Hora da Consulta (DD/MM/YYYY HH:MM)',
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.calendar_today),
                          onPressed: () => _selectDataHora(context),
                        ),
                      ),
                      readOnly: true, // Impede digitação manual
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