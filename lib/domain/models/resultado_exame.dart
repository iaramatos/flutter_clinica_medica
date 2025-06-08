// lib/models/resultado_exame.dart

class ResultadoExame {
  int? idResultado;
  int? idConsulta;
  int? idExame;
  String? resultado;

  ResultadoExame({
    this.idResultado,
    this.idConsulta,
    this.idExame,
    this.resultado,
  });

  Map<String, dynamic> toMap() {
    return {
      'idResultado': idResultado,
      'idConsulta': idConsulta,
      'idExame': idExame,
      'resultado': resultado,
    };
  }

  factory ResultadoExame.fromMap(Map<String, dynamic> map) {
    return ResultadoExame(
      idResultado: map['idResultado'] as int?,
      idConsulta: map['idConsulta'] as int?,
      idExame: map['idExame'] as int?,
      resultado: map['resultado'] as String?,
    );
  }

  @override
  String toString() {
    return 'ResultadoExame(idResultado: $idResultado, idConsulta: $idConsulta, idExame: $idExame)';
  }
}