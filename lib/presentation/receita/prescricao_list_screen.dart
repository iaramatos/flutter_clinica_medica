// lib/presentation/receita/prescricao_list_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_clinica_medica/domain/models/prescricao_medicamento.dart';
import 'package:flutter_clinica_medica/domain/repositories/medicamento_repository.dart';
import 'package:flutter_clinica_medica/domain/repositories/prescricao_medicamento_repository.dart';
import 'package:flutter_clinica_medica/domain/repositories/receita_repository.dart';
import 'package:flutter_clinica_medica/presentation/receita/prescricao_form_screen.dart';

class PrescricaoListScreen extends StatefulWidget {
  const PrescricaoListScreen({super.key});

  static const String routeName = '/prescricao-list';

  @override
  State<PrescricaoListScreen> createState() => _PrescricaoListScreenState();
}

class _PrescricaoListScreenState extends State<PrescricaoListScreen> {
  final PrescricaoMedicamentoRepository _prescricaoRepository =
      PrescricaoMedicamentoRepository();
  final ReceitaRepository _receitaRepository = ReceitaRepository();
  final MedicamentoRepository _medicamentoRepository = MedicamentoRepository();

  List<PrescricaoMedicamento> _prescricoes = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPrescricoes();
  }

  Future<void> _loadPrescricoes() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final prescricoes =
          await _prescricaoRepository.getAllPrescricaoMedicamentos();
      setState(() {
        _prescricoes = prescricoes;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao carregar prescrições: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _deletePrescricao(int id) async {
    try {
      await _prescricaoRepository.deletePrescricaoMedicamento(id);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Prescrição excluída com sucesso!')),
      );
      _loadPrescricoes();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao excluir prescrição: $e')),
      );
    }
  }

  // Métodos auxiliares para obter nomes de Receita e Medicamento
  Future<String> _getReceitaInfo(int? id) async {
    if (id == null) return 'Receita Desconhecida';
    final receita = await _receitaRepository.getReceitaById(id);
    return receita != null
        ? 'Receita ID: ${receita.idReceita} (${receita.dataEmissao?.toIso8601String().substring(0, 10) ?? 'N/A'})'
        : 'Receita Desconhecida';
  }

  Future<String> _getMedicamentoNome(int? id) async {
    if (id == null) return 'Medicamento Desconhecido';
    final medicamento = await _medicamentoRepository.getMedicamentoById(id);
    return medicamento?.nome ?? 'Medicamento Desconhecido';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lista de Prescrições'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadPrescricoes,
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () async {
              // Navegar para o formulário de prescrição
              await Navigator.of(context)
                  .pushNamed(PrescricaoFormScreen.routeName);
              _loadPrescricoes(); // Recarrega a lista
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _prescricoes.isEmpty
              ? const Center(child: Text('Nenhuma prescrição cadastrada.'))
              : ListView.builder(
                  itemCount: _prescricoes.length,
                  itemBuilder: (context, index) {
                    final prescricao = _prescricoes[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      child: FutureBuilder<List<String>>(
                        // Usar FutureBuilder para carregar os nomes relacionados
                        future: Future.wait([
                          _getReceitaInfo(prescricao.idReceita),
                          _getMedicamentoNome(prescricao.idMedicamento),
                        ]),
                        builder: (context, snapshot) {
                          String receitaInfo =
                              snapshot.data?[0] ?? 'Carregando Receita...';
                          String medicamentoNome =
                              snapshot.data?[1] ?? 'Carregando Medicamento...';

                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            receitaInfo = 'Carregando...';
                            medicamentoNome = 'Carregando...';
                          } else if (snapshot.hasError) {
                            receitaInfo = 'Erro';
                            medicamentoNome = 'Erro';
                          }

                          return ListTile(
                            title: Text('Med.: $medicamentoNome'),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(receitaInfo),
                                if (prescricao.dosagem != null &&
                                    prescricao.dosagem!.isNotEmpty)
                                  Text('Dosagem: ${prescricao.dosagem}'),
                                if (prescricao.frequencia != null &&
                                    prescricao.frequencia!.isNotEmpty)
                                  Text('Frequência: ${prescricao.frequencia}'),
                              ],
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit,
                                      color: Colors.blue),
                                  onPressed: () {
                                    // Implementar edição futuramente (passar objeto prescricao)
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                          content: Text(
                                              'Edição de prescrição futura.')),
                                    );
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete,
                                      color: Colors.red),
                                  onPressed: () => _deletePrescricao(
                                      prescricao.idPrescricao!),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
    );
  }
}
