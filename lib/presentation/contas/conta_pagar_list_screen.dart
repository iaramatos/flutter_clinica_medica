// lib/presentation/contas/conta_pagar_list_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_clinica_medica/domain/models/conta_pagar.dart';
import 'package:flutter_clinica_medica/domain/repositories/conta_pagar_repository.dart';
import 'package:flutter_clinica_medica/presentation/contas/conta_pagar_form_screen.dart';
import 'package:intl/intl.dart';

class ContaPagarListScreen extends StatefulWidget {
  const ContaPagarListScreen({super.key});

  static const String routeName = '/conta-pagar-list';

  @override
  State<ContaPagarListScreen> createState() => _ContaPagarListScreenState();
}

class _ContaPagarListScreenState extends State<ContaPagarListScreen> {
  final ContaPagarRepository _contaPagarRepository = ContaPagarRepository();
  List<ContaPagar> _contas = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadContas();
  }

  Future<void> _loadContas() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final contas = await _contaPagarRepository.getAllContasPagar();
      setState(() {
        _contas = contas;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao carregar contas a pagar: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _deleteConta(int id) async {
    try {
      await _contaPagarRepository.deleteContaPagar(id);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Conta a pagar excluída com sucesso!')),
      );
      _loadContas();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao excluir conta a pagar: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Contas a Pagar'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadContas,
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () async {
              await Navigator.of(context).pushNamed(ContaPagarFormScreen.routeName);
              _loadContas();
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _contas.isEmpty
              ? const Center(child: Text('Nenhuma conta a pagar cadastrada.'))
              : ListView.builder(
                  itemCount: _contas.length,
                  itemBuilder: (context, index) {
                    final conta = _contas[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: ListTile(
                        title: Text(conta.descricao ?? 'Sem descrição'),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Valor: R\$ ${conta.valor?.toStringAsFixed(2) ?? 'N/A'}'),
                            Text('Vencimento: ${conta.vencimento != null ? DateFormat('dd/MM/yyyy').format(conta.vencimento!) : 'N/A'}'),
                            Text('Status: ${conta.status ?? 'N/A'}'),
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.blue),
                              onPressed: () async {
                                await Navigator.of(context).push(MaterialPageRoute(
                                  builder: (context) => ContaPagarFormScreen(conta: conta),
                                ));
                                _loadContas();
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _deleteConta(conta.idConta!),
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