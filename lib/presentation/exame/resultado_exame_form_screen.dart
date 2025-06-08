// lib/presentation/exame/resultado_exame_form_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_clinica_medica/domain/models/resultado_exame.dart';
import 'package:flutter_clinica_medica/domain/models/consulta.dart';
import 'package:flutter_clinica_medica/domain/models/exame.dart';
import 'package:flutter_clinica_medica/domain/repositories/resultado_exame_repository.dart';
import 'package:flutter_clinica_medica/domain/repositories/consulta_repository.dart';
import 'package:flutter_clinica_medica/domain/repositories/exame_repository.dart';
import 'package:intl/intl.dart'; // ADICIONE ESTA LINHA

class ResultadoExameFormScreen extends StatefulWidget {
  final int? idConsulta; // Opcional, para vincular a uma consulta
  const ResultadoExameFormScreen({super.key, this.idConsulta});

  static const String routeName = '/resultado-exame-form';

  @override
  State<ResultadoExameFormScreen> createState() => _ResultadoExameFormScreenState();
}

class _ResultadoExameFormScreenState extends State<ResultadoExameFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _resultadoController = TextEditingController();
  final _urlDocumentoController = TextEditingController();

  Consulta? _selectedConsulta;
  Exame? _selectedExame;
  List<Consulta> _consultas = [];
  List<Exame> _exames = [];
  bool _isLoadingDropdowns = true;

  final ResultadoExameRepository _resultadoExameRepository = ResultadoExameRepository();
  final ConsultaRepository _consultaRepository = ConsultaRepository();
  final ExameRepository _exameRepository = ExameRepository();

  @override
  void initState() {
    super.initState();
    _loadDropdownData();
  }

  Future<void> _loadDropdownData() async {
    try {
      final consultas = await _consultaRepository.getAllConsultas();
      final exames = await _exameRepository.getAllExames();
      setState(() {
        _consultas = consultas;
        _exames = exames;
        _isLoadingDropdowns = false;
        if (widget.idConsulta != null) {
          _selectedConsulta = consultas.firstWhere(
            (c) => c.idConsulta == widget.idConsulta,
            orElse: () => consultas.isEmpty ? null as Consulta : consultas.first,
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

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedConsulta == null || _selectedExame == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Por favor, selecione a Consulta e o Exame.')),
        );
        return;
      }

      final resultadoExame = ResultadoExame(
        idConsulta: _selectedConsulta!.idConsulta,
        idExame: _selectedExame!.idExame,
        resultado: _resultadoController.text.isNotEmpty ? _resultadoController.text : null,
        urlDocumento: _urlDocumentoController.text.isNotEmpty ? _urlDocumentoController.text : null,
      );

      try {
        await _resultadoExameRepository.insertResultadoExame(resultadoExame);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Resultado de exame salvo com sucesso!')),
        );
        _clearForm();
        Navigator.of(context).pop();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao salvar resultado de exame: $e')),
        );
      }
    }
  }

  void _clearForm() {
    _resultadoController.clear();
    _urlDocumentoController.clear();
    setState(() {
      _selectedConsulta = null;
      _selectedExame = null;
    });
  }

  @override
  void dispose() {
    _resultadoController.dispose();
    _urlDocumentoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Registrar Resultado de Exame'),
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
                    DropdownButtonFormField<Consulta>(
                      value: _selectedConsulta,
                      decoration: const InputDecoration(labelText: 'Consulta Vinculada'),
                      items: _consultas.map((cons) {
                        return DropdownMenuItem(
                          value: cons,
                          child: Text('Consulta ID: ${cons.idConsulta} - ${DateFormat('dd/MM/yyyy HH:mm').format(cons.dataHora)}'),
                        );
                      }).toList(),
                      onChanged: (Consulta? newValue) {
                        setState(() {
                          _selectedConsulta = newValue;
                        });
                      },
                      validator: (value) {
                        if (value == null) {
                          return 'Selecione a consulta';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 10),
                    DropdownButtonFormField<Exame>(
                      value: _selectedExame,
                      decoration: const InputDecoration(labelText: 'Tipo de Exame'),
                      items: _exames.map((exame) {
                        return DropdownMenuItem(
                          value: exame,
                          child: Text('${exame.nome ?? 'Exame S/N'}'),
                        );
                      }).toList(),
                      onChanged: (Exame? newValue) {
                        setState(() {
                          _selectedExame = newValue;
                        });
                      },
                      validator: (value) {
                        if (value == null) {
                          return 'Selecione o tipo de exame';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: _resultadoController,
                      decoration: const InputDecoration(labelText: 'Resultado / Observações'),
                      maxLines: 5,
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: _urlDocumentoController,
                      decoration: const InputDecoration(labelText: 'URL do Documento (opcional)'),
                      keyboardType: TextInputType.url,
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _submitForm,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                      ),
                      child: const Text('Salvar Resultado de Exame'),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}