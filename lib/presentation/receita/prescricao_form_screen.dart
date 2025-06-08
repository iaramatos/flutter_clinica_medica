// lib/presentation/receita/prescricao_form_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_clinica_medica/domain/models/medicamento.dart';
import 'package:flutter_clinica_medica/domain/models/paciente.dart';
import 'package:flutter_clinica_medica/domain/models/prescricao_medicamento.dart';
import 'package:flutter_clinica_medica/domain/models/receita.dart';
import 'package:flutter_clinica_medica/domain/repositories/medicamento_repository.dart';
import 'package:flutter_clinica_medica/domain/repositories/paciente_repository.dart';
import 'package:flutter_clinica_medica/domain/repositories/prescricao_medicamento_repository.dart';
import 'package:flutter_clinica_medica/domain/repositories/receita_repository.dart';

class PrescricaoFormScreen extends StatefulWidget {
  final int? idReceita;
  const PrescricaoFormScreen({super.key, this.idReceita});

  static const String routeName = '/prescricao-form';

  @override
  State<PrescricaoFormScreen> createState() => _PrescricaoFormScreenState();
}

class _PrescricaoFormScreenState extends State<PrescricaoFormScreen> {
  final _formKey = GlobalKey<FormState>();
  // REMOVIDO: final _dosagemController = TextEditingController();
  // REMOVIDO: final _viaController = TextEditingController();
  // REMOVIDO: final _frequenciaController = TextEditingController();

  Paciente? _selectedPaciente;
  Medicamento? _selectedMedicamento;
  String? _selectedDosagem; // NOVO: Para Dosagem
  String? _selectedVia; // NOVO: Para Via
  String? _selectedFrequencia; // NOVO: Para Frequência

  List<Medicamento> _medicamentos = [];
  List<Paciente> _pacientes = [];
  bool _isLoadingDropdown = true;

  final ReceitaRepository _receitaRepository = ReceitaRepository();
  final MedicamentoRepository _medicamentoRepository = MedicamentoRepository();
  final PrescricaoMedicamentoRepository _prescricaoRepository =
      PrescricaoMedicamentoRepository();
  final PacienteRepository _pacienteRepository = PacienteRepository();

  int? _currentReceitaId;

  @override
  void initState() {
    super.initState();
    _loadDataForDropdowns();
    _ensureReceitaExists();
  }

  Future<void> _loadDataForDropdowns() async {
    try {
      final medicamentos = await _medicamentoRepository.getAllMedicamentos();
      final pacientes = await _pacienteRepository.getAllPacientes();
      setState(() {
        _medicamentos = medicamentos;
        _pacientes = pacientes;
        _isLoadingDropdown = false;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao carregar dados: $e')),
      );
      setState(() {
        _isLoadingDropdown = false;
      });
    }
  }

  Future<void> _ensureReceitaExists() async {
    if (widget.idReceita != null) {
      _currentReceitaId = widget.idReceita;
      return;
    }

    final newReceita = Receita(
        dataEmissao: DateTime.now(),
        observacoes: 'Receita gerada automaticamente');
    try {
      _currentReceitaId = await _receitaRepository.insertReceita(newReceita);
      print('Nova receita criada automaticamente com ID: $_currentReceitaId');
    } catch (e) {
      print('Erro ao criar nova receita automaticamente: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao preparar receita: $e')),
      );
    }
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate() && _currentReceitaId != null) {
      if (_selectedMedicamento == null ||
          _selectedPaciente == null ||
          _selectedDosagem == null) {
        // Adicionado validação para dosagem
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text(
                  'Por favor, selecione o medicamento, paciente e dosagem.')),
        );
        return;
      }

      final prescricao = PrescricaoMedicamento(
        idReceita: _currentReceitaId!,
        idMedicamento: _selectedMedicamento!.idMedicamento!,
        dosagem: _selectedDosagem, // Usar o valor do dropdown
        via: _selectedVia, // Usar o valor do dropdown
        frequencia: _selectedFrequencia, // Usar o valor do dropdown
      );

      try {
        await _prescricaoRepository.insertPrescricaoMedicamento(prescricao);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Prescrição adicionada com sucesso!')),
        );
        _clearForm();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao adicionar prescrição: $e')),
        );
      }
    }
  }

  void _clearForm() {
    // REMOVIDO: _dosagemController.clear();
    // REMOVIDO: _viaController.clear();
    // REMOVIDO: _frequenciaController.clear();
    setState(() {
      _selectedMedicamento = null;
      _selectedPaciente = null;
      _selectedDosagem = null; // Limpa Dosagem
      _selectedVia = null; // Limpa Via
      _selectedFrequencia = null; // Limpa Frequência
    });
  }

  @override
  void dispose() {
    // REMOVIDO: _dosagemController.dispose();
    // REMOVIDO: _viaController.dispose();
    // REMOVIDO: _frequenciaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Prescrever Medicamento'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: _isLoadingDropdown
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: ListView(
                  children: [
                    // CAMPO: Seleção de Paciente
                    DropdownButtonFormField<Paciente>(
                      value: _selectedPaciente,
                      decoration: const InputDecoration(labelText: 'Paciente'),
                      items: _pacientes.map((paciente) {
                        return DropdownMenuItem(
                          value: paciente,
                          child:
                              Text('${paciente.nome} (CPF: ${paciente.cpf})'),
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

                    // Campo de Medicamento
                    DropdownButtonFormField<Medicamento>(
                      value: _selectedMedicamento,
                      decoration:
                          const InputDecoration(labelText: 'Medicamento'),
                      items: _medicamentos.map((med) {
                        return DropdownMenuItem(
                          value: med,
                          child: Text(
                              '${med.nome} (Estoque: ${med.estoqueAtual ?? 'N/A'})'),
                        );
                      }).toList(),
                      onChanged: (Medicamento? newValue) {
                        setState(() {
                          _selectedMedicamento = newValue;
                        });
                      },
                      validator: (value) {
                        if (value == null) {
                          return 'Selecione um medicamento';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 10),

                    // CAMPO DOSAGEM (COM DROPDOWN)
                    DropdownButtonFormField<String>(
                      value: _selectedDosagem,
                      decoration: const InputDecoration(labelText: 'Dosagem'),
                      items: const [
                        DropdownMenuItem(value: '500mg', child: Text('500mg')),
                        DropdownMenuItem(value: '250mg', child: Text('250mg')),
                        DropdownMenuItem(value: '10mg', child: Text('10mg')),
                        DropdownMenuItem(
                            value: '5mg', child: Text('5mg')), // Mais uma opção
                        DropdownMenuItem(
                            value: '200mg',
                            child: Text('200mg')), // Mais uma opção
                        // Adicione mais dosagens comuns
                      ],
                      onChanged: (String? newValue) {
                        setState(() {
                          _selectedDosagem = newValue;
                        });
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor, insira a dosagem';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 10),

                    // CAMPO VIA DE ADMINISTRAÇÃO (COM DROPDOWN)
                    DropdownButtonFormField<String>(
                      value: _selectedVia,
                      decoration: const InputDecoration(
                          labelText: 'Via de Administração'),
                      items: const [
                        DropdownMenuItem(value: 'Oral', child: Text('Oral')),
                        DropdownMenuItem(
                            value: 'Intravenosa', child: Text('Intravenosa')),
                        DropdownMenuItem(
                            value: 'Tópica', child: Text('Tópica')),
                        DropdownMenuItem(
                            value: 'Subcutânea',
                            child: Text('Subcutânea')), // Mais uma opção
                        // Adicione mais vias comuns
                      ],
                      onChanged: (String? newValue) {
                        setState(() {
                          _selectedVia = newValue;
                        });
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor, insira a via de administração';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 10),

                    // CAMPO FREQUÊNCIA (COM DROPDOWN)
                    DropdownButtonFormField<String>(
                      value: _selectedFrequencia,
                      decoration:
                          const InputDecoration(labelText: 'Frequência'),
                      items: const [
                        DropdownMenuItem(value: '8/8h', child: Text('8/8h')),
                        DropdownMenuItem(
                            value: '12/12h', child: Text('12/12h')),
                        DropdownMenuItem(
                            value: '24/24h', child: Text('24/24h')),
                        DropdownMenuItem(
                            value: 'Uma vez ao dia',
                            child: Text('Uma vez ao dia')),
                        DropdownMenuItem(
                            value: 'De 6 em 6 horas',
                            child: Text('De 6 em 6 horas')), // Mais uma opção
                        // Adicione mais frequências comuns
                      ],
                      onChanged: (String? newValue) {
                        setState(() {
                          _selectedFrequencia = newValue;
                        });
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor, insira a frequência';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),

                    ElevatedButton(
                      onPressed: _submitForm,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                      ),
                      child: const Text('Adicionar Prescrição'),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
