// lib/presentation/sala/sala_form_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_clinica_medica/domain/models/sala.dart';
import 'package:flutter_clinica_medica/domain/repositories/sala_repository.dart';

class SalaFormScreen extends StatefulWidget {
  final Sala? sala; // Opcional, para edição
  const SalaFormScreen({super.key, this.sala});

  static const String routeName = '/sala-form';

  @override
  State<SalaFormScreen> createState() => _SalaFormScreenState();
}

class _SalaFormScreenState extends State<SalaFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  final _tipoController = TextEditingController();
  final _capacidadeController = TextEditingController();

  final SalaRepository _salaRepository = SalaRepository();

  @override
  void initState() {
    super.initState();
    if (widget.sala != null) {
      _nomeController.text = widget.sala!.nome ?? '';
      _tipoController.text = widget.sala!.tipo ?? '';
      _capacidadeController.text = widget.sala!.capacidade?.toString() ?? '';
    }
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      final sala = Sala(
        idSala: widget.sala?.idSala,
        nome: _nomeController.text.isNotEmpty ? _nomeController.text : null,
        tipo: _tipoController.text.isNotEmpty ? _tipoController.text : null,
        capacidade: int.tryParse(_capacidadeController.text),
      );

      try {
        if (sala.idSala == null) {
          await _salaRepository.insertSala(sala);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Sala salva com sucesso!')),
          );
        } else {
          await _salaRepository.updateSala(sala);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Sala atualizada com sucesso!')),
          );
        }
        Navigator.of(context).pop();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao salvar sala: $e')),
        );
      }
    }
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _tipoController.dispose();
    _capacidadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.sala == null ? 'Cadastro de Sala' : 'Editar Sala'),
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
                decoration: const InputDecoration(labelText: 'Nome da Sala (Ex: Consultório 1)'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira o nome da sala';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _tipoController,
                decoration: const InputDecoration(labelText: 'Tipo de Sala (Ex: Consultório, Laboratório)'),
              ),
              TextFormField(
                controller: _capacidadeController,
                decoration: const InputDecoration(labelText: 'Capacidade (Opcional)'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value != null && value.isNotEmpty && int.tryParse(value) == null) {
                    return 'Por favor, insira um número válido para a capacidade';
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
                child: const Text('Salvar Sala'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}