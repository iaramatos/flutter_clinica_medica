// lib/presentation/paciente/paciente_form_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_clinica_medica/domain/models/paciente.dart';
import 'package:flutter_clinica_medica/domain/models/usuario.dart'; // NOVO IMPORT
import 'package:flutter_clinica_medica/domain/repositories/paciente_repository.dart';
import 'package:flutter_clinica_medica/domain/repositories/usuario_repository.dart'; // NOVO IMPORT
import 'package:intl/intl.dart';

class PacienteFormScreen extends StatefulWidget {
  final Paciente? paciente;
  const PacienteFormScreen({super.key, this.paciente});

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
  final _alergiasController = TextEditingController();
  final _condicoesPreExistentesController = TextEditingController();

  String? _selectedConvenio;
  Usuario? _selectedUsuario; // NOVO: Campo para o usuário selecionado
  List<Usuario> _usuarios = []; // NOVO: Lista de usuários
  bool _isLoadingUsuarios = true; // NOVO: Para controlar o carregamento de usuários

  final PacienteRepository _pacienteRepository = PacienteRepository();
  final UsuarioRepository _usuarioRepository = UsuarioRepository(); // NOVO: Repositório de usuário

  @override
  void initState() {
    super.initState();
    _loadUsuarios(); // Carrega usuários no início
    if (widget.paciente != null) {
      _nomeController.text = widget.paciente!.nome;
      _cpfController.text = widget.paciente!.cpf;
      if (widget.paciente!.dataNascimento != null) {
        _dataNascimentoController.text = DateFormat('dd-MM-yyyy').format(widget.paciente!.dataNascimento!);
      }
      _telefoneController.text = widget.paciente!.telefone ?? '';
      _emailController.text = widget.paciente!.email ?? '';
      _enderecoController.text = widget.paciente!.endereco ?? '';
      _selectedConvenio = widget.paciente!.convenio;
      _alergiasController.text = widget.paciente!.alergias ?? '';
      _condicoesPreExistentesController.text = widget.paciente!.condicoesPreExistentes ?? '';
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
        if (widget.paciente != null && widget.paciente!.idUsuario != null) {
          _selectedUsuario = usuarios.firstWhere(
            (u) => u.idUsuario == widget.paciente!.idUsuario,
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

  Future<void> _selectDataNascimento(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      locale: const Locale('pt', 'BR'),
    );
    if (picked != null) {
      setState(() {
        _dataNascimentoController.text = DateFormat('dd-MM-yyyy').format(picked);
      });
    }
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      final paciente = Paciente(
        idPaciente: widget.paciente?.idPaciente,
        idUsuario: _selectedUsuario?.idUsuario, // NOVO: Atribui o ID do Usuário
        nome: _nomeController.text,
        cpf: _cpfController.text,
        dataNascimento: _dataNascimentoController.text.isNotEmpty
            ? DateFormat('dd-MM-yyyy').parse(_dataNascimentoController.text)
            : null,
        telefone: _telefoneController.text.isNotEmpty ? _telefoneController.text : null,
        email: _emailController.text.isNotEmpty ? _emailController.text : null,
        endereco: _enderecoController.text.isNotEmpty ? _enderecoController.text : null,
        convenio: _selectedConvenio,
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
        Navigator.of(context).pop();
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
    _alergiasController.clear();
    _condicoesPreExistentesController.clear();
    setState(() {
      _selectedConvenio = null;
      _selectedUsuario = null; // NOVO: Limpa o usuário selecionado
    });
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _cpfController.dispose();
    _dataNascimentoController.dispose();
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
        title: Text(widget.paciente == null ? 'Cadastro de Paciente' : 'Editar Paciente'),
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
                        return null;
                      },
                    ),
                    TextFormField(
                      controller: _dataNascimentoController,
                      decoration: InputDecoration(
                        labelText: 'Data de Nascimento (DD-MM-YYYY)',
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.calendar_today),
                          onPressed: () => _selectDataNascimento(context),
                        ),
                      ),
                      readOnly: true,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor, insira a data de nascimento';
                        }
                        return null;
                      },
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
                      decoration: const InputDecoration(labelText: 'Endereço Completo'),
                      maxLines: 2,
                    ),
                    DropdownButtonFormField<String>(
                      value: _selectedConvenio,
                      decoration: const InputDecoration(labelText: 'Convênio Médico'),
                      items: const [
                        DropdownMenuItem(value: 'Particular', child: Text('Particular')),
                        DropdownMenuItem(value: 'Unimed', child: Text('Unimed')),
                        DropdownMenuItem(value: 'Epsemg', child: Text('Epsemg')),
                        DropdownMenuItem(value: 'Bradesco Saúde', child: Text('Bradesco Saúde')),
                        DropdownMenuItem(value: 'Amil', child: Text('Amil')),
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
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: _alergiasController,
                      decoration: const InputDecoration(labelText: 'Alergias'),
                      maxLines: 2,
                    ),
                    const SizedBox(height: 10),
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