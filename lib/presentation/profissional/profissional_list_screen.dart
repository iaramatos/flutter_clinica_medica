// lib/presentation/profissional/profissional_list_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_clinica_medica/domain/models/profissional.dart';
import 'package:flutter_clinica_medica/domain/repositories/profissional_repository.dart';
import 'package:flutter_clinica_medica/presentation/profissional/profissional_form_screen.dart';

class ProfissionalListScreen extends StatefulWidget {
  const ProfissionalListScreen({super.key});

  static const String routeName = '/profissional-list';

  @override
  State<ProfissionalListScreen> createState() => _ProfissionalListScreenState();
}

class _ProfissionalListScreenState extends State<ProfissionalListScreen> {
  final ProfissionalRepository _profissionalRepository = ProfissionalRepository();
  List<Profissional> _profissionais = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProfissionais();
  }

  Future<void> _loadProfissionais() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final profissionais = await _profissionalRepository.getAllProfissionais();
      setState(() {
        _profissionais = profissionais;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao carregar profissionais: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _deleteProfissional(int id) async {
    try {
      await _profissionalRepository.deleteProfissional(id);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profissional excluído com sucesso!')),
      );
      _loadProfissionais(); // Recarrega a lista
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao excluir profissional: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lista de Profissionais'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadProfissionais,
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () async {
              await Navigator.of(context).pushNamed(ProfissionalFormScreen.routeName);
              _loadProfissionais(); // Recarrega a lista ao voltar do formulário
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _profissionais.isEmpty
              ? const Center(child: Text('Nenhum profissional cadastrado.'))
              : ListView.builder(
                  itemCount: _profissionais.length,
                  itemBuilder: (context, index) {
                    final profissional = _profissionais[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: ListTile(
                        title: Text(profissional.nome),
                        subtitle: Text(
                          '${profissional.especialidade ?? 'N/A'} - ${profissional.tipoUsuario}',
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.blue),
                              onPressed: () async {
                                // Navegar para o formulário para edição
                                await Navigator.of(context).push(MaterialPageRoute(
                                  builder: (context) => ProfissionalFormScreen(
                                    profissional: profissional, // Passa o objeto profissional para edição
                                  ),
                                ));
                                _loadProfissionais(); // Recarrega a lista após edição
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _deleteProfissional(profissional.idProfissional!),
                            ),
                          ],
                        ),
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Detalhes de ${profissional.nome}')),
                          );
                        },
                      ),
                    );
                  },
                ),
    );
  }
}