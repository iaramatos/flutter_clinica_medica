import 'package:flutter/material.dart';
import 'package:flutter_clinica_medica/domain/models/paciente.dart';
import 'package:flutter_clinica_medica/domain/models/consulta.dart';
import 'package:flutter_clinica_medica/domain/models/receita.dart';
import 'package:flutter_clinica_medica/domain/models/prescricao_medicamento.dart';
import 'package:flutter_clinica_medica/domain/models/exame.dart';
import 'package:flutter_clinica_medica/domain/models/resultado_exame.dart';
import 'package:flutter_clinica_medica/domain/models/medicamento.dart'; // Para detalhes do medicamento na prescrição
import 'package:flutter_clinica_medica/domain/models/profissional.dart'; // Para detalhes do profissional na consulta

import 'package:flutter_clinica_medica/domain/repositories/paciente_repository.dart';
import 'package:flutter_clinica_medica/domain/repositories/consulta_repository.dart';
import 'package:flutter_clinica_medica/domain/repositories/receita_repository.dart';
import 'package:flutter_clinica_medica/domain/repositories/prescricao_medicamento_repository.dart';
import 'package:flutter_clinica_medica/domain/repositories/exame_repository.dart';
import 'package:flutter_clinica_medica/domain/repositories/resultado_exame_repository.dart';
import 'package:flutter_clinica_medica/domain/repositories/medicamento_repository.dart';
import 'package:flutter_clinica_medica/domain/repositories/profissional_repository.dart';

import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

class PacienteDetailsScreen extends StatefulWidget {
  final int pacienteId;
  const PacienteDetailsScreen({super.key, required this.pacienteId});

  static const String routeName = '/paciente-details';

  @override
  State<PacienteDetailsScreen> createState() => _PacienteDetailsScreenState();
}

class _PacienteDetailsScreenState extends State<PacienteDetailsScreen> {
  final PacienteRepository _pacienteRepository = PacienteRepository();
  final ConsultaRepository _consultaRepository = ConsultaRepository();
  final ReceitaRepository _receitaRepository = ReceitaRepository();
  final PrescricaoMedicamentoRepository _prescricaoRepository = PrescricaoMedicamentoRepository();
  final ExameRepository _exameRepository = ExameRepository();
  final ResultadoExameRepository _resultadoExameRepository = ResultadoExameRepository();
  final MedicamentoRepository _medicamentoRepository = MedicamentoRepository();
  final ProfissionalRepository _profissionalRepository = ProfissionalRepository();

  Paciente? _paciente;
  List<Consulta> _consultas = [];
  List<ResultadoExame> _resultadosExames = [];
  List<PrescricaoMedicamento> _prescricoes = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPacienteDetails();
  }

  Future<void> _loadPacienteDetails() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final paciente = await _pacienteRepository.getPacienteById(widget.pacienteId);
      if (paciente == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Paciente não encontrado!')),
          );
          Navigator.of(context).pop();
        }
        return;
      }
      _paciente = paciente;

      // Carregar consultas do paciente
      final allConsultas = await _consultaRepository.getAllConsultas();
      _consultas = allConsultas.where((c) => c.idPaciente == widget.pacienteId).toList();

      // Carregar resultados de exames do paciente
      final allResultados = await _resultadoExameRepository.getAllResultadosExames();
      _resultadosExames = allResultados.where((re) =>
          _consultas.any((c) => c.idConsulta == re.idConsulta)).toList();

      // --- INÍCIO DA CORREÇÃO ---
      // Carregar prescrições do paciente de forma otimizada
      
      // 1. Coleta os IDs das receitas a partir das consultas do paciente.
      final idsReceitasDoPaciente = _consultas
          .where((c) => c.idReceita != null)
          .map((c) => c.idReceita!)
          .toSet(); // Usar um Set para busca eficiente.

      // 2. Se houver receitas, busca e filtra as prescrições.
      if (idsReceitasDoPaciente.isNotEmpty) {
        final allPrescricoes = await _prescricaoRepository.getAllPrescricaoMedicamentos();
        _prescricoes = allPrescricoes
            .where((p) => idsReceitasDoPaciente.contains(p.idReceita))
            .toList();
      } else {
        // Se não houver receitas, a lista de prescrições fica vazia.
        _prescricoes = [];
      }
      // --- FIM DA CORREÇÃO ---

    } catch (e) {
      if(mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao carregar detalhes do paciente: $e')),
        );
      }
    } finally {
      if(mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<String> _getProfissionalNome(int? id) async {
    if (id == null) return 'Desconhecido';
    final prof = await _profissionalRepository.getProfissionalById(id);
    return prof?.nome ?? 'Desconhecido';
  }

  Future<String> _getExameNome(int? id) async {
    if (id == null) return 'Desconhecido';
    final exame = await _exameRepository.getExameById(id);
    return exame?.nome ?? 'Desconhecido';
  }

  Future<String> _getMedicamentoNome(int? id) async {
    if (id == null) return 'Desconhecido';
    final medicamento = await _medicamentoRepository.getMedicamentoById(id);
    return medicamento?.nome ?? 'Desconhecido';
  }

  Future<void> _launchUrl(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri)) {
      if(mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Não foi possível abrir o link: $url')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Carregando Prontuário...')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }
    if (_paciente == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Prontuário Não Encontrado')),
        body: const Center(child: Text('Paciente não encontrado.')),
      );
    }

    return DefaultTabController(
      length: 4, // Dados Pessoais, Consultas, Exames, Prescrições
      child: Scaffold(
        appBar: AppBar(
          title: Text('Prontuário: ${_paciente!.nome}'),
          backgroundColor: Theme.of(context).colorScheme.primary,
          foregroundColor: Colors.white,
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Dados', icon: Icon(Icons.info_outline)),
              Tab(text: 'Consultas', icon: Icon(Icons.calendar_today)),
              Tab(text: 'Exames', icon: Icon(Icons.science)),
              Tab(text: 'Prescrições', icon: Icon(Icons.receipt)),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // --- Aba: Dados Pessoais ---
            _buildDadosPessoaisTab(),
            // --- Aba: Histórico de Consultas ---
            _buildConsultasTab(),
            // --- Aba: Resultados de Exames ---
            _buildExamesTab(),
            // --- Aba: Histórico de Prescrições ---
            _buildPrescricoesTab(),
          ],
        ),
      ),
    );
  }

  // Métodos de construção das abas
  Widget _buildDadosPessoaisTab() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ListView(
        children: [
          _buildDetailRow('Nome:', _paciente!.nome),
          _buildDetailRow('CPF:', _paciente!.cpf),
          _buildDetailRow('Nascimento:', _paciente!.dataNascimento != null ? DateFormat('dd/MM/yyyy').format(_paciente!.dataNascimento!) : 'N/A'),
          _buildDetailRow('Telefone:', _paciente!.telefone ?? 'N/A'),
          _buildDetailRow('Email:', _paciente!.email ?? 'N/A'),
          _buildDetailRow('Endereço:', _paciente!.endereco ?? 'N/A'),
          _buildDetailRow('Convênio:', _paciente!.convenio ?? 'N/A'),
          _buildDetailRow('Alergias:', _paciente!.alergias ?? 'Nenhuma'),
          _buildDetailRow('Condições Pré-existentes:', _paciente!.condicoesPreExistentes ?? 'Nenhuma'),
        ],
      ),
    );
  }

  Widget _buildConsultasTab() {
    if (_consultas.isEmpty) {
      return const Center(child: Text('Nenhuma consulta registrada para este paciente.'));
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: _consultas.length,
      itemBuilder: (context, index) {
        final consulta = _consultas[index];
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 8.0),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Data/Hora: ${DateFormat('dd/MM/yyyy HH:mm').format(consulta.dataHora)}', style: const TextStyle(fontWeight: FontWeight.bold)),
                FutureBuilder<String>(
                  future: _getProfissionalNome(consulta.idProfissional),
                  builder: (context, snapshot) => Text('Profissional: ${snapshot.data ?? 'Carregando...'}'),
                ),
                Text('Motivo: ${consulta.motivo ?? 'N/A'}'),
                Text('Diagnóstico: ${consulta.diagnostico ?? 'N/A'}'),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildExamesTab() {
    if (_resultadosExames.isEmpty) {
      return const Center(child: Text('Nenhum resultado de exame registrado para este paciente.'));
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: _resultadosExames.length,
      itemBuilder: (context, index) {
        final resultado = _resultadosExames[index];
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 8.0),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FutureBuilder<String>(
                  future: _getExameNome(resultado.idExame),
                  builder: (context, snapshot) => Text('Exame: ${snapshot.data ?? 'Carregando...'}', style: const TextStyle(fontWeight: FontWeight.bold)),
                ),
                Text('Resultado: ${resultado.resultado ?? 'N/A'}'),
                if (resultado.urlDocumento != null && resultado.urlDocumento!.isNotEmpty)
                  InkWell(
                    onTap: () => _launchUrl(resultado.urlDocumento!),
                    child: const Text(
                      'Ver Documento',
                      style: TextStyle(color: Colors.blue, decoration: TextDecoration.underline),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPrescricoesTab() {
    if (_prescricoes.isEmpty) {
      return const Center(child: Text('Nenhuma prescrição registrada para este paciente.'));
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: _prescricoes.length,
      itemBuilder: (context, index) {
        final prescricao = _prescricoes[index];
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 8.0),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FutureBuilder<String>(
                  future: _getMedicamentoNome(prescricao.idMedicamento),
                  builder: (context, snapshot) => Text('Medicamento: ${snapshot.data ?? 'Carregando...'}', style: const TextStyle(fontWeight: FontWeight.bold)),
                ),
                Text('Dosagem: ${prescricao.dosagem ?? 'N/A'}'),
                Text('Via: ${prescricao.via ?? 'N/A'}'),
                Text('Frequência: ${prescricao.frequencia ?? 'N/A'}'),
                Text('Quantidade: ${prescricao.quantidade}'),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 150, // Ajuste a largura conforme necessário
            child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}