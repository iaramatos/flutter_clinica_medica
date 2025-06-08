// lib/presentation/profissional/profissional_form_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_clinica_medica/domain/models/profissional.dart';
import 'package:flutter_clinica_medica/domain/repositories/profissional_repository.dart';

class ProfissionalFormScreen extends StatefulWidget {
  final Profissional? profissional; // Opcional, para edição
  const ProfissionalFormScreen({super.key, this.profissional});

  static const String routeName = '/profissional-form';

  @override
  State<ProfissionalFormScreen> createState() => _ProfissionalFormScreenState();
}

class _ProfissionalFormScreenState extends State<ProfissionalFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  // REMOVIDO: final _especialidadeController = TextEditingController(); // Removido, pois usaremos Dropdown
  final _registroController = TextEditingController();
  final _emailController = TextEditingController();
  final _telefoneController = TextEditingController();

  String? _selectedTipoUsuario; // Para o ENUM tipoUsuario
  String? _selectedEspecialidade; // NOVO: Variável para a especialidade selecionada no Dropdown

  final ProfissionalRepository _profissionalRepository = ProfissionalRepository();

  @override
  void initState() {
    super.initState();
    if (widget.profissional != null) {
      _nomeController.text = widget.profissional!.nome;
      _selectedEspecialidade = widget.profissional!.especialidade; // Pré-seleciona a especialidade
      _registroController.text = widget.profissional!.registro ?? '';
      _emailController.text = widget.profissional!.email ?? '';
      _telefoneController.text = widget.profissional!.telefone ?? '';
      _selectedTipoUsuario = widget.profissional!.tipoUsuario;
    }
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      final profissional = Profissional(
        idProfissional: widget.profissional?.idProfissional, // Para edição
        nome: _nomeController.text,
        especialidade: _selectedEspecialidade, // Usar o valor do dropdown
        registro: _registroController.text.isNotEmpty ? _registroController.text : null,
        email: _emailController.text.isNotEmpty ? _emailController.text : null,
        telefone: _telefoneController.text.isNotEmpty ? _telefoneController.text : null,
        tipoUsuario: _selectedTipoUsuario ?? 'recepcionista', // Padrão se não selecionado
      );

      try {
        if (profissional.idProfissional == null) {
          await _profissionalRepository.insertProfissional(profissional);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Profissional salvo com sucesso!')),
          );
        } else {
          await _profissionalRepository.updateProfissional(profissional);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Profissional atualizado com sucesso!')),
          );
        }
        Navigator.of(context).pop(); // Volta para a lista
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao salvar profissional: $e')),
        );
      }
    }
  }

  @override
  void dispose() {
    _nomeController.dispose();
    // REMOVIDO: _especialidadeController.dispose(); // Removido
    _registroController.dispose();
    _emailController.dispose();
    _telefoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool isMedico = _selectedTipoUsuario == 'medico'; // Variável para controlar visibilidade

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.profissional == null ? 'Cadastro de Profissional' : 'Editar Profissional'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
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
                    return 'Por favor, insira o nome do profissional';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                keyboardType: TextInputType.emailAddress,
              ),
              TextFormField(
                controller: _telefoneController,
                decoration: const InputDecoration(labelText: 'Telefone'),
                keyboardType: TextInputType.phone,
              ),
              // CAMPO TIPO DE USUÁRIO (Já existe, mas é a base para o condicional)
              DropdownButtonFormField<String>(
                value: _selectedTipoUsuario,
                decoration: const InputDecoration(labelText: 'Tipo de Usuário'),
                items: const [
                  DropdownMenuItem(value: 'admin', child: Text('Administrador')),
                  DropdownMenuItem(value: 'medico', child: Text('Médico')),
                  DropdownMenuItem(value: 'enfermeiro', child: Text('Enfermeiro')),
                  DropdownMenuItem(value: 'recepcionista', child: Text('Recepcionista')),
                ],
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedTipoUsuario = newValue;
                    // Limpa especialidade/registro se não for médico
                    if (newValue != 'medico') {
                      _selectedEspecialidade = null;
                      _registroController.clear(); // Limpa o controller do registro
                    }
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, selecione o tipo de usuário';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 10),

              // CAMPO ESPECIALIDADE (CONDICIONAL COM DROPDOWN)
              if (isMedico) // SÓ APARECE SE FOR MÉDICO
                Column( // Usar Column para agrupar e aplicar SizedBox entre eles
                  children: [
                    DropdownButtonFormField<String>(
                      value: _selectedEspecialidade,
                      decoration: const InputDecoration(labelText: 'Especialidade'),
                      items: const [
                        DropdownMenuItem(value: 'Clínico Geral', child: Text('Clínico Geral')),
                        DropdownMenuItem(value: 'Cardiologia', child: Text('Cardiologia')),
                        DropdownMenuItem(value: 'Dermatologia', child: Text('Dermatologia')),
                        DropdownMenuItem(value: 'Pediatria', child: Text('Pediatria')),
                        DropdownMenuItem(value: 'Ginecologia', child: Text('Ginecologia')),
                        // Adicione mais especialidades conforme necessário
                      ],
                      onChanged: (String? newValue) {
                        setState(() {
                          _selectedEspecialidade = newValue;
                        });
                      },
                      validator: (value) {
                        if (isMedico && (value == null || value.isEmpty)) {
                          return 'Selecione a especialidade do médico';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 10), // Espaçamento entre especialidade e registro
                  ],
                ),
              
              // CAMPO REGISTRO (CONDICIONAL)
              if (isMedico) // SÓ APARECE SE FOR MÉDICO
                TextFormField(
                  controller: _registroController,
                  decoration: const InputDecoration(labelText: 'Registro (CRM/COREN/etc.)'),
                  validator: (value) {
                    if (isMedico && (value == null || value.isEmpty)) {
                      return 'Por favor, insira o registro do profissional';
                    }
                    return null;
                  },
                ),
              const SizedBox(height: 20), // Espaçamento antes do botão

              ElevatedButton(
                onPressed: _submitForm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                ),
                child: const Text('Salvar Profissional'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}