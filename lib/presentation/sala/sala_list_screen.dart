// lib/presentation/sala/sala_list_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_clinica_medica/domain/models/sala.dart';
import 'package:flutter_clinica_medica/domain/repositories/sala_repository.dart';
import 'package:flutter_clinica_medica/presentation/sala/sala_form_screen.dart';

class SalaListScreen extends StatefulWidget {
  const SalaListScreen({super.key});

  static const String routeName = '/sala-list';

  @override
  State<SalaListScreen> createState() => _SalaListScreenState();
}

class _SalaListScreenState extends State<SalaListScreen> {
  final SalaRepository _salaRepository = SalaRepository();
  List<Sala> _salas = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSalas();
  }

  Future<void> _loadSalas() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final salas = await _salaRepository.getAllSalas();
      setState(() {
        _salas = salas;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao carregar salas: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _deleteSala(int id) async {
    try {
      await _salaRepository.deleteSala(id);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sala excluída com sucesso!')),
      );
      _loadSalas();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao excluir sala: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lista de Salas'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadSalas,
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () async {
              await Navigator.of(context).pushNamed(SalaFormScreen.routeName);
              _loadSalas();
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _salas.isEmpty
              ? const Center(child: Text('Nenhuma sala cadastrada.'))
              : ListView.builder(
                  itemCount: _salas.length,
                  itemBuilder: (context, index) {
                    final sala = _salas[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: ListTile(
                        title: Text(sala.nome ?? 'Sala sem nome'),
                        subtitle: Text('Tipo: ${sala.tipo ?? 'N/A'} - Capacidade: ${sala.capacidade ?? 'N/A'}'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.blue),
                              onPressed: () async {
                                await Navigator.of(context).push(MaterialPageRoute(
                                  builder: (context) => SalaFormScreen(
                                    sala: sala,
                                  ),
                                ));
                                _loadSalas();
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _deleteSala(sala.idSala!),
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