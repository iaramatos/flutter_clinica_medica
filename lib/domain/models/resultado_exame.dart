// lib/domain/models/resultado_exame.dart

class ResultadoExame {
  int? idResultado;
  int? idConsulta;
  int? idExame;
  String? resultado;
  String? urlDocumento; // NOVO: Propriedade urlDocumento adicionada

  ResultadoExame({
    this.idResultado,
    this.idConsulta,
    this.idExame,
    this.resultado,
    this.urlDocumento, // NOVO: Adicionado ao construtor
  });

  Map<String, dynamic> toMap() {
    return {
      'idResultado': idResultado,
      'idConsulta': idConsulta,
      'idExame': idExame,
      'resultado': resultado,
      'urlDocumento': urlDocumento, // NOVO: Adicionado ao toMap
    };
  }

  factory ResultadoExame.fromMap(Map<String, dynamic> map) {
    return ResultadoExame(
      idResultado: map['idResultado'] as int?,
      idConsulta: map['idConsulta'] as int?,
      idExame: map['idExame'] as int?,
      resultado: map['resultado'] as String?,
      urlDocumento: map['urlDocumento'] as String?, // NOVO: Adicionado ao fromMap
    );
  }

  @override
  String toString() {
    return 'ResultadoExame(idResultado: $idResultado, idConsulta: $idConsulta, idExame: $idExame)';
  }
}