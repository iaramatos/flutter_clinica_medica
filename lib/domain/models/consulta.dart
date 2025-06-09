// lib/domain/models/consulta.dart

class Consulta {
  int? idConsulta;
  DateTime dataHora;
  String? motivo;
  String? diagnostico;
  int? idPaciente;
  int? idProfissional;
  int? idSala;
  int? idReceita;
  int? idProcedimentoPrincipal; // NOVO: Adicionado para o procedimento principal

  Consulta({
    this.idConsulta,
    required this.dataHora,
    this.motivo,
    this.diagnostico,
    this.idPaciente,
    this.idProfissional,
    this.idSala,
    this.idReceita,
    this.idProcedimentoPrincipal, // NOVO: Adicionado ao construtor
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
      'idProcedimentoPrincipal': idProcedimentoPrincipal, // NOVO: Adicionado ao toMap
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
      idProcedimentoPrincipal: map['idProcedimentoPrincipal'] as int?, // NOVO: Adicionado ao fromMap
    );
  }

  @override
  String toString() {
    return 'Consulta(idConsulta: $idConsulta, dataHora: $dataHora, idPaciente: $idPaciente, idProfissional: $idProfissional)';
  }
}