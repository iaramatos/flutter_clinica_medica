// lib/models/financeiro.dart

class Financeiro {
  int? idFinanceiro;
  int? idConsulta;
  double? valor; // REAL no SQLite é mapeado para double
  String? formaPagamento;
  DateTime? dataPagamento;
  String? statusPagamento; // ENUM('Pago', 'Pendente')

  Financeiro({
    this.idFinanceiro,
    this.idConsulta,
    this.valor,
    this.formaPagamento,
    this.dataPagamento,
    this.statusPagamento,
  });

  Map<String, dynamic> toMap() {
    return {
      'idFinanceiro': idFinanceiro,
      'idConsulta': idConsulta,
      'valor': valor,
      'formaPagamento': formaPagamento,
      'dataPagamento': dataPagamento?.toIso8601String(),
      'statusPagamento': statusPagamento,
    };
  }

  factory Financeiro.fromMap(Map<String, dynamic> map) {
    return Financeiro(
      idFinanceiro: map['idFinanceiro'] as int?,
      idConsulta: map['idConsulta'] as int?,
      valor: (map['valor'] as num?)?.toDouble(), // 'num' para lidar com int ou double do SQLite
      formaPagamento: map['formaPagamento'] as String?,
      dataPagamento: map['dataPagamento'] != null
          ? DateTime.parse(map['dataPagamento'] as String)
          : null,
      statusPagamento: map['statusPagamento'] as String?,
    );
  }

  @override
  String toString() {
    return 'Financeiro(idFinanceiro: $idFinanceiro, idConsulta: $idConsulta, valor: $valor)';
  }
}