// lib/models/consulta.dart

class Consulta {
  int? idConsulta;
  DateTime dataHora;
  String? motivo;
  String? diagnostico;
  int? idPaciente;
  int? idProfissional;
  int? idSala;
  int? idReceita; // Chave estrangeira para Receita

  Consulta({
    this.idConsulta,
    required this.dataHora,
    this.motivo,
    this.diagnostico,
    this.idPaciente,
    this.idProfissional,
    this.idSala,
    this.idReceita,
  });

  Map<String, dynamic> toMap() {
    return {
      'idConsulta': idConsulta,
      'dataHora': dataHora.toIso8601String(),
      'motivo': motivo,
      'diagnostico': diagnostico,
      'idPaciente': idPaciente,
      'idProfissional': idProfissional,
      'idSala': idSala,
      'idReceita': idReceita,
    };
  }

  factory Consulta.fromMap(Map<String, dynamic> map) {
    return Consulta(
      idConsulta: map['idConsulta'] as int?,
      dataHora: DateTime.parse(map['dataHora'] as String),
      motivo: map['motivo'] as String?,
      diagnostico: map['diagnostico'] as String?,
      idPaciente: map['idPaciente'] as int?,
      idProfissional: map['idProfissional'] as int?,
      idSala: map['idSala'] as int?,
      idReceita: map['idReceita'] as int?,
    );
  }

  @override
  String toString() {
    return 'Consulta(idConsulta: $idConsulta, dataHora: $dataHora, idPaciente: $idPaciente)';
  }
}