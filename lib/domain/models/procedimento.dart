// lib/domain/models/procedimento.dart

class Procedimento {
  int? idProcedimento;
  String nome;
  String? descricao;
  double valor;

  Procedimento({
    this.idProcedimento,
    required this.nome,
    this.descricao,
    required this.valor,
  });

  Map<String, dynamic> toMap() {
    return {
      'idProcedimento': idProcedimento,
      'nome': nome,
      'descricao': descricao,
      'valor': valor,
    };
  }

  factory Procedimento.fromMap(Map<String, dynamic> map) {
    return Procedimento(
      idProcedimento: map['idProcedimento'] as int?,
      nome: map['nome'] as String,
      descricao: map['descricao'] as String?,
      valor: (map['valor'] as num).toDouble(), // Converte num para double
    );
  }

  @override
  String toString() {
    return 'Procedimento(idProcedimento: $idProcedimento, nome: $nome, valor: $valor)';
  }
}