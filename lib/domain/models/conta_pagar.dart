// lib/models/conta_pagar.dart

class ContaPagar {
  int? idConta;
  String? descricao;
  double? valor;
  DateTime? vencimento;
  String? status; // ENUM('Aberto', 'Pago')

  ContaPagar({
    this.idConta,
    this.descricao,
    this.valor,
    this.vencimento,
    this.status,
  });

  Map<String, dynamic> toMap() {
    return {
      'idConta': idConta,
      'descricao': descricao,
      'valor': valor,
      'vencimento': vencimento?.toIso8601String(),
      'status': status,
    };
  }

  factory ContaPagar.fromMap(Map<String, dynamic> map) {
    return ContaPagar(
      idConta: map['idConta'] as int?,
      descricao: map['descricao'] as String?,
      valor: (map['valor'] as num?)?.toDouble(),
      vencimento: map['vencimento'] != null
          ? DateTime.parse(map['vencimento'] as String)
          : null,
      status: map['status'] as String?,
    );
  }

  @override
  String toString() {
    return 'ContaPagar(idConta: $idConta, descricao: $descricao, valor: $valor)';
  }
}