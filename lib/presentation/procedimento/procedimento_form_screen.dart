// lib/presentation/procedimento/procedimento_form_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_clinica_medica/domain/models/procedimento.dart';
import 'package:flutter_clinica_medica/domain/repositories/procedimento_repository.dart';

class ProcedimentoFormScreen extends StatefulWidget {
  final Procedimento? procedimento; // Opcional, para edição
  const ProcedimentoFormScreen({super.key, this.procedimento});

  static const String routeName = '/procedimento-form';

  @override
  State<ProcedimentoFormScreen> createState() => _ProcedimentoFormScreenState();
}

class _ProcedimentoFormScreenState extends State<ProcedimentoFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  final _descricaoController = TextEditingController();
  final _valorController = TextEditingController();

  final ProcedimentoRepository _procedimentoRepository = ProcedimentoRepository();

  @override
  void initState() {
    super.initState();
    if (widget.procedimento != null) {
      _nomeController.text = widget.procedimento!.nome;
      _descricaoController.text = widget.procedimento!.descricao ?? '';
      _valorController.text = widget.procedimento!.valor.toStringAsFixed(2);
    }
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      final procedimento = Procedimento(
        idProcedimento: widget.procedimento?.idProcedimento,
        nome: _nomeController.text,
        descricao: _descricaoController.text.isNotEmpty ? _descricaoController.text : null,
        valor: double.parse(_valorController.text),
      );

      try {
        if (procedimento.idProcedimento == null) {
          await _procedimentoRepository.insertProcedimento(procedimento);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Procedimento salvo com sucesso!')),
          );
        } else {
          await _procedimentoRepository.updateProcedimento(procedimento);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Procedimento atualizado com sucesso!')),
          );
        }
        Navigator.of(context).pop(); // Volta para a lista
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao salvar procedimento: $e')),
        );
      }
    }
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _descricaoController.dispose();
    _valorController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.procedimento == null ? 'Cadastro de Procedimento' : 'Editar Procedimento'),
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
                decoration: const InputDecoration(labelText: 'Nome do Procedimento'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira o nome do procedimento';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _descricaoController,
                decoration: const InputDecoration(labelText: 'Descrição'),
                maxLines: 3,
              ),
              TextFormField(
                controller: _valorController,
                decoration: const InputDecoration(labelText: 'Valor'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty || double.tryParse(value) == null) {
                    return 'Por favor, insira um valor válido';
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
                child: const Text('Salvar Procedimento'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}