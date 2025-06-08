// lib/presentation/consulta/consulta_form_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_clinica_medica/domain/models/consulta.dart';
import 'package:flutter_clinica_medica/domain/models/paciente.dart';
import 'package:flutter_clinica_medica/domain/models/profissional.dart';
import 'package:flutter_clinica_medica/domain/models/sala.dart'; // Para selecionar salas (futuramente)
import 'package:flutter_clinica_medica/domain/repositories/consulta_repository.dart';
import 'package:flutter_clinica_medica/domain/repositories/paciente_repository.dart';
import 'package:flutter_clinica_medica/domain/repositories/profissional_repository.dart';
import 'package:intl/intl.dart'; // Importe para formatação de data e hora

class ConsultaFormScreen extends StatefulWidget {
  final Consulta? consulta; // Adicionado para suportar edição (embora não implementado ainda na lista)
  const ConsultaFormScreen({super.key, this.consulta}); // Adicionado construtor para edição

  static const String routeName = '/consulta-form';

  @override
  State<ConsultaFormScreen> createState() => _ConsultaFormScreenState();
}

class _ConsultaFormScreenState extends State<ConsultaFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _dataHoraController = TextEditingController(); // Controller para a data e hora
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
    // Preenche os campos se estiver em modo de edição
    if (widget.consulta != null) {
      _dataHoraController.text = DateFormat('dd/MM/yyyy HH:mm').format(widget.consulta!.dataHora);
      _motivoController.text = widget.consulta!.motivo ?? '';
      _diagnosticoController.text = widget.consulta!.diagnostico ?? '';
      // Para edição, _selectedPaciente e _selectedProfissional precisariam ser pré-selecionados
      // após o carregamento da lista de pacientes/profissionais em _loadDropdownData.
      // Isso seria uma melhoria para uma iteração futura, focando no básico agora.
    }
  }

  Future<void> _loadDropdownData() async {
    try {
      final pacientes = await _pacienteRepository.getAllPacientes();
      final profissionais = await _profissionalRepository.getAllProfissionais();
      setState(() {
        _pacientes = pacientes;
        _profissionais = profissionais;
        _isLoadingDropdowns = false;

        // Lógica de pré-seleção para edição, se estiver no modo de edição
        if (widget.consulta != null) {
          _selectedPaciente = pacientes.firstWhere(
            (p) => p.idPaciente == widget.consulta!.idPaciente,
            orElse: () => pacientes.isEmpty ? null as Paciente : pacientes.first,
          );
          _selectedProfissional = profissionais.firstWhere(
            (pr) => pr.idProfissional == widget.consulta!.idProfissional,
            orElse: () => profissionais.isEmpty ? null as Profissional : profissionais.first,
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

  // NOVO MÉTODO: Seletor de Data e Hora
  Future<void> _selectDataHora(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(), // Data inicial do calendário
      firstDate: DateTime.now(),   // A partir de hoje
      lastDate: DateTime(2101),    // Última data possível
      locale: const Locale('pt', 'BR'), // Para calendário em português
    );
    if (pickedDate != null) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(), // Hora inicial do seletor
        builder: (BuildContext context, Widget? child) {
          return MediaQuery(
            data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true), // Força formato 24h
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
          // Formata para DD/MM/YYYY HH:MM para exibição
          _dataHoraController.text = DateFormat('dd/MM/yyyy HH:mm').format(finalDateTime);
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
        idConsulta: widget.consulta?.idConsulta, // Mantém o ID para edição
        // Converte de volta para DateTime usando o formato correto
        dataHora: DateFormat('dd/MM/yyyy HH:mm').parse(_dataHoraController.text),
        motivo: _motivoController.text.isNotEmpty ? _motivoController.text : null,
        diagnostico: _diagnosticoController.text.isNotEmpty ? _diagnosticoController.text : null,
        idPaciente: _selectedPaciente!.idPaciente,
        idProfissional: _selectedProfissional!.idProfissional,
        idSala: null, // Temporariamente nulo
        idReceita: null, // Temporariamente nulo
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
        Navigator.of(context).pop(); // Volta para a lista
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
        title: Text(widget.consulta == null ? 'Agendar Consulta' : 'Editar Consulta'), // Título dinâmico
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
                        // Opcional: Adicionar validação de formato se necessário
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