// lib/presentation/receita/prescricao_form_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_clinica_medica/domain/models/receita.dart';
import 'package:flutter_clinica_medica/domain/models/medicamento.dart';
import 'package:flutter_clinica_medica/domain/models/prescricao_medicamento.dart';
import 'package:flutter_clinica_medica/domain/models/paciente.dart'; // NOVO IMPORT
import 'package:flutter_clinica_medica/domain/repositories/receita_repository.dart';
import 'package:flutter_clinica_medica/domain/repositories/medicamento_repository.dart';
import 'package:flutter_clinica_medica/domain/repositories/prescricao_medicamento_repository.dart';
import 'package:flutter_clinica_medica/domain/repositories/paciente_repository.dart'; // NOVO IMPORT

class PrescricaoFormScreen extends StatefulWidget {
  final int? idReceita; // Para associar a uma receita existente, se for o caso
  const PrescricaoFormScreen({super.key, this.idReceita});

  static const String routeName = '/prescricao-form';

  @override
  State<PrescricaoFormScreen> createState() => _PrescricaoFormScreenState();
}

class _PrescricaoFormScreenState extends State<PrescricaoFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _dosagemController = TextEditingController();
  final _viaController = TextEditingController();
  final _frequenciaController = TextEditingController();

  Paciente? _selectedPaciente; // NOVO: Campo para o paciente selecionado
  Medicamento? _selectedMedicamento;
  List<Medicamento> _medicamentos = [];
  List<Paciente> _pacientes = []; // NOVO: Lista de pacientes
  bool _isLoadingDropdown = true;

  final ReceitaRepository _receitaRepository = ReceitaRepository();
  final MedicamentoRepository _medicamentoRepository = MedicamentoRepository();
  final PrescricaoMedicamentoRepository _prescricaoRepository = PrescricaoMedicamentoRepository();
  final PacienteRepository _pacienteRepository = PacienteRepository(); // NOVO: Repositório de paciente

  int? _currentReceitaId; // O ID da receita a ser usada para a prescrição

  @override
  void initState() {
    super.initState();
    _loadDataForDropdowns(); // Renomeado para carregar tudo
    _ensureReceitaExists();
  }

  // NOVO MÉTODO: Carrega pacientes e medicamentos
  Future<void> _loadDataForDropdowns() async {
    try {
      final medicamentos = await _medicamentoRepository.getAllMedicamentos();
      final pacientes = await _pacienteRepository.getAllPacientes(); // Carrega todos os pacientes
      setState(() {
        _medicamentos = medicamentos;
        _pacientes = pacientes; // Atualiza a lista de pacientes
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

  // Garante que uma Receita exista para vincular a prescrição
  Future<void> _ensureReceitaExists() async {
    if (widget.idReceita != null) {
      _currentReceitaId = widget.idReceita;
      return;
    }

    // Se não veio um idReceita, cria uma nova receita básica
    final newReceita = Receita(dataEmissao: DateTime.now(), observacoes: 'Receita gerada automaticamente');
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
      if (_selectedMedicamento == null || _selectedPaciente == null) { // VALIDAR SE PACIENTE FOI SELECIONADO
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Por favor, selecione o medicamento e o paciente.')),
        );
        return;
      }

      final prescricao = PrescricaoMedicamento(
        idReceita: _currentReceitaId!,
        idMedicamento: _selectedMedicamento!.idMedicamento!,
        dosagem: _dosagemController.text.isNotEmpty ? _dosagemController.text : null,
        via: _viaController.text.isNotEmpty ? _viaController.text : null,
        frequencia: _frequenciaController.text.isNotEmpty ? _frequenciaController.text : null,
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
    _dosagemController.clear();
    _viaController.clear();
    _frequenciaController.clear();
    setState(() {
      _selectedMedicamento = null;
      _selectedPaciente = null; // Limpa também o paciente selecionado
    });
  }

  @override
  void dispose() {
    _dosagemController.dispose();
    _viaController.dispose();
    _frequenciaController.dispose();
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
                    // NOVO CAMPO: Seleção de Paciente
                    DropdownButtonFormField<Paciente>(
                      value: _selectedPaciente,
                      decoration: const InputDecoration(labelText: 'Paciente'),
                      items: _pacientes.map((paciente) {
                        return DropdownMenuItem(
                          value: paciente,
                          child: Text('${paciente.nome} (CPF: ${paciente.cpf})'),
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

                    // Campo de Medicamento (já existente)
                    DropdownButtonFormField<Medicamento>(
                      value: _selectedMedicamento,
                      decoration: const InputDecoration(labelText: 'Medicamento'),
                      items: _medicamentos.map((med) {
                        return DropdownMenuItem(
                          value: med,
                          child: Text('${med.nome} (Estoque: ${med.estoqueAtual ?? 'N/A'})'),
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

                    // Demais campos de dosagem, via, frequência (já existentes)
                    TextFormField(
                      controller: _dosagemController,
                      decoration: const InputDecoration(labelText: 'Dosagem (Ex: 500mg)'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor, insira a dosagem';
                          }
                          return null;
                      },
                    ),
                    TextFormField(
                      controller: _viaController,
                      decoration: const InputDecoration(labelText: 'Via de Administração (Ex: Oral)'),
                    ),
                    TextFormField(
                      controller: _frequenciaController,
                      decoration: const InputDecoration(labelText: 'Frequência (Ex: 8/8h)'),
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