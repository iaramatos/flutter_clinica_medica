// lib/presentation/procedimento/procedimento_list_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_clinica_medica/domain/models/procedimento.dart';
import 'package:flutter_clinica_medica/domain/repositories/procedimento_repository.dart';
import 'package:flutter_clinica_medica/presentation/procedimento/procedimento_form_screen.dart';

class ProcedimentoListScreen extends StatefulWidget {
  const ProcedimentoListScreen({super.key});

  static const String routeName = '/procedimento-list';

  @override
  State<ProcedimentoListScreen> createState() => _ProcedimentoListScreenState();
}

class _ProcedimentoListScreenState extends State<ProcedimentoListScreen> {
  final ProcedimentoRepository _procedimentoRepository = ProcedimentoRepository();
  List<Procedimento> _procedimentos = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProcedimentos();
  }

  Future<void> _loadProcedimentos() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final procedimentos = await _procedimentoRepository.getAllProcedimentos();
      setState(() {
        _procedimentos = procedimentos;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao carregar procedimentos: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _deleteProcedimento(int id) async {
    try {
      await _procedimentoRepository.deleteProcedimento(id);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Procedimento excluído com sucesso!')),
      );
      _loadProcedimentos();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao excluir procedimento: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lista de Procedimentos'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadProcedimentos,
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () async {
              await Navigator.of(context).pushNamed(ProcedimentoFormScreen.routeName);
              _loadProcedimentos();
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _procedimentos.isEmpty
              ? const Center(child: Text('Nenhum procedimento cadastrado.'))
              : ListView.builder(
                  itemCount: _procedimentos.length,
                  itemBuilder: (context, index) {
                    final procedimento = _procedimentos[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: ListTile(
                        title: Text(procedimento.nome),
                        subtitle: Text('Valor: R\$ ${procedimento.valor.toStringAsFixed(2)}'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.blue),
                              onPressed: () async {
                                await Navigator.of(context).push(MaterialPageRoute(
                                  builder: (context) => ProcedimentoFormScreen(
                                    procedimento: procedimento,
                                  ),
                                ));
                                _loadProcedimentos();
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _deleteProcedimento(procedimento.idProcedimento!),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}