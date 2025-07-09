// lib/presentation/paciente/paciente_form_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_clinica_medica/domain/models/medicamento.dart';
import 'package:flutter_clinica_medica/domain/models/paciente.dart';
import 'package:flutter_clinica_medica/domain/models/usuario.dart';
import 'package:flutter_clinica_medica/domain/repositories/medicamento_repository.dart';
import 'package:flutter_clinica_medica/domain/repositories/paciente_repository.dart';
import 'package:flutter_clinica_medica/domain/repositories/usuario_repository.dart';
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
  final _condicoesPreExistentesController = TextEditingController();

  String? _selectedConvenio;
  Usuario? _selectedUsuario;
  List<Usuario> _usuarios = [];
  bool _isLoading = true;

  // Estados para o seletor de alergias
  final MedicamentoRepository _medicamentoRepository = MedicamentoRepository();
  List<Medicamento> _allMedicamentos = [];
  List<Medicamento> _selectedAlergias = [];

  final PacienteRepository _pacienteRepository = PacienteRepository();
  final UsuarioRepository _usuarioRepository = UsuarioRepository();

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    setState(() => _isLoading = true);
    try {
      final results = await Future.wait([
        _usuarioRepository.getAllUsuarios(),
        _medicamentoRepository.getAllMedicamentos(),
      ]);
      _usuarios = results[0] as List<Usuario>;
      _allMedicamentos = results[1] as List<Medicamento>;

      if (widget.paciente != null) {
        _fillFormWithPacienteData();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao carregar dados iniciais: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _fillFormWithPacienteData() {
    final paciente = widget.paciente!;
    _nomeController.text = paciente.nome;
    _cpfController.text = paciente.cpf;
    if (paciente.dataNascimento != null) {
      _dataNascimentoController.text =
          DateFormat('dd-MM-yyyy').format(paciente.dataNascimento!);
    }
    _telefoneController.text = paciente.telefone ?? '';
    _emailController.text = paciente.email ?? '';
    _enderecoController.text = paciente.endereco ?? '';
    _selectedConvenio = paciente.convenio;
    _condicoesPreExistentesController.text =
        paciente.condicoesPreExistentes ?? '';

    if (paciente.idUsuario != null) {
      // Correção: usa 'try-first' para evitar erro se o usuário não for encontrado.
      _selectedUsuario =
          _usuarios.where((u) => u.idUsuario == paciente.idUsuario).firstOrNull;
    }

    if (paciente.alergias != null && paciente.alergias!.isNotEmpty) {
      final alergiasNomes = paciente.alergias!
          .split(',')
          .map((e) => e.trim().toLowerCase())
          .toSet();
      _selectedAlergias = _allMedicamentos
          .where((med) => alergiasNomes.contains(med.nome.toLowerCase()))
          .toList();
    }
  }

  Future<void> _showMultiSelectAlergias() async {
    final List<Medicamento> tempSelectedAlergias = List.from(_selectedAlergias);
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Selecione as Alergias'),
          content: SizedBox(
            width: double.maxFinite,
            child: StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
                return ListView.builder(
                  itemCount: _allMedicamentos.length,
                  itemBuilder: (BuildContext context, int index) {
                    final medicamento = _allMedicamentos[index];
                    final bool isSelected = tempSelectedAlergias.any((item) =>
                        item.idMedicamento == medicamento.idMedicamento);
                    return CheckboxListTile(
                      title: Text(medicamento.nome),
                      value: isSelected,
                      onChanged: (bool? value) {
                        setState(() {
                          if (value == true) {
                            tempSelectedAlergias.add(medicamento);
                          } else {
                            tempSelectedAlergias.removeWhere((item) =>
                                item.idMedicamento ==
                                medicamento.idMedicamento);
                          }
                        });
                      },
                    );
                  },
                );
              },
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancelar'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            ElevatedButton(
              child: const Text('Confirmar'),
              onPressed: () {
                setState(() {
                  _selectedAlergias = tempSelectedAlergias;
                });
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
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
        _dataNascimentoController.text =
            DateFormat('dd-MM-yyyy').format(picked);
      });
    }
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      final String alergiasText =
          _selectedAlergias.map((m) => m.nome).join(', ');

      DateTime? dataNascimento;
      try {
        if (_dataNascimentoController.text.isNotEmpty) {
          dataNascimento =
              DateFormat('dd-MM-yyyy').parse(_dataNascimentoController.text);
        }
      } catch (e) {
        // Lida com data inválida, embora o DatePicker minimize isso.
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Formato de data inválido. Use DD-MM-YYYY.')),
        );
        return;
      }

      final paciente = Paciente(
        idPaciente: widget.paciente?.idPaciente,
        idUsuario: _selectedUsuario?.idUsuario,
        nome: _nomeController.text,
        cpf: _cpfController.text,
        dataNascimento: dataNascimento,
        telefone: _telefoneController.text.isNotEmpty
            ? _telefoneController.text
            : null,
        email: _emailController.text.isNotEmpty ? _emailController.text : null,
        endereco: _enderecoController.text.isNotEmpty
            ? _enderecoController.text
            : null,
        convenio: _selectedConvenio,
        alergias: alergiasText.isNotEmpty ? alergiasText : null,
        condicoesPreExistentes:
            _condicoesPreExistentesController.text.isNotEmpty
                ? _condicoesPreExistentesController.text
                : null,
      );

      try {
        if (paciente.idPaciente == null) {
          await _pacienteRepository.insertPaciente(paciente);
        } else {
          await _pacienteRepository.updatePaciente(paciente);
        }
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(
                    'Paciente ${paciente.idPaciente == null ? "salvo" : "atualizado"} com sucesso!')),
          );
          // Retorna 'true' para a tela anterior saber que precisa recarregar a lista
          Navigator.of(context).pop(true);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erro ao salvar paciente: $e')),
          );
        }
      }
    }
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _cpfController.dispose();
    _dataNascimentoController.dispose();
    _telefoneController.dispose();
    _emailController.dispose();
    _enderecoController.dispose();
    _condicoesPreExistentesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.paciente == null
            ? 'Cadastro de Paciente'
            : 'Editar Paciente'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: ListView(
                  children: [
                    DropdownButtonFormField<Usuario>(
                      value: _selectedUsuario,
                      decoration: const InputDecoration(
                          labelText: 'Vincular à Conta de Usuário (Opcional)'),
                      items: _usuarios.map((usuario) {
                        return DropdownMenuItem(
                          value: usuario,
                          child: Text('${usuario.username} (${usuario.tipo})'),
                        );
                      }).toList(),
                      onChanged: (Usuario? newValue) {
                        setState(() => _selectedUsuario = newValue);
                      },
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: _nomeController,
                      decoration:
                          const InputDecoration(labelText: 'Nome Completo'),
                      validator: (value) => value == null || value.isEmpty
                          ? 'Por favor, insira o nome do paciente'
                          : null,
                    ),
                    TextFormField(
                      controller: _cpfController,
                      decoration: const InputDecoration(labelText: 'CPF'),
                      keyboardType: TextInputType.number,
                      validator: (value) => value == null || value.isEmpty
                          ? 'Por favor, insira o CPF'
                          : null,
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
                      decoration:
                          const InputDecoration(labelText: 'Endereço Completo'),
                      maxLines: 2,
                    ),
                    DropdownButtonFormField<String>(
                      value: _selectedConvenio,
                      decoration:
                          const InputDecoration(labelText: 'Convênio Médico'),
                      items: const [
                        DropdownMenuItem(
                            value: 'Particular', child: Text('Particular')),
                        DropdownMenuItem(
                            value: 'Unimed', child: Text('Unimed')),
                        DropdownMenuItem(
                            value: 'Epsemg', child: Text('Epsemg')),
                        DropdownMenuItem(
                            value: 'Bradesco Saúde',
                            child: Text('Bradesco Saúde')),
                        DropdownMenuItem(value: 'Amil', child: Text('Amil')),
                      ],
                      onChanged: (String? newValue) {
                        setState(() => _selectedConvenio = newValue);
                      },
                      validator: (value) => value == null || value.isEmpty
                          ? 'Selecione o convênio'
                          : null,
                    ),
                    const SizedBox(height: 20),
                    Text('Alergias a Medicamentos',
                        style: Theme.of(context).textTheme.titleSmall),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade400),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Wrap(
                        spacing: 6.0,
                        runSpacing: 0.0,
                        children: [
                          ..._selectedAlergias.map((med) => Chip(
                                label: Text(med.nome),
                                onDeleted: () {
                                  setState(() {
                                    _selectedAlergias.removeWhere((item) =>
                                        item.idMedicamento ==
                                        med.idMedicamento);
                                  });
                                },
                              )),
                          ActionChip(
                            avatar: const Icon(Icons.add, size: 18),
                            label: const Text('Selecionar'),
                            onPressed: _showMultiSelectAlergias,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: _condicoesPreExistentesController,
                      decoration: const InputDecoration(
                          labelText: 'Condições Pré-existentes'),
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
