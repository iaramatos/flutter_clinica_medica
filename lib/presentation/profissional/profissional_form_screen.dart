// lib/presentation/profissional/profissional_form_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_clinica_medica/domain/models/profissional.dart';
import 'package:flutter_clinica_medica/domain/models/usuario.dart'; // NOVO IMPORT
import 'package:flutter_clinica_medica/domain/repositories/profissional_repository.dart';
import 'package:flutter_clinica_medica/domain/repositories/usuario_repository.dart'; // NOVO IMPORT

class ProfissionalFormScreen extends StatefulWidget {
  final Profissional? profissional;
  const ProfissionalFormScreen({super.key, this.profissional});

  static const String routeName = '/profissional-form';

  @override
  State<ProfissionalFormScreen> createState() => _ProfissionalFormScreenState();
}

class _ProfissionalFormScreenState extends State<ProfissionalFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  final _registroController = TextEditingController();
  final _emailController = TextEditingController();
  final _telefoneController = TextEditingController();

  String? _selectedTipoUsuario;
  String? _selectedEspecialidade;
  Usuario? _selectedUsuario; // NOVO: Campo para o usuário selecionado
  List<Usuario> _usuarios = []; // NOVO: Lista de usuários
  bool _isLoadingUsuarios = true; // NOVO: Para controlar o carregamento de usuários

  final ProfissionalRepository _profissionalRepository = ProfissionalRepository();
  final UsuarioRepository _usuarioRepository = UsuarioRepository(); // NOVO: Repositório de usuário

  @override
  void initState() {
    super.initState();
    _loadUsuarios(); // Carrega usuários no início
    if (widget.profissional != null) {
      _nomeController.text = widget.profissional!.nome;
      _selectedEspecialidade = widget.profissional!.especialidade;
      _registroController.text = widget.profissional!.registro ?? '';
      _emailController.text = widget.profissional!.email ?? '';
      _telefoneController.text = widget.profissional!.telefone ?? '';
      _selectedTipoUsuario = widget.profissional!.tipoUsuario;
    }
  }

  // NOVO MÉTODO: Carrega usuários para o dropdown
  Future<void> _loadUsuarios() async {
    try {
      final usuarios = await _usuarioRepository.getAllUsuarios();
      setState(() {
        _usuarios = usuarios;
        _isLoadingUsuarios = false;
        // Se estiver editando, pré-seleciona o usuário associado
        if (widget.profissional != null && widget.profissional!.idUsuario != null) {
          _selectedUsuario = usuarios.firstWhere(
            (u) => u.idUsuario == widget.profissional!.idUsuario,
            orElse: () => usuarios.isEmpty ? null as Usuario : usuarios.first,
          );
        }
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao carregar usuários: $e')),
      );
      setState(() {
        _isLoadingUsuarios = false;
      });
    }
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      final profissional = Profissional(
        idProfissional: widget.profissional?.idProfissional,
        idUsuario: _selectedUsuario?.idUsuario, // NOVO: Atribui o ID do Usuário
        nome: _nomeController.text,
        especialidade: _selectedEspecialidade,
        registro: _registroController.text.isNotEmpty ? _registroController.text : null,
        email: _emailController.text.isNotEmpty ? _emailController.text : null,
        telefone: _telefoneController.text.isNotEmpty ? _telefoneController.text : null,
        tipoUsuario: _selectedTipoUsuario ?? 'recepcionista',
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
        Navigator.of(context).pop();
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
    _registroController.dispose();
    _emailController.dispose();
    _telefoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool isMedico = _selectedTipoUsuario == 'medico';

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.profissional == null ? 'Cadastro de Profissional' : 'Editar Profissional'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: _isLoadingUsuarios // NOVO: Condicional para carregar usuários
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: ListView(
                  children: [
                    // NOVO CAMPO: Seleção de Usuário
                    DropdownButtonFormField<Usuario>(
                      value: _selectedUsuario,
                      decoration: const InputDecoration(labelText: 'Vincular à Conta de Usuário (Opcional)'),
                      items: _usuarios.map((usuario) {
                        return DropdownMenuItem(
                          value: usuario,
                          child: Text('${usuario.username} (${usuario.tipo})'),
                        );
                      }).toList(),
                      onChanged: (Usuario? newValue) {
                        setState(() {
                          _selectedUsuario = newValue;
                        });
                      },
                      // Não obrigatório, por isso sem validator aqui
                    ),
                    const SizedBox(height: 10),

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
                          if (newValue != 'medico') {
                            _selectedEspecialidade = null;
                            _registroController.clear();
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
                    if (isMedico)
                      Column(
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
                          const SizedBox(height: 10),
                        ],
                      ),
                    if (isMedico)
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
                    const SizedBox(height: 20),
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