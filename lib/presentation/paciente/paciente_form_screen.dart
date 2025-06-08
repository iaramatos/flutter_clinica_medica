// lib/presentation/paciente/paciente_form_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_clinica_medica/domain/models/paciente.dart';
import 'package:flutter_clinica_medica/domain/repositories/paciente_repository.dart';

class PacienteFormScreen extends StatefulWidget {
  const PacienteFormScreen({super.key});

  static const String routeName = '/paciente-form';

  @override
  State<PacienteFormScreen> createState() => _PacienteFormScreenState();
}

class _PacienteFormScreenState extends State<PacienteFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  final _cpfController = TextEditingController();
  final _dataNascimentoController = TextEditingController();
  final _telefoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _enderecoController = TextEditingController();
  final _convenioController = TextEditingController();

  final PacienteRepository _pacienteRepository = PacienteRepository();

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      final paciente = Paciente(
        nome: _nomeController.text,
        cpf: _cpfController.text,
        dataNascimento: _dataNascimentoController.text.isNotEmpty
            ? DateTime.tryParse(_dataNascimentoController.text)
            : null,
        telefone: _telefoneController.text.isNotEmpty ? _telefoneController.text : null,
        email: _emailController.text.isNotEmpty ? _emailController.text : null,
        endereco: _enderecoController.text.isNotEmpty ? _enderecoController.text : null,
        convenio: _convenioController.text.isNotEmpty ? _convenioController.text : null,
      );

      try {
        await _pacienteRepository.insertPaciente(paciente);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Paciente salvo com sucesso!')),
        );
        _clearForm(); // Limpa o formulário após o sucesso
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
    _dataNascimentoController.clear();
    _telefoneController.clear();
    _emailController.clear();
    _enderecoController.clear();
    _convenioController.clear();
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _cpfController.dispose();
    _dataNascimentoController.dispose();
    _telefoneController.dispose();
    _emailController.dispose();
    _enderecoController.dispose();
    _convenioController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cadastro de Paciente'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white, // Para o texto do título e ícones
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
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
              TextFormField(
                controller: _cpfController,
                decoration: const InputDecoration(labelText: 'CPF'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira o CPF';
                  }
                  // Adicionar validação de CPF mais robusta se necessário
                  return null;
                },
              ),
              TextFormField(
                controller: _dataNascimentoController,
                decoration: const InputDecoration(labelText: 'Data de Nascimento (YYYY-MM-DD)'),
                keyboardType: TextInputType.datetime,
                // Opcional: Adicionar um seletor de data (DatePicker)
              ),
              TextFormField(
                controller: _telefoneController,
                decoration: const InputDecoration(labelText: 'Telefone'),
                keyboardType: TextInputType.phone,
              ),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                keyboardType: TextInputType.emailAddress,
              ),
              TextFormField(
                controller: _enderecoController,
                decoration: const InputDecoration(labelText: 'Endereço'),
              ),
              TextFormField(
                controller: _convenioController,
                decoration: const InputDecoration(labelText: 'Convênio Médico'),
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