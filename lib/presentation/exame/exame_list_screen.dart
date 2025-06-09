// lib/presentation/exame/exame_list_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_clinica_medica/domain/models/exame.dart';
import 'package:flutter_clinica_medica/domain/repositories/exame_repository.dart';

class ExameListScreen extends StatefulWidget {
  const ExameListScreen({super.key});

  static const String routeName = '/exame-list';

  @override
  State<ExameListScreen> createState() => _ExameListScreenState();
}

class _ExameListScreenState extends State<ExameListScreen> {
  final ExameRepository _exameRepository = ExameRepository();
  List<Exame> _exames = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadExames();
  }

  Future<void> _loadExames() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final exames = await _exameRepository.getAllExames();
      setState(() {
        _exames = exames;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao carregar tipos de exames: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _deleteExame(int id) async {
    try {
      await _exameRepository.deleteExame(id);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tipo de exame excluído com sucesso!')),
      );
      _loadExames();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao excluir tipo de exame: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tipos de Exames'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadExames,
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () async {
              // Navegar para um formulário de cadastro de tipo de exame
              // Como não criamos um ExameFormScreen separado, usamos um AlertDialog simples para cadastro
              // Como não criamos um ExameFormScreen, podemos fazer um AlertDialog simples para cadastro
              await _showAddExameDialog(context);
              _loadExames(); // Recarrega a lista após adicionar
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _exames.isEmpty
              ? const Center(child: Text('Nenhum tipo de exame cadastrado.'))
              : ListView.builder(
                  itemCount: _exames.length,
                  itemBuilder: (context, index) {
                    final exame = _exames[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: ListTile(
                        title: Text(exame.nome ?? 'Exame sem nome'),
                        subtitle: Text(exame.descricao ?? 'Sem descrição'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.blue),
                              onPressed: () async {
                                // Implementar edição futuramente ou usar o mesmo AlertDialog para isso
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Edição de tipo de exame futura.')),
                                );
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _deleteExame(exame.idExame!),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }

  // NOVO MÉTODO: AlertDialog simples para adicionar tipo de exame
  Future<void> _showAddExameDialog(BuildContext context) async {
    final _nomeController = TextEditingController();
    final _descricaoController = TextEditingController();
    final ExameRepository _exameRepository = ExameRepository();

    return showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Novo Tipo de Exame'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nomeController,
                decoration: const InputDecoration(labelText: 'Nome do Exame'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Nome é obrigatório';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _descricaoController,
                decoration: const InputDecoration(labelText: 'Descrição'),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancelar'),
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
            ),
            TextButton(
              child: const Text('Adicionar'),
              onPressed: () async {
                // Validação manual aqui, pois o Form não é usado no AlertDialog
                if (_nomeController.text.isNotEmpty) {
                  final novoExame = Exame(
                    nome: _nomeController.text,
                    descricao: _descricaoController.text.isNotEmpty ? _descricaoController.text : null,
                  );
                  try {
                    await _exameRepository.insertExame(novoExame);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Tipo de exame salvo!')),
                    );
                    Navigator.of(dialogContext).pop(); // Fecha o AlertDialog
                    Navigator.of(dialogContext).pop();
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Erro ao salvar tipo de exame: $e')),
                    );
                  }
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('O nome do exame é obrigatório!')),
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }
}