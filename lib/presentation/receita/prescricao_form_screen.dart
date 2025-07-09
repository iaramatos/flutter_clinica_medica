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
  final _quantidadeController = TextEditingController();

  Paciente? _selectedPaciente;
  Medicamento? _selectedMedicamento;
  String? _selectedDosagem;
  String? _selectedVia;
  String? _selectedFrequencia;

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
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao preparar receita: $e')),
      );
    }
  }

  // MÉTODO PRINCIPAL DE VERIFICAÇÃO DE SEGURANÇA (TRAVA DE ALERGIA)
  Future<void> _checkAllergyAndBlock(Medicamento? med) async {
    // Só continua se um paciente e um medicamento estiverem selecionados
    if (med == null || _selectedPaciente == null) {
      return;
    }

    final alergiasDoPaciente = _selectedPaciente!.alergias?.toLowerCase() ?? '';
    final nomeMedicamento = med.nome.toLowerCase();

    // Verifica se a string de alergias do paciente contém o nome do medicamento
    if (alergiasDoPaciente.isNotEmpty &&
        alergiasDoPaciente.contains(nomeMedicamento)) {
      // Usa o 'await' para esperar o dialogo ser fechado antes de continuar
      await showDialog(
        context: context,
        barrierDismissible: false, // Impede que o usuário feche clicando fora
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Row(
              children: [
                Icon(Icons.warning_amber_rounded, color: Colors.red),
                SizedBox(width: 10),
                Text('ALERTA DE ALERGIA!'),
              ],
            ),
            content: Text(
              'O paciente ${_selectedPaciente!.nome} possui alergia a "${med.nome}". A prescrição deste item será bloqueada.',
            ),
            actions: <Widget>[
              TextButton(
                child: const Text('Entendido'),
                onPressed: () {
                  Navigator.of(context).pop(); // Fecha o pop-up
                },
              ),
            ],
          );
        },
      );

      // AÇÃO DE BLOQUEIO: Limpa a seleção do medicamento problemático
      setState(() {
        _selectedMedicamento = null;
      });
    }
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate() && _currentReceitaId != null) {
      if (_selectedMedicamento == null ||
          _selectedPaciente == null ||
          _selectedDosagem == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text(
                  'Por favor, selecione o medicamento, paciente e dosagem.')),
        );
        return;
      }

      final quantidade = int.tryParse(_quantidadeController.text);
      if (quantidade == null || quantidade <= 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text(
                  'Por favor, insira uma quantidade válida para o medicamento.')),
        );
        return;
      }

      final prescricao = PrescricaoMedicamento(
        idReceita: _currentReceitaId!,
        idMedicamento: _selectedMedicamento!.idMedicamento!,
        dosagem: _selectedDosagem,
        via: _selectedVia,
        frequencia: _selectedFrequencia,
        quantidade: quantidade,
      );

      try {
        await _prescricaoRepository.insertPrescricaoMedicamento(prescricao);

        if (_selectedMedicamento != null &&
            _selectedMedicamento!.estoqueAtual != null) {
          final novoEstoque = _selectedMedicamento!.estoqueAtual! - quantidade;
          if (novoEstoque < 0) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                  content: Text('Estoque insuficiente para esta prescrição!'),
                  backgroundColor: Colors.red),
            );
          }
          final medicamentoAtualizado = Medicamento(
            idMedicamento: _selectedMedicamento!.idMedicamento,
            nome: _selectedMedicamento!.nome,
            descricao: _selectedMedicamento!.descricao,
            estoqueAtual: novoEstoque,
          );
          await _medicamentoRepository.updateMedicamento(medicamentoAtualizado);
        }

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
    _quantidadeController.clear();
    setState(() {
      _selectedMedicamento = null;
      _selectedPaciente = null;
      _selectedDosagem = null;
      _selectedVia = null;
      _selectedFrequencia = null;
    });
  }

  @override
  void dispose() {
    _quantidadeController.dispose();
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
                        // Checa a alergia caso um medicamento já esteja selecionado
                        _checkAllergyAndBlock(_selectedMedicamento);
                      },
                      validator: (value) =>
                          value == null ? 'Selecione o paciente' : null,
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
                        // AQUI ACONTECE A MÁGICA: chama a verificação ao selecionar
                        _checkAllergyAndBlock(newValue);
                      },
                      validator: (value) =>
                          value == null ? 'Selecione um medicamento' : null,
                    ),
                    const SizedBox(height: 10),

                    // CAMPO QUANTIDADE
                    TextFormField(
                      controller: _quantidadeController,
                      decoration:
                          const InputDecoration(labelText: 'Quantidade'),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null ||
                            value.isEmpty ||
                            int.tryParse(value) == null ||
                            int.parse(value) <= 0) {
                          return 'Por favor, insira uma quantidade válida';
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
                        DropdownMenuItem(value: '5mg', child: Text('5mg')),
                        DropdownMenuItem(value: '200mg', child: Text('200mg')),
                      ],
                      onChanged: (String? newValue) {
                        setState(() => _selectedDosagem = newValue);
                      },
                      validator: (value) => value == null || value.isEmpty
                          ? 'Por favor, insira a dosagem'
                          : null,
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
                            value: 'Subcutânea', child: Text('Subcutânea')),
                      ],
                      onChanged: (String? newValue) {
                        setState(() => _selectedVia = newValue);
                      },
                      validator: (value) => value == null || value.isEmpty
                          ? 'Por favor, insira a via de administração'
                          : null,
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
                            child: Text('De 6 em 6 horas')),
                      ],
                      onChanged: (String? newValue) {
                        setState(() => _selectedFrequencia = newValue);
                      },
                      validator: (value) => value == null || value.isEmpty
                          ? 'Por favor, insira a frequência'
                          : null,
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
