// lib/presentation/financeiro/financeiro_form_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_clinica_medica/domain/models/financeiro.dart';
import 'package:flutter_clinica_medica/domain/models/consulta.dart';
import 'package:flutter_clinica_medica/domain/repositories/financeiro_repository.dart';
import 'package:flutter_clinica_medica/domain/repositories/consulta_repository.dart';
import 'package:intl/intl.dart';

class FinanceiroFormScreen extends StatefulWidget {
  final int? idConsulta; // Opcional, para pré-selecionar uma consulta
  const FinanceiroFormScreen({super.key, this.idConsulta});

  static const String routeName = '/financeiro-form';

  @override
  State<FinanceiroFormScreen> createState() => _FinanceiroFormScreenState();
}

class _FinanceiroFormScreenState extends State<FinanceiroFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _valorController = TextEditingController();
  // REMOVIDO: final _formaPagamentoController = TextEditingController(); // Removido, pois usaremos Dropdown
  final _dataPagamentoController = TextEditingController();

  Consulta? _selectedConsulta;
  String? _selectedFormaPagamento; // NOVO: Variável para a forma de pagamento selecionada
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
            // Fallback se não encontrar ou se a lista estiver vazia
            orElse: () {
              // Se a consulta específica não for encontrada, e a lista não for vazia, selecione a primeira
              if (consultas.isNotEmpty) {
                return consultas.first;
              }
              // Caso contrário, retorna null (se for permitido que o valor seja nulo)
              return null as Consulta; // Cast necessário para evitar erro de tipo
            },
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
      locale: const Locale('pt', 'BR'), // Opcional: para calendário em português
    );
    if (picked != null) {
      setState(() {
        _dataPagamentoController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedConsulta == null || _selectedFormaPagamento == null) { // NOVO: Validar forma de pagamento
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Por favor, selecione a consulta e a forma de pagamento.')),
        );
        return;
      }

      final financeiro = Financeiro(
        idConsulta: _selectedConsulta!.idConsulta,
        valor: double.tryParse(_valorController.text),
        formaPagamento: _selectedFormaPagamento, // Usar o valor do dropdown
        dataPagamento: _dataPagamentoController.text.isNotEmpty
            ? DateTime.tryParse(_dataPagamentoController.text)
            : null,
        statusPagamento: 'Pago', // Assumimos 'Pago' ao registrar o financeiro
      );

      try {
        await _financeiroRepository.insertFinanceiro(financeiro);
        
        // NOVO: Atualizar o status da consulta (se você tiver um campo 'status' no modelo Consulta)
        // Se você adicionou um campo 'status' na tabela Consulta e no modelo Consulta,
        // você pode descomentar e usar o método update aqui.
        /*
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
            status: 'Paga', // Exemplo: defina o status como 'Paga'
          );
          await _consultaRepository.updateConsulta(updatedConsulta);
        }
        */

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
    // REMOVIDO: _formaPagamentoController.clear();
    _dataPagamentoController.text = DateFormat('yyyy-MM-dd').format(DateTime.now()); // Resetar para data atual
    setState(() {
      _selectedConsulta = null;
      _selectedFormaPagamento = null; // Limpa a forma de pagamento
    });
  }

  @override
  void dispose() {
    _valorController.dispose();
    // REMOVIDO: _formaPagamentoController.dispose();
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
                    const SizedBox(height: 10), // Adicionado para espaçar os campos

                    // CAMPO FORMA DE PAGAMENTO (COM DROPDOWN)
                    DropdownButtonFormField<String>(
                      value: _selectedFormaPagamento,
                      decoration: const InputDecoration(labelText: 'Forma de Pagamento'),
                      items: const [
                        DropdownMenuItem(value: 'Dinheiro', child: Text('Dinheiro')),
                        DropdownMenuItem(value: 'Cartão de Crédito', child: Text('Cartão de Crédito')),
                        DropdownMenuItem(value: 'Cartão de Débito', child: Text('Cartão de Débito')),
                        DropdownMenuItem(value: 'Pix', child: Text('Pix')),
                        DropdownMenuItem(value: 'Transferência Bancária', child: Text('Transferência Bancária')),
                        // Adicione mais formas de pagamento
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