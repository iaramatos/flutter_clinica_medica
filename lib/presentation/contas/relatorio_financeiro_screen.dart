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

  final TextEditingController _dataInicialController = TextEditingController();
  final TextEditingController _dataFinalController = TextEditingController();

  DateTime? _dataInicial;
  DateTime? _dataFinal;

  // Listas para exibir os detalhes
  List<Financeiro> _receitasConsultas = [];
  List<ContaReceber> _contasReceberPagas = [];
  List<ContaPagar> _contasPagarPagas = [];


  @override
  void initState() {
    super.initState();
    // Definir período padrão (ex: último mês)
    _dataFinal = DateTime.now();
    _dataInicial = DateTime(_dataFinal!.year, _dataFinal!.month - 1, _dataFinal!.day);
    _dataInicialController.text = DateFormat('dd-MM-yyyy').format(_dataInicial!);
    _dataFinalController.text = DateFormat('dd-MM-yyyy').format(_dataFinal!);

    _loadRelatorioData();
  }

  Future<void> _selectDate(BuildContext context, TextEditingController controller, Function(DateTime) onDateSelected) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: controller.text.isNotEmpty ? DateFormat('dd-MM-yyyy').parse(controller.text) : DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
      locale: const Locale('pt', 'BR'),
    );
    if (picked != null) {
      setState(() {
        controller.text = DateFormat('dd-MM-yyyy').format(picked);
        onDateSelected(picked);
      });
    }
  }

  Future<void> _loadRelatorioData() async {
    setState(() {
      _isLoading = true;
    });
    try {
      // Filtrar por período
      final List<Financeiro> allReceitasFinanceiro = await _financeiroRepository.getAllFinanceiros();
      final List<ContaPagar> allDespesasContasPagar = await _contaPagarRepository.getAllContasPagar();
      final List<ContaReceber> allContasReceber = await _contaReceberRepository.getAllContasReceber();


      // Aplicar filtro de data
      final List<Financeiro> filteredReceitasFinanceiro = allReceitasFinanceiro
          .where((r) => r.dataPagamento != null &&
              (_dataInicial == null || r.dataPagamento!.isAfter(_dataInicial!.subtract(const Duration(days: 1)))) &&
              (_dataFinal == null || r.dataPagamento!.isBefore(_dataFinal!.add(const Duration(days: 1)))))
          .toList();

      final List<ContaPagar> filteredDespesasContasPagar = allDespesasContasPagar
          .where((dp) => dp.status == 'Pago' && dp.vencimento != null &&
              (_dataInicial == null || dp.vencimento!.isAfter(_dataInicial!.subtract(const Duration(days: 1)))) &&
              (_dataFinal == null || dp.vencimento!.isBefore(_dataFinal!.add(const Duration(days: 1)))))
          .toList();

      final List<ContaReceber> filteredContasReceberPagas = allContasReceber
          .where((cr) => cr.status == 'Pago' && cr.vencimento != null &&
              (_dataInicial == null || cr.vencimento!.isAfter(_dataInicial!.subtract(const Duration(days: 1)))) &&
              (_dataFinal == null || cr.vencimento!.isBefore(_dataFinal!.add(const Duration(days: 1)))))
          .toList();


      double sumReceitas = 0.0;
      for (var r in filteredReceitasFinanceiro) {
        sumReceitas += r.valor ?? 0.0;
      }

      double sumContasReceberPagas = 0.0;
      for (var cr in filteredContasReceberPagas) {
        sumContasReceberPagas += cr.valor ?? 0.0;
      }

      double sumDespesasPagas = 0.0;
      for (var dp in filteredDespesasContasPagar) {
        sumDespesasPagas += dp.valor ?? 0.0;
      }

      setState(() {
        _totalReceitas = sumReceitas + sumContasReceberPagas;
        _totalDespesas = sumDespesasPagas;
        _saldo = _totalReceitas - _totalDespesas;
        
        // Atribuir as listas filtradas para exibição de detalhes
        _receitasConsultas = filteredReceitasFinanceiro;
        _contasReceberPagas = filteredContasReceberPagas;
        _contasPagarPagas = filteredDespesasContasPagar;
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
  void dispose() {
    _dataInicialController.dispose();
    _dataFinalController.dispose();
    super.dispose();
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
                  // Filtros de Data
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _dataInicialController,
                          decoration: InputDecoration(
                            labelText: 'Data Inicial (DD-MM-YYYY)',
                            suffixIcon: IconButton(
                              icon: const Icon(Icons.calendar_today),
                              onPressed: () => _selectDate(context, _dataInicialController, (date) => _dataInicial = date),
                            ),
                          ),
                          readOnly: true,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextFormField(
                          controller: _dataFinalController,
                          decoration: InputDecoration(
                            labelText: 'Data Final (DD-MM-YYYY)',
                            suffixIcon: IconButton(
                              icon: const Icon(Icons.calendar_today),
                              onPressed: () => _selectDate(context, _dataFinalController, (date) => _dataFinal = date),
                            ),
                          ),
                          readOnly: true,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.filter_list),
                        onPressed: _loadRelatorioData, // Recarregar dados com filtro
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
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
                    'Detalhes (Receitas de Consultas e Contas Recebidas Pagas)',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 10),
                  // Detalhes das Receitas de Consultas (tabela Financeiro)
                  // Use uma lista de widgets para os detalhes
                  ...(_receitasConsultas.isNotEmpty
                    ? _receitasConsultas.map((r) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4.0),
                        child: Text('- Consulta ${r.idConsulta}: R\$ ${r.valor?.toStringAsFixed(2)} (${r.formaPagamento}) - ${r.dataPagamento != null ? DateFormat('dd/MM/yyyy').format(r.dataPagamento!) : 'N/A'}'),
                      )).toList()
                    : [const Text('Nenhum registro de pagamento de consulta no período.')]),
                  
                  const SizedBox(height: 15),
                  Text(
                    'Detalhes (Contas a Receber Pagas)',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 10),
                  // Detalhes das Contas a Receber Pagas
                  ...( _contasReceberPagas.isNotEmpty
                    ? _contasReceberPagas.map((cr) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4.0),
                        child: Text('- ${cr.descricao}: R\$ ${cr.valor?.toStringAsFixed(2)} (Vencimento: ${cr.vencimento != null ? DateFormat('dd/MM/yyyy').format(cr.vencimento!) : 'N/A'})'),
                      )).toList()
                    : [const Text('Nenhuma conta a receber paga no período.')]),

                  const SizedBox(height: 15),
                  Text(
                    'Detalhes (Contas a Pagar Pagas)',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 10),
                  // Detalhes das Contas a Pagar Pagas
                  ...( _contasPagarPagas.isNotEmpty
                    ? _contasPagarPagas.map((dp) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4.0),
                        child: Text('- ${dp.descricao}: R\$ ${dp.valor?.toStringAsFixed(2)} (Vencimento: ${dp.vencimento != null ? DateFormat('dd/MM/yyyy').format(dp.vencimento!) : 'N/A'})'),
                      )).toList()
                    : [const Text('Nenhuma conta a pagar paga no período.')]),

                  const SizedBox(height: 20),
                ],
              ),
            ),
    );
  }
}