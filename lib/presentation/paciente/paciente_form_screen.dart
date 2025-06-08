// lib/presentation/paciente/paciente_form_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_clinica_medica/domain/models/paciente.dart';
import 'package:flutter_clinica_medica/domain/repositories/paciente_repository.dart';
import 'package:intl/intl.dart'; // Importe para formatação de data

class PacienteFormScreen extends StatefulWidget {
  final Paciente? paciente; // Adicionado para suportar edição
  const PacienteFormScreen({super.key, this.paciente});

  static const String routeName = '/paciente-form';

  @override
  State<PacienteFormScreen> createState() => _PacienteFormScreenState();
}

class _PacienteFormScreenState extends State<PacienteFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  final _cpfController = TextEditingController();
  final _dataNascimentoController = TextEditingController(); // Controller para a data
  final _telefoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _enderecoController = TextEditingController();
  // final _convenioController = TextEditingController(); // REMOVIDO: Usaremos Dropdown
  final _alergiasController = TextEditingController(); // NOVO
  final _condicoesPreExistentesController = TextEditingController(); // NOVO

  String? _selectedConvenio; // NOVO: Variável para o convênio selecionado no Dropdown

  final PacienteRepository _pacienteRepository = PacienteRepository();

  @override
  void initState() {
    super.initState();
    // Preenche os campos se estiver em modo de edição
    if (widget.paciente != null) {
      _nomeController.text = widget.paciente!.nome;
      _cpfController.text = widget.paciente!.cpf;
      if (widget.paciente!.dataNascimento != null) {
        // Formata a data de nascimento para DD-MM-YYYY para exibir
        _dataNascimentoController.text = DateFormat('dd-MM-yyyy').format(widget.paciente!.dataNascimento!);
      }
      _telefoneController.text = widget.paciente!.telefone ?? '';
      _emailController.text = widget.paciente!.email ?? '';
      _enderecoController.text = widget.paciente!.endereco ?? '';
      _selectedConvenio = widget.paciente!.convenio; // Define o convênio selecionado
      _alergiasController.text = widget.paciente!.alergias ?? ''; // Pré-preenche
      _condicoesPreExistentesController.text = widget.paciente!.condicoesPreExistentes ?? ''; // Pré-preenche
    }
  }

  // NOVO MÉTODO: Seletor de Data de Nascimento
  Future<void> _selectDataNascimento(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(), // Data inicial do calendário
      firstDate: DateTime(1900),   // Primeira data possível
      lastDate: DateTime.now(),    // Última data possível (hoje)
      locale: const Locale('pt', 'BR'), // Opcional: para calendário em português
    );
    if (picked != null) {
      setState(() {
        // Formata a data selecionada para DD-MM-YYYY para exibir no campo
        _dataNascimentoController.text = DateFormat('dd-MM-yyyy').format(picked);
      });
    }
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      final paciente = Paciente(
        idPaciente: widget.paciente?.idPaciente, // Mantém o ID para edição
        nome: _nomeController.text,
        cpf: _cpfController.text,
        dataNascimento: _dataNascimentoController.text.isNotEmpty
            ? DateFormat('dd-MM-yyyy').parse(_dataNascimentoController.text) // Converte de volta para DateTime para o banco
            : null,
        telefone: _telefoneController.text.isNotEmpty ? _telefoneController.text : null,
        email: _emailController.text.isNotEmpty ? _emailController.text : null,
        endereco: _enderecoController.text.isNotEmpty ? _enderecoController.text : null,
        convenio: _selectedConvenio, // Usar o valor do dropdown
        alergias: _alergiasController.text.isNotEmpty ? _alergiasController.text : null,
        condicoesPreExistentes: _condicoesPreExistentesController.text.isNotEmpty ? _condicoesPreExistentesController.text : null,
      );

      try {
        if (paciente.idPaciente == null) {
          await _pacienteRepository.insertPaciente(paciente);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Paciente salvo com sucesso!')),
          );
        } else {
          await _pacienteRepository.updatePaciente(paciente);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Paciente atualizado com sucesso!')),
          );
        }
        Navigator.of(context).pop(); // Volta para a lista após salvar
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao salvar paciente: $e')),
        );
      }
    }
  }

  void _clearForm() {
    _nomeController.clear();
    _cpfController.clear();
    _dataNascimentoController.clear(); // Limpa também o campo de data
    _telefoneController.clear();
    _emailController.clear();
    _enderecoController.clear();
    _alergiasController.clear();
    _condicoesPreExistentesController.clear();
    setState(() {
      _selectedConvenio = null; // Limpa a seleção do dropdown
    });
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _cpfController.dispose();
    _dataNascimentoController.dispose(); // Dispose do novo controller
    _telefoneController.dispose();
    _emailController.dispose();
    _enderecoController.dispose();
    _alergiasController.dispose();
    _condicoesPreExistentesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.paciente == null ? 'Cadastro de Paciente' : 'Editar Paciente'), // Título dinâmico
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // CAMPO: Nome Completo
              TextFormField(
                controller: _nomeController,
                decoration: const InputDecoration(labelText: 'Nome Completo'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira o nome do paciente';
                  }
                  return null;
                },
              ),
              // CAMPO: CPF
              TextFormField(
                controller: _cpfController,
                decoration: const InputDecoration(labelText: 'CPF'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira o CPF';
                  }
                  return null;
                },
              ),
              // CAMPO DATA DE NASCIMENTO (COM DATE PICKER E FORMATO DD-MM-YYYY)
              TextFormField(
                controller: _dataNascimentoController,
                decoration: InputDecoration(
                  labelText: 'Data de Nascimento (DD-MM-YYYY)',
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.calendar_today),
                    onPressed: () => _selectDataNascimento(context),
                  ),
                ),
                readOnly: true, // Impede digitação manual
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira a data de nascimento';
                  }
                  return null;
                },
              ),
              // CAMPO: Telefone
              TextFormField(
                controller: _telefoneController,
                decoration: const InputDecoration(labelText: 'Telefone'),
                keyboardType: TextInputType.phone,
              ),
              // CAMPO: Email
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                keyboardType: TextInputType.emailAddress,
              ),
              // CAMPO: Endereço (MANTIDO COMO TEXTO LIVRE POR ENQUANTO)
              TextFormField(
                controller: _enderecoController,
                decoration: const InputDecoration(labelText: 'Endereço Completo'),
                maxLines: 2,
              ),
              // CAMPO CONVÊNIO (COM DROPDOWN)
              DropdownButtonFormField<String>(
                value: _selectedConvenio,
                decoration: const InputDecoration(labelText: 'Convênio Médico'),
                items: const [
                  DropdownMenuItem(value: 'Particular', child: Text('Particular')),
                  DropdownMenuItem(value: 'Unimed', child: Text('Unimed')),
                  DropdownMenuItem(value: 'Epsemg', child: Text('Epsemg')),
                  DropdownMenuItem(value: 'Bradesco Saúde', child: Text('Bradesco Saúde')),
                  DropdownMenuItem(value: 'Amil', child: Text('Amil')),
                  // Adicione mais convênios conforme necessário
                ],
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedConvenio = newValue;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Selecione o convênio';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 10), // Espaçamento entre os campos

              // CAMPO: Alergias (NOVO)
              TextFormField(
                controller: _alergiasController,
                decoration: const InputDecoration(labelText: 'Alergias'),
                maxLines: 2,
              ),
              const SizedBox(height: 10),
              // CAMPO: Condições Pré-existentes (NOVO)
              TextFormField(
                controller: _condicoesPreExistentesController,
                decoration: const InputDecoration(labelText: 'Condições Pré-existentes'),
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
                child: const Text('Salvar Paciente'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}