// lib/presentation/financeiro/financeiro_form_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_clinica_medica/domain/models/financeiro.dart';
import 'package:flutter_clinica_medica/domain/models/consulta.dart';
import 'package:flutter_clinica_medica/domain/models/procedimento.dart';
import 'package:flutter_clinica_medica/domain/repositories/financeiro_repository.dart';
import 'package:flutter_clinica_medica/domain/repositories/consulta_repository.dart';
import 'package:flutter_clinica_medica/domain/repositories/procedimento_repository.dart';
import 'package:intl/intl.dart';

class FinanceiroFormScreen extends StatefulWidget {
  final int? idConsulta;
  const FinanceiroFormScreen({super.key, this.idConsulta});

  static const String routeName = '/financeiro-form';

  @override
  State<FinanceiroFormScreen> createState() => _FinanceiroFormScreenState();
}

class _FinanceiroFormScreenState extends State<FinanceiroFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _valorController = TextEditingController();
  final _dataPagamentoController = TextEditingController();

  String? _selectedFormaPagamento;
  Consulta? _selectedConsulta;
  List<Consulta> _consultas = [];
  List<Procedimento> _procedimentos = [];
  bool _isLoadingDropdown = true;

  final FinanceiroRepository _financeiroRepository = FinanceiroRepository();
  final ConsultaRepository _consultaRepository = ConsultaRepository();
  final ProcedimentoRepository _procedimentoRepository = ProcedimentoRepository();

  @override
  void initState() {
    super.initState();
    _dataPagamentoController.text = DateFormat('yyyy-MM-dd').format(DateTime.now());
    _loadDropdownDataAndSetInitialValue();
  }

  Future<void> _loadDropdownDataAndSetInitialValue() async {
    setState(() {
      _isLoadingDropdown = true;
    });
    try {
      final consultas = await _consultaRepository.getAllConsultas();
      final procedimentos = await _procedimentoRepository.getAllProcedimentos();
      setState(() {
        _consultas = consultas;
        _procedimentos = procedimentos;
        _isLoadingDropdown = false;
        if (widget.idConsulta != null) {
          _selectedConsulta = consultas.firstWhere(
            (c) => c.idConsulta == widget.idConsulta,
            orElse: () => consultas.isEmpty ? null as Consulta : consultas.first,
          );
        }
        if (_selectedConsulta != null && _selectedConsulta!.idProcedimentoPrincipal != null) {
          final procedimento = _procedimentos.firstWhere(
            (p) => p.idProcedimento == _selectedConsulta!.idProcedimentoPrincipal,
            orElse: () => null as Procedimento,
          );
          if (procedimento != null) {
            _valorController.text = procedimento.valor.toStringAsFixed(2);
          } else {
            _valorController.clear();
          }
        }
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

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
      locale: const Locale('pt', 'BR'),
    );
    if (picked != null) {
      setState(() {
        _dataPagamentoController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedConsulta == null || _selectedFormaPagamento == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Por favor, selecione a consulta e a forma de pagamento.')),
        );
        return;
      }

      // Lógica de simulação para "Pagamento Online"
      if (_selectedFormaPagamento == 'Pagamento Online') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Simulação: Redirecionando para plataforma de pagamento online...'),
            backgroundColor: Colors.blue,
            duration: Duration(seconds: 3),
          ),
        );
      }

      final financeiro = Financeiro(
        idConsulta: _selectedConsulta!.idConsulta,
        valor: double.tryParse(_valorController.text),
        formaPagamento: _selectedFormaPagamento,
        dataPagamento: _dataPagamentoController.text.isNotEmpty
            ? DateTime.tryParse(_dataPagamentoController.text)
            : null,
        statusPagamento: 'Pago',
      );

      try {
        await _financeiroRepository.insertFinanceiro(financeiro);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Registro financeiro salvo com sucesso!')),
        );
        _clearForm();
        Navigator.of(context).pop();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao salvar registro financeiro: $e')),
        );
      }
    }
  }

  void _clearForm() {
    _valorController.clear();
    _dataPagamentoController.text = DateFormat('yyyy-MM-dd').format(DateTime.now());
    setState(() {
      _selectedConsulta = null;
      _selectedFormaPagamento = null;
    });
  }

  @override
  void dispose() {
    _valorController.dispose();
    _dataPagamentoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Registrar Pagamento'),
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
                    DropdownButtonFormField<Consulta>(
                      value: _selectedConsulta,
                      decoration: const InputDecoration(labelText: 'Consulta'),
                      items: _consultas.map((cons) {
                        return DropdownMenuItem(
                          value: cons,
                          child: Text('Consulta ID: ${cons.idConsulta} - ${DateFormat('dd/MM/yyyy HH:mm').format(cons.dataHora)}'),
                        );
                      }).toList(),
                      onChanged: (Consulta? newValue) {
                        setState(() {
                          _selectedConsulta = newValue;
                          // Pré-preencher valor com base no procedimento da consulta selecionada
                          if (newValue != null && newValue.idProcedimentoPrincipal != null) {
                            final procedimento = _procedimentos.firstWhere(
                              (p) => p.idProcedimento == newValue.idProcedimentoPrincipal,
                              orElse: () => null as Procedimento,
                            );
                            if (procedimento != null) {
                              _valorController.text = procedimento.valor.toStringAsFixed(2);
                            } else {
                              _valorController.clear();
                            }
                          } else {
                            _valorController.clear();
                          }
                        });
                      },
                      validator: (value) {
                        if (value == null) {
                          return 'Selecione uma consulta';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: _valorController,
                      decoration: const InputDecoration(labelText: 'Valor (Ex: 150.00)'),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty || double.tryParse(value) == null) {
                          return 'Por favor, insira um valor válido';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 10),

                    DropdownButtonFormField<String>(
                      value: _selectedFormaPagamento,
                      decoration: const InputDecoration(labelText: 'Forma de Pagamento'),
                      items: const [
                        DropdownMenuItem(value: 'Dinheiro', child: Text('Dinheiro')),
                        DropdownMenuItem(value: 'Cartão de Crédito', child: Text('Cartão de Crédito')),
                        DropdownMenuItem(value: 'Cartão de Débito', child: Text('Cartão de Débito')),
                        DropdownMenuItem(value: 'Pix', child: Text('Pix')),
                        DropdownMenuItem(value: 'Transferência Bancária', child: Text('Transferência Bancária')),
                        DropdownMenuItem(value: 'Pagamento Online', child: Text('Pagamento Online')),
                      ],
                      onChanged: (String? newValue) {
                        setState(() {
                          _selectedFormaPagamento = newValue;
                        });
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor, selecione a forma de pagamento';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 10),

                    TextFormField(
                      controller: _dataPagamentoController,
                      decoration: InputDecoration(
                        labelText: 'Data do Pagamento (YYYY-MM-DD)',
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.calendar_today),
                          onPressed: () => _selectDate(context),
                        ),
                      ),
                      readOnly: true,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor, insira a data do pagamento';
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
                      child: const Text('Registrar Pagamento'),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}