// lib/presentation/medicamento/medicamento_form_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_clinica_medica/domain/models/medicamento.dart';
import 'package:flutter_clinica_medica/domain/repositories/medicamento_repository.dart';

class MedicamentoFormScreen extends StatefulWidget {
  final Medicamento? medicamento; // Opcional, para edição
  const MedicamentoFormScreen({super.key, this.medicamento});

  static const String routeName = '/medicamento-form';

  @override
  State<MedicamentoFormScreen> createState() => _MedicamentoFormScreenState();
}

class _MedicamentoFormScreenState extends State<MedicamentoFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  final _descricaoController = TextEditingController();
  final _estoqueAtualController = TextEditingController();

  final MedicamentoRepository _medicamentoRepository = MedicamentoRepository();

  @override
  void initState() {
    super.initState();
    if (widget.medicamento != null) {
      _nomeController.text = widget.medicamento!.nome;
      _descricaoController.text = widget.medicamento!.descricao ?? '';
      _estoqueAtualController.text = widget.medicamento!.estoqueAtual?.toString() ?? '';
    }
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      final medicamento = Medicamento(
        idMedicamento: widget.medicamento?.idMedicamento,
        nome: _nomeController.text,
        descricao: _descricaoController.text.isNotEmpty ? _descricaoController.text : null,
        estoqueAtual: int.tryParse(_estoqueAtualController.text),
      );

      try {
        if (medicamento.idMedicamento == null) {
          await _medicamentoRepository.insertMedicamento(medicamento);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Medicamento salvo com sucesso!')),
          );
        } else {
          await _medicamentoRepository.updateMedicamento(medicamento);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Medicamento atualizado com sucesso!')),
          );
        }
        Navigator.of(context).pop();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao salvar medicamento: $e')),
        );
      }
    }
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _descricaoController.dispose();
    _estoqueAtualController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.medicamento == null ? 'Cadastro de Medicamento' : 'Editar Medicamento'),
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
                decoration: const InputDecoration(labelText: 'Nome do Medicamento'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira o nome do medicamento';
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
                controller: _estoqueAtualController,
                decoration: const InputDecoration(labelText: 'Estoque Atual'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value != null && value.isNotEmpty && int.tryParse(value) == null) {
                    return 'Por favor, insira um número válido para o estoque';
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
                child: const Text('Salvar Medicamento'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}