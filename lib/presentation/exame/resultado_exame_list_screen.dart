// lib/presentation/exame/resultado_exame_list_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_clinica_medica/domain/models/resultado_exame.dart';
import 'package:flutter_clinica_medica/domain/models/consulta.dart';
import 'package:flutter_clinica_medica/domain/models/exame.dart';
import 'package:flutter_clinica_medica/domain/repositories/resultado_exame_repository.dart';
import 'package:flutter_clinica_medica/domain/repositories/consulta_repository.dart';
import 'package:flutter_clinica_medica/domain/repositories/exame_repository.dart';
import 'package:flutter_clinica_medica/presentation/exame/resultado_exame_form_screen.dart'; // Para navegar para o formulário
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart'; // Para abrir URLs (certifique-se de que 'url_launcher' está no pubspec.yaml)
import 'package:url_launcher/url_launcher.dart'; // Para abrir URLs (adicione ao pubspec.yaml)

class ResultadoExameListScreen extends StatefulWidget {
  const ResultadoExameListScreen({super.key});

  static const String routeName = '/resultado-exame-list';

  @override
  State<ResultadoExameListScreen> createState() => _ResultadoExameListScreenState();
}

class _ResultadoExameListScreenState extends State<ResultadoExameListScreen> {
  final ResultadoExameRepository _resultadoExameRepository = ResultadoExameRepository();
  final ConsultaRepository _consultaRepository = ConsultaRepository();
  final ExameRepository _exameRepository = ExameRepository();
  List<ResultadoExame> _resultados = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadResultados();
  }

  Future<void> _loadResultados() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final resultados = await _resultadoExameRepository.getAllResultadosExames();
      setState(() {
        _resultados = resultados;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao carregar resultados de exames: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _deleteResultado(int id) async {
    try {
      await _resultadoExameRepository.deleteResultadoExame(id);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Resultado de exame excluído com sucesso!')),
      );
      _loadResultados();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao excluir resultado de exame: $e')),
      );
    }
  }

  // Função auxiliar para obter informações da Consulta
  Future<String> _getConsultaInfo(int? id) async {
    if (id == null) return 'Consulta Desconhecida';
    final consulta = await _consultaRepository.getConsultaById(id);
    return consulta != null
        ? 'Consulta ID: ${consulta.idConsulta} (${DateFormat('dd/MM/yyyy').format(consulta.dataHora)})'
        : 'Consulta Desconhecida';
  }

  // Função auxiliar para obter o nome do Tipo de Exame
  Future<String> _getExameNome(int? id) async {
    if (id == null) return 'Exame Desconhecido';
    final exame = await _exameRepository.getExameById(id);
    return exame?.nome ?? 'Exame Desconhecido';
  }

  // Função para abrir URL
  Future<void> _launchUrl(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Não foi possível abrir o link: $url')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Resultados de Exames'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadResultados,
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () async {
              await Navigator.of(context).pushNamed(ResultadoExameFormScreen.routeName);
              _loadResultados();
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _resultados.isEmpty
              ? const Center(child: Text('Nenhum resultado de exame cadastrado.'))
              : ListView.builder(
                  itemCount: _resultados.length,
                  itemBuilder: (context, index) {
                    final resultado = _resultados[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: FutureBuilder<List<String>>(
                        future: Future.wait([
                          _getConsultaInfo(resultado.idConsulta),
                          _getExameNome(resultado.idExame),
                        ]),
                        builder: (context, snapshot) {
                          String consultaInfo = snapshot.data?[0] ?? 'Carregando...';
                          String exameNome = snapshot.data?[1] ?? 'Carregando...';

                          if (snapshot.connectionState == ConnectionState.waiting) {
                            consultaInfo = 'Carregando...';
                            exameNome = 'Carregando...';
                          } else if (snapshot.hasError) {
                            consultaInfo = 'Erro';
                            exameNome = 'Erro';
                          }

                          return ListTile(
                            title: Text('Exame: $exameNome'),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(consultaInfo),
                                if (resultado.resultado != null && resultado.resultado!.isNotEmpty)
                                  Text('Resultado: ${resultado.resultado}'),
                                if (resultado.urlDocumento != null && resultado.urlDocumento!.isNotEmpty)
                                  InkWell(
                                    onTap: () => _launchUrl(resultado.urlDocumento!),
                                    child: Text(
                                      'Ver Documento',
                                      style: TextStyle(color: Colors.blue, decoration: TextDecoration.underline),
                                    ),
                                  ),
                              ],
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit, color: Colors.blue),
                                  onPressed: () {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('Edição de resultado futura.')),
                                    );
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.red),
                                  onPressed: () => _deleteResultado(resultado.idResultado!),
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