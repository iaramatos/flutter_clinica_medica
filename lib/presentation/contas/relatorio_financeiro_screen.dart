// lib/presentation/relatorios/relatorio_financeiro_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_clinica_medica/domain/models/financeiro.dart';
import 'package:flutter_clinica_medica/domain/models/conta_pagar.dart';
import 'package:flutter_clinica_medica/domain/models/conta_receber.dart';
import 'package:flutter_clinica_medica/domain/repositories/financeiro_repository.dart';
import 'package:flutter_clinica_medica/domain/repositories/conta_pagar_repository.dart';
import 'package:flutter_clinica_medica/domain/repositories/conta_receber_repository.dart';
import 'package:intl/intl.dart';

class RelatorioFinanceiroScreen extends StatefulWidget {
  const RelatorioFinanceiroScreen({super.key});

  static const String routeName = '/relatorios-financeiro';

  @override
  State<RelatorioFinanceiroScreen> createState() => _RelatorioFinanceiroScreenState();
}

class _RelatorioFinanceiroScreenState extends State<RelatorioFinanceiroScreen> {
  final FinanceiroRepository _financeiroRepository = FinanceiroRepository();
  final ContaPagarRepository _contaPagarRepository = ContaPagarRepository();
  final ContaReceberRepository _contaReceberRepository = ContaReceberRepository();

  double _totalReceitas = 0.0;
  double _totalDespesas = 0.0;
  double _saldo = 0.0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadRelatorioData();
  }

  Future<void> _loadRelatorioData() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final List<Financeiro> receitas = await _financeiroRepository.getAllFinanceiros();
      final List<ContaPagar> despesas = await _contaPagarRepository.getAllContasPagar();
      final List<ContaReceber> contasReceber = await _contaReceberRepository.getAllContasReceber();

      double sumReceitas = 0.0;
      for (var r in receitas) {
        sumReceitas += r.valor ?? 0.0;
      }

      double sumContasReceberPagas = 0.0;
      for (var cr in contasReceber) {
        if (cr.status == 'Pago') {
          sumContasReceberPagas += cr.valor ?? 0.0;
        }
      }

      double sumDespesasPagas = 0.0;
      for (var dp in despesas) {
        if (dp.status == 'Pago') {
          sumDespesasPagas += dp.valor ?? 0.0;
        }
      }

      setState(() {
        _totalReceitas = sumReceitas + sumContasReceberPagas;
        _totalDespesas = sumDespesasPagas;
        _saldo = _totalReceitas - _totalDespesas;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao gerar relatório: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Relatório Financeiro'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadRelatorioData,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Card(
                    elevation: 4,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          Text('Total de Receitas: R\$ ${NumberFormat.currency(locale: 'pt_BR', symbol: '').format(_totalReceitas)}',
                            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.green),
                          ),
                          const SizedBox(height: 8),
                          Text('Total de Despesas: R\$ ${NumberFormat.currency(locale: 'pt_BR', symbol: '').format(_totalDespesas)}',
                            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.red),
                          ),
                          const SizedBox(height: 8),
                          Text('Saldo: R\$ ${NumberFormat.currency(locale: 'pt_BR', symbol: '').format(_saldo)}',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: _saldo >= 0 ? Colors.green.shade700 : Colors.red.shade700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Detalhes (Contas Pagas/Recebidas da Consulta)',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 10),
                  // Você pode adicionar mais detalhes aqui, como listas de transações recentes
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          // Exemplo: Lista de financeiro
                          // Text('Registros de Pagamento de Consultas:'),
                          // if (receitas.isNotEmpty)
                          //   ...receitas.map((r) => Text('- ${r.formaPagamento}: R\$ ${r.valor}')).toList(),
                          // Text('Contas a Pagar Pagas:'),
                          // if (despesas.isNotEmpty)
                          //   ...despesas.where((d) => d.status == 'Pago').map((d) => Text('- ${d.descricao}: R\$ ${d.valor}')).toList(),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}