// lib/presentation/financeiro/financeiro_form_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_clinica_medica/domain/models/financeiro.dart';
import 'package:flutter_clinica_medica/domain/models/consulta.dart';
import 'package:flutter_clinica_medica/domain/repositories/financeiro_repository.dart';
import 'package:flutter_clinica_medica/domain/repositories/consulta_repository.dart';
import 'package:intl/intl.dart';

class FinanceiroFormScreen extends StatefulWidget {
  final int? idConsulta; // NOVO: Opcional, para pré-selecionar uma consulta
  const FinanceiroFormScreen({super.key, this.idConsulta});

  static const String routeName = '/financeiro-form';

  @override
  State<FinanceiroFormScreen> createState() => _FinanceiroFormScreenState();
}

class _FinanceiroFormScreenState extends State<FinanceiroFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _valorController = TextEditingController();
  final _formaPagamentoController = TextEditingController();
  final _dataPagamentoController = TextEditingController();

  Consulta? _selectedConsulta;
  List<Consulta> _consultas = [];
  bool _isLoadingDropdown = true;

  final FinanceiroRepository _financeiroRepository = FinanceiroRepository();
  final ConsultaRepository _consultaRepository = ConsultaRepository();

  @override
  void initState() {
    super.initState();
    _loadConsultas();
    // Preenche a data de pagamento com a data atual por padrão
    _dataPagamentoController.text = DateFormat('yyyy-MM-dd').format(DateTime.now());
  }

  Future<void> _loadConsultas() async {
    try {
      final consultas = await _consultaRepository.getAllConsultas();
      setState(() {
        _consultas = consultas;
        _isLoadingDropdown = false;
        // Se um idConsulta foi passado, tenta pré-selecionar
        if (widget.idConsulta != null) {
          _selectedConsulta = consultas.firstWhere(
            (c) => c.idConsulta == widget.idConsulta,
            orElse: () => consultas.isEmpty ? null as Consulta : consultas.first, // Fallback se não encontrar
          );
        }
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao carregar consultas: $e')),
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
    );
    if (picked != null) {
      setState(() {
        _dataPagamentoController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedConsulta == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Por favor, selecione a consulta.')),
        );
        return;
      }

      final financeiro = Financeiro(
        idConsulta: _selectedConsulta!.idConsulta,
        valor: double.tryParse(_valorController.text),
        formaPagamento: _formaPagamentoController.text.isNotEmpty ? _formaPagamentoController.text : null,
        dataPagamento: _dataPagamentoController.text.isNotEmpty
            ? DateTime.tryParse(_dataPagamentoController.text)
            : null,
        statusPagamento: 'Pago', // Assumimos 'Pago' ao registrar o financeiro
      );

      try {
        await _financeiroRepository.insertFinanceiro(financeiro);
        
        // NOVO: Atualizar o status da consulta
        if (_selectedConsulta != null) {
          final updatedConsulta = Consulta(
            idConsulta: _selectedConsulta!.idConsulta,
            dataHora: _selectedConsulta!.dataHora,
            motivo: _selectedConsulta!.motivo,
            diagnostico: _selectedConsulta!.diagnostico,
            idPaciente: _selectedConsulta!.idPaciente,
            idProfissional: _selectedConsulta!.idProfissional,
            idSala: _selectedConsulta!.idSala,
            idReceita: _selectedConsulta!.idReceita,
            // Adicione um campo de status no modelo Consulta se você tiver
            // Para esta iteração, vamos assumir que o "status de pagamento"
            // é o que indica que a consulta foi concluída financeiramente
            // ou você pode adicionar um campo 'status' na tabela Consulta.
            // Exemplo hipotético:
            // status: 'Paga',
          );
          // await _consultaRepository.updateConsulta(updatedConsulta);
          // Se você adicionar um campo 'status' na tabela Consulta, descomente e use o método update.
        }

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Registro financeiro salvo com sucesso!')),
        );
        _clearForm();
        Navigator.of(context).pop(); // Volta para a tela anterior
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao salvar registro financeiro: $e')),
        );
      }
    }
  }

  void _clearForm() {
    _valorController.clear();
    _formaPagamentoController.clear();
    // Manter a data atual na dataPagamentoController
    setState(() {
      _selectedConsulta = null;
    });
  }

  @override
  void dispose() {
    _valorController.dispose();
    _formaPagamentoController.dispose();
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
                    TextFormField(
                      controller: _formaPagamentoController,
                      decoration: const InputDecoration(labelText: 'Forma de Pagamento'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor, insira a forma de pagamento';
                        }
                        return null;
                      },
                    ),
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