// lib/presentation/contas/conta_pagar_form_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_clinica_medica/domain/models/conta_pagar.dart';
import 'package:flutter_clinica_medica/domain/repositories/conta_pagar_repository.dart';
import 'package:intl/intl.dart';

class ContaPagarFormScreen extends StatefulWidget {
  final ContaPagar? conta; // Opcional, para edição
  const ContaPagarFormScreen({super.key, this.conta});

  static const String routeName = '/conta-pagar-form';

  @override
  State<ContaPagarFormScreen> createState() => _ContaPagarFormScreenState();
}

class _ContaPagarFormScreenState extends State<ContaPagarFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _descricaoController = TextEditingController();
  final _valorController = TextEditingController();
  final _vencimentoController = TextEditingController();

  String? _selectedStatus; // ENUM('Aberto', 'Pago')

  final ContaPagarRepository _contaPagarRepository = ContaPagarRepository();

  @override
  void initState() {
    super.initState();
    if (widget.conta != null) {
      _descricaoController.text = widget.conta!.descricao ?? '';
      _valorController.text = widget.conta!.valor?.toStringAsFixed(2) ?? '';
      if (widget.conta!.vencimento != null) {
        _vencimentoController.text = DateFormat('dd-MM-yyyy').format(widget.conta!.vencimento!);
      }
      _selectedStatus = widget.conta!.status;
    }
  }

  Future<void> _selectVencimento(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
      locale: const Locale('pt', 'BR'),
    );
    if (picked != null) {
      setState(() {
        _vencimentoController.text = DateFormat('dd-MM-yyyy').format(picked);
      });
    }
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      final conta = ContaPagar(
        idConta: widget.conta?.idConta,
        descricao: _descricaoController.text.isNotEmpty ? _descricaoController.text : null,
        valor: double.tryParse(_valorController.text),
        vencimento: _vencimentoController.text.isNotEmpty
            ? DateFormat('dd-MM-yyyy').parse(_vencimentoController.text)
            : null,
        status: _selectedStatus ?? 'Aberto',
      );

      try {
        if (conta.idConta == null) {
          await _contaPagarRepository.insertContaPagar(conta);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Conta a pagar salva com sucesso!')),
          );
        } else {
          await _contaPagarRepository.updateContaPagar(conta);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Conta a pagar atualizada com sucesso!')),
          );
        }
        Navigator.of(context).pop();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao salvar conta a pagar: $e')),
        );
      }
    }
  }

  @override
  void dispose() {
    _descricaoController.dispose();
    _valorController.dispose();
    _vencimentoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.conta == null ? 'Nova Conta a Pagar' : 'Editar Conta a Pagar'),
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
                controller: _descricaoController,
                decoration: const InputDecoration(labelText: 'Descrição'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Insira uma descrição';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _valorController,
                decoration: const InputDecoration(labelText: 'Valor'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty || double.tryParse(value) == null) {
                    return 'Insira um valor válido';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _vencimentoController,
                decoration: InputDecoration(
                  labelText: 'Data de Vencimento (DD-MM-YYYY)',
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.calendar_today),
                    onPressed: () => _selectVencimento(context),
                  ),
                ),
                readOnly: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Insira a data de vencimento';
                  }
                  return null;
                },
              ),
              DropdownButtonFormField<String>(
                value: _selectedStatus,
                decoration: const InputDecoration(labelText: 'Status'),
                items: const [
                  DropdownMenuItem(value: 'Aberto', child: Text('Aberto')),
                  DropdownMenuItem(value: 'Pago', child: Text('Pago')),
                ],
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedStatus = newValue;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Selecione o status';
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
                child: const Text('Salvar Conta a Pagar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}