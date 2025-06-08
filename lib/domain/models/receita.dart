// lib/models/receita.dart

class Receita {
  int? idReceita;
  DateTime? dataEmissao;
  String? observacoes;

  Receita({
    this.idReceita,
    this.dataEmissao,
    this.observacoes,
  });

  Map<String, dynamic> toMap() {
    return {
      'idReceita': idReceita,
      'dataEmissao': dataEmissao?.toIso8601String(),
      'observacoes': observacoes,
    };
  }

  factory Receita.fromMap(Map<String, dynamic> map) {
    return Receita(
      idReceita: map['idReceita'] as int?,
      dataEmissao: map['dataEmissao'] != null
          ? DateTime.parse(map['dataEmissao'] as String)
          : null,
      observacoes: map['observacoes'] as String?,
    );
  }

  @override
  String toString() {
    return 'Receita(idReceita: $idReceita, dataEmissao: $dataEmissao)';
  }
}