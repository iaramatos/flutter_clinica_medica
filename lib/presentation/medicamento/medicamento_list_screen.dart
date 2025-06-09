// lib/presentation/medicamento/medicamento_list_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_clinica_medica/domain/models/medicamento.dart';
import 'package:flutter_clinica_medica/domain/repositories/medicamento_repository.dart';
import 'package:flutter_clinica_medica/presentation/medicamento/medicamento_form_screen.dart';

class MedicamentoListScreen extends StatefulWidget {
  const MedicamentoListScreen({super.key});

  static const String routeName = '/medicamento-list';

  @override
  State<MedicamentoListScreen> createState() => _MedicamentoListScreenState();
}

class _MedicamentoListScreenState extends State<MedicamentoListScreen> {
  final MedicamentoRepository _medicamentoRepository = MedicamentoRepository();
  List<Medicamento> _medicamentos = [];
  bool _isLoading = true;
  final int _estoqueMinimoAlerta = 10; // Definir um limite para alerta de baixa

  @override
  void initState() {
    super.initState();
    _loadMedicamentos();
  }

  Future<void> _loadMedicamentos() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final medicamentos = await _medicamentoRepository.getAllMedicamentos();
      setState(() {
        _medicamentos = medicamentos;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao carregar medicamentos: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _deleteMedicamento(int id) async {
    try {
      await _medicamentoRepository.deleteMedicamento(id);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Medicamento excluído com sucesso!')),
      );
      _loadMedicamentos();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao excluir medicamento: $e')),
      );
    }
  }

  // NOVO: Método para simular alerta de baixa ou reposição
  void _triggerLowStockAlert(Medicamento medicamento) {
    if (medicamento.estoqueAtual != null && medicamento.estoqueAtual! < _estoqueMinimoAlerta) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('ALERTA DE ESTOQUE BAIXO: ${medicamento.nome} tem apenas ${medicamento.estoqueAtual} unidades. Sugerir reposição.'),
          backgroundColor: Colors.orange,
          duration: const Duration(seconds: 5),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${medicamento.nome} tem estoque suficiente (${medicamento.estoqueAtual ?? 'N/A'}).'),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lista de Medicamentos'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadMedicamentos,
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () async {
              await Navigator.of(context).pushNamed(MedicamentoFormScreen.routeName);
              _loadMedicamentos();
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _medicamentos.isEmpty
              ? const Center(child: Text('Nenhum medicamento cadastrado.'))
              : ListView.builder(
                  itemCount: _medicamentos.length,
                  itemBuilder: (context, index) {
                    final medicamento = _medicamentos[index];
                    // Determinar a cor do texto do estoque
                    Color estoqueColor = Colors.black;
                    if (medicamento.estoqueAtual != null && medicamento.estoqueAtual! < _estoqueMinimoAlerta) {
                      estoqueColor = Colors.red; // Estoque baixo
                    } else if (medicamento.estoqueAtual != null && medicamento.estoqueAtual! > _estoqueMinimoAlerta * 2) {
                      estoqueColor = Colors.blue; // Estoque alto
                    }

                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: ListTile(
                        title: Text(medicamento.nome),
                        subtitle: Text(
                          'Estoque: ${medicamento.estoqueAtual ?? 'N/A'}',
                          style: TextStyle(color: estoqueColor, fontWeight: FontWeight.bold),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // NOVO: Botão de Alerta/Reposição
                            IconButton(
                              icon: const Icon(Icons.warning_amber, color: Colors.orange),
                              onPressed: () => _triggerLowStockAlert(medicamento),
                            ),
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.blue),
                              onPressed: () async {
                                await Navigator.of(context).push(MaterialPageRoute(
                                  builder: (context) => MedicamentoFormScreen(
                                    medicamento: medicamento,
                                  ),
                                ));
                                _loadMedicamentos();
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _deleteMedicamento(medicamento.idMedicamento!),
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